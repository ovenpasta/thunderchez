
(library (sxml match)
  (export sxml-match sxml-match-let sxml-match-let*)
  (import (chezscheme)
	  (srfi private include))
  (include/resolve () "sxml/sxml-match.ss")

  (import sxml-matcher))
