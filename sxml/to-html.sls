(library (sxml to-html)
  (export
   SXML->HTML
   string->goodHTML
   entag
   enattr)
   (import (except (scheme)
                  string-copy string-for-each string->list string-upcase
                  string-downcase string-titlecase string-hash string-copy! string-fill!
                  fold-right error filter)
          (prefix (only (scheme) error) scheme:)
          (srfi s13 strings)
	  (sxml tree-trans))
   (include "utils.ss")
   (include "SXML-to-HTML.scm"))
		
