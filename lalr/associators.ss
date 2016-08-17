;;; associators.ss
;;;
;;; (eval-when (compile) (optimize-level 2))
;;;
;;; Mark Johnson, April 1993.
;;;
;;; An associator is a suite of functions for manipulating a finite function  
;;; from keys to values. This file contains associators based on avl trees
;;; (which are balanced binary trees) and tries (which extend an associator
;;; from keys of type T to keys of type list-of-T), as well as associators
;;; based on association lists and vectors.
;;;
;;; At the bottom of this file there are predefined associators for atoms
;;; and for lists of atoms.
;;;
;;; Because all associators have the same interface, it should be possible
;;; to e.g., develop a program using simple, general associators (e.g.,
;;; the associators based on association lists), and substitute more
;;; efficient, specialized associators if needed.
;;;
;;; An associator-maker is a function which maps keywords into appropriate
;;; associator manipulation functions.  Here are the keywords an associator
;;; should understand:
;;;
;;; ((associator-maker 'make)) returns a new associator that associates
;;;               #f with every value.
;;; ((associator-maker 'ref) associator key) returns value associated with key
;;;              in associator.
;;; ((associator-maker 'set!) associator key value) destructively changes the
;;;              value associated with key in associator to be value, and
;;;              returns the old value.
;;; ((associator-maker 'update!) associator key update-fn) destructively
;;;              changes the value associated with key to (update-fn key 
;;;              old-value), where old-value was the value that the associator
;;;              previously associated with value.
;;; ((associator-maker 'push!) associator key elt) destructively changes the
;;;              value associated with key to (cons elt elts), where elts is
;;;              '() if the value associated with key was #f, and the value
;;;               associated with key otherwise.
;;; ((associator-maker 'inc!) associator key inc) destructively changes the
;;;              value associated with key to (+ inc value), where value is 0 
;;;              if the value associated with key was #f, and the value
;;;              associated with key otherwise.
;;; ((associator-maker 'map) associator fn) returns a new associator that
;;;              assigns (fn key value) to each key where associator
;;;              assigned a non-#f value value to key.
;;; ((associator-maker 'map!) associator fn) is the same as map, except
;;;              that associator is destructively updated.
;;; ((associator-maker 'for-each) associator fn) calls (fn key value) on
;;;              each key-value pair in associator such that value =/= #f.
;;; ((associator-maker 'reduce) associator fn start) calls
;;;              (fn key value so-far) on each key-value pair in associator,
;;;              where so-far is the value returned from the previous fn
;;;              call (so-far in the first fn call is start). 
;;;
;;; The idea is that given an associator-maker, the various associator 
;;; manipulation functions will be assigned to local variables, rather than
;;; obtained by associator-maker each time the manipulation functions are used.
;;;
;;; Often a particular type of associator needs additional parameters, e.g.,
;;; an ordering or equality predicate.  The avl-maker, for example, takes an
;;; ordering predicate and returns an associator-maker.

(define (assoc:inc!-maker update!)
  (lambda (assoc key inc)
    (if (not (zero? inc))
      (update! assoc key (lambda (val) (if val (+ val inc) inc))))))

(define (assoc:push!-maker update!)
  (lambda (assoc key elt)
    (update! assoc key (lambda (elts) (if elts (cons elt elts) (list elt))))))

;;; alist-associators are simple association lists.
;;; They are lists of the form (@ (key1 . val1) ...)
;;; They have the advantage of being easily readable.

(define (alist-maker eqp?)

  (define (find-pair avs key)
    (if (pair? avs)
      (if (eqp? (caar avs) key)
        (car avs)
        (find-pair (cdr avs) key))
      #f))

  (define (push alist key value)
    (set-cdr! alist (cons (cons key value) (cdr alist)))
    #f)

  (define (lookup alist key)
    (let ((p (find-pair (cdr alist) key)))
      (if (pair? p)
        (cdr p)
        #f)))

  (define (update! alist key update-fn)
    (let ((p (find-pair (cdr alist) key)))
      (if (pair? p)
        (let ((v (cdr p)))
          (set-cdr! p (update-fn v))
          v)
        (push alist key (update-fn #f)))))

  (define (reduce avs fn start)
    (if (pair? avs)
      (reduce (cdr avs) fn
              (if (cdar avs)
                (fn (caar avs) (cdar avs) start)
                start))
      start))

  (lambda (selector)
    (case selector
      ((make) (lambda () (list '@)))
      ((ref) lookup)
      ((set!) (lambda (alist key value) 
                   (update! alist key (lambda (oldvalue) value))))
      ((update!) update!)
      ((inc!) (assoc:inc!-maker update!))
      ((push!) (assoc:push!-maker update!))
      ((map) (lambda (alist fn)
               (cons '@ (map (lambda (p) 
                               (cons (car p) (if (cdr p)
                                               (fn (car p) (cdr p))
                                               #f)))
                             (cdr alist)))))
      ((for-each) (lambda (alist fn)
                   (for-each (lambda (p) 
                              (if (cdr p)
                                (fn (car p) (cdr p))))
                            (cdr alist))))
      ((map!) (lambda (alist fn)
                (for-each (lambda (p) 
                            (if (cdr p)
                              (set-cdr! p (fn (car p) (cdr p)))))
                          (cdr alist))
                alist))
      ((reduce) (lambda (alist fn start)
                  (reduce (cdr alist) fn start)))
      (else (error "Unimplemented selector: " selector)))))

;;; avl-associators are balanced binary trees

(define (avl-maker ordered?)
  
  (define (node-height node) (if node (vector-ref node 0) 0))
  (define (node-left node) (vector-ref node 1))
  (define (node-key node) (vector-ref node 2))
  (define (node-value node) (vector-ref node 3))
  (define (node-right node) (vector-ref node 4))
  
  (define (set-node-height! node height) (vector-set! node 0 height))
  (define (set-node-left! node left) (vector-set! node 1 left))
  (define (set-node-key! node key) (vector-set! node 2 key))
  (define (set-node-value! node value) (vector-set! node 3 value))
  (define (set-node-right! node right) (vector-set! node 4 right))
  
  (define (set-node-key-value! node key value)
    (set-node-height! node 1)
    (set-node-key! node key)
    (set-node-value! node value))
  
  (define (empty? node)
    (not (vector-ref node 0)))
  
  (define (search key node)
    (if node
        (cond ((ordered? key (node-key node)) (search key (node-left node)))
              ((ordered? (node-key node) key) (search key (node-right node)))
              (else (node-value node)))
        #f))
  
  (define (compute-height! node)
    (set-node-height! node (+ (max (node-height (node-left node))
                                   (node-height (node-right node)))
                              1)))
  
  (define (rotate-left! a)
    (let* ((b (node-right a))
           (b-key (node-key b))
           (b-value (node-value b))
           (b-right (node-right b)))
      (set-node-right! b (node-left b))
      (set-node-left! b (node-left a))
      (set-node-key! b (node-key a))
      (set-node-value! b (node-value a))
      (compute-height! b)
      (set-node-left! a b)
      (set-node-key! a b-key)
      (set-node-value! a b-value)
      (set-node-right! a b-right)
      ; (compute-height! a)
      a))
  
  (define (rotate-right! a)
    (let* ((b (node-left a))
           (b-key (node-key b))
           (b-value (node-value b))
           (b-left (node-left b)))
      (set-node-left! b (node-right b))
      (set-node-right! b (node-right a))
      (set-node-key! b (node-key a))
      (set-node-value! b (node-value a))
      (compute-height! b)
      (set-node-right! a b)
      (set-node-key! a b-key)
      (set-node-value! a b-value)
      (set-node-left! a b-left)
      ; (compute-height! a)
      a))
  
  (define (rebalance-node! node)
    (case (- (node-height (node-left node)) 
             (node-height (node-right node)))
      ((2) (rotate-right! node))
      ((-2) (rotate-left! node)))
    (compute-height! node))
  
  (define (insert! key value node)
    (let ((old-value
           (cond ((ordered? key (node-key node))
                  (if (node-left node)
                      (insert! key value (node-left node))
                      (begin 
                       (set-node-left! node (vector 1 #f key value #f))
                       #f)))
                 ((ordered? (node-key node) key)
                  (if (node-right node)
                      (insert! key value (node-right node))
                      (begin 
                       (set-node-right! node (vector 1 #f key value #f))
                       #f)))
                 (else (let ((old-value (node-value node)))
                         ; (set-node-key! node key)
                         (set-node-value! node value)
                         old-value)))))
      (rebalance-node! node)     
      old-value))
  
  (define (update! tree key update-fn)

    (define (updater key update-fn node)
      (cond ((ordered? key (node-key node))
             (if (node-left node)
               (updater key update-fn (node-left node))
               (set-node-left! node (vector 1 #f key (update-fn #f) #f))))
            ((ordered? (node-key node) key)
             (if (node-right node)
               (updater key update-fn (node-right node))
               (set-node-right! node (vector 1 #f key (update-fn #f) #f))))
            (else (set-node-value! node (update-fn (node-value node)))))
      (rebalance-node! node))

    (if (empty? tree)
      (set-node-key-value! tree key (update-fn #f))
      (updater key update-fn tree)))
  
  (define (foreach-node fn node)
    (if node 
        (begin
         (foreach-node fn (node-left node))
         (fn (node-key node) (node-value node))
         (foreach-node fn (node-right node)))))

  (define (map!-node fn node)
    (if node 
      (begin
        (map!-node fn (node-left node))
        (set-node-value! node (fn (node-key node) (node-value node)))
        (map!-node fn (node-right node)))))

  (define (reduce-node fn node so-far)
    (if node
        (reduce-node fn (node-left node)
                        (fn (node-key node) (node-value node)
                                            (reduce-node fn (node-right node) 
                                                            so-far)))
        so-far))
  
  (define (map-node fn node)
    (if (vector? node)
        (vector (vector-ref node 0)
                (map-node fn (vector-ref node 1))
                (vector-ref node 2)
                (fn (vector-ref node 2) (vector-ref node 3))
                (map-node fn (vector-ref node 4)))
        #f))
  
  (lambda (selector)  
    (case selector
      ((make) (lambda () (make-vector 5 #f)))
      ((make-with-value) (lambda (key value)
                          (vector 1 #f key value #f)))
      ((empty?) empty?)
      ((ref) (lambda (tree key)
               (if (empty? tree)
                 #f
                 (search key tree))))
      ((set!) (lambda (tree key value)
                (if (empty? tree)
                  (begin
                    (set-node-key-value! tree key value)
                    #f)
                  (insert! key value tree))))
      ((for-each) (lambda (tree fn) 
                   (if (empty? tree)
                       #f
                       (foreach-node fn tree))))
      ((map) (lambda (tree fn)
               (if (empty? tree)
                   (make-vector 5 #f)
                   (map-node fn tree))))
      ((map!) (lambda (tree fn) 
                (if (empty? tree)
                  #f
                  (map!-node fn tree))
                tree))
      ((reduce) (lambda (tree fn start) 
                  (if (empty? tree)
                      start
                      (reduce-node fn tree start))))
      ((update!) update!)
      ((inc!) (assoc:inc!-maker update!))
      ((push!) (assoc:push!-maker update!))
      (else (error "Unimplemented selector: " selector)))))

(define (trie-maker associator-maker)
  (let ((assoc-new (associator-maker 'make))
        (assoc-update! (associator-maker 'update!))
        (assoc-insert! (associator-maker 'set!))
        (assoc-lookup (associator-maker 'ref))
        (assoc-map (associator-maker 'map))
        (assoc-map! (associator-maker 'map!))
        (assoc-reduce (associator-maker 'reduce))
        (assoc-foreach (associator-maker 'for-each)))
    (define (search trie keys)
      (if trie
          (if (null? keys)
              (car trie)
              (if (not (null? (cdr trie)))
                  (search (assoc-lookup (cdr trie) (car keys)) (cdr keys))
                  #f))
          #f))
    (define (assoc-new-value key value)
      (let ((a (assoc-new)))
        (assoc-insert! a key value)
        a))
    (define (new-path keys value)
      (if (null? keys)
          (list value)
          (cons #f (assoc-new-value (car keys) (new-path (cdr keys) value)))))
    (define (insert! trie keys value)
      (let ((old-value #f))
        (define (inserter keys trie)
          (cond ((null? keys) (set! old-value (car trie)) (set-car! trie value))
                ((null? (cdr trie))
                 (set-cdr! trie (assoc-new-value (car keys) 
                                                 (new-path (cdr keys) value))))
                (else (assoc-update! (cdr trie)
                                     (car keys)
                                     (lambda (sub-trie)
                                       (if sub-trie
                                           (inserter (cdr keys) sub-trie)
                                           (new-path (cdr keys) value))))))
          trie)
        (inserter keys trie)
        old-value))
    (define (update! trie keys update-fn)
      (define (updater keys trie)
        (cond ((null? trie) (new-path keys (update-fn #f)))
              ((null? keys) (set-car! trie (update-fn (car trie))))
              ((null? (cdr trie))
               (set-cdr! trie (assoc-new-value (car keys) 
                                               (new-path (cdr keys) 
                                                         (update-fn #f)))))
              (else (assoc-update! (cdr trie)
                                   (car keys)
                                   (lambda (sub-trie) 
                                     (if sub-trie
                                       (updater (cdr keys) sub-trie)
                                       (new-path (cdr keys) (update-fn #f)))))))
        trie)
      (updater keys trie))
    (define (reduce-trie fn keys trie so-far0)
      (if (pair? trie)
          (let ((so-far1 (if (car trie)
                             (fn (reverse keys) (car trie) so-far0)
                             so-far0)))
            (if (null? (cdr trie))
                so-far1
                (assoc-reduce (cdr trie)
                              (lambda (key new-trie so-far2)
                                (reduce-trie fn (cons key keys) new-trie 
                                                                so-far2))
                              so-far1)))
          so-far0))
    (define (foreach-trie fn keys trie)
      (if (pair? trie)
          (begin
           (if (car trie) 
               (fn (reverse keys) (car trie)))
           (if (not (null? (cdr trie)))
               (assoc-foreach (cdr trie)
                              (lambda (key new-trie)
                                (foreach-trie fn (cons key keys) new-trie)))))))
    (define (map!-trie fn keys trie)
      (if (pair? trie)
          (begin
           (if (car trie) 
               (set-car! trie (fn (reverse keys) (car trie))))
           (if (not (null? (cdr trie)))
               (assoc-foreach (cdr trie)
                              (lambda (key new-trie)
                                (map!-trie fn (cons key keys) new-trie)))))))
    (define (map-trie fn keys trie)
      (if trie
          (cons (if (car trie)
                    (fn (reverse keys) (car trie))
                    #f)
                (if (null? (cdr trie))
                    '()
                    (assoc-map (cdr trie)
                               (lambda (key new-trie)
                                 (map-trie fn (cons key keys) new-trie)))))
          #f))
    
    (lambda (selector)
      (case selector
        ((make) (lambda () (list #f)))
        ((ref) search)
        ((set!) insert!)
        ((map) (lambda (trie fn) (map-trie fn '() trie)))
        ((update!) update!)
        ((reduce) (lambda (trie fn start) (reduce-trie fn '() trie start)))
        ((for-each) (lambda (trie fn) (foreach-trie fn '() trie) trie))
        ((map!) (lambda (trie fn) (map!-trie fn '() trie) trie))
        ((inc!) (assoc:inc!-maker update!))
        ((push!) (assoc:push!-maker update!))
        (else (error "Unimplemented selector: " selector))))))

(define (vector-associator size fill)
  (lambda (selector)
    (case selector
      ((make) (lambda () (make-vector size fill)))
      ((ref) vector-ref)
      ((set!) (lambda (vec i v)
                (let ((old-value (vector-ref vec i)))
                  (vector-set! vec i v)
                  old-value)))
      ((map) (lambda (old-vec fn)
               (let ((new-vec (make-vector size)))
                 (do ((i (- size 1) (- i 1)))
                     ((negative? i) new-vec)
                   (let ((v (vector-ref old-vec i)))
                     (if v
                       (vector-set! new-vec i (fn i v))))))))
      ((update!) (lambda (vec i f)
                   (vector-set! vec i (f (vector-ref vec i)))))
      ((reduce) (lambda (vec f thread)
                  (define (reduce i thread)
                    (if (negative? i)
                      thread
                      (reduce (- i 1) 
                              (let ((v (vector-ref vec i)))
                                (if v
                                  (f i v thread)
                                  thread)))))
                  (reduce (- size 1) thread)))
      ((for-each) (lambda (vec proc)
                    (do ((i (- size 1) (- i 1)))
                        ((negative? i))
                      (let ((v (vector-ref vec i)))
                        (if v
                          (proc i v))))))
      ((map!) (lambda (vec proc)
                (do ((i (- size 1) (- i 1)))
                    ((negative? i))
                  (let ((v (vector-ref vec i)))
                    (if v
                      (vector-set! vec i (proc i v)))))
                vec))
      ((inc!) (lambda (vec i inc)
                (if (not (zero? inc))
                  (let ((v (vector-ref vec i)))
                    (vector-set! vec i (if v (+ v i) i))))))
      ((push!) (lambda (vec i e)
                 (vector-set! vec i 
                              (let ((v (vector-ref vec i)))
                                (if v
                                  (cons e v)
                                  (list v))))))
      (else (error "Unimplemented selector: " selector)))))


;;; define an associator from atoms to values

(define atom@
  (avl-maker (lambda (a1 a2)
               (if (symbol? a1)
                 (if (symbol? a2)
                   (string<? (symbol->string a1)
                             (symbol->string a2))
                   #f)
                 (if (symbol? a2)
                   #t
                   (< a1 a2))))))


(define atom@-make (atom@ 'make))
(define atom@-ref (atom@ 'ref))
(define atom@-set! (atom@ 'set!))
(define atom@-map (atom@ 'map))
(define atom@-map! (atom@ 'map!))
(define atom@-update! (atom@ 'update!))
(define atom@-reduce (atom@ 'reduce))
(define atom@-for-each (atom@ 'for-each))
(define atom@-push! (atom@ 'push!))
(define atom@-inc! (atom@ 'inc!))

;;; define an associator from list-of-symbols->value

(define atoms@ (trie-maker atom@))

(define atoms@-make (atoms@ 'make))
(define atoms@-ref (atoms@ 'ref))
(define atoms@-set! (atoms@ 'set!))
(define atoms@-map (atoms@ 'map))
(define atoms@-map! (atoms@ 'map!))
(define atoms@-update! (atoms@ 'update!))
(define atoms@-reduce (atoms@ 'reduce))
(define atoms@-for-each (atoms@ 'for-each))
(define atoms@-push! (atoms@ 'push!))
(define atoms@-inc! (atoms@ 'inc!))
