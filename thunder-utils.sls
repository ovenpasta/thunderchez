;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(library (thunder-utils)
  (export string-split string-replace bytevector-copy* read-string
	  print-stack-trace
	  sub-bytevector  sub-bytevector=?
	  load-bytevector save-bytevector
	  define/optional lambda/optional /optional
	  define/keys lambda/keys /keys decode-keys)
  
  (import (scheme) (srfi s14 char-sets)
	  (only (srfi s1 lists) take drop)
	  (srfi private auxiliary-keyword))

  ;; s is a string , c is a character-set or a list of chars
  ;; null strings are discarded from result by default unless #f is specified as third argument
  (define string-split
    (case-lambda
     [(s c)
      (string-split s c #t)]
     [(s c discard-null?)
      (define res '())
      (let loop ([l (string->list s)] [t '()])
	(if (null? l) 
	    (if (and (null? t) discard-null?)
		res (append res (list (list->string t))))
	    (if (or (and (char-set? c) (char-set-contains? c (car l)))
		    (and (pair? c) (memv (car l) c)))
		(begin 
		  (unless (and (null? t) discard-null?)
			  (set! res (append res (list (list->string t)))))
		  (loop (cdr l) '()))
		(loop (cdr l) (append t (list (car l)))))))]))
  
  ;; POSSIBLE THAT THIS NOT EXIST?
  ;; if x is a character: (eqv?  s[i] x) => s[i] = y
  ;; if x is a list:      (memv s[i] x) => s[i] = y

  (define (string-replace s x y)
    (list->string  
     (let ([cmp (if (list? x) memv eqv?)])
       (map (lambda (z) (if (cmp z x) y z)) (string->list s)))))

  ;; WHY THERE NOT EXISTS BYTEVECTOR-COPY WITH src-start and n? F*** YOU
  (define bytevector-copy*
    (case-lambda
     [(bv) (bytevector-copy bv)]
     [(bv start)
      (bytevector-copy* bv start (- (bytevector-length bv) start))]
     [(bv start n)
      (let ([dst (make-bytevector n)])
	(bytevector-copy! bv start dst 0 n) dst)]))

  (define read-string
    (case-lambda
     [() (read-string #f)]
     [(n) (read-string n (current-input-port))]
     [(n port)
      (if n
	  (get-string-n port n)
	  (get-string-all port))]))

  (define (print-stack-trace depth)
    (printf "stack-trace:\n")
    (call/cc 
     (lambda (k)
       (let loop ((cur (inspect/object k))
		  (i 0))
	 (if (and (< i depth)
		  (> (cur 'depth) 1))
	     (let* ([name (cond [((cur 'code) 'name) => (lambda (x) x)]
				[else "*"])]
		    [source ((cur 'code) 'source)]
		    [source-txt (if source
				    (let ([ss (with-output-to-string
						(lambda ()
						  (source 'write (current-output-port))))])
					  (if (> (string-length ss) 50)
					      (string-truncate! ss 50)
					      ss))
				    "*")])
	       (call-with-values
		   (lambda () (cur 'source-path))
		 (case-lambda
		  [() (printf "[no source] [~a]: ~a\n" name source-txt)]
		  [(fn bfp) (printf "~a char ~a [~a]: ~a\n" fn bfp name source-txt)]
		  [(fn line char) (printf "~a:~a:~a [~a]: ~a\n" fn line char name source-txt)]))
	       (loop (cur 'link) (+ i 1)))))))
    (printf "stack-trace end.\n"))


  (define sub-bytevector
    (case-lambda
      [(b start)
       (sub-bytevector b start (bytevector-length b))]
      [(b start end)
       (let* ([n (- end start)]
	      [x (make-bytevector n)])
	 (bytevector-copy! b start x 0 n)
	 x)]))

  (define (sub-bytevector=? b1 start1 b2 start2 len)
    (bytevector=? (sub-bytevector b1 start1 (+ start1 len))
		  (sub-bytevector b2 start2 (+ start2 len))))

  (define (load-bytevector path)
    (call-with-port (open-file-input-port path)
		    (lambda (p) (get-bytevector-all p))))
  
  (define (save-bytevector path data)
    (call-with-port (open-file-output-port path)
		    (lambda (p) (put-bytevector p data))))

  ;; from https://fare.livejournal.com/189741.html
  (define-syntax (nest stx)
    (syntax-case stx ()
      ((nest outer ... inner)
       (fold-right (lambda (o i)
		     (with-syntax (((outer ...) o)
				   (inner i))
		       #'(outer ... inner)))
		   #'inner (syntax->list #'(outer ...))))))

  (define-auxiliary-keywords /optional /keys)

  (define-syntax define/optional
    (lambda (stx)
      (syntax-case stx (/optional)
	[(_ (name params ... (/optional opts ...)) body ...)
	 (let ([opts-list
		(map (lambda (opt)
		       (let ([x (syntax->datum opt)])
			 (if (list? x)
			     (list (datum->syntax (car (syntax->list opt)) (car x))
				   (datum->syntax (car (syntax->list opt)) (cadr x) ))
			     (list opt #f))))
		     (syntax->list #'(opts ...)))])
	   #`(define name
	       (case-lambda
		 #,@(map (lambda (i)
			   #`[(params ... #,@(take (map car opts-list) i))
			      (name params ...
				    #,@(take (map car opts-list) i)
				    #,@(drop (map cadr opts-list) i))])
			 (iota  (length opts-list)))
		 [(params ... #,@(map car opts-list))
		  body ...])))])))

  
  (define-syntax lambda/optional
    (lambda (stx)
      (syntax-case stx (/optional)
	[(_ (params ... (/optional opts ...)) body ...)
	 (let ([opts-list
		(map (lambda (opt)
		       (let ([x (syntax->datum opt)])
			 (if (list? x)
			     (list (datum->syntax (car (syntax->list opt)) (car x))
				   (datum->syntax (car (syntax->list opt)) (cadr x) ))
			     (list opt #f))))
		     (syntax->list #'(opts ...)))])
	   #`(letrec ([func 
		       (case-lambda
			 #,@(map (lambda (i)
				   #`[(params ... #,@(take (map car opts-list) i))
				      (func params ...
					    #,@(take (map car opts-list) i)
					    #,@(drop (map cadr opts-list) i))])
				 (iota  (length opts-list)))
			 [(params ... #,@(map car opts-list))
			  body ...])])
	       func))])))

  (define (decode-keys func-name names keys)
    (for-each (lambda (k)
		(unless (assq (car k) names)
		  (errorf func-name "unknown keyword argument ~d" k)))
	      keys)
    (apply values (map (lambda (name)
			 (let ([p (assq (if (pair? name) (car name) name) keys)])
			   (if p
			       (if (pair? (cdr p))
				   (cadr p)
				   (cdr p))
			       (if (pair? name)
				   (if (pair? (cdr name))
				       (cadr name)
				       (cdr name))
				   #f))))
		       names)))
  
  (define-syntax define/keys 
    (lambda (stx)
      (syntax-case stx (/keys)
	[(_ (name params ... (/keys keys ...)) body ...)
	 (let ([keys-list
		(map (lambda (key)
		       (let ([x (syntax->datum key)])
			 (if (list? x)
			     (list (datum->syntax (car (syntax->list key)) (car x))
				   (datum->syntax (car (syntax->list key)) (cadr x) ))
			     (list key #f))))
		     (syntax->list #'(keys ...)))])
 	   #`(define name
	       (lambda (params ... . keys*)
		 (import (only (data-structures) chop))
		 (import (only (thunder-utils) decode-keys))
		 (let-values ([(#,@(map car keys-list))
			       (decode-keys 'name '#,keys-list (chop keys* 2))])
		   body ...))))])))

  
  (define-syntax lambda/keys 
    (lambda (stx)
      (syntax-case stx (/keys)
	[(_ (params ... (/keys keys ...)) body ...)
	 (let ([keys-list
		(map (lambda (key)
		       (let ([x (syntax->datum key)])
			 (if (list? x)
			     (list (datum->syntax (car (syntax->list key)) (car x))
				   (datum->syntax (car (syntax->list key)) (cadr x) ))
			     (list key #f))))
		     (syntax->list #'(keys ...)))])
 	   #`(lambda (params ... . keys*)
	       (import (only (data-structures) chop))
	       (import (only (thunder-utils) decode-keys))
	       (let-values ([(#,@(map car keys-list))
			     (decode-keys 'func '#,keys-list (chop keys* 2))])
		 body ...)))])))
  );library

