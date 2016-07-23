
(define (read-line . o)
  (let ((port (if (pair? o) (car o) (current-input-port))))
    (let lp ((res '()))
      (let ((c (read-char port)))
        (cond 
	 [(and (eof-object? c) (null? res)) #f]
	 [(or (eof-object? c) (eqv? c #\newline))
	  (list->string (reverse res))]
	 [else
	  (lp (cons c res))])))))
