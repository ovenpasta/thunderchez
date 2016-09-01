
(define-syntax cast
  (syntax-rules ()
    [(_ type ptr)
     (make-ftype-pointer type (if (ftype-pointer? ptr) (ftype-pointer-address ptr)
				  ptr))]))

(define-syntax define-mdb-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type) 
	(begin 
	  #`(begin
	      (define (name) 
		(mdb-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))
	      ))])))
 (define-syntax define-mdb-array-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type element-type) 
	(begin
	  #'(define (name size) 
	      (mdb-guard-pointer (make-ftype-pointer type (foreign-alloc (* (ftype-sizeof element-type) size))))))])))

 (define-syntax define-lmdb-func
   (lambda (x)
     (syntax-case x ()
       [(_ ret-type name ((arg-name arg-type) ...) c-name) 
	(with-syntax 
	 ([function-ftype 
	   (datum->syntax #'name 
			  (string->symbol 
			   (string-append 
			    (symbol->string 
			     (syntax->datum #'name)) "-ft")))])
	 #`(begin
	     (define name (lambda (arg-name ...)
	       (define-ftype function-ftype (function (arg-type ...) ret-type))
	       (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)]
		      [function       (ftype-ref function-ftype () function-fptr)])
		 (let ([result (function arg-name ...)])
		   #,(case (datum #'ret-type)
		       [(#'int) #`(if (not (= result 0))
				    (raise ;(condition 
					    ;(make-error) 
					    ;(make-message-condition "returned error ~d: ~d") 
					    ;(make-irritants-condition result (mdb-strerror result))
					    (make-mdb-cond result (mdb-strerror result)))
					   
				    #,(case (datum #'name)
					[else #'result]))]
		       [else (printf "else ~d~n" (datum #'ret-type)) #'result])))))))])))
