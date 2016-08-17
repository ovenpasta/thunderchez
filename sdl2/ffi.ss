	
 (define-syntax define-ftype-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type) 
	#'(define (name) 
	    (sdl-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))])))

 (define-syntax define-sdl-func
   (lambda (x)
     (define (anti-camel x)
       (let* ([x (string-replace x #\_ #\-)]
	      [len (string-length x)]
	      [s (list->string
		  (reverse
		   (fold (lambda (i acc) 
			   (let ([a (string-ref x i)] 
				 [b (if (< (+ 1 i) len) (string-ref x (+ 1 i)) #f)]
				 [c (if (> i 0) (string-ref x (- i 1)) #f)])
			     (if (and (char-upper-case? a) 
				      b (not (char-upper-case? b)) c (not (char-upper-case? c)))
				 (cons (char-downcase a) (if (and c (char=? c #\-)) acc (cons #\- acc)))
				 (cons (char-downcase a) acc)))) '() (iota len))))])
	 
	 s))
     
     (define (rename-scheme->c type)
       (cond [(case (syntax->datum type)
		[(unknown) 'unknown]
		[else #f])
	      => (lambda (t)
		   (datum->syntax type t))]
	     [else type]))

     (define (convert-scheme->c function-name name type)
       name)

     (define (datum->string x)
       (symbol->string (syntax->datum x)))

     (define (string->datum t x)
       (datum->syntax t (string->symbol x)))

     (syntax-case x ()
       [(_ ret-type name ((arg-name arg-type) ...) c-name) 
	(with-syntax (;[name/string (datum->string #'name)]
		      ;[name (string->datum #'name (anti-camel (datum->string #'name)))]
		      [(renamed-type ...) (map rename-scheme->c #'(arg-type ...))]
		      [renamed-ret (rename-scheme->c #'ret-type)]
		      [function-ftype (datum->syntax #'name (string->symbol (string-append (symbol->string (syntax->datum #'name)) "-ft")))]
		      [((arg-name arg-convert) ...) (map (lambda (n t) 
							   (list n (convert-scheme->c #'name n t))) 
							 #'(arg-name ...) #'(arg-type ...))])
		     #`(begin
			 (define (name arg-name ...) 
			   (define-ftype function-ftype (function (renamed-type ...) renamed-ret))
			   (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)]
				  [function       (ftype-ref function-ftype () function-fptr)]
				  [arg-name arg-convert] ...)
			     (let ([result (function arg-name ...)])
			       #,(case (syntax->datum #'ret-type)
				   [(int%)             #'(if (< result 0) (raise (make-sdl2-condition (sdl-get-error result))))]
				   [((* sdl-texture-t)
				     (* sdl-surface-t)
				     (* sdl-cursor-t)
				     (* sdl-pixel-format-t)
				     (* sdl-palette-t)
				     (* sdl-rw-ops-t)
				     (* sdl-mutex-t)
				     (* sdl-window-t)
				     (* sdl-sem-t)
				     (* sdl-cond-t)
				     (* sdl-renderer-t))  #'(sdl-guard-pointer result)]
				   [else #'result]))))))])))
     
 (define-syntax new-struct
   (lambda (x)
     (syntax-case x ()
       [(_ ftype-name (field value) ... )
	#'(let ([object (make-ftype-pointer 
			 ftype-name
			 (foreign-alloc (ftype-sizeof ftype-name)))])
	    (ftype-set! ftype-name (field) object value) ...
	    (sdl-guard-pointer object))])))


;; This is useful if the c function returns values by reference (pointers)
;; the macro automatically allocates the variables and references the values after the call.
;;
(define-syntax sdl-let-ref-call
  (lambda (x)
    (syntax-case x ()
      [(k func (param ...) result body ...) 
       (with-syntax ([((var val) ...) (map (lambda (p)
					     (let ([p* (syntax->datum p)])
					       (if (pair? p*)
						   (list (datum->syntax #'k (car p*)) 
							 #`(sdl-guard-pointer 
							    (make-ftype-pointer 
							     #,(datum->syntax #'k (cadr p*))
							     (foreign-alloc 
							      (ftype-sizeof #,(datum->syntax #'k (cadr p*)))))))
						   (list p p)))) #'(param ...))])
		    (with-syntax
		     ([(val2 ...) (map (lambda (p v)
					     (let ([p* (syntax->datum p)])
					       (if (pair? p*)
						     (if (memq '& p*)
							 #`(ftype-&ref
							    #,(datum->syntax #'k (cadr p*))
							    ()
							    #,v)
							 #`(ftype-ref 
							    #,(datum->syntax #'k (cadr p*))
							    ()
							    #,v))
						   p))) #'(param ...) #'(var ...) )])
		     #'(let ([var val] ...)
			 (let ([result (func var ...)])
			   (let ((var val2) ...)
			     body ...)))))])))
