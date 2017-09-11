;;
;;   Copyright (c) 2009 Takeshi Abe. All rights reserved.
;;
;;   Redistribution and use in source and binary forms, with or without
;;   modification, are permitted provided that the following conditions
;;   are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in the
;;       documentation and/or other materials provided with the distribution.
;;
;;    3. Neither the name of the authors nor the names of its contributors
;;       may be used to endorse or promote products derived from this
;;       software without specific prior written permission.
;;
;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
;;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(library (base64)
  (export encode
          encode-bytevector
          decode
          decode-string
          &invalid-encoding
          invalid-encoding?
          invalid-encoding-position
          &unknown-alphabet
          unknown-alphabet?
          unknown-alphabet-char)
  (import (rnrs))

  (define *table*
    '#(#\A #\B #\C #\D #\E #\F #\G #\H
       #\I #\J #\K #\L #\M #\N #\O #\P
       #\Q #\R #\S #\T #\U #\V #\W #\X
       #\Y #\Z #\a #\b #\c #\d #\e #\f
       #\g #\h #\i #\j #\k #\l #\m #\n
       #\o #\p #\q #\r #\s #\t #\u #\v
       #\w #\x #\y #\z #\0 #\1 #\2 #\3
       #\4 #\5 #\6 #\7 #\8 #\9 #\+ #\/))

  (define (encode iport oport)

    (define (put-alphabet i)
      (put-char oport (vector-ref *table* i)))

    (assert (binary-port? iport))
    (assert (textual-port? oport))

    (let loop ((b0 (get-u8 iport))
               (n 0))
      (cond ((eof-object? b0)
             n)
            (else
             (put-alphabet (fxarithmetic-shift-right b0 2))
             (let ((p0 (fxarithmetic-shift-left (fxbit-field b0 0 2) 4))
                   (b1 (get-u8 iport)))
               (cond ((eof-object? b1)
                      (put-alphabet p0)
                      (put-string oport "==")
                      (+ n 4))
                     (else
                      (put-alphabet (fxior p0 (fxarithmetic-shift-right b1 4)))
                      (let ((p1 (fxarithmetic-shift-left (fxbit-field b1 0 4) 2))
                            (b2 (get-u8 iport)))
                        (cond ((eof-object? b2)
                               (put-alphabet p1)
                               (put-char oport #\=)
                               (+ n 4))
                              (else
                               (put-alphabet (fxior p1 (fxarithmetic-shift-right b2 6)))
                               (put-alphabet (fxbit-field b2 0 6))
                               (loop (get-u8 iport) (+ n 4))))))))))))

  (define (encode-bytevector bv)
    (assert (bytevector? bv))
    (call-with-port (open-bytevector-input-port bv)
      (lambda (iport)
        (call-with-string-output-port
         (lambda (oport)
           (encode iport oport))))))

  (define-condition-type &invalid-encoding &condition
    make-invalid-encoding invalid-encoding?
    (position invalid-encoding-position))

  (define-condition-type &unknown-alphabet &condition
    make-unknown-alphabet unknown-alphabet?
    (char unknown-alphabet-char))
 
  (define (decode iport oport)

    (define (c->i c)
      (let ((n (char->integer c)))
        (cond ((<= 65 n 90)   (- n 65))
              ((<= 97 n 122)  (- n 71)) ; (+ (- n 97) 26)
              ((<= 48 n 57)   (+ n 4))  ; (+ (- n 48) 52)
              ((char=? #\+ c) 62)
              ((char=? #\/ c) 63)
              (else (raise (make-unknown-alphabet c))))))

    (define-syntax put-bytes
      (syntax-rules ()
        ((_ c0 c1)
         (let* ((i0 (c->i c0))
                (i1 (c->i c1))
                (b0 (fxior (fxarithmetic-shift-left i0 2)
                           (fxbit-field i1 4 6))))
           (put-u8 oport b0)
           i1))
        ((_ c0 c1 c2)
         (let* ((i1 (put-bytes c0 c1))
                (i2 (c->i c2))
                (b1 (fxior (fxarithmetic-shift-left (fxbit-field i1 0 4) 4)
                           (fxbit-field i2 2 6))))
           (put-u8 oport b1)
           i2))
        ((_ c0 c1 c2 c3)
         (let* ((i2 (put-bytes c0 c1 c2))
                (b2 (fxior (fxarithmetic-shift-left (fxbit-field i2 0 2) 6)
                           (c->i c3))))
           (put-u8 oport b2)))))

    (assert (textual-port? iport))
    (assert (binary-port? oport))

    (let loop ((c0 (get-char iport))
               (n 0))
      (if (eof-object? c0)
          n
          (let ((c1 (get-char iport)))
            (if (eof-object? c1)
                (raise (make-invalid-encoding (+ n 1))))
            (let ((c2 (get-char iport)))
              (if (eof-object? c2)
                  (raise (make-invalid-encoding (+ n 2))))
              (let ((c3 (get-char iport)))
                (cond ((eof-object? c3)
                       (raise (make-invalid-encoding (+ n 3))))
                      ((char=? #\= c2)
                       (cond ((char=? #\= c3)
                              (put-bytes c0 c1)
                              (+ n 1))
                             (else
                              (raise (make-invalid-encoding (+ n 3))))))
                      ((char=? #\= c3)
                       (put-bytes c0 c1 c2)
                       (+ n 2))
                      (else
                       (put-bytes c0 c1 c2 c3)
                       (loop (get-char iport) (+ n 3))))))))))

  (define (decode-string str)
    (assert (string? str))
    (call-with-port (open-string-input-port str)
      (lambda (iport)
        (call-with-bytevector-output-port
         (lambda (oport)
           (decode iport oport))))))

)
