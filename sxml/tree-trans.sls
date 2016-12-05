(library (sxml tree-trans)
  (export
   SRV:send-reply
   pre-post-order
   post-order
   foldts
   replace-range)
   (import (except (scheme)
                  string-copy string-for-each string->list string-upcase
                  string-downcase string-titlecase string-hash string-copy! string-fill!
                  fold-right error filter)
          (prefix (only (scheme) error) scheme:)
          (srfi s13 strings))
   (include "utils.ss")
   (include "SXML-tree-trans.scm"))
		
