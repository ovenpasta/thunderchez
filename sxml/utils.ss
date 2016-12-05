


(define chez-error scheme:error)
(define error
  (lambda (msg . args)
    (chez-error 'runtime-error "~a~%" (cons msg args))))


(define pp pretty-print)


(define-syntax declare	; Gambit-specific compiler-decl
  (syntax-rules () ((declare . x) (begin #f))))

; A few convenient functions that are not Chez
(define (call-with-input-string str proc)
    (proc (open-input-string str)))
(define (call-with-output-string proc)
  (let ((port (open-output-string)))
    (proc port)
    (get-output-string port)))


; Frequently-occurring syntax-rule macros

; A symbol? predicate at the macro-expand time
;	symbol?? FORM KT KF
; FORM is an arbitrary form or datum
; expands in KT if FORM is a symbol (identifier), Otherwise, expands in KF

(define-syntax symbol??
  (syntax-rules ()
    ((symbol?? (x . y) kt kf) kf)	; It's a pair, not a symbol
    ((symbol?? #(x ...) kt kf) kf)	; It's a vector, not a symbol
    ((symbol?? maybe-symbol kt kf)
      (let-syntax
	((test
	   (syntax-rules ()
	     ((test maybe-symbol t f) t)
	     ((test x t f) f))))
	(test abracadabra kt kf)))))

; A macro-expand-time memv function for identifiers
;	id-memv?? FORM (ID ...) KT KF
; FORM is an arbitrary form or datum, ID is an identifier.
; The macro expands into KT if FORM is an identifier, which occurs
; in the list of identifiers supplied by the second argument.
; All the identifiers in that list must be unique.
; Otherwise, id-memv?? expands to KF.
; Two identifiers match if both refer to the same binding occurrence, or
; (both are undefined and have the same spelling).

(define-syntax id-memv??
  (syntax-rules ()
    ((id-memv?? form (id ...) kt kf)
      (let-syntax
	((test
	   (syntax-rules (id ...)
	     ((test id _kt _kf) _kt) ...
	     ((test otherwise _kt _kf) _kf))))
	(test form kt kf)))))

; Commonly-used CPS macros
; The following macros follow the convention that a continuation argument
; has the form (k-head ! args ...)
; where ! is a dedicated symbol (placeholder).
; When a CPS macro invokes its continuation, it expands into
; (k-head value args ...)
; To distinguish such calling conventions, we prefix the names of
; such macros with k!

(define-syntax k!id			; Just the identity. Useful in CPS
  (syntax-rules ()
    ((k!id x) x)))

; k!reverse ACC (FORM ...) K
; reverses the second argument, appends it to the first and passes
; the result to K

(define-syntax k!reverse
  (syntax-rules (!)
    ((k!reverse acc () (k-head ! . k-args))
      (k-head acc . k-args))
    ((k!reverse acc (x . rest) k)
      (k!reverse (x . acc) rest k))))

(define-syntax assure
  (syntax-rules ()
    ((assure exp error-msg) (assert exp report: error-msg))))

(define (identify-error msg args . disposition-msgs)
  (let ((port (console-output-port)))
    (newline port)
    (display "ERROR" port)
    (display msg port)
    (for-each (lambda (msg) (display msg port))
	      (append args disposition-msgs))
    (newline port)))

; like cout << arguments << args
; where argument can be any Scheme object. If it's a procedure
; (without args) it's executed rather than printed (like newline)

(define (cout . args)
  (for-each (lambda (x)
              (if (procedure? x) (x) (display x)))
            args))

(define (cerr . args)
  (for-each (lambda (x)
              (if (procedure? x) (x (console-output-port))
		(display x (console-output-port))))
            args))

(define nl (string #\newline))

; Some useful increment/decrement operators

(define-syntax inc!		; Mutable increment
  (syntax-rules ()
    ((inc! x) (set! x (+ 1 x)))))
(define-syntax inc               ; Read-only increment
  (syntax-rules ()
    ((inc x) (+ 1 x))))

(define-syntax dec!		; Mutable decrement
  (syntax-rules ()
    ((dec! x) (set! x (- x 1)))))
(define-syntax dec		; Read-only decrement
  (syntax-rules ()
    ((dec x) (- x 1))))

; Some useful control operators

			; if condition is false execute stmts in turn
			; and return the result of the last statement
			; otherwise, return unspecified.
			; This primitive is often called 'unless'
(define-syntax whennot
  (syntax-rules ()
    ((whennot condition . stmts)
      (or condition (begin . stmts)))))


			; Execute a sequence of forms and return the
			; result of the _first_ one. Like PROG1 in Lisp.
			; Typically used to evaluate one or more forms with
			; side effects and return a value that must be
			; computed before some or all of the side effects happen.
(define-syntax begin0
  (syntax-rules ()
    ((begin0 form form1 ... ) 
      (let ((val form)) form1 ... val))))

			; Prepend an ITEM to a LIST, like a Lisp macro PUSH
			; an ITEM can be an expression, but ls must be a VAR
(define-syntax push!
  (syntax-rules ()
    ((push! item ls)
      (set! ls (cons item ls)))))

			; assoc-primitives with a default clause
			; If the search in the assoc list fails, the
			; default action argument is returned. If this
			; default action turns out to be a thunk,
			; the result of its evaluation is returned.
			; If the default action is not given, an error
			; is signaled

(define-syntax assq-def
  (syntax-rules ()
    ((assq-def key alist)
      (or (assq key alist)
	(error "failed to assq key '" key "' in a list " alist)))
    ((assq-def key alist #f)
      (assq key alist))
    ((assq-def key alist default)
      (or (assq key alist) (if (procedure? default) (default) default)))))

(define-syntax assv-def
  (syntax-rules ()
    ((assv-def key alist)
      (or (assv key alist)
	(error "failed to assv key '" key "' in a list " alist)))
    ((assv-def key alist #f)
      (assv key alist))
    ((assv-def key alist default)
      (or (assv key alist) (if (procedure? default) (default) default)))))

(define-syntax assoc-def
  (syntax-rules ()
    ((assoc-def key alist)
      (or (assoc key alist)
	(error "failed to assoc key '" key "' in a list " alist)))
    ((assoc-def key alist #f)
      (assoc key alist))
    ((assoc-def key alist default)
      (or (assoc key alist) (if (procedure? default) (default) default)))))

			; Convenience macros to avoid quoting of symbols
			; being deposited/looked up in the environment
(define-syntax env.find
  (syntax-rules () ((env.find key) (%%env.find 'key))))
(define-syntax env.demand
  (syntax-rules () ((env.demand key) (%%env.demand 'key))))
(define-syntax env.bind
  (syntax-rules () ((env.bind key value) (%%env.bind 'key value))))


;   ssax:warn PORT MESSAGE SPECIALISING-MSG*
; to notify the user about warnings that are NOT errors but still
; may alert the user.
; Result is unspecified.
; We need to define the function to allow the self-tests to run.
; Normally the definition of ssax:warn is to be provided by the user.

 (define (ssax:warn port msg . other-msg)
   (apply cerr (cons* nl "Warning: " msg other-msg)))



;   parser-error PORT MESSAGE SPECIALISING-MSG*
; to let the user know of a syntax error or a violation of a
; well-formedness or validation constraint.
; Result is unspecified.
; We need to define the function to allow the self-tests to run.
; Normally the definition of parser-error is to be provided by the user.

 (define (parser-error port msg . specializing-msgs)
   (apply error (cons msg specializing-msgs)))

(define-syntax define-opt
    (syntax-rules (optional)
      ((define-opt (name . bindings) . bodies)
       (define-opt "seek-optional" bindings () ((name . bindings) . bodies)))

      ((define-opt "seek-optional" ((optional . _opt-bindings))
         (reqd ...) ((name . _bindings) . _bodies))
       (define (name reqd ... . _rest)
         (letrec-syntax
             ((handle-opts
               (syntax-rules ()
                 ((_ rest bodies (var init))
                  (let ((var (if (null? rest) init
                                 (if (null? (cdr rest)) (car rest)
                                     (error "extra rest" rest)))))
                    . bodies))
                 ((_ rest bodies var) (handle-opts rest bodies (var #f)))
                 ((_ rest bodies (var init) . other-vars)
                  (let ((var (if (null? rest) init (car rest)))
                        (new-rest (if (null? rest) '() (cdr rest))))
                    (handle-opts new-rest bodies . other-vars)))
                 ((_ rest bodies var . other-vars)
                  (handle-opts rest bodies (var #f) . other-vars))
                 ((_ rest bodies)		; no optional args, unlikely
                  (let ((_ (or (null? rest) (error "extra rest" rest))))
                    . bodies)))))
           (handle-opts _rest _bodies . _opt-bindings))))

      ((define-opt "seek-optional" (x . rest) (reqd ...) form)
       (define-opt "seek-optional" rest (reqd ... x) form))

      ((define-opt "seek-optional" not-a-pair reqd form)
       (define . form))			; No optional found, regular define

      ((define-opt name body)		; Just the definition for 'name',
       (define name body))		; for compatibilibility with define
      ))

  (define ascii->char integer->char)
  (define ucscode->char integer->char)
  
  (define char-return (ascii->char 13))
  (define char-tab    (ascii->char 9))
  (define char-newline (ascii->char 10))
    
  (define-opt (peek-next-char (optional (port (current-input-port))))
    (read-char port) 
    (peek-char port)) 
  
  (define-opt (assert-curr-char expected-chars comment
                                (optional (port (current-input-port))))
    (let ((c (read-char port)))
      (if (memv c expected-chars) c
          (parser-error port "Wrong character " c
                        " (0x" (if (eof-object? c) "*eof*"
                                   (number->string (char->integer c) 16)) ") "
                                   comment ". " expected-chars " expected"))))

  (define-opt (skip-until arg (optional (port (current-input-port))) )
    (cond
     ((number? arg)		; skip 'arg' characters
      (do ((i arg (dec i)))
      	  ((not (positive? i)) #f)
        (if (eof-object? (read-char port))
      	    (parser-error port "Unexpected EOF while skipping "
                          arg " characters"))))
     (else			; skip until break-chars (=arg)
      (let loop ((c (read-char port)))
        (cond
         ((memv c arg) c)
         ((eof-object? c)
          (if (memq '*eof* arg) c
              (parser-error port "Unexpected EOF while skipping until " arg)))
         (else (loop (read-char port))))))))

  (define-opt (skip-while skip-chars (optional (port (current-input-port))) )
    (do ((c (peek-char port) (peek-char port)))
        ((not (memv c skip-chars)) c)
      (read-char port)))
  
  (define input-parse:init-buffer
    (let ((buffer (make-string 512)))
      (lambda () buffer)))
  
  (define-opt (next-token-old prefix-skipped-chars break-chars
                              (optional (comment "") (port (current-input-port))) )
    (let* ((buffer (input-parse:init-buffer))
           (curr-buf-len (string-length buffer))
           (quantum curr-buf-len))
      (let loop ((i 0) (c (skip-while prefix-skipped-chars port)))
        (cond
         ((memv c break-chars) (substring buffer 0 i))
         ((eof-object? c)
          (if (memq '*eof* break-chars)
              (substring buffer 0 i)
              (parser-error port "EOF while reading a token " comment)))
         (else
          (if (>= i curr-buf-len)
              (begin
                (set! buffer (string-append buffer (make-string quantum)))
                (set! quantum curr-buf-len)
                (set! curr-buf-len (string-length buffer))))
          (string-set! buffer i c)
          (read-char port)
          (loop (inc i) (peek-char port))
          )))))

  (define-opt (next-token prefix-skipped-chars break-chars
                          (optional (comment "") (port (current-input-port))) )
    (let outer ((buffer (input-parse:init-buffer)) (filled-buffer-l '())
                (c (skip-while prefix-skipped-chars port)))
      (let ((curr-buf-len (string-length buffer)))
        (let loop ((i 0) (c c))
          (cond
           ((memv c break-chars)
            (if (null? filled-buffer-l) (substring buffer 0 i)
                (string-concatenate-reverse filled-buffer-l buffer i)))
           ((eof-object? c)
            (if (memq '*eof* break-chars)	; was EOF expected?
                (if (null? filled-buffer-l) (substring buffer 0 i)
                    (string-concatenate-reverse filled-buffer-l buffer i))
                (parser-error port "EOF while reading a token " comment)))
           ((>= i curr-buf-len)
            (outer (make-string curr-buf-len)
                   (cons buffer filled-buffer-l) c))
           (else
            (string-set! buffer i c)
            (read-char port)
            (loop (inc i) (peek-char port))))))))

  (define-opt (next-token-of incl-list/pred
                             (optional (port (current-input-port))) )
    (let* ((buffer (input-parse:init-buffer))
           (curr-buf-len (string-length buffer)))
      (if (procedure? incl-list/pred)
          (let outer ((buffer buffer) (filled-buffer-l '()))
            (let loop ((i 0))
              (if (>= i curr-buf-len)		; make sure we have space
                  (outer (make-string curr-buf-len) (cons buffer filled-buffer-l))
                  (let ((c (incl-list/pred (peek-char port))))
                    (if c
                        (begin
                          (string-set! buffer i c)
                          (read-char port)			; move to the next char
                          (loop (inc i)))
                                        ; incl-list/pred decided it had had enough
                        (if (null? filled-buffer-l) (substring buffer 0 i)
                            (string-concatenate-reverse filled-buffer-l buffer i)))))))

                                        ; incl-list/pred is a list of allowed characters
          (let outer ((buffer buffer) (filled-buffer-l '()))
            (let loop ((i 0))
              (if (>= i curr-buf-len)		; make sure we have space
                  (outer (make-string curr-buf-len) (cons buffer filled-buffer-l))
                  (let ((c (peek-char port)))
                    (cond
                     ((not (memv c incl-list/pred))
                      (if (null? filled-buffer-l) (substring buffer 0 i)
                          (string-concatenate-reverse filled-buffer-l buffer i)))
                     (else
                      (string-set! buffer i c)
                      (read-char port)
                      (loop (inc i)))))))))))

  (define *read-line-breaks* (list char-newline char-return '*eof*))

  (define-opt (read-text-line (optional (port (current-input-port))) )
    (if (eof-object? (peek-char port)) (peek-char port)
        (let* ((line
                (next-token '() *read-line-breaks*
                            "reading a line" port))
               (c (read-char port)))
          (and (eqv? c char-return) (eqv? (peek-char port) #\newline)
               (read-char port))
          line)))

  (define-opt (read-string n (optional (port (current-input-port))) )
    (if (not (positive? n)) ""
        (let ((buffer (make-string n)))
          (let loop ((i 0) (c (read-char port)))
            (if (eof-object? c) (substring buffer 0 i)
                (let ((i1 (inc i)))
                  (string-set! buffer i c)
                  (if (= i1 n) buffer
                      (loop i1 (read-char port)))))))))

  (define (miscio:find-string-from-port? str <input-port> . max-no-char)
    (set! max-no-char (if (null? max-no-char) #f (car max-no-char)))
    (letrec
        ((no-chars-read 0)
         (my-peek-char
          (lambda () (and (or (not max-no-char) (< no-chars-read max-no-char))
                          (let ((c (peek-char <input-port>)))
                            (if (eof-object? c) #f c)))))
         (next-char (lambda () (read-char <input-port>)
                            (set! no-chars-read  (inc no-chars-read))))
         (match-1st-char
          (lambda ()
            (let ((c (my-peek-char)))
              (if (not c) #f
                  (begin (next-char)
                         (if (char=? c (string-ref str 0))
                             (match-other-chars 1)
                             (match-1st-char)))))))
         (match-other-chars
          (lambda (pos-to-match)
            (if (>= pos-to-match (string-length str))
                no-chars-read
                (let ((c (my-peek-char)))
                  (and c
                       (if (not (char=? c (string-ref str pos-to-match)))
                           (backtrack 1 pos-to-match)
                           (begin (next-char)
                                  (match-other-chars (inc pos-to-match)))))))))
         (backtrack
          (lambda (i matched-substr-len)
            (let ((j (- matched-substr-len i)))
              (if (<= j 0)
                  (match-1st-char)
                  (let loop ((k 0))
                    (if (>= k j)
                        (match-other-chars j)
                        (if (char=? (string-ref str k)
                                    (string-ref str (+ i k)))
                            (loop (inc k))
                            (backtrack (inc i) matched-substr-len)))))))))
      (match-1st-char)))

  (define find-string-from-port? miscio:find-string-from-port?)


; make-char-quotator QUOT-RULES
;
; Given QUOT-RULES, an assoc list of (char . string) pairs, return
; a quotation procedure. The returned quotation procedure takes a string
; and returns either a string or a list of strings. The quotation procedure
; check to see if its argument string contains any instance of a character
; that needs to be encoded (quoted). If the argument string is "clean",
; it is returned unchanged. Otherwise, the quotation procedure will
; return a list of string fragments. The input straing will be broken
; at the places where the special characters occur. The special character
; will be replaced by the corresponding encoding strings.
;
; For example, to make a procedure that quotes special HTML characters,
; do
;	(make-char-quotator
;	    '((#\< . "&lt;") (#\> . "&gt;") (#\& . "&amp;") (#\" . "&quot;")))

(define (make-char-quotator char-encoding)
  (let ((bad-chars (map car char-encoding)))

    ; Check to see if str contains one of the characters in charset,
    ; from the position i onward. If so, return that character's index.
    ; otherwise, return #f
    (define (index-cset str i charset)
      (let loop ((i i))
	(and (< i (string-length str))
	     (if (memv (string-ref str i) charset) i
		 (loop (inc i))))))

    ; The body of the function
    (lambda (str)
      (let ((bad-pos (index-cset str 0 bad-chars)))
	(if (not bad-pos) str	; str had all good chars
	    (let loop ((from 0) (to bad-pos))
	      (cond
	       ((>= from (string-length str)) '())
	       ((not to)
		(cons (substring str from (string-length str)) '()))
	       (else
		(let ((quoted-char
		       (cdr (assv (string-ref str to) char-encoding)))
		      (new-to 
		       (index-cset str (inc to) bad-chars)))
		  (if (< from to)
		      (cons
		       (substring str from to)
		       (cons quoted-char (loop (inc to) new-to)))
		      (cons quoted-char (loop (inc to) new-to))))))))))
))
