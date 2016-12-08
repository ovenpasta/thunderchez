
(library (c-eval)
	(export c-eval c-eval-printf c-eval-includes)
	(import (chezscheme) (posix))

	(define c-eval-includes (make-parameter '("stdio.h")))
	
	(define (c-eval-printf format . values)
	  (import (only (data-structures) string-intersperse ->string))
	  (c-eval (string-append "printf (\"" format "\"," (string-intersperse (map ->string values) ",") ");")))
		
	(define (c-eval expr)
	  (with-mktemp
	   "/tmp/c-eval-XXXXXX"
	   (lambda (file)
	     (apply
	      (lambda (in out pid)
		(for-each (lambda (x)
			    (fprintf out "#include <~a>~%" x)) (c-eval-includes))
		(fprintf out "int main() {~%")
		(fprintf out "~a~%" expr)
		(fprintf out "}~%")
		(close-port out)
		(display (cond [(get-string-all in ) => (lambda (x) (if (eof-object? x) "" x))]))
		(unless (zero? (wait-for-pid pid))
			(errorf 'c-repl "compilation failed"))
		(apply (lambda (p-in p-out p-pid)
			 (get-string-all p-in))
		       (process (format "~a" file))))
	      (process (format #f "gcc -o ~a -x c -" file))))))

	  
	  ) ;;library c-eval

#|
(import (c-eval))
(c-eval-includes '("stdio.h" "stdint.h"))
(string->number (c-eval-printf  "%d" "sizeof (uint32_t)"))

|#
