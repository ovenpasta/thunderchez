

(library (posix)
  (export strerror errno EAGAIN EINTR
	  mktemp mkstemp with-mktemp close
	  wtermsig wifexited wifsignaled wexitstatus
	  wait-for-pid)
  (import (chezscheme))
;;; POSIX STUFF
  (define init (load-shared-object "libc.so.6"))

  (define strerror
    (case-lambda
     [() (strerror (errno))]
     [(n)
      (define strerror* (foreign-procedure "strerror_r" (int u8* size_t) string))
      (define buff (make-bytevector 1024))
      (strerror* n buff 1024)]))

  (define (errno)
    (foreign-ref 'int (foreign-entry "errno") 0))

  (define EAGAIN 11)
  (define EINTR 4)

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
    (eq? (wtermsig x) 0))
  (define (wifsignaled x)
    (> (logand #xff (bitwise-arithmetic-shift-right
		     (+ 1 (wtermsig x))
		     1))
       0))
  (define (wexitstatus x)
    (bitwise-arithmetic-shift-right (logand x #xff00) 8))

  (define (wait-for-pid pid)
    (define waitpid* (foreign-procedure "waitpid" (int u8* int) int))
    (define status* (make-bytevector (foreign-sizeof 'int)))
    (let loop ()
      (let ([r (waitpid* pid status* 0)])
	(when (< r 0)
	      (errorf 'wait-for-pid "waitpid failed: ~d" (strerror)))
	(let ([status (bytevector-sint-ref status* 0 (native-endianness) (foreign-sizeof 'int))])
	  (cond [(wifexited status) (wexitstatus status)]
		[(wifsignaled status) #f]
		[(loop)])))))
) ;;library posix
