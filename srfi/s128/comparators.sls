(library (srfi s128 comparators)
  (export comparator? comparator-ordered? comparator-hashable?
          make-comparator
          make-pair-comparator make-list-comparator make-vector-comparator
          make-eq-comparator make-eqv-comparator make-equal-comparator
          boolean-hash char-hash char-ci-hash
          string-hash string-ci-hash symbol-hash number-hash
          make-default-comparator default-hash comparator-register-default!
          comparator-type-test-predicate comparator-equality-predicate
          comparator-ordering-predicate comparator-hash-function
          comparator-test-type comparator-check-type comparator-hash
          hash-bound hash-salt
          =? <? >? <=? >=?
          comparator-if<=>
          )
  (import (rename (except (chezscheme) make-hash-table define-record-type)
		  (error error-chez))
	  (only (srfi s9 records) define-record-type)
	  (only (srfi s69 basic-hash-tables) make-hash-table))

  (alias exact-integer? exact?)

  (define (error . x)
    (error-chez 'comparators (car x) (cdr x)))

  (include "128.body1.scm")
  (include "128.body2.scm")
)
