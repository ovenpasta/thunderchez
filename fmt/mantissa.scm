
;; Break a positive real number down to a normalized mantissa and
;; exponent. Default base=2, mant-size=52, exp-size=11 for IEEE doubles.


(define mantissa+exponent
  (case-lambda 
    [(num) (mantissa+exponent num 2)]
    [(num base) (mantissa+exponent num base 52)]
    [(num base mant-size) (mantissa+exponent num base mant-size 11)]
    [(num base mant-size exp-size)
     (if (zero? num)
	 (list 0 0)
	 (let* ((bot (expt base mant-size))
		(top (* base bot)))
	   (let lp ((n num) (e 0))
	     (cond
	      ((>= n top) (lp (quotient n base) (+ e 1)))
	      ((< n bot) (lp (* n base) (- e 1)))
	      (else (list n e))))))]))
