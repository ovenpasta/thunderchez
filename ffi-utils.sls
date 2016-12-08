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

#!r6rs

(library
 (ffi-utils)
 (export define-enumeration* define-function 
	 define-flags make-flags flags flags-name flags-alist flags-indexer flags-ref-maker flags-decode-maker
	 let-struct
	 char*->bytevector cast
	 )
 (import (chezscheme))

;; TODO: maybe we should support multiple structs?
;; and maybe also normal let entries? let-struct* also?

 (define-syntax let-struct
   (lambda (x)
     (syntax-case x ()
       [(_ object ftype-name (field ...) body ...)
	#'(let ([field (ftype-ref ftype-name (field) object)] ...)
	    body ...)])))

 ;; Uses make-enumeration to define an enum with the following:
 ;; function (name x) -> index
 ;; function (name-ref index) -> symbol
 ;; variable name-enum  -> #>enum-set>
 ;; name-t -> ftype int
 ;; usage: (define-enumeration* NAME (tag1 tag2 tag3 ...))

 (define-syntax define-enumeration*
   (lambda (x)
     (define gen-id
       (lambda (template-id . args)
	 (datum->syntax
	  template-id
	  (string->symbol
	   (apply string-append
		  (map (lambda (x)
			 (if (string? x) x (symbol->string (syntax->datum x))))
		       args))))))
     (syntax-case x ()
       [(_ name (l ...))
	(with-syntax ([base-name (gen-id #'name "" #'name)]
		      [enum-name (gen-id #'name #'name "-enum")]
		      [ref-name (gen-id #'name #'name "-ref")]
		      [name/t (gen-id #'name #'name "-t")])
		     (indirect-export base-name enum-name ref-name name/t)
		     #'(begin
			 (define enum-name (make-enumeration '(l ...)))
			 (define base-name
			   (lambda (x)
			     (let ([r ((enum-set-indexer enum-name) x)])
			       (if r r
				   (assertion-violation 'enum-name
							"symbol not found"
							x)))))
			 (define ref-name
			   (lambda (index)
			     (list-ref (enum-set->list enum-name) index)))
			 (define-ftype name/t int)))])))

 (define-syntax define-function
   (lambda (x)
     (syntax-case x ()
       [(_ name ((arg-name arg-type) ...) ret)
	#'(define name 
	    (lambda (arg-name ...)
	      (foreign-procedure (symbol->string name) (arg-type ...) ret)))]
       [(_ ret name ((arg-name arg-type) ...))
	#'(define name 
	    (lambda (arg-name ...)
	      (foreign-procedure (symbol->string name) (arg-type ...) ret)))]
       ;; WITH ONLY ARGUMENT TYPES
       [(_ name (args ...) ret)
	#'(define name
	    (foreign-procedure (symbol->string 'name) (args ...) ret))]
       [(_ ret name (args ...))
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
;> (color-decode 6) -> (blue green) !!! ATTENTION should raise exception?
;> (flags-alist color-flags) -> ((red . 1) (blue . 2) (green . 4))
;> (flags-name color-flags) -> color

;; TODO, what to do for value 0?

 (define-record flags (name alist))
 
 (define (flags-indexer  flags)
  (lambda names
    (let loop ([f names] [result 0])
      (if (null? f) result
	  (let ([r (assq (car f) (flags-alist flags))])
	    (if (not r) (assertion-violation (flags-name flags) "symbol not found" f)
		(loop (cdr f) (logor result (cdr r)))))))))

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
       [(ka name (k  v) ...)
	#'(ka name int (k v) ...)] 
       [(y name type (k  v) ...)
	(with-syntax ([base-name (gen-id #'y "" #'name)]
		      [flags-name (gen-id #'y #'name "-flags")]
		      [ref-name (gen-id #'y #'name "-ref")]
		      [decode-name (gen-id #'y #'name "-decode")]
		      [name-t (gen-id #'y #'name "-t")]
		      #;[(v1 ...) (map (lambda (v)  
					  (if (char? (datum v))
					       (datum->syntax #'v (char->integer (datum v)))
					      v))
				        #'(v ...) )])
		     
		     (indirect-export flags-indexer flags-ref-maker flags-decode-maker)
		     #`(begin 
		;	 (import (ffi-utils))
			 (define flags-name (make-flags 'name (list (cons 'k v) ...)))
			 (define base-name (flags-indexer flags-name))
			 (define ref-name (flags-ref-maker flags-name))
			 (define decode-name (flags-decode-maker flags-name))
			 (define-ftype name-t type)
			 ;(indirect-export base-name flags-name ref-name decode-name name-t )
			 ))])))



 (define (char*->bytevector fptr bytes)
   (define bb (make-bytevector bytes))
   (let f ([i 0])
     (if (< i  bytes)
	 (let ([c (ftype-ref char () fptr i)])
	   (bytevector-u8-set! bb i (char->integer c))
	   (f (fx+ i 1)))))
   bb)


 (define-syntax cast
   (syntax-rules ()
     [(_ ftype fptr)
      (make-ftype-pointer ftype
			  (ftype-pointer-address fptr))]))


 ); library ffi-utils
