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
    (cond
     [#f #f]
     [else (f x len)])))

(define (add-t x)
  (let ([xd (string-downcase x)])
    (if (and (string-prefix? "cairo-" xd) 
	     (not  (or (string-suffix? "*" x) (string-suffix? "-t" x))))
	(string-append x "-t")
	x)))

(define (add-* x)
  (string-append x "*"))

(define (symbol-append . symbols)
  (apply string-append (map symbol->string symbols)))

(define (decode-type t)
  (if t
      (let-json-object t (tag type)
		       (let ([tag* (if (string? tag) (string->symbol tag) tag)])
			 (case tag*
			   [:function-pointer 'void*]
			   [:int 'int]
			   [:unsigned-int 'unsigned-int]
			   [:unsigned-long-long 'unsigned-long-long]
			   [:unsigned-long 'unsigned-long]
			   [:long 'long]
			   [:double 'double]
			   [:long-double 'long-double]
			   [:float 'float]
			   [:pointer (let ([pt (decode-type type)])
				       (case pt
					 (char 'string)
					 (void 'void*)
					 (else
					  (if (and (pair? pt ) (eq? (car pt) '*))
					      `(* ,(symbol-append (cadr pt) '*)) ;; DOUBLE STAR SEEMS NOT SUPPORTED ON CHEZ
					      `(* ,pt))
					  #;(string->symbol 
					   (add-*
					    (symbol->string pt))))))]
			   [:void 'void]
			   [:char 'char]
			   [:unsigned-char 'unsigned-8]
			   [(cairo_user_scaled_font_init_func_t
			    cairo_user_scaled_font_render_glyph_func_t
			    cairo_user_scaled_font_text_to_glyphs_func_t
			    cairo_user_scaled_font_unicode_to_glyph_func_t
			    cairo_surface_observer_callback_t
			    cairo_write_func_t
			    cairo_read_func_t
			    cairo_raster_source_release_func_t
			    cairo_raster_source_acquire_func_t
			    cairo_raster_source_snapshot_func_t
			    cairo_raster_source_copy_func_t
			    cairo_raster_source_finish_func_t)
			    `(* ,(string->symbol (string-replace (symbol->string tag*) #\_ #\-)))]
	     
			   [else (if (symbol? tag*)
				     (string->symbol 
				      (add-t
				       (anti-camel 
					(symbol->string tag*))))
				     tag*)])))
      #f))
(define (decode-param p)
  (let-json-object p (tag name type)
		   (if (equal? name "") 
		       (decode-type type)
		       (list name (decode-type type)))))


(define cairo-json-text (read-file "cairo.json"))
(define cairo-json (string->json cairo-json-text))

(define cairo-pdf-json-text (read-file "cairo-pdf.json"))
(define cairo-pdf-json (string->json cairo-pdf-json-text))

(with-output-to-file "cairo.sexp" (lambda () (pretty-print cairo-json)) 'truncate)

(with-output-to-file "cairo-pdf.sexp" (lambda () (pretty-print cairo-pdf-json)) 'truncate)

(define blacklist '())

(import (only (srfi s13 strings) string-contains))
(define (parse-json-function x m)
  (let-json-object x (tag name location return-type parameters) 
		   (if (and  (or (string-contains location m) 
				(and (equal? "cairo" m) (string-contains location "cairo.h")))
			     (equal? tag "function")
			    (string-prefix? "cairo_" name))
		       (cond
			[(memq (string->symbol (anti-camel name)) blacklist)
			 (printf ";;blacklisted probably because it uses a struct as value.\n(define ~d #f)\n" (anti-camel name))]
			[else
			   (printf "(define-cairo-func ~d ~d ~d \"~d\")\n"
				   (decode-type return-type) 
				   (case name
				     (else (anti-camel name)))
				   
				   (map (lambda (p) (decode-param p)) (vector->list parameters))
				   name)]))))

(for-each (lambda (m) 
	    (with-output-to-file (string-append (car m) "-functions.ss")
	      (lambda () 
		(vector-for-each 
		 (lambda (x) 
		   (parse-json-function x (car m)))
		 (cdr m)))
	      'truncate)) `(("cairo" . ,cairo-json) ("cairo-pdf" . ,cairo-pdf-json)))
