
(import (scheme)
	(json))

(define sdl-json-text (read-file "sdl2.json"))
(define sdl-json (string->json sdl-json-text))

(with-output-to-file "sdl2.sexp" (lambda () (pretty-print sdl-json)) 'truncate)

(import (only (thunder-utils) string-replace string-split) 
	(only (srfi s13 strings) string-drop string-downcase string-prefix? string-suffix? string-delete)
	(only (srfi s1 lists) fold)
	(srfi s14 char-sets))

;; (define (anti-camel x)
;;   (let* ([x (string-replace x #\_ #\-)]
;; 	 [len (string-length x)]
;; 	 [s (list->string
;; 	     (reverse
;; 	      (fold (lambda (i acc) 
;; 		      (let ([a (string-ref x i)] 
;; 			    [b (if (< (+ 1 i) len) (string-ref x (+ 1 i)) #f)]
;; 			    [c (if (> i 0) (string-ref x (- i 1)) #f)])
;; 			(if (and (char-upper-case? a) 
;; 				 b (not (char-upper-case? b)) c (not (char-upper-case? c)))
;; 			    (cons (char-downcase a) 
;; 				  (if (and c (char=? c #\-)) 
;; 				      acc 
;; 				      (cons #\- acc)))
;; 			    (cons (char-downcase a) acc)))) '() (iota len))))])
    
;;     s))

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
     [(string-prefix? "SDL-GL-" x)
      (string-append "sdl-gl-" (f (string-drop x 7) (- len 7)))]
     [(string-prefix? "SDL-GL" x)
      (string-append "sdl-gl-" (f (string-drop x 6) (- len 6)))]
     [(equal? "SDL-RWops" x) "sdl-rw-ops"] ;HACK
     [else (f x len)])))

(define (add-t x)
  (let ([xd (string-downcase x)])
    (if (and (string-prefix? "sdl-" xd) 
	     (not  (or (string-suffix? "*" x) (string-suffix? "-t" x))))
	(string-append x "-t")
	x)))

(define (add-* x)
  (string-append x "*"))
 
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
					      pt ;; DOUBLE STAR SEEMS NOT SUPPORTED ON CHEZ
					      `(* ,pt))
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
(define (decode-param p)
  (let-json-object p (tag name type)
		   (if (equal? name "") 
		       (decode-type type)
		       (list name (decode-type type)))))

(define blacklist '(sdl-joystick-instance-id 
		    sdl-joystick-get-device-guid
		    sdl-joystick-get-guid 
		    sdl-joystick-get-guid-string 
		    sdl-joystick-get-guid-from-string
		    sdl-game-controller-mapping-for-guid))

(import (only (srfi s13 strings) string-contains))
(define (parse-json-function x m)
  (let-json-object x (tag name location return-type parameters) 
		   (if (and (or (string-contains location m) 
				(and (equal? "sdl" m) (string-contains location "SDL.h")))
			    (equal? tag "function")
			    (string-prefix? "SDL_" name))
		       (cond
			[(memq (string->symbol (anti-camel name)) blacklist)
			 (printf ";;blacklisted probably because it uses a struct as value.\n(define ~d #f)\n" (anti-camel name))]
			[else
			   (printf "(define-sdl-func ~d ~d ~d \"~d\")\n"
				   (decode-type return-type) 
				   (case name
				     ("SDL_log" "sdl-logn")
				     (else (anti-camel name)))
				   
				   (map (lambda (p) (decode-param p)) (vector->list parameters))
				   name)]))))

(define sdl2-modules-func
  '(assert atomic audio clipboard
    cpuinfo endian error events 
    filesystem hints joystick
    keyboard loadso log main messagebox
    mouse mutex pixels platform power
    rect render rwops surface system
    thread timer touch version video gamecontroller gesture sdl))

(for-each (lambda (m) 
	    (with-output-to-file (string-append m "-functions.ss")
	      (lambda () 
		(vector-for-each 
		 (lambda (x) 
		   (parse-json-function x m))
		 sdl-json))
	      'truncate)) (map symbol->string sdl2-modules-func))


