
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
          (srfi s13 strings)
	  (srfi private include))
   (include/resolve ("sxml") "utils.ss")
   (include/resolve ("sxml") "SXML-tree-trans.scm"))
		
