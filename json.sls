;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

#!chezscheme
(library 
 (json)
 (export parse-json-str read-file let-json-object string->json json->string)
 (import (srfi s14 char-sets)
	 (scheme)
	 (only (data-structures) string-intersperse string-translate*))

 (include "lalr/associators.ss")
 (include "lalr/lalr.ss")

 (define (parse-json-str pos data escaping out)
   (cond
    [(>= pos (string-length data))
     (error 'parse-json-str "error unexpected end of string")]
    [(and (char=? (string-ref data pos) #\") (not escaping))
     (values (list->string (reverse out)) pos)]
    [else
     (let ([char (string-ref data pos)])
       (cond 
	[escaping
	 (let* ([special '((#\/ . #\/) (#\b . #\backspace) (#\n . #\newline) 
			   (#\r . #\return) (#\t . #\tab) (#\\ . #\\) (#\" . #\"))]
		[q (assq char special)])
	   (cond 
	    [q (parse-json-str (+ 1 pos) data #f (cons (cdr q) out))]
	    [(char=? char #\\) (parse-json-str (+ 1 pos) data #f (cons #\\ out))]
	    [(char=? char #\u)
	     (if (< (+ 4 pos) (string-length data))
		 (let ([num (string->number (substring data (+ pos 1) (+ pos 5)) 16)])
		   (if num
		       (parse-json-str (+ 5 pos) data #f (cons (integer->char num) out))
		       (error 'parse-json-str "invalid unicode sequence at" pos)))
		 (error 'parse-json-str "unexpected end of string in unicode sequence"))]	
	    [else
	     (error 'parse-json-str "parse error" escaping char)]))]
	[(char=? char #\\)
	 (parse-json-str (+ 1 pos) data (cons #\\ (+ 1 pos)) out)]
	
	[(char-set-contains? char-set:iso-control char)
	 (error 'parse-json-str "parse error: special character in string literal" char )]
	[else
	 (parse-json-str (+ 1 pos) data escaping (cons char out))]))]))

 (define (parse-literal pos data out)
   (cond
    [(or (>= pos (string-length data))
	 (not (char-set-contains?  char-set:letter (string-ref data pos))))
     (values (list->string (reverse out)) pos)]
    [else
     (parse-literal (+ 1 pos) data (cons (string-ref data pos) out))]))

 ;; TODO WRITE MORE TESTS LIKE THIS
 ;; WRITE A MACRO THAT SIMPLIFIES TESTING
					;(eval-when (compile eval)
					;	   (unless (equal? (parse-json "a b c") '((char . #\a) (char . #\b) (char . #\c)))
					;		   (error 'parse-json-test "a b c assertion failed")))

 (define (identity expr) expr)

 (define expr-grammar
   `(;(expr --> expr expr-op term ,binary-apply)    ;;; change ` to '
     (main --> object ,identity)
     (main --> array ,identity)
     (main --> pair ,identity)
     (main --> value ,identity)
     (object --> lbracket rbracket ,(lambda (l r) '()))
     (object --> lbracket members rbracket ,(lambda (l m r) m))
     (members --> pair ,(lambda (p) (list p)))
     (members --> pair comma members ,(lambda (p c m) (append (list p) m)))
     (pair --> string colon value ,(lambda (s c v) `(,(string->symbol s)  . ,v)))
     (array --> lsquare rsquare ,(lambda (l r) '#()))
     (array --> lsquare elements rsquare ,(lambda (l e r) `#(,@e)))
     (elements --> value ,(lambda (v) (list v)))
     (elements --> value comma elements ,(lambda (v c e) (append (list v) e)))
     (value --> string ,identity)
     (value --> number ,(lambda (n) (string->number n)))
     (value --> object ,identity)
     (value --> array ,identity)
     (value --> true ,(lambda (x) #t))
     (value --> false ,(lambda (x) #f))
     (value --> null ,(lambda (x) '()))

     (int --> digits ,identity)
     (int --> minus digits ,(lambda (m d) (string-append "-" d )))
     (frac --> dot digits ,(lambda (p d)  (string-append "." d)))
     (exp --> ex digits ,(lambda (e d) (string-append (if (eq? e 'minus-e) "e-" "e") d)))
     (ex --> e ,identity)
     (ex --> e plus ,(lambda (e p) 'plus-e))
     (ex --> e minus ,(lambda (e p) 'minus-e))
     
     (number --> int ,identity)
     (number --> int frac ,(lambda (i f) (string-append i f)))
     (number --> int exp ,(lambda (i e) (string-append i e)))
     (number --> int frac exp ,(lambda (i f e) (string-append i f e)))
     (digit -> digit-1-9 ,(lambda (n) (number->string n)))
     (digit -> zero ,(lambda (n) "0"))
     ;; I COULDN'T FORCE THE digit-1-9 start stuff. is it really needed??
     (digits --> digit digits  ,(lambda (d n) (string-append d n)))
					; (digits --> digit-1-9 ,(lambda (n) (number->string n)))
					; (digits --> d ,(lambda (n) (number->string n)))
     (digits --> digit ,identity)
     ))

 (define expr-terminals '(string literal digit-1-9 zero char lbracket rbracket lsquare rsquare e dot minus plus colon comma true false null ) )

 (define table (lalr-table expr-grammar expr-terminals #f)) 

 (define (string->json data)
   (import (srfi s14 char-sets))
   (let ((pos 0))
     (define lexical-analyser 
       (lambda ()
	 (if (>= pos (string-length data)) #f
	     (begin
	       (let ([char (string-ref data pos)])
		 (cond
		  [(char=? char #\")
		   (let-values ([(str pos*) (parse-json-str (+ 1 pos) data #f '())])
		     ;;(parse (+ 1 pos*) data (cons (cons 'str str) out)))]
		     (set! pos (+ 1 pos*))
		     `(string . ,str))]
		  [(char-set-contains? char-set:whitespace char)
		   (set! pos (+ 1 pos))
		   (lexical-analyser)]
		  [(char-set-contains? char-set:letter char) ;; literals 
		   (let-values ([(str pos*) (parse-literal pos data '())])
		     (set! pos pos*)
		     (let ([sym (string->symbol str)])
		       (case sym
			 [(true) `(true . #t)]
			 [(false) `(false . #f)]
			 [(null) `(null . '())]
			 [(e E) `(e . #f)]
			 [else
			  `(literal ,(string->symbol str))])))]
		  [(char-set-contains? (string->char-set "123456789") char)
		   (set! pos (+ 1 pos))
		   `(digit-1-9 . ,(- (char->integer char) (char->integer #\0)))]
		  [(char=? #\0 char)
		   (set! pos (+ 1 pos))
		   `(zero . 0)]
		  [else 
		   (set! pos (+ 1 pos))
		   (case char
		     ((#\{) '(lbracket . #f))
		     ((#\}) '(rbracket . #f))
		     ((#\[) '(lsquare . #f))
		     ((#\]) '(rsquare . #f))
					; ((#\e #\E) '(e . #f))
		     ((#\.) '(dot . #f))
		     ((#\-) '(minus . #f))
		     ((#\+) '(plus . #f))
		     ((#\:) '(colon . #f))
		     ((#\,) '(comma . #f))
		     [else
		      `(char . ,char)])]))))))
     (define (parse-error)
       (display "Error somewhere in ")
       (write (substring data (max 0 (- pos -100)) pos))
       (newline))
     (lalr-parser table lexical-analyser parse-error)))

 (define (read-file filename)
   (with-input-from-file filename
     (lambda () 
       (let loop ([x (read-char)] [acc '()])  
	 (if (eof-object? x) (apply string (reverse acc))
	     (loop (read-char) (cons x acc)))))))

 (define-syntax let-json-object
   (lambda (x)
     (syntax-case x ()
       [(_ object (tag ...) body ...)
	#`(let #,(map (lambda (t) #`(#,t 
				     (let ([v (assq (quote #,t) object)])
				       (if v (cdr v) v))))#'(tag ...))
	    body ...)])))


 (define (json->string json)
   (define special '((#\backspace . #\b) (#\newline . #\n) (#\alarm . #\a) 
		     (#\return . #\r) (#\tab #\t) (#\\ . #\\) (#\" . #\")))
   (cond [(and (pair? json) (eq? (car json) 'dict))
	  (string-append 
	   "{\n"
	   (string-intersperse
	    (map (lambda (pair)
		   (let ([k (car pair)]
			 [v (cdr pair)])
		     (string-append "  " (json->string k)
				    " : " (json->string v))))
		 (cdr json))
	    ",\n")
	   "\n}\n")]
	 [(list? json)
	  (string-append  "["
			  (string-intersperse (map json->string json) ",")
			  "]\n")]
	 [(number? json)
	  (number->string json)]
	 [(string? json)
	  (string-append "\""
			 (list->string (fold-right
					(lambda (x acc)
					  (let ([q (assq x special)])
					    (if q (cons #\\ (cons (cdr q) acc))
						(cons x acc))))
					'()
					(string->list json)))
			 "\"" )]
   
	 [(symbol? json)
	  (json->string (symbol->string json))]
	 [else
	  (json->string "")]))
 
 )

;;#!eof
