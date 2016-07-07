
(define (call-with-output-string f)
  (let ((port (open-output-string)))
    (let () (f port))
    (get-output-string port)))
