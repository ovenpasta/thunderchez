;	   An advanced example of SXML-to-HTML transformations
;
; The problem
; We are given a source document in SXML. The document has the
; HTML-like 'head' and the 'body'. The latter is made of sections,
; each of which is a sequence of paragraphs or (sub)sections. The
; sub-sections are in turn are made of paragraphs or other (subsub...)
; sections, etc.  See the definition of 'doc' below for a sample
; document.
;
; We need to number the sections and (sub...)sections and output
; an HTML document of the following structure:
;
;    1. First Section
;       ...
;    2. Second Section
;    2.1. First sub-section
;    2.2. Another sub-section
;   ...section contents...
;
; We should use the appropriate HTML tags (H2, H3, ...) to set off the
; title of the sections and subsections.
; In addition, we have to generate a hierarchical table of contents
; and place it at the beginning.
;
; This example is due to Jim Bender, who used a similar transformation for
; compiling an XML Schema into ASN.1 specifications.
;
; This file presents a solution, which relies on SXML transformations
; by a traversal combinator pre-post-order. The latter is defined in a
; file ../lib/SXML-tree-trans.scm
;
; The present solution is not the only one possible, nor is it the
; most optimal. The most efficient solution should visit each node of
; the SXML tree exactly once and should not create any closures, let
; alone trees of closures. The pre-post-order combinator -- the tree
; fold in general -- cannot express this single traversal, but an
; accumulating tree fold 'foldts' (also defined in
; ../lib/SXML-tree-trans.scm) can.
;
; The approach taken in this file is not meant to be the most
; efficient.  Rather, it is aimed to be illustrative of various SXSLT
; facilities and idioms.  In particular, we demonstrate: higher-order
; tags, pre-order and post-order transformations, re-writing of SXML
; elements in regular and special ways, context-sensitive applications
; of re-writing rules. Finally, we illustrate SXSLT reflection: an
; ability of a rule to query its own stylesheet and to re-apply the
; stylesheet with "modifications".
;
; All SXSLT transformations in this file are purely functional and
; declarative. The entire code has no mutations. The code maintains
; the full referential transparency.
;
; $Id: sxslt-advanced.scm,v 1.3 2003/08/07 19:55:31 oleg Exp oleg $
;
; IMPORT
; The following is a Bigloo-specific module declaration.
; Other Scheme systems have something similar.
;
; (module sxslt-advanced
; 	(include "myenv-bigloo.scm")
; 	(include "srfi-13-local.scm") ; or import from SRFI-13 if available
; 	(include "util.scm")
; 	(include "SXML-tree-trans.scm")
; 	(include "SXML-to-HTML.scm")
; 	(include "SXML-to-HTML-ext.scm")
; 	)
; See the Makefile for the rules to run this example on Bigloo, SCM
; and other systems

; A sample source document, marked up in SXML.
; Note the ampersand character in the text of the first Section
; paragraph. We should also point out the space character in the name
; of the document file (in the href attribute of the link). These
; characters must be properly escaped in the target HTML document.

(define doc
  '(html (head (title "Document"))
   (body
     (section "First Section"
       (p "This is the intro section.")
       (p "Paragraph &c"))
     (section "Second Section"
       (section "A sub-section"
	 (p "This is section 2.1."
	   (br)
	   (a (@ (href "another doc.html"))
	     "link")))
       (section "Another sub-section"
	 (p "This is section 2.2.")))
     (section "Last major section"
       (p "This is the third section")))))


; Auxiliary procedures

; (a b c ...) => (1 2 3 ...)
(define (list-numbering lst)
  (let loop ((i 1) (lst lst))
    (if (null? lst) '()
      (cons i (loop (+ 1 i) (cdr lst))))))

