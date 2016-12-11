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

(library (netstring)
  (export read-netstring write-netstring read-netstring/string)
  (import (chezscheme))
  
  (define (read-netstring port)
    (let loop ([len 0])
      (let ([c (get-u8 port)] )
	(when (eof-object? c)
	    (errorf 'read-netstring "unexpected end of file while reading header"))
	(cond
	 [(<= #x30 c #x39)
	  (loop (fx+ (fx* 10 len) (fx- c #x30)))]
	 [(fx= c (char->integer #\:))
	  (let ([r (get-bytevector-n port len)])
	    (when (or (eof-object? r)
		      (< (bytevector-length r) len))
		  (errorf 'read-netstring "unexpected end of file while reading data"))
	    (unless (eqv? (get-u8 port) (char->integer #\,))
		    (errorf 'read-netstring "expected , at end of netstring" ))
	    r)]
	 [else
	  (errorf 'read-netstring "unexpected character while reading header #x~x" c)]))))
  
  (define (read-netstring/string port)
    (utf8->string (read-netstring port)))
  
  (define (write-netstring port data)
    (let ([data (if (string? data) (string->utf8 data) data)])
      (put-bytevector port (string->utf8 (number->string (bytevector-length data))))
      (put-u8 port (char->integer #\:))
      (put-bytevector port data)
      (put-u8 port (char->integer #\,)))))

#|
(define msg "abcdefghijkl")
(define-values (pt bv) (open-bytevector-output-port))
(write-netstring pt msg)
(define x (bv))
(if (equal? msg
	    (read-netstring/string (open-bytevector-input-port x)))
    (printf "test OK~n")
    (printf "test FAILED~n"))
    
|#
