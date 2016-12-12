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

(library (posix)
  (export strerror errno
	  mktemp mkstemp with-mktemp close
	  wtermsig wifexited wifsignaled wexitstatus
	  wait-flag
	  wait-for-pid fork dup file-write file-read bytes-ready)
  (import (chezscheme)
	  (only (thunder-utils) bytevector-copy*)
	  (ffi-utils)
	  (only (posix errno) strerror errno EAGAIN EINTR))
  
;;; POSIX STUFF
  (define init (load-shared-object "libc.so.6"))

  (define (mkstemp template)
    (define mkstemp* (foreign-procedure "mkstemp" (u8*) int))
    (define t (string->utf8 template))
    
    (let ([fd (mkstemp* t)])
      (when (< fd 0)
	    (errorf 'mkstemp "failed: ~a" (strerror)))
      (values fd (utf8->string t))))

  (define (mktemp template)
    (define mktemp* (foreign-procedure "mktemp" (string) string))    
    (let ([s (mktemp* template)])
      (when (string=? s "")
	    (errorf 'mktemp "failed: ~a" (strerror)))
      s))

  (define (with-mktemp template f)
	  (define file (mktemp template))
	  (dynamic-wind
	      (lambda () (void))
	      (lambda () (f file))
	      (lambda () (delete-file file))))

  (define (close fd)
    (define close* (foreign-procedure "close" (int) int))
    (if (< (close* fd) 0)
	(errorf 'close "failed: ~a" (strerror))))


  (define (wtermsig x)
    (logand x #x7f))
  (define (wifexited x)
    (zero? (wtermsig x)))
  (define (wifsignaled x)
    (> (logand #xff (bitwise-arithmetic-shift-right
		     (+ 1 (wtermsig x))
		     1))
       0))
  (define (wexitstatus x)
    (bitwise-arithmetic-shift-right (logand x #xff00) 8))
  (meta-cond
   [(memq (machine-type) '(a6le ta6le i3le ti3le))
    (define-flags wait-flag (nohang 1) (untraced 2) (stopped 2) (exited 4) (continued 8)
      (nowait #x01000000) (nothread #x20000000) (all #x40000000) (clone #x80000000))])

  (define wait-for-pid
    (case-lambda
     [(pid) (wait-for-pid pid '())]
     [(pid options)
      (define waitpid* (foreign-procedure "waitpid" (int u8* int) int))
      (define status* (make-bytevector (foreign-sizeof 'int)))
      (let loop ()
	(let ([r (waitpid* pid status* (apply wait-flag options))])
	  (when (< r 0)
		(errorf 'wait-for-pid "waitpid failed: ~d" (strerror)))
	  (let ([status (bytevector-sint-ref status* 0 (native-endianness) (foreign-sizeof 'int))])
	    (cond [(wifexited status) (wexitstatus status)]
		  [(wifsignaled status) #f]
		  [(loop)]))))]))

  (define (fork)
    (define fork* (foreign-procedure "fork" () integer-32))
     (let ([r (fork*)])
      (if (< r 0)
	  (errorf 'dup2 "failed: ~d" (strerror))
	  r)))

  (define dup
    (case-lambda
     [(filedes filedes2)
      (define dup2* (foreign-procedure "dup2" (int int) int))
      (let ([r (dup2* filedes filedes2)])
	(if (< r 0)
	    (errorf 'dup2 "failed: ~d" (strerror))
	    r))]
     [(filedes)
      (define dup* (foreign-procedure "dup" (int) int))
      (let ([r (dup* filedes)])
	(if (< r 0)
	    (errorf 'dup "failed: ~d" (strerror))
	    r))]))
  
  ;; these shouldn't be needed.. use just open-fd-input-port,
  ;; open-fd-output-port or open-fd-input/output-port and then use the scheme
  ;; functions...
  
  (define (file-write fd data)
    (define write* (foreign-procedure "write" (int u8* size_t) ssize_t))
    (define n (bytevector-length data))
    (let loop ([data data])
      (let ([m (bytevector-length data)])
	(cond
	 [(> m 0)
	  (let ([r (write* fd data m)])
	    (cond
	     [(< r 0)
	      (if (or (= (errno) EAGAIN) (= (errno) EINTR))
		  (loop data)
		  (errorf 'write "error writing data: ~a: ~a" (errno) (strerror)))]
	     [else
	      (loop (bytevector-copy* data r))]))]
	 [else n]))))

  (define (file-read fd n)
    (define read* (foreign-procedure "read" (int u8* size_t) ssize_t))
    (define buf (make-bytevector n))
    (let loop ()
      (let ([r (read* fd buf n)])
	(cond
	 [(>= r 0) r]
	 [(or (= (errno) EAGAIN) (= (errno) EINTR)) -1]
	 [else (loop)]))))
    (define FIONREAD #x541B)

  (define (bytes-ready fd)
    (define ioctl* (foreign-procedure "ioctl" (int int void*) int))
    (define n* (foreign-alloc (foreign-sizeof 'int)))
    (ioctl* fd FIONREAD n*)
    (let ([n (foreign-ref 'int n* 0)])
      (foreign-free n*)
      n))

) ;;library posix
