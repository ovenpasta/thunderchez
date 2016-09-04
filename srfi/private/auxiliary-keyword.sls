
#!r6rs
(library (srfi private auxiliary-keyword)
	 (export define-auxiliary-keyword define-auxiliary-keywords)
	 (import (scheme))

	 (define-syntax define-auxiliary-keyword
	   (syntax-rules ()
	     [(_ name)
	      (define-syntax name 
		(lambda (x)
		  (syntax-violation 'name "misplaced use of auxiliary keyword" x)))]))
	 
	 (define-syntax define-auxiliary-keywords
	   (syntax-rules ()
	     [(_ name* ...)
	      (begin (define-auxiliary-keyword name*) ...)])))
	 
