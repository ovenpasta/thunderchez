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

(library (thunder-utils)
	 (export string-split string-replace)
	 (import (scheme) (srfi s14 char-sets))

	 ;; POSSIBLE THAT NOT EXISTS THIS FUNCTION???
	 ;; s is a string , c is a character-set
	 ;; null strings are discarded from result by default unless #f is specified as third argument
	 (define string-split
	   (case-lambda
	    [(s c)
	     (string-split s c #t)]
	    [(s c discard-null?)
	     (define res '())
	     (let loop ([l (string->list s)] [t '()])
	       (if (null? l) 
		   (if (and (null? t) discard-null?)
		       res (append res (list (list->string t))))
		 (if (char-set-contains? c (car l))
		     (begin 
		       (unless (and (null? t) discard-null?)
			       (set! res (append res (list (list->string t)))))
		       (loop (cdr l) '()))
		     (loop (cdr l) (append t (list (car l)))))))]))
	    
	 ;; POSSIBLE THAT THIS NOT EXIST?
	 ;; if x is a character: (eq?  s[i] x) => s[i] = y
	 ;; if x is a list:      (memq s[i] x) => s[i] = y

	 (define (string-replace s x y)
	   (list->string  
	    (let ([cmp (if (list? x) memq eq?)])
	      (map (lambda (z) (if (cmp z x) y z)) (string->list s)))))



);library
