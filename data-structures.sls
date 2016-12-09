
;; CHICKEN data-structures module

#!r6rs
(library (data-structures)
	 
	 (export
	  identity conjoin disjoin constantly flip complement
	  compose o list-of? each any? tail? intersperse butlast
	  flatten chop join compress alist-update! alist-update
	  alist-ref rassoc reverse-string-append ->string conc
	  define-alias
	  string-intersperse string-translate* string-chop
	  sorted?
	  ;merge merge! sort! sort topological-sort
	  binary-search
	  )
	 (import (scheme)
		 (srfi private include))	

	 (include/resolve () "data-structures.scm"))
	  
