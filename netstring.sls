
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
	    (unless (eq? (get-u8 port) (char->integer #\,))
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
