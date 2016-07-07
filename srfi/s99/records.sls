(library (srfi s99 records)
  (export
   make-rtd rtd? rtd-constructor rtd-predicate rtd-accessor rtd-mutator
   record? record-rtd rtd-name rtd-parent
   rtd-field-names rtd-all-field-names rtd-field-mutable?
   define-record-type)
  (import (srfi s99 records procedural)
          (srfi s99 records inspection)
          (srfi s99 records syntactic)))
