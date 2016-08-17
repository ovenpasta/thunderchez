;;; lalr-test.ss - An example file showing how the lalr parser can be used.
;;;
;;; An example using the lalr parser.  This file defines the function
;;; eval-string, which takes a string representing a simple arithmetic
;;; expression and returns its value.  E.g.
;;;
;;; (eval-string " 45 + 76 * 2 ") ==> 197
;;;
;;; To produce an expression defining the parse table which you could compile, 
;;; change the backquote to a quote in the definition of expr-grammar,
;;; and evaluate
;;;
;;; `(define table ,(list 'quasiquote (lalr-table expr-grammar expr-terminals #f)))
;;;
;;; Be sure to include any procedures referenced in expr-grammar (in this
;;; example, binary-apply and identity)

(define (binary-apply expr1 op expr2) (op expr1 expr2))
(define (identity expr) expr)

(define expr-grammar
  `((expr --> expr expr-op term ,binary-apply)    ;;; change ` to '
    (expr --> term ,identity)                     ;;; if you want to generate
    (term --> term term-op term0 ,binary-apply)   ;;; a Scheme program table
    (term --> term0 ,identity)
    (term0 --> lparen expr rparen ,(lambda (lp expr rp) expr))
    (term0 --> number ,identity)
    (number --> number digit ,(lambda (n d) (+ (* 10 n) d)))
    (number --> digit ,identity)))

(define expr-terminals '(expr-op term-op lparen rparen digit))

(define table (lalr-table expr-grammar expr-terminals #f))

(define (eval-string string)
  (let ((pos 0))
    (define (lexical-analyser)
      (if (< pos (string-length string))
        (let ((char (string-ref string pos)))
          (set! pos (+ pos 1))
          (if (char=? char #\ )
            (lexical-analyser)
            (case char
              ((#\+) `(expr-op . ,+))
              ((#\-) `(expr-op . ,-))
              ((#\*) `(term-op . ,*))
              ((#\/) `(term-op . ,/))
              ((#\() '(lparen . #f))
              ((#\)) '(rparen . #f))
              ((#\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)
               `(digit . ,(- (char->integer char) (char->integer #\0))))
              (else (parse-error)))))))
    (define (parse-error)
      (display "Error somewhere in ")
      (write (substring string 0 pos))
      (newline))
    (lalr-parser table lexical-analyser parse-error)))
