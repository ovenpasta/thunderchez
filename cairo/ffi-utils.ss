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

 (define-syntax define-cairo-func
   (lambda (x)
     (define (string-replace s x y)
       (list->string  
	(let ([cmp (if (list? x) memq eq?)])
	  (map (lambda (z) (if (cmp z x) y z)) (string->list s)))))
     
     (define (rename-scheme->c type)
       (cond 
	[(case (syntax->datum type)
	   (const-char* 'string)
	   (else #f)) 
	 =>
	 (lambda (x) (datum->syntax type x))]
	[else type]))

     (define convert-scheme->c 
       (lambda (function-name name type)
	 (import (only (srfi s13 strings) 
		       string-delete string-suffix? string-prefix?))
	 (define (remove-* x)
	   x)
	 (let ([t* (syntax->datum type)])
	   (cond [(equal? t* '(* double))
		  #`(if (vector? #,name)
			(double-array-create-from-vector #,name)
			#,name )]
		 [(eq? t* 'double) #`(real->flonum #,name)]
		 [else name]))))

     (define (datum->string x)
       (symbol->string (syntax->datum x)))

     (define (string->datum t x)
       (datum->syntax t (string->symbol x)))

     (syntax-case x ()
       [(_ ret-type name ((arg-name arg-type) ...) c-name) 
	(with-syntax
	 ([(renamed-type ...) (map rename-scheme->c #'(arg-type ...))]
	  [renamed-ret (rename-scheme->c #'ret-type)]
	  [function-ftype (datum->syntax #'name (string->symbol (string-append (symbol->string (syntax->datum #'name)) "-ft")))]
	  [((arg-name arg-convert) ...)
	   (map (lambda (n t) 
		  (list n (convert-scheme->c #'name n t))) 
		#'(arg-name ...) #'(arg-type ...))])
	 (begin
					; (indirect-export cairo-guard-pointer)
	   #`(begin
	       (define (name arg-name ...) 
		 (define-ftype function-ftype (function (renamed-type ...) renamed-ret))
		 (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)]
			[function       (ftype-ref function-ftype () function-fptr)]
			[arg-name arg-convert] ...)
		   ;(printf "calling ffi ~d ~n" c-name)
		   (let ([result (function arg-name ...)])
		     
		     #,(case (syntax->datum #'ret-type)
			 [(cairo-status-t)  #'(cairo-status-enum-ref result)]
			 [((* cairo-t)
			   (* cairo-surface-t)
			   (* cairo-pattern-t)
			   (* cairo-region-t)
			   (* cairo-rectangle-list-t)
			   (* cairo-font-options-t)
			   (* cairo-font-face-t)
			   (* cairo-scaled-font-t)
			   (* cairo-path-t)
			   (* cairo-device-t)) 
			  #'(cairo-guard-pointer result)]
			 [else #'result])))))))])))

 (define-syntax define-ftype-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type) 
	(begin 
	 ; (indirect-export cairo-guard-pointer)
	  #`(begin
	      (define (name) 
		(cairo-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))
	      ))])))

 (define-syntax define-ftype-array-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type element-type) 
	(begin
	 ; (indirect-export cairo-guard-pointer)
	#'(define (name size) 
	    (cairo-guard-pointer (make-ftype-pointer type (foreign-alloc (* (ftype-sizeof element-type) size))))))])))

;;; EXPERIMENTAL CONVENIENT SYNTAX:

 (define-syntax with-cairo
   (lambda (x)
     (define valid-functions 
       '(get-user-data set-user-data save restore
			     push-group push-group-with-content pop-group
			     pop-group-to-source set-operator set-source
			     set-source-rgb set-source-rgba set-source-surface
			     set-tolerance set-antialias set-fill-rule
			     set-line-width set-line-cap set-line-join
			     set-dash set-miter-limit translate scale
			     rotate transform set-matrix identity-matrix
			     user-to-device user-to-device-distance
			     device-to-user device-to-user-distance new-path
			     move-to new-sub-path line-to curve-to
			     arc arc-negative rel-move-to
			     rel-line-to rel-curve-to rectangle
			     close-path path-extents paint
			     paint-with-alpha mask mask-surface stroke
			     stroke-preserve fill fill-preserve copy-page
			     show-page in-stroke in-fill in-clip
			     stroke-extents fill-extents reset-clip clip
			     clip-preserve clip-extents copy-clip-rectangle-list
			     get-operator get-source get-tolerance
			     get-antialias has-current-point get-current-point
			     get-fill-rule get-line-width get-line-cap
			     get-line-join get-miter-limit get-dash-count
			     get-dash get-matrix get-target
			     get-group-target copy-path copy-path-flat
			     append-path status select-font-face
			     set-font-size set-font-matrix get-font-matrix
			     set-font-options get-font-options set-font-face
			     get-font-face set-scaled-font get-scaled-font
			     show-text show-glyphs show-text-glyphs
			     text-path glyph-path text-extents
			     glyph-extents font-extents
			     set-source-color))
     (define (rename-cairo name)
       (string->symbol (string-append "cairo-" (symbol->string name))))
     (syntax-case x ()
       [(_ context application ...)
	(with-syntax ([(forms ...) 
		       (map (lambda (y) 
			      (let ([y* (syntax->datum y)])
				(if (pair? y*)
				    (let* ([f* (car y*)])
				      (if (memq f* valid-functions)
					  (syntax-case y ()
					    [(f param ...) #`(#,(datum->syntax #'f (rename-cairo (syntax->datum #'f))) 
							      context param ...)])
					  y))
				    y)))
			    #'(application ...))])
		     #'(begin forms ...))])))
