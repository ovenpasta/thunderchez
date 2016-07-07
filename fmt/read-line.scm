
(define (read-line . o)
  (let ((port (if (pair? o) (car o) (current-input-port))))
    (let lp ((res '()))
      (let ((c (read-char port)))
        (if (or (eof-object? c) (eqv? c #\newline))
            (list->string (reverse res))
            (lp (cons c res)))))))