; The ordinary filter combinator
(define (filter pred lst)
  (cond
    ((null? lst) lst)
    ((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
    (else (filter pred (cdr lst)))))

; (3 2 1) => "1.2.3"
(define (numbers->string lst)
  (apply string-append
    (list-intersperse 
      (map number->string (reverse lst)) ".")))



; Recursive numbering of sections: given a list of 'sections', return
; the list of '*sections':
;
;   ((section title (section title el ...) ...) 
;    (section title (section title el ...) ...) ...)
; =>
;   ((*section (1) title (*section (1 1) title el ...) el ...)
;    (*section (2) title (*section (1 2) title el ...) el ...) ...)
;
; The numbering (the first element of a *section) is a list of section
; numbers in reverse order: the numeric label of the current section
; followed by the labels of its ancestors.
;
; A 'section' of the source document may contain either (sub)sections,
; or other SXML nodes such as strings or paragraphs. The numbering
; transformation should not affect the latter nodes.
;
; The function 'number-sections' illustrates a typical XSLT-like
; processing. We transform an SXML tree by invoking the traversal
; combinator pre-post-order and passing it the source tree and a
; stylesheet. In the code below, the stylesheet has only three
; rules. The *text* rule is the identity rule. It passes the character
; data from the source SXML tree to the result SXML tree as they are.
; The *default* rule is also an identity rule. A *preorder* label by
; the rule tells pre-post-order to return a non-'section' branch as it
; is, _without_ recursing into it.  A 'section' rule tells what to do
; when we encounter a section: we make a (*section ...) element out of
; the title and the _numbered_ children of the section in question.
;
; We should point out that the traversal combinator pre-post-order is
; an ordinary Scheme function, and can be _mapped_. The stylesheet
; handlers are likewise ordinary Scheme functions, which can invoke
; other Scheme functions, including pre-post-order itself.

(define (number-sections ancestor-numbers sections)
  (map (lambda (el i) 
	 (pre-post-order el
	   ; the stylesheet
	   `((section *preorder*
	       . ,(lambda (tag title . elems)
		    (let ((my-number (cons i ancestor-numbers)))
		    (cons* '*section my-number title
		      (number-sections my-number elems)))))
	      (*default* *preorder* . ,(lambda x x))
	      (*text* . ,(lambda (tag str) str)))))
    sections (list-numbering sections)))



; Building a hierarchical table of contents
;
; It is more lucid to build the TOC in a separate pass, by traversing
; the previously numbered sections. In this pass, we turn '*section'
; elements into TOC entries, and rewrite everything else to nothing.
;
; The function make-toc-entries takes the output of the procedure
; 'number-sections' and yields the list of TOC entries. To be more
; precise, we do the following transformation:
;
;   ((*section (1) title1 non-section-el ...)
;    (*section (2) title2 (*section (1 2) title21 el ...) el ...) ...)
; =>
;   ((li "1. " title1)
;    (li "2. " title2 (ul (li "2.1. " title21) ...)) ...)
;
; Again, we execute the pre-post-order transformation with a
; three-rule stylesheet.  As before, the character data are not
; affected: see the *text* rule.  The *default* rule is different now:
; it transforms a non-'section' branch to nothing at all. To be more
; precise, an SXML element other than *section is turned into '(),
; which will be filtered out later. As a matter of fact, we do not
; have to filter out '() because they will be disregarded by the
; SRV:send-reply function at the very end. In any case, we can regard
; the empty list as being nothing.
;
; The stylesheet almost literally looks like the above re-writing
; example.  We should note that the stylesheet rules are applied to
; all elements of the tree, recursively. We indeed process the
; arbitrary nesting of *sections without much ado. We do not need to
; write something like <apply-templates/>.  Unlike XSLT, but like tree
; fold, the pre-post-order combinator traverses the tree in post-order
; by default. That is, the handler for the *section rule below (lambda
; (tag numbering title . elems) ...) receives, as 'elems', the list of
; the _transformed_ children of the *section in question. To be more
; precise, 'elems' will be the list of TOC elements for internal
; subsections -- or the list of nothing.
;
; We use an auxiliary function 'numbers->string' to convert the list
; of numerical labels such as (1 2 3) into a string label "3.2.1"

(define (make-toc-entries numbered-sections)
  (pre-post-order numbered-sections
    ; the stylesheet
    `((*section
	. ,(lambda (tag numbering title . elems)
	     (let ((elems (filter pair? elems)))
	       `(li ,(numbers->string numbering) ". " ,title
		  ,(and (pair? elems) (list 'ul elems))))))
       (*default* . ,(lambda _ '()))
       (*text* . ,(lambda (tag str) str)))))



; The main transformation stylesheet: from the source SXML document
; to the tree of HTML fragments.
;
; Note [1]
; The general SXML-to-HTML conversion is taken care by the *default*
; and *text* rules in 'universal-conversion-rules', which are defined
; in SXML-to-HTML-ext.scm. xThe *text* rule checks text strings for
; dangerous characters such as angular brackets and the ampersand. The
; rule encodes these characters as the corresponding HTML entities.
; The *default* rule turns an SXML element into the appropriate HTML
; element. These two transformations will be uniformly applied to all
; nodes of the source SXML tree. We _only_ need to add rules for the
; SXML elements that have to be treated in a special way.
;
; Note [2]
; The 'body' of the document, a collection of sections, has to be
; processed specially.  First we recursively number the sections and
; replace them with *sections.  Frankly, there is no need to introduce
; the auxiliary element *section.  Doing so however seems to make the
; example clearer.  We pass the renumbered sections to
; make-toc-entries and get the list of TOC entries (as 'low-level'
; SXML elements).
;
; Note [3]
; We insert the TOC elements before the numbered sections, and
; re-apply main-ss. Actually, we re-apply a slightly "modified"
; stylesheet: the element 'body' no longer needs to be processed
; specially.  In the present example, this 'switching off' of a rule
; is a bit contrived.  We wanted to illustrate however the ability
; to re-apply a stylesheet with some dynamic 'modifications'.  XSLT
; can accomplish something similar, with the help of modes. SXSLT
; gives far simpler tools to dynamically 'modify' the effective
; ruleset.  There are, of course, no mutations. We merely re-invoke
; pre-post-order and pass it main-ss with the modified rules
; prepended.
;
; The 'overridden' rule for the 'body' element has the same handler as
; that of the *default* rule. To find the latter, we _query_ the
; stylesheet itself!  Indeed, the stylesheet is a simple data
; structure, an associative list, and can be manipulated as such. This
; example demonstrates reflexive abilities of SXSLT. A stylesheet can
; analyze itself.
;
; Note [4]
; On the re-application pass, the traversal combinator treats 'body'
; as any other element. The combinator processes its children first,
; and now notices *section elements. We transform a *section as
; follows:
;   (*section (1 2 3) "title321" elem ...)
; =>
;   ((h4 "3.2.1. " "title321") elem ...)
; and re-apply the main stylesheet. Our auxiliary function
; numbers->string helps us to convert the list of labels to a
; string. We use the length of the list (that is, the depth of the
; section in question) to choose the HTML tag for the section: h2, h3,
; h4, etc.
;
; We should point out that *section elements are processed twice, with
; two _different_ stylesheets. First we scan *sections and turn them
; into TOC entries. Later we turn the same *sections into HTML
; headers.
;
; The elements 'section' and 'body' of the source document act as
; higher-level SXML elements. They are recursively re-written into
; more primitive SXML elements until they are finally turned into HTML
; text fragments. Essentially, we compute the fixpoint of the
; re-writing stylesheet. We do not iterate on the whole document
; however, only on the branches that need iterating. The whole
; approach is rather similar to that of Scheme macros.  Scheme macros
; do not have '*default*' rules however. R5RS macros cannot transform
; in post-order and cannot explicitly re-invoke the macro-expander.

; Note [5]
; We have one more thing to take care of. The source document had an
; anchor element '(a (@ (href "another doc.html")) "link")' with the
; name of a local file in the 'href' attribute. In the output HTML
; document, that name will become a URL. File names may contain spaces
; -- but URLs may not. Therefore, we need to encode the space
; character. We should URL-encode the space character only in the
; context of the 'href' node, and nowhere else. The white space
; elsewhere in the document must remain the white space.  Hence we
; need a special rule for 'href', with its own handler for character
; data. This *text* handler is _local_: it acts only in scope of the
; 'href' node. The local text handler looks for the space character
; and URL-encodes it. We have just shown a context-sensitive
; application of re-writing rules. It still appears clear and
; intuitive.
;
; Note [6]
; Joerg-Cyril Hoehle observed that the handler for the 'body' can be
; written as a *macro*. The macro re-writes (body sections) into
; (*body toc numbered-sections), where the auxiliary SXML element *body
; expands into an HTML element 'body'. We need this extra indirection
; to avoid endless recursion. His submission follows (see his message
; on the SSAX-SXML mailing list on Aug 1, 2003).
;      (body *macro*
;        . ,(lambda (tag . elems)
;             (let ((numbered-sections
;                     (number-sections '() elems)))
;               (display numbered-sections)
;               (let*
;                 ((toc
;                    (make-toc-entries numbered-sections)))
;                 ; Now the body contain the TOC entries and the
;                 ; numbered sections. See Note [3] above
;                 `(*body (ul ,toc) ,numbered-sections))) ))
;      (*body
;        ; prevent endless recursion once TOC was generated
;        . ,(lambda (tag . elems) (entag 'body elems)))

(define main-ss 
  `(
     ; see Notes [2,6]
     (body *preorder*
       . ,(lambda (tag . elems)
	    (let ((numbered-sections
		    (number-sections '() elems)))
	      ;(pp numbered-sections)
	      (let*
		((toc
		   (make-toc-entries numbered-sections)))
		; re-apply the main-ss.
		; Now the body contain the TOC entries and the
		; numbered sections. See Note [3] above
		(pre-post-order
		  `(body (ul ,toc) ,numbered-sections)
		  ; now process 'body' without an exception
		  ; an example of a dynamic "amending" a stylesheet
		  (append
		    `((body . ,(cdr (assq '*default* main-ss))))
		       main-ss)))
	      )))
     ; see Note [4]
     (*section *preorder*
       . ,(lambda (tag numbering title . elems)
	    (let ((header-tag
		    (list-ref '(h1 h2 h3 h4 h5 h6)
		      (length numbering))))
	      (pre-post-order
		`((,header-tag ,(numbers->string numbering) ". " ,title)
		  ,@ elems)
		main-ss))))
     ; see Note [5]
     (href
       ((*text* . ,(lambda (tag str)
		     (if (string? str)
		       ((make-char-quotator '((#\space . "%20"))) str) str))))
       . ,(lambda (attr-key . value) (enattr attr-key value)))
     ; see Note [1]
     ,@universal-conversion-rules))



; The main function
; The following expression executes the transformation of 'doc' into
; a target SXML tree: a tree of HTML fragments. The expression then
; writes out that tree on the standard output. You may want to save
; the result in a file and load the file in a web browser.

(SRV:send-reply (pre-post-order doc main-ss))
