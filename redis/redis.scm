#| Created and Maintained by Jack Lucas <silverbeard@protonmail.com>
see standalone repo at https://github.com/silverbeard00/siredis for license
|#

(define-record-type redsock
  (fields name ip port send (mutable receive)))

(define (red-mk-socket addr port)
  (let ((s (socket 'inet 'stream '() 0)))
    (connect/inet s addr port)
    (make-redsock "Redis" addr port s 0)))

(define (red-snd redsock command)
  (let ((active-sock (redsock-send redsock)))
    (put-bytevector
     active-sock
     (string->utf8 (format #f "~a\r\n" command)))
    (flush-output-port active-sock)))

(define (red-recv redsock)
  (red-read-socket redsock))

(define (red-byte-convert sock)
  (utf8->string (bytevector (get-u8 sock))))

(define (red-clear-end-tags sock)
  (get-u8 sock) (get-u8 sock))

(define (red-read-integer sock)
  (string->number (red-read-socket sock)))

;;;Should be turned into a vector version that converts to
;;;a string at the last step.
(define (red-read-socket sock)
  (let ((redsock (redsock-send sock)))
    (let getter ((data
                  (red-byte-convert redsock))
                 (acc "") (prev 0))
      (cond
       ((and (equal? acc "") (equal? data "*"))
        (red-read-array sock))
       ((and (equal? acc "") (equal? data ":"))
        (red-read-integer sock))
       ((and (equal? acc "") (equal? data "$"))
        (let ((l (red-byte-convert redsock)))
          (if (and (equal? l "-")
                   (equal? (red-byte-convert redsock) "1"))
              (begin
                (red-clear-end-tags redsock)
                #f)
              (begin
                (red-clear-end-tags redsock)
                (red-read-socket sock)))))

       ((equal? data "\r")
        (let ((l (red-byte-convert redsock)))
          (if (equal? l "\n")
              acc
              (getter l
                      (string-append acc data)
                      data))))
       (else
        (getter (red-byte-convert redsock)
                (string-append acc data)
                data))))))

(define (red-array-length redsock)
  (let ((data (string->list (red-read-socket redsock))))
    (string->number (list->string data))))

(define (red-read-array redsock)
  (let ((active-sock (redsock-send redsock))
        (num (red-array-length redsock)))
    (if (= num -1)
        #f
        (let array-read ((num num)
                         (acc '()))
          (cond
           ((= num 0) (reverse acc))
           (else
            (let ((data (red-read-socket redsock)))
              (array-read (- num 1) (cons data acc)))))))))

(define (red-parse-command cmd)
  (fold-left (lambda (x y)
               (cond
                ((symbol? y)
                 (string-append x " " (symbol->string y)))
                ((number? y)
                 (string-append x " " (number->string y)))
                ((string? y)
                 (string-append x " " y))))
             (symbol->string (car cmd))
             (cdr cmd)))

(define (red-parse-commands cmds)
  (map (lambda (x)  (red-parse-command x))
       cmds))

(define (red-pipe-recv sock cmd)
  (map (lambda (cmd0) (red-recv sock))
       cmd))

(define (red-operate sock cmd)
  (if (and (pair? (first cmd)) (list? (first cmd)))
      (begin
        (map (lambda (cmd0) (red-snd sock cmd0))
             (red-parse-commands cmd))
        (red-pipe-recv sock cmd))
      (begin
        (red-snd sock (red-parse-command cmd))
        (red-recv sock))))

(define (return-redis-closure ip port)
  (let ((internal-socket (red-mk-socket ip port)))
    (lambda cmd
      (red-operate internal-socket cmd))))


#|Examples of creating shorthand for redis commands|#

(define (red-set key value)
  `(set ,key ,value))

(define (red-get key)
  `(get ,key))

(define (red-append key value)
  `(append ,key ,value))

(define (red-getset key value)
  `(get-set ,key ,value))

