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

;;Hackingly editted by Jack Lucas <silverbeard@protonmail.com> for use in
;;generating nuklear bindings.
;;Added support for returning structure references


(library-directories "~/thunderchez")

(import (scheme)
	(json))

(import (only (thunder-utils) string-replace string-split)
	(only (srfi s13 strings) string-drop string-downcase string-prefix? string-suffix? string-delete)
	(only (srfi s1 lists) fold)
	(srfi s14 char-sets))

(define (anti-camel x)
  (let* ([x (string-replace x #\_ #\-)]
	 [len (string-length x)]
	 [f (lambda (s len)
	      (list->string
	       (reverse
		(fold (lambda (i acc)
			(let ([a (string-ref s i)]
			      [next (if (< (+ 1 i) len) (string-ref s (+ 1 i)) #f)]
			      [prev (if (> i 0) (string-ref s (- i 1)) #f)])
			  (if (and (char-upper-case? a)  next prev
				   (not
				    (or (char=? a #\-) (char=? prev #\-) (char=? next #\-)
					(and (char-upper-case? next) (char-upper-case? prev)))))
			      (cons (char-downcase a) (cons #\- acc))
			      (cons (char-downcase a) acc)))) '() (iota len)))))])
    (define tbl '(("SDL-RWops" "sdl-rw-ops")
		  ("UDPpacket" "udp-packet") ("TCPsocket" "tcp-socket")
		  ("IPaddress" "ip-address") ("UDPsocket" "udp-socket")))
    (cond
     [(string-prefix? "SDL-GL-" x)
      (string-append "sdl-gl-" (f (string-drop x 7) (- len 7)))]
     [(string-prefix? "SDL-GL" x)
      (string-append "sdl-gl-" (f (string-drop x 6) (- len 6)))]
     [(assoc x tbl) => (lambda (y) (cadr y))]
     [else (f x len)])))

(define (add-t x)
  (let ([xd (string-downcase x)])
    (if (and (string-prefix? "nk-" xd)
	     (not  (or (string-suffix? "*" x) (string-suffix? "-t" x))))
	(string-append x "-t")
	x)))

(define (add-* x)
  (string-append x "*"))

(define (decode-type t)
  (if t
      (let-json-object t (tag type name ns)
		       (let ([tag* (if (string? tag) (string->symbol tag) tag)])
			 (case tag*
			   [:function-pointer 'void*]
			   [:int 'int]
			   [:unsigned-int 'unsigned-int]
			   [:unsigned-long-long 'unsigned-long-long]
			   [:unsigned-long 'unsigned-long]
			   [:long 'long]
         [:enum 'unsigned-int]
			   [:double 'double]
			   [:long-double 'long-double]
			   [:float 'float]
         [:struct
          `(& ,(if (symbol? name)
                   (string->symbol (add-t (anti-camel (symbol->string name))))
                   (string->symbol (add-t (anti-camel name)))))]
         ['struct
          `(& ,(if (symbol? name)
                   (string->symbol (add-t (anti-camel (symbol->string name))))
                   (string->symbol (add-t (anti-camel name)))))]
			   [:pointer
          (let ([pt (decode-type type)])
				       (case pt
					 (char 'string)
					 (string 'void*)
					 (void 'void*)
					 (else
					  (if (and (pair? pt ))
					      (cond
                 ((eq? (car pt) '*) pt)
                 ((eq? (car pt) '&)
                  `(* ,(cadr pt))))
                 ;; DOUBLE STAR SEEMS NOT SUPPORTED ON CHEZ
					      `(* ,(if (symbol? pt)
                         (string->symbol (add-t (anti-camel (symbol->string pt))))
                         (string->symbol (add-t (anti-camel pt))))))
					  #;(string->symbol
					   (add-*
					    (symbol->string pt))))))]
			   [:void 'void]
			   [:char 'char]
			   [else (if (symbol? tag*)
				     (string->symbol
				      (add-t
				       (anti-camel
					(symbol->string tag*))))
				     tag*)])))
      #f))


(define (check-for-name ty)
  (let-json-object ty (tag type name)
                   (if (or (equal? type "") (equal? type #f))
                       ""
                       (check-for-name type))))


(define (remove-nk x)
      (substring x 2 (string-length x)))

(define (decode-param p n)
  (let-json-object p (tag name type)
                   (let ((pn (check-for-name type)))
		                 (if (equal? name "")
		                     (if (equal? pn "")
                             (list (string-append "arg-" (number->string n))
                                   (decode-type type))
                             (list pn (decode-type type)))
                         (list name (decode-type type))))))

(import (only (srfi s13 strings) string-contains))

(define blacklist '())

(define (parse-json-function x m)
  (let-json-object x
                   (tag name location return-type parameters)
		               (if (and (or (string-contains location m)
				                        (and (equal? "nk" m) (string-contains location "nuklear.h")))
			                      (equal? tag "function")
				                    (string-prefix? "nk_" name))

		                   (begin
			                   (printf "(define-nk-func ~d ~d ~d \"~d\")\n"
				                         (decode-type return-type)
				                         (anti-camel name)
				                         (map (lambda (p n) (decode-param p n))
					                            (vector->list parameters)
					                            (iota (vector-length parameters)))
				                         name)))))

(define sdl2-modules-func
  '(nk))

(define sdl-json-text (read-file "nuklear.json"))
(define sdl-json (string->json sdl-json-text))

(with-output-to-file "nuklear.sexp" (lambda () (pretty-print sdl-json)) 'truncate)

(for-each (lambda (m)
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda ()
		      (vector-for-each
		       (lambda (x)
		         (parse-json-function x m))
		       sdl-json))
	      'truncate)) (map symbol->string sdl2-modules-func))

