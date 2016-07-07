;;;; fmt-js.scm -- javascript formatting utilities
;;
;; Copyright (c) 2011-2012 Alex Shinn.  All rights reserved.
;; BSD-style license: http://synthcode.com/license.txt

#!r6rs
(library 
 (fmt js)
 (export
  js-expr js-function js-var js-comment js-array js-object js=== js>>>)
 
 (import (chezscheme)
	 (fmt fmt) (fmt c))
 
 (include "fmt-js.scm")
 
 )
