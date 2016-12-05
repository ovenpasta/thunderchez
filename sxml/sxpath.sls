
(library (sxml sxpath)
  (export nodeset?
          node-typeof?
          node-eq?
          node-equal?
          node-pos
          take-until
          take-after
          map-union
          node-reverse
          node-trace
          select-kids
          node-self
          node-join
          node-reduce
          node-or
          node-closure
          node-parent
          sxpath)
  (import (except (scheme)
                  string-copy string-for-each string->list string-upcase
                  string-downcase string-titlecase string-hash string-copy! string-fill!
                  fold-right error filter)
          (prefix (only (scheme) error) scheme:)
          (srfi s13 strings))
  
  (include "utils.ss")
  (include "sxpath-impl.ss")
  
  )
