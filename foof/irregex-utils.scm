;;;; irregex-utils.scm
;;
;; Copyright (c) 2008 Alex Shinn.  All rights reserved.
;; BSD-style license: http://synthcode.com/license.txt

(define rx-special-chars
  "\\|[](){}.*+?^$#")

(define (string-scan-char str c . o)
  (let ((end (string-length str)))
    (let scan ((i (if (pair? o) (car o) 0)))
      (cond ((= i end) #f)
            ((eqv? c (string-ref str i)) i)
            (else (scan (+ i 1)))))))

(define (irregex-quote str)
  (list->string
   (let loop ((ls (string->list str)) (res '()))
     (if (null? ls)
       (reverse res)
       (let ((c (car ls)))
         (if (string-scan-char rx-special-chars c)
           (loop (cdr ls) (cons c (cons #\\ res)))
           (loop (cdr ls) (cons c res))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (irregex-opt ls)
  (cond
    ((null? ls) "")
    ((null? (cdr ls)) (irregex-quote (car ls)))
    (else
     (let ((chars (make-vector 256 '())))
       (let lp1 ((ls ls) (empty? #f))
         (if (null? ls)
           (string-append
            "(?:"
            (string-intersperse
             (let lp2 ((i 0) (res '()))
               (if (= i 256)
                 (reverse res)
                 (let ((c (integer->char i))
                       (opts (vector-ref chars i)))
                   (lp2 (+ i 1)
                        (if (null? opts)
                          res
                          (cons (string-append
                                 (irregex-quote (string c))
                                 (irregex-opt opts))
                                res))))))
             "|")
            (if empty? "|" "") ; or use trailing '?' ?
            ")")
           (let* ((str (car ls))
                  (len (string-length str)))
             (if (zero? len)
               (lp1 (cdr ls) #t)
               (let ((i (char->integer (string-ref str 0))))
                 (vector-set!
                  chars
                  i
                  (cons (substring str 1 (string-length str))
                        (vector-ref chars i)))
                 (lp1 (cdr ls) empty?))))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (cset->string ls)
  (with-output-to-string
    (lambda ()
      (let lp ((ls ls))
        (unless (null? ls)
          (cond
            ((pair? (car ls))
             (display (irregex-quote (string (caar ls))))
             (display "-")
             (display (irregex-quote (string (cdar ls)))))
            (else (display (irregex-quote (string (car ls))))))
          (lp (cdr ls)))))))

(define (sre->string obj)
  (with-output-to-string
    (lambda ()
      (let lp ((x obj))
        (cond
          ((pair? x)
           (case (car x)
             ((|:| seq)
              (cond
                ((and (pair? (cddr x)) (pair? (cddr x)) (not (eq? x obj)))
                 (display "(?:") (for-each lp (cdr x)) (display ")"))
                (else (for-each lp (cdr x)))))
             ((submatch) (display "(") (for-each lp (cdr x)) (display ")"))
             ((|\|| or)
              (display "(?:")
              (lp (cadr x))
              (for-each (lambda (x) (display "|") (lp x)) (cddr x))
              (display ")"))
             ((* + ?)
              (cond
                ((pair? (cddr x))
                 (display "(?:") (for-each lp (cdr x)) (display ")"))
                (else (lp (cadr x))))
              (display (car x)))
             ((not)
              (cond
                ((and (pair? (cadr x)) (eq? 'cset (caadr x)))
                 (display "[^")
                 (display (cset->string (cdadr x)))
                 (display "]"))
                (else (error "can't represent general 'not' in strings" x))))
             ((cset)
              (display "[")
              (display (cset->string (cdr x)))
              (display "]"))
             ((w/case w/nocase)
              (display "(?")
              (if (eq? (car x) 'w/case) (display "-"))
              (display ":")
              (for-each lp (cdr x))
              (display ")"))
             (else (error "unknown match operator" x))))
          ((symbol? x)
           (case x
             ((bos bol) (display "^"))
             ((eos eol) (display "$"))
             ((any nonl) (display "."))
             (else (error "unknown match symbol" x))))
          ((string? x)
           (display (irregex-quote (->string x))))
          (else (error "unknown match pattern" x)))))))

