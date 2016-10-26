;; Copyright (c) 2009 Derick Eddington.  All rights reserved.
;; Licensed under an MIT-style license.  My license is in the file
;; named LICENSE from the original collection this file is distributed
;; with.  If this file is redistributed with some other collection, my
;; license must also be included.

#!r6rs
(library (srfi s26 cut)
  (export cut cute <> <...>)
  (import (chezscheme) 
	  (srfi private auxiliary-keyword)
	  (srfi private include))

  (include/resolve ("srfi" "s26") "cut-impl.scm")  
  (define-auxiliary-keywords <> <...>)
)
