;;;; fmt-gauche.scm -- Gauche fmt extension
;;
;; Copyright (c) 2006-2011 Alex Shinn.  All rights reserved.
;; BSD-style license: http://synthcode.com/license.txt

(define-module text.fmt
  (use srfi-1)
  (use srfi-6)
  (use srfi-13)
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
   fmt-columns columnar tabular line-numbers
   ))
(select-module text.fmt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SRFI-69 compatible hashtables

(define (make-eq?-table)
  (make-hash-table 'eq?))
(define hash-table-ref/default hash-table-get)
(define hash-table-set! hash-table-put!)
(define (hash-table-walk tab proc) (hash-table-for-each tab proc))

(define (mantissa+exponent num)
  (let ((vec (decode-float num)))
    (list (vector-ref vec 0) (vector-ref vec 1))))

