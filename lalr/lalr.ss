;;; lalr.ss - An LALR(1) parser generator
;;;
;;; Author: Mark Johnson (mj@cs.brown.edu)
;;; Date: 24th May, 1993
;;; Version: 0.9 
;;;
;;;
;;; The parser generator consists of two functions.  The first constructs
;;; the parse tables, which the second function uses to actually parse.
;;; You can see how to use these in the file lalr-test.ss.
;;;
;;; (lalr-table grammar terminals print-table-flag) returns
;;; the lalr parsing table for the grammar.  Its arguments are:
;;; 
;;;   grammar: A list of productions, each of which is a list of the
;;;     form (<cat> --> <cat> ... <action>), where <cat> is a symbol
;;;     (a category label) and <action> is a procedure of appropriate
;;;     arity.  The procedure will be called each time this production
;;;     is reduced with the values associated with each child node.
;;;     The categories can be any symbol _except_ $start$ and $end$.
;;;     The grammar's start symbol is the parent category of the first
;;;     production, i.e., (caar grammar).
;;;
;;;   terminals: A list of all the categories that the lexical analyser
;;;     can return.
;;;
;;;   print-table-flag: If non-#f, causes the pretty-printing of the
;;;     lalr parse tables as a side-effect.  Parse conflicts are indicated
;;;     in the table (search for ** ).
;;;
;;; (lalr-parser table lexical-analyser parse-error) returns the value
;;; associated with the root node if the parse is successful, or the
;;; value of parse-error otherwise.
;;;
;;;  table: A parse table produced by lalr-table.
;;;
;;;  lexical-analyser: A procedure of no arguments which advances the
;;;     input stream by one element each time it is called, returning
;;;     (cons <cat> <val>) where <cat> is the category label of the 
;;;     next token, and <val> is the value associated with that token.
;;;     It should return #f at the end of the input stream.
;;;
;;;  parse-error: A procedure of no arguments, which is called if the
;;;     the parser blocks (i.e., detects a syntactic error in the input
;;;     stream).
;;;
;;;
;;;  The parser resolves any parse conflicts in a standard way;
;;;  shift/reduce conflicts are resolved by shifting, and reduce/reduce
;;;  conflicts are resolved by choosing the longest applicable
;;;  reduction.
;;;
;;;  Note: It is most convenient to use the backquote mechanism to
;;;  enter the grammar into scheme.  The actions, which are procedures,
;;;  can be created by unquoting a corresponding lambda expression
;;;  (see the associated example file).  You can use lalr-table to
;;;  produce expressions that can appear in Scheme programs by changing 
;;;  the backquote infront of the grammar to a normal quote.

