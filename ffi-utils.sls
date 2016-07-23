#!chezscheme

(library (ffi-utils)
	 (export define-enumeration* define-function define-flags make-flags flags flags-name flags-alist flags-indexer flags-ref-maker flags-decode-maker)
	 (import (chezscheme))

	 
 ;; Uses make-enumeration to define an enum with the following:
 ;; function (name x) -> index
 ;; function (name-ref index) -> symbol
 ;; variable name-enum  -> #>enum-set>
 ;; usage: (define-enumeration* NAME (tag1 tag2 tag3 ...))

 (define-syntax define-enumeration*
   (lambda (x)
     (define gen-id
       (lambda (template-id . args)
	 (datum->syntax
	  template-id
	  (string->symbol
	   (apply
	    string-append
	    (map (lambda (x)
		   (if (string? x) x (symbol->string (syntax->datum x))))
		 args))))))
     (syntax-case x ()
       [(_ name (l ...))
	(with-syntax ([base-name (gen-id #'name "" #'name)]
		      [enum-name (gen-id #'name #'name "-enum")]
		      [ref-name (gen-id #'name #'name "-ref")])
		     #'(begin
			 (define enum-name (make-enumeration '(l ...)))
			 (define base-name
			   (lambda (x)
			     (let ([r ((enum-set-indexer enum-name) x)])
			       (if r
				   r
				   (assertion-violation 'enum-name
							"symbol not found"
							x)))))
			 (define ref-name
			   (lambda (index)
			     (list-ref (enum-set->list enum-name) index)))
			 (indirect-export base-name enum-name ref-name)))])))

;; ;; TODO: WRITE SOME AUTOMATED TYPE CHECKS/CONVERSIONS

;;  (define ffi-types-conversion-list (make-parameter '()))
;;  (define-record ffi-type (name >scheme >c ffi-name))

;;  (define (find-ffi-type t)
;;    (find (lambda (x) (equal? (ffi-type-name x) t)) (ffi-types-conversion-list)))
   
;;  (define-syntax define-function
;;    (lambda (x)
;;      (define (rename-type t) (datum->syntax t (cond [(find-ffi-type (syntax->datum t)) 
;; 						       => (lambda (ft) (ffi-type-ffi-name ft))]
;; 						      [else (syntax->datum t)])))
;;      (define (rename-types ls)
;;        (let loop ([ls ls] [collect '()])
;; 	 (if (null? ls) (reverse collect)
;; 	     (loop (cdr ls) (cons (rename-type (car ls)) collect)))))

;;      (define (value->c x)
;;        (let ([type (syntax->datum (cadr x))] [name (syntax->datum (car x))])
;; 	 (let ([t (find-ffi-type type)])
;; 	   (if t ((ffi-type->c t) name)
;; 	       name))))
      
;;      (syntax-case x ()
;;        ; WITH NAME+TYPE ARGUMENTS , this is nice because you can catch the argument name if some error happens
;;        ; In any case it is handy to have the argument names also in the scheme declarations for quick reference.
;;        ; We could also ignore them in expansion time
;;        [(_ name ((arg-name arg-type) ...) ret)
;; 	(with-syntax ([args/types #'((arg-name arg-type) ...)]
;; 		      [types-list #'(arg-type ...)]
;; 		      [renamed-types (rename-types #'(arg-type ...))]
;; 		      [renamed-ret (rename-type #'ret)]
;; 		      [name/string (symbol->string (syntax->datum #'name))])
;; 		     (with-syntax ([(values ...) 
;; 				    (map (lambda (x)
;; 					   (let ([ft (datum->syntax #'x (value->c x )) ])
;; 					     ft))
;; 					     #'args/types)])
;; 				  #'(define (name arg-name ...)
				      
;; 				      ((foreign-procedure name/string renamed-types renamed-ret) 
;; 				       values ...))))])))
;;        ; WITH ONLY ARGUMENT TYPES
;;        [(_ name (args ...) ret)
;; 	#'(define name
;; 	    (foreign-procedure (symbol->string 'name) (args ...) ret))])))

 (define-syntax define-function
   (lambda (x)
     (syntax-case x ()
       [(_ name ((arg-name arg-type) ...) ret)
	#'(define name 
	    (lambda (arg-name ...)
	      (foreign-procedure (symbol->string name) (arg-type ...) ret)))]
       ;; WITH ONLY ARGUMENT TYPES
       [(_ name (args ...) ret)
	#'(define name
	    (foreign-procedure (symbol->string 'name) (args ...) ret))])))

(define-syntax define-function*
  (lambda (x)
    (define (rename-scheme->c type)
      type)
    (define (convert-scheme->c name type)
      name)
    (syntax-case x ()
      [(_ name ((arg-name arg-type) ...) ret-type) 
       (with-syntax ([name/string (symbol->string (syntax->datum #'name))]
		     [(renamed-type ...) (map rename-scheme->c #'(arg-type ...))]
		     [renamed-ret #'ret-type]
		     [((arg-name arg-convert) ...) (map (lambda (n t) 
							  (list n (convert-scheme->c n t))) 
							#'(arg-name ...) #'(arg-type ...))])
		    #`(begin
		       (define (name arg-name ...) 
			 (let ([p (foreign-procedure name/string (renamed-type ...) renamed-ret)]
			       [arg-name arg-convert] ...)
			   (p arg-name ...)))))])))

;(sc-expand '(define-function memcpy ((dest void*) (from void*) (n int)) void*))

;DEFINE FLAGS:
;USAGE: (define-flags flags-name (name value) ...)
; name will be escaped
; value will be evaluated
; the following functions will be defined:
; <flags-name>-flags  -> record describing the flags
; <flags-name>      -> takes a list of flags and returns a number that correspond 
;                       to the bitwise or of the corresponding values
; <flags-name>-ref  -> takes a number as argument and returns the flag name
; <flags-name>-decode -> takes a number and returns a list of flags that match to create that value
; you can use also (flags-alist <flags-name>-flags) to get the alist of flags
; and (flags-name <flags-name>-flags) to get the name

;EXAMPLE: (define-flag colors (red 1) (blue 2) (green 4))
;> color-flags -> #[#{flags ew79exa0q5qi23j9k1faa8-51} color ((red . 1) (blue . 2) (green . 4))]
;> (color 'blue) -> 2
;> (color 'red 'blue) -> 3
;> (color 'black) -> Exception in color: symbol not found with irritant (black)
;> (color-ref 1) -> red
;> (color-ref 5) -> #f
;> (color-decode 3) -> (red blue)
;> (color-decode 16) -> ()
;> (color-decode 6) -> (blue green) !!! ATTENTION
;> (flags-alist color-flags) -> ((red . 1) (blue . 2) (green . 4))
;> (flags-name color-flags) -> color

;; TODO, what to do for value 0?

 (define-syntax define-flags
   (lambda (x)
     (define gen-id
       (lambda (template-id . args)
	 (datum->syntax
	  template-id
	  (string->symbol
	   (apply
	    string-append
	    (map (lambda (x)
		   (if (string? x) x (symbol->string (syntax->datum x))))
		 args))))))
     (syntax-case x ()
       [(_ name (k  v) ...)
	(with-syntax ([base-name (gen-id #'name "" #'name)]
		      [flags-name (gen-id #'name #'name "-flags")]
		      [ref-name (gen-id #'name #'name "-ref")]
		      [decode-name (gen-id #'name #'name "-decode")])
		     #'(begin
			 (define flags-name (make-flags 'name (list (cons 'k v) ...)))
			 (define base-name (flags-indexer flags-name))
			 (define ref-name (flags-ref-maker flags-name))
			 (define decode-name (flags-decode-maker flags-name))
			 (indirect-export base-name flags-name ref-name decode-name flags-indexer flags-ref-maker flags-decode-maker)))])))

 (define-record flags (name alist))
 
 (define (flags-indexer  flags)
   (lambda (name . more-names)
     (let ([names (append (list name) more-names)])
       (let loop ([f names] [result 0])
	 (if (null? f) result
	   (let ([r (assq (car f) (flags-alist flags))])
	     ;(printf "r: ~d flags: ~d f: ~d\n" r flags f)
	     (if (not r) (assertion-violation (flags-name flags) "symbol not found" f)
		 (loop (cdr f) (logor result (cdr r))))))))))

 (define (flags-ref-maker flags)
   (lambda (index)
     (let ([p (find (lambda (x) (equal? index (cdr x))) (flags-alist flags))])
       (if p (car p) p))))

;; FIXME: WHAT TO DO IF VALUES OVERLAP?
;; AT THE MOMENT RESULT MAYBE NOT WHAT EXPECTED
 (define (flags-decode-maker flags)
   (lambda (mask)
     (if (not (number? mask)) (assertion-violation (flags-name flags) "decode: mask must be an integer" mask))
     (let loop ([l (flags-alist flags)] [result '()])
       (if (null? l) result
	   (let ([item (car l)])
	     (if (zero? (logand (cdr item) mask))
		 (loop (cdr l) result)
		 (loop (cdr l) (append result (list (car item))))))))))
 
 ); library ffi-utils
