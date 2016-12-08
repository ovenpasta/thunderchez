;;;; fmt.scm -- extensible formatting library
;;
;; Copyright (c) 2006-2009 Alex Shinn.  All rights reserved.
;; BSD-style license: http://synthcode.com/license.txt

#!r6rs
(library (fmt fmt)
	 (export
	  new-fmt-state
	  fmt fmt-start fmt-if fmt-capture fmt-let fmt-bind fmt-null
	  fmt-ref fmt-set! fmt-add-properties! fmt-set-property!
	  fmt-col fmt-set-col! fmt-row fmt-set-row!
	  fmt-radix fmt-set-radix! fmt-precision fmt-set-precision!
	  fmt-properties fmt-set-properties! fmt-width fmt-set-width!
	  fmt-writer fmt-set-writer! fmt-port fmt-set-port!
	  fmt-decimal-sep fmt-set-decimal-sep!
	  fmt-file fmt-try-fit cat apply-cat nl fl nl-str
	  fmt-join fmt-join/last fmt-join/dot
	  fmt-join/prefix fmt-join/suffix fmt-join/range
	  pad pad/right pad/left pad/both trim trim/left trim/both trim/length
	  fit fit/left fit/both tab-to space-to wrt wrt/unshared dsp
	  pretty pretty/unshared slashified maybe-slashified
	  num num/si num/fit num/comma radix fix decimal-align ellipses
	  upcase downcase titlecase pad-char comma-char decimal-char
	  with-width wrap-lines fold-lines justify
	  make-string-fmt-transformer
	  make-space make-nl-space display-to-string write-to-string
	  fmt-columns columnar tabular line-numbers)
	 (import (chezscheme) 
		 (only (srfi s13 strings) string-count string-index
		       string-index-right 
		       string-concatenate string-concatenate-reverse  
		       substring/shared reverse-list->string string-tokenize
		       string-suffix? string-prefix?)
		 (srfi private let-opt)
		 (srfi private include)
		 (scheme)
		 (only (srfi s1 lists) fold length+))

	 (include/resolve ("fmt") "hash-compat.scm")
	 (include/resolve ("fmt") "mantissa.scm")
	 (include/resolve ("fmt") "read-line.scm")
	 (include/resolve ("fmt") "string-ports.scm")
	 (include/resolve ("fmt") "fmt.scm")
	 (include/resolve ("fmt") "fmt-column.scm")
	 (include/resolve ("fmt") "fmt-pretty.scm")
	 )
