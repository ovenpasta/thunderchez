
(library (sxml)
  (export make-xml-token
          xml-token?
          xml-token-kind
          xml-token-head

          ssax:skip-S
          ssax:ncname-starting-char?
          ssax:read-NCName
          ssax:read-QName
          ssax:Prefix-XML

          name-compare

          ssax:largest-unres-name
          ssax:read-markup-token
          ssax:skip-pi
          ssax:read-pi-body-as-string
          ssax:skip-internal-dtd
          ssax:read-cdata-body
          ssax:read-char-ref
          ssax:predefined-parsed-entities
          ssax:handle-parsed-entity

          make-empty-attlist
          attlist-add
          attlist-null?
          attlist-remove-top
          attlist->alist
          attlist-fold
          
          ssax:read-attributes
          ssax:resolve-name
          ssax:uri-string->symbol
          ssax:complete-start-tag
          ssax:read-external-id
          ssax:scan-Misc
          ssax:read-char-data
          ssax:assert-token
          ssax:make-parser
          ssax:make-pi-parser
          ssax:make-elem-parser
          ssax:make-parser/positional-args
          ssax:define-labeled-arg-macro
          ssax:reverse-collect-str
          ssax:reverse-collect-str-drop-ws
          ssax:xml->sxml

          nodeset?
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
          (srfi s13 strings)
          (sxml ssax)
          (sxml sxpath)))