;;; (require 'sort)
;;; (require 'assoc)

(define (lalr-table grammar terminals print-flag)
  
  (define new-start-symbol '$start$)
  (define end-marker '$end$)

;;;;;;; Utilities

  (define (list-prefix elts n)
    (if (zero? n)
	'()
	(cons (car elts) (list-prefix (cdr elts) (- n 1)))))

  (define (list-suffix elts n)
    (if (zero? n)
	elts
	(list-suffix (cdr elts) (- n 1))))

  (define (sublist elts start . end)
    (if (null? end)
	(list-suffix elts start)
	(list-prefix (list-suffix elts start) (- (car end) start))))

  (define (butlast elts)
    (cond ((null? elts) '())
	  ((null? (cdr elts)) '())
	  (else (cons (car elts) (butlast (cdr elts))))))

  (define (last elts)
    (cond ((null? elts) #f)
	  ((null? (cdr elts)) (car elts))
	  (else (last (cdr elts)))))

  (define (select p? es)
    (cond ((null? es) '())
	  ((p? (car es)) (cons (car es) (select p? (cdr es))))
	  (else (select p? (cdr es)))))

  (define (find-if p? es)
    (cond ((null? es) #f)
	  ((p? (car es)) (car es))
	  (else (find-if p? (cdr es)))))

  (define (some p? es)
    (if (null? es)
	#f
	(or (p? (car es))
	    (some p? (cdr es)))))

  (define (every p? es)
    (if (null? es)
	#t
	(and (p? (car es))
	     (every p? (cdr es)))))

  (define (reduce f es init)
    (if (null? es)
	init
	(reduce f (cdr es) (f (car es) init))))

  (define (union e1s e2s)
    (if (null? e1s)
	e2s
	(if (member (car e1s) e2s)
	    (union (cdr e1s) e2s)
	    (cons (car e1s) (union (cdr e1s) e2s)))))

  (define (intersection e1s e2s)
    (if (null? e1s)
	'()
	(if (member (car e1s) e2s)
	    (cons (car e1s) (intersection (cdr e1s) e2s))
	    (intersection (cdr e1s) e2s))))

  (define (subtract e1s e2s)
    (if (null? e1s)
	'()
	(if (member (car e1s) e2s)
	    (subtract (cdr e1s) e2s)
	    (cons (car e1s) (subtract (cdr e1s) e2s)))))

  (define (unions sets)
    (cond ((null? sets) '())
	  ((null? (cdr sets)) (car sets))
	  (else (union (car sets) (unions (cdr sets))))))

  (define (close op es)
    (define (close1 todo sofar)
      (if (pair? todo)
	  (close1 (cdr todo)
		  (if (member (car todo) sofar)
		      sofar
		      (close1 (op (car todo)) (cons (car todo) sofar))))
	  sofar))
    (close1 es '()))

  (define (collect f es)
    (define (collect1 todo sofar)
      (if (null? todo)
	  sofar
	  (let ((val (f (car todo))))
	    (collect1 (cdr todo) (if val (adjoin val sofar) sofar)))))
    (collect1 es '()))

  (define (adjoin e es)
    (if (member e es)
	es
	(cons e es)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;                    Globals
;;;

  (define cat@ atom@)

  (define memoize1
    (lambda (assoc-maker fn)
      (let* ((store ((assoc-maker 'make)))
	     (ref (assoc-maker 'ref))
	     (setter! (assoc-maker 'set!)))
	(lambda (arg)
	  (or (ref store arg)
	      (let ((val (fn arg)))
		(setter! store arg val)
		val))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;                    Rules and Grammars
;;;

  (define (make-rule index-number mother daughters action)
    (vector index-number mother daughters action))

  (define (rule-no rule) (vector-ref rule 0))
  (define (rule-mother rule) (vector-ref rule 1))
  (define (rule-daughters rule) (vector-ref rule 2))
  (define (rule-action rule) (vector-ref rule 3))

  (define (transform-rule grammar-rule rule-no)
    (let ((l (length grammar-rule)))
      (make-rule rule-no (car grammar-rule) 
		 (butlast (cddr grammar-rule))
		 (last grammar-rule))))


  (let* ((grules (let ((i -1))
		   (map (lambda (r)
			  (set! i (1+ i))
			  (transform-rule r i))
			grammar)))
	 (nrules (length grules))
	 (nonterminals (collect rule-mother grules))

	 (start-symbol (caar grammar))

	 (expand
	  (memoize1 cat@
		    (lambda (cat) 
		      (select (lambda (rule) (eq? (rule-mother rule) cat))
			      grules))))
       
	 (gcats (union terminals (collect rule-mother grules)))

	 (derives-epsilon?
	  (memoize1 cat@
		    (lambda (c)
		      (define (try dejaVu cat)
			(and (not (member cat dejaVu))
			     (some (lambda (r) 
				     (every (lambda (c1) (try (cons cat dejaVu) c1))
					    (rule-daughters r)))
				   (expand cat))))
		      (try '() c))))

	 (left-corners (lambda (c)
			 (reduce (lambda (rule sofar)
				   (define (skip rhs sofar)
				     (if (null? rhs)
					 sofar
					 (if (derives-epsilon? (car rhs))
					     (skip (cdr rhs) (adjoin (car rhs) sofar))
					     (adjoin (car rhs) sofar))))
				   (skip (rule-daughters rule) sofar))
				 (expand c)
				 '())))

	 (left-most-terminals
	  (memoize1 cat@
		    (lambda (c0)
		      (select (lambda (term) 
				(or (eq? end-marker term) (member term terminals)))
			      (close left-corners (list c0)))))))
       
                      
    (define (left-most catList)
      (if (pair? catList)
	  (if (derives-epsilon? (car catList))
	      (union (left-most-terminals (car catList))
		     (left-most (cdr catList)))
	      (left-most-terminals (car catList)))
	  '()))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;                  LR(0) parsing table constructor
;;;

    (define (make-item rule pos) (vector pos rule '()))
    (define (item-rule item) (vector-ref item 1))
    (define (item-pos item) (vector-ref item 0))
    (define (item-las item) (vector-ref item 2))
    (define (item-las-push! item la) 
      (vector-set! item 2 (cons la (vector-ref item 2))))

    (define (item-daughters item) (rule-daughters (item-rule item)))
    (define (item-right item) (list-suffix (item-daughters item) (item-pos item)))
    (define (item-next item)
      (let ((rhs (item-right item)))
	(if (pair? rhs) (car rhs) #f)))

;;;(define (item<? item1 item2)
;;;  (let ((rn1 (rule-no (item-rule item1)))
;;;        (rn2 (rule-no (item-rule item2))))
;;;    (cond ((< rn1 rn2) #t)
;;;          ((> rn1 rn2) #f)
;;;          (else (< (item-pos item1) (item-pos item2))))))

    (define (item<? item1 item2)
      (let ((ip1 (item-pos item1))
	    (ip2 (item-pos item2)))
	(cond ((> ip1 ip2) #t)
	      ((< ip1 ip2) #f)
	      (else (< (rule-no (item-rule item1))
		       (rule-no (item-rule item2)))))))

;;; deleted because states must *not* share items!
;;;(define cat->items
;;;  (memoize1 cat@
;;;            (lambda (cat)
;;;              (map (lambda (rule) (make-item rule 0))
;;;                   (expand cat)))))
 
    (define (cat->items cat)
      (map (lambda (rule) (make-item rule 0))
	   (expand cat)))
  
    (define (close-items items)
      (close (lambda (item)
	       (let ((rh-cat (item-next item)))
		 (if rh-cat
		     (cat->items rh-cat)
		     '())))
	     items))
  
    (define (shift-items items cat)
      (collect (lambda (item)
		 (if (eq? cat (item-next item))
		     (make-item (item-rule item) (1+ (item-pos item)))
		     #f))
	       items))
  
;;; returns the set of categories appearing to the right of the dot

    (define (items-next items)
      (collect item-next items))
  

;;;  The actual table construction functions

    (define (make-state no items) (vector no items #f))
  
    (define (state-no state) (vector-ref state 0))
    (define (state-items state) (vector-ref state 1))
    (define (state-shifts state) (vector-ref state 2))
    (define (state-shifts-set! state shifts) (vector-set! state 2 shifts))
  

    (define (sort-items! items) (sort! item<? items))

    (let* ((state@ (trie-maker (avl-maker item<?)))
	   (initial-item (make-item (make-rule -1 new-start-symbol
					       (list start-symbol) #f) 0))

	   (state-vec
	    (let ((assc ((state@ 'make)))
		  (ref (state@ 'ref))
		  (setter! (state@ 'set!))
		  (nstates 0))
	      (define (follow items)
		(let* ((sitems (sort-items! items))
		       (existing-state (ref assc sitems)))
		  (if existing-state
		      (state-no existing-state)
		      (begin
			(let* ((closure (sort-items! (close-items sitems)))
			       (state (make-state nstates closure)))
			  (set! nstates (1+ nstates))
			  (setter! assc sitems state)
			  (state-shifts-set!
			   state
			   (map (lambda (cat)
				  (cons cat
					(follow (shift-items closure cat))))
				(collect item-next closure)))
			  (state-no state))))))
	      (follow (list initial-item))
	      (let ((state-vec (make-vector nstates)))
		((state@ 'for-each) assc
				    (lambda (items state) 
				      (vector-set! state-vec (state-no state)
						   state)))
		state-vec))))
         
      (define (propagate-la state-no rule pos la)
	(let* ((state (vector-ref state-vec state-no))
	       (state-item (find-if (lambda (item) 
				      (and (= (rule-no rule)
					      (rule-no (item-rule item)))
					   (= pos (item-pos item))))
				    (state-items state))))
	  (cond ((not (member la (item-las state-item)))
		 (item-las-push! state-item la)
		 (let ((rhs (list-suffix (rule-daughters rule) pos)))
		   (if (pair? rhs)
		       (let ((new-las (left-most (append (cdr rhs) (list la)))))
			 (for-each (lambda (new-rule)
				     (for-each (lambda (new-la) 
						 (propagate-la state-no
							       new-rule 0
							       new-la))
					       new-las))
				   (expand (car rhs)))
			 (propagate-la (cdr (assq (car rhs) (state-shifts state)))
				       rule (1+ pos) la))))))))

      (define (print-table)
	(define (space-display p) (display " ") (display p))
	(do ((state-no 0 (1+ state-no)))
	    ((= state-no (vector-length state-vec)))
	  (newline) (display "State ") (display state-no) (newline)
	  (let* ((state (vector-ref state-vec state-no))
		 (deja-vu (map car (state-shifts state)))
		 (conflicts '()))
	    (for-each (lambda (item)
			(newline) 
			(display "     ") 
			(display (rule-mother (item-rule item)))
			(display " -->")
			(for-each space-display 
				  (sublist (rule-daughters (item-rule item))
					   0 (item-pos item)))
			(space-display ".")
			(for-each space-display (item-right item))
			(space-display ";")
			(for-each space-display (item-las item)))
		      (state-items state))
	    (newline)
	    (for-each (lambda (shift)
			(newline)
			(display "  On ")
			(display (car shift))
			(display " shift to state ")
			(display (cdr shift)))
		      (state-shifts state))
	    (for-each (lambda (item)
			(newline)
			(display "  On")
			(for-each space-display (item-las item))
			(display " reduce: ")
			(display (rule-mother (item-rule item)))
			(display " -->")
			(for-each space-display (rule-daughters (item-rule item)))
			(let ((cs (intersection (item-las item) deja-vu)))
			  (if (not (null? cs))
			      (set! conflicts (union cs conflicts)))))
		      (select (lambda (item) (null? (item-right item)))
			      (state-items state)))
	    (if (not (null? conflicts))
		(begin
		  (newline)
		  (display "  ** Conflicting actions on")
		  (for-each space-display conflicts)))
	    (newline))))
    
      (propagate-la 0 (item-rule initial-item) 0  end-marker)
    
      (if print-flag
	  (print-table))

      (let ((shift-vec (make-vector (vector-length state-vec)))
	    (goto-vec (make-vector (vector-length state-vec)))
	    (redn-vec (make-vector (vector-length state-vec)))
	    (rule-parent-vec (make-vector nrules))
	    (rule-length-vec (make-vector nrules))
	    (rule-action-vec (make-vector nrules)))
	(do ((i 0 (+ i 1)))
	    ((= i (vector-length state-vec)))
	  (let* ((state (vector-ref state-vec i))
		 (so-far (map car (state-shifts state))))
	    (vector-set! shift-vec i
			 (select (lambda (shift)
				   (member (car shift) terminals))
				 (state-shifts state)))
	    (vector-set! goto-vec i
			 (select (lambda (shift)
				   (member (car shift) nonterminals))
				 (state-shifts state)))
	    (vector-set! redn-vec i
			 (map (lambda (item)
				(let ((new-las (subtract (item-las item) so-far)))
				  (set! so-far (append new-las so-far))
				  (cons (rule-no (item-rule item)) new-las)))
			      (select (lambda (item) (null? (item-right item)))
				      (state-items state))))))
	(for-each (lambda (rule)
		    (let ((no (rule-no rule)))
		      (vector-set! rule-parent-vec no (rule-mother rule))
		      (vector-set! rule-length-vec no
				   (length (rule-daughters rule)))
		      (vector-set! rule-action-vec no (rule-action rule))))
		  grules)
	
	(vector shift-vec
		goto-vec
		redn-vec
		rule-parent-vec
		rule-length-vec
		rule-action-vec)
	))))
  
(define (lalr-parser lalr-tables lexical-analyser parse-error)
  (define end-marker '$end$)
  (define (find-redn la redns)
    (if (null? redns)
      #f
      (if (memq la (cdar redns))
        (caar redns)
        (find-redn la (cdr redns)))))
  (define (list-prefix elts n)
    (if (zero? n) '() (cons (car elts) (list-prefix (cdr elts) (- n 1)))))  
  (define (list-suffix elts n)
    (if (zero? n) elts (list-suffix (cdr elts) (- n 1))))  
  (let ((shift-vec (vector-ref lalr-tables 0))
        (goto-vec (vector-ref lalr-tables 1))
        (redn-vec (vector-ref lalr-tables 2))
        (rule-parent (vector-ref lalr-tables 3))
        (rule-length (vector-ref lalr-tables 4))
        (rule-action (vector-ref lalr-tables 5))
        (next-cat #f)
        (next-val #f))
    (define (advance-input)
      (let ((p (lexical-analyser)))
        (if (pair? p)
          (begin
            (set! next-cat (car p))
            (set! next-val (cdr p)))
          (begin
            (set! next-cat end-marker)
            (set! next-val #f)))))
    (define (move* state states vals)
      (let* ((shift-pair (assq next-cat (vector-ref shift-vec state))))
        (if shift-pair 
          (let ((old-val next-val))
            (advance-input)
            (move* (cdr shift-pair)
                   (cons state states)
                   (cons old-val vals)))
          (let ((redn (find-redn next-cat (vector-ref redn-vec state))))
            (if redn
              (if (and (= redn -1) (eq? next-cat end-marker))
                (car vals)
                (let* ((l (vector-ref rule-length redn))
                       (new-states (if (zero? l)
                                     (cons state states)
                                     (list-suffix states (- l 1)))))
                  (move* (cdr (assq (vector-ref rule-parent redn)
                                    (vector-ref goto-vec (car new-states))))
                         new-states
                         (cons (apply (vector-ref rule-action redn)
                                      (reverse (list-prefix vals l)))
                               (list-suffix vals l)))))
              (parse-error))))))
    (advance-input)
    (move* 0 '() '())))
