(load "sxml-match.ss")
(import sxml-matcher)

(define-syntax run-test
  (syntax-rules ()
    ((run-test desc test expected-result)
     (let ((expected expected-result))
       (newline)
       (display "Running test ")
       (write desc)
       (display ":")
       (newline)
       (pretty-print (quote test))
       (let ((actual test))
         (if (equal? actual expected)
             (begin (newline)
                    (display "gave the expected result: ")
                    (pretty-print actual)
                    (newline))
             (begin (newline (current-error-port))
                    (display "Unexpected result: " (current-error-port))
                    (write actual (current-error-port))
                    (newline (current-error-port))
                    (display "expected " (current-error-port))
                    (write expected (current-error-port))
                    (newline (current-error-port)))))))))

(define-syntax compile-match
  (syntax-rules ()
    [(compile-match pat action0 action ...)
     (lambda (x)
       (sxml-match x [pat action0 action ...]))]))

(run-test "basic match of a top-level pattern var"
          (sxml-match '(e 3 4 5)
            [,y (list "matched" y)])
          '("matched" (e 3 4 5)))
(run-test "match of simple element contents with pattern vars"
          ((compile-match (e ,a ,b ,c) (list a b c)) '(e 3 4 5))
          '(3 4 5))
(run-test "match a literal pattern within a element pattern"
          ((compile-match (e ,a "abc" ,c) (list a c)) '(e 3 "abc" 5))
          '(3 5))
(run-test "match an empty element"
          ((compile-match (e) "match") '(e))
          "match")
(run-test "match a nested element"
          ((compile-match (e ,a (f ,b ,c) ,d) (list a b c d)) '(e 3 (f 4 5) 6))
          '(3 4 5 6))
(run-test "match a dot-rest pattern within a nested element"
          ((compile-match (e ,a (f . ,y) ,d) (list a y d)) '(e 3 (f 4 5) 6))
          '(3 (4 5) 6))
(run-test "match a basic list pattern"
          ((compile-match (list ,a ,b ,c ,d ,e) (list a b c d e)) '("i" "j" "k" "l" "m"))
          '("i" "j" "k" "l" "m"))
(run-test "match a list pattern with a dot-rest pattern"
          ((compile-match (list ,a ,b ,c . ,y) (list a b c y)) '("i" "j" "k" "l" "m"))
          '("i" "j" "k" ("l" "m")))
(run-test "basic test of a multi-clause sxml-match"
          (sxml-match '(a 1 2 3)
            ((a ,n) n)
            ((a ,m ,n) (+ m n))
            ((a ,m ,n ,o) (list "matched" (list m n o))))
          '("matched" (1 2 3)))
(run-test "basic test of a sxml-match-let"
          (sxml-match-let ([(a ,i ,j) '(a 1 2)])
            (+ i j))
          3)
(run-test "basic test of a sxml-match-let*"
          (sxml-match-let* ([(a ,k) '(a (b 1 2))]
                            [(b ,i ,j) k])
            (list i j))
          '(1 2))
(run-test "match of top-level literal string pattern"
          ((compile-match "abc" "match") "abc")
          "match")
(run-test "match of top-level literal number pattern"
          ((compile-match 77 "match") 77)
          "match")
(run-test "test of multi-expression guard in pattern"
          (sxml-match '(a 1 2 3)
            ((a ,n) n)
            ((a ,m ,n) (+ m n))
            ((a ,m ,n ,o) (guard (number? m) (number? n) (number? o)) (list "guarded-matched" (list m n o))))
          '("guarded-matched" (1 2 3)))
(run-test "basic test of multiple action items in match clause"
          ((compile-match 77 (display "match-77\n") "match") 77)
          "match")

(define simple-eval
  (lambda (x)
    (sxml-match x
      [,i (guard (integer? i)) i]
      [(+ ,x ,y) (+ (simple-eval x) (simple-eval y))]
      [(* ,x ,y) (* (simple-eval x) (simple-eval y))]
      [(- ,x ,y) (- (simple-eval x) (simple-eval y))]
      [(/ ,x ,y) (/ (simple-eval x) (simple-eval y))]
      [,otherwise (error "simple-eval: invalid expression" x)])))

(run-test "basic test of explicit recursion in match clauses"
          (simple-eval '(* (+ 7 3) (- 7 3)))
          40)

(define simple-eval2
  (lambda (x)
    (sxml-match x
      [,i (guard (integer? i)) i]
      [(+ ,[x] ,[y]) (+ x y)]
      [(* ,[x] ,[y]) (* x y)]
      [(- ,[x] ,[y]) (- x y)]
      [(/ ,[x] ,[y]) (/ x y)]
      [,otherwise (error "simple-eval: invalid expression" x)])))

(run-test "basic test of anonymous catas"
          (simple-eval2 '(* (+ 7 3) (- 7 3)))
          40)

(define simple-eval3
  (lambda (x)
    (sxml-match x
      [,i (guard (integer? i)) i]
      [(+ ,[simple-eval3 -> x] ,[simple-eval3 -> y]) (+ x y)]
      [(* ,[simple-eval3 -> x] ,[simple-eval3 -> y]) (* x y)]
      [(- ,[simple-eval3 -> x] ,[simple-eval3 -> y]) (- x y)]
      [(/ ,[simple-eval3 -> x] ,[simple-eval3 -> y]) (/ x y)]
      [,otherwise (error "simple-eval: invalid expression" x)])))

(run-test "test of named catas"
          (simple-eval3 '(* (+ 7 3) (- 7 3)))
          40)

; need a test case for cata on a ". rest)" pattern

(run-test "successful test of attribute matching: pat-var in value position"
          (sxml-match '(e (@ (z 1)) 3 4 5)
            [(e (@ (z ,d)) ,a ,b ,c) (list d a b c)]
            [,otherwise #f])
          '(1 3 4 5))

(run-test "failing test of attribute matching: pat-var in value position"
          (sxml-match '(e (@ (a 1)) 3 4 5)
            [(e (@ (z ,d)) ,a ,b ,c) (list d a b c)]
            [,otherwise #f])
          #f)

(run-test "test of attribute matching: literal in value position"
          ((compile-match (e (@ (z 1)) ,a ,b ,c) (list a b c)) '(e (@ (z 1)) 3 4 5))
          '(3 4 5))

(run-test "test of attribute matching: default-value spec in value position"
          ((compile-match (e (@ (z (,d 1))) ,a ,b ,c) (list d a b c)) '(e 3 4 5))
          '(1 3 4 5))

(run-test "test of attribute matching: multiple attributes in pattern"
          ((compile-match (e (@ (y ,e) (z ,d)) ,a ,b ,c) (list e d a b c)) '(e (@ (z 1) (y 2)) 3 4 5))
          '(2 1 3 4 5))

(run-test "basic test of ellipses in pattern; no ellipses in output"
          ((compile-match (e ,i ...) i) '(e 3 4 5))
          '(3 4 5))

(run-test "test of non-null tail pattern following ellipses"
          ((compile-match (e ,i ... ,a ,b) i) '(e 3 4 5 6 7))
          '(3 4 5 ))

(define simple-eval4
  (lambda (x)
    (sxml-match x
      [,i (guard (integer? i)) i]
      [(+ ,[x*] ...) (apply + x*)]
      [(* ,[x*] ...) (apply * x*)]
      [(- ,[x] ,[y]) (- x y)]
      [(/ ,[x] ,[y]) (/ x y)]
      [,otherwise (error "simple-eval: invalid expression" x)])))

(run-test "test of catas with ellipses in pattern"
          (simple-eval4 '(* (+ 7 3) (- 7 3)))
          40)

(run-test "simple test of ellipses in pattern and output"
          ((compile-match (e ,i ...) ((lambda rst (cons 'f rst)) i ...)) '(e 3 4 5))
          '(f 3 4 5))

(define simple-eval5
  (lambda (x)
    (sxml-match x
      [,i (guard (integer? i)) i]
      [(+ ,[x*] ...) (+ x* ...)]
      [(* ,[x*] ...) (* x* ...)]
      [(- ,[x] ,[y]) (- x y)]
      [(/ ,[x] ,[y]) (/ x y)]
      [,otherwise (error "simple-eval: invalid expression" x)])))

(run-test "test of catas with ellipses in pattern and output"
          (simple-eval5 '(* (+ 7 3) (- 7 3)))
          40)

(run-test "test of nested dots in pattern and output"
          ((lambda (x)
             (sxml-match x
               [(d (a ,b ...) ...)
                (list (list b ...) ...)]))
           '(d (a 1 2 3) (a 4 5) (a 6 7 8) (a 9 10)))
          '((1 2 3) (4 5) (6 7 8) (9 10)))

(run-test "test successful tail pattern match (after ellipses)"
          (sxml-match '(e 3 4 5 6 7) ((e ,i ... 6 7) #t) (,otherwise #f))
          #t)

(run-test "test failing tail pattern match (after ellipses), too few items"
          (sxml-match '(e 3 4 5 6) ((e ,i ... 6 7) #t) (,otherwise #f))
          #f)

(run-test "test failing tail pattern match (after ellipses), too many items"
          (sxml-match '(e 3 4 5 6 7 8) ((e ,i ... 6 7) #t) (,otherwise #f))
          #f)

(run-test "test failing tail pattern match (after ellipses), wrong items"
          (sxml-match '(e 3 4 5 7 8) ((e ,i ... 6 7) #t) (,otherwise #f))
          #f)

(run-test "test of ellipses in output quasiquote"
          (sxml-match '(e 3 4 5 6 7)
            [(e ,i ... 6 7) `("start" ,i ... "end")]
            [,otherwise #f])
          '("start" 3 4 5 "end"))

(run-test "test of ellipses in output quasiquote, with more complex unquote expression"
          (sxml-match '(e 3 4 5 6 7)
            [(e ,i ... 6 7) `("start" ,(list 'wrap i) ... "end")]
            [,otherwise #f])
          '("start" (wrap 3) (wrap 4) (wrap 5) "end"))

(run-test "test of a quasiquote expr within the dotted unquote expression"
          (sxml-match '(e 3 4 5 6 7)
            [(e ,i ... 6 7) `("start" ,`(wrap ,i) ... "end")]
            [,otherwise #f])
          '("start" (wrap 3) (wrap 4) (wrap 5) "end"))

(define x '(d (a 1 2 3) (a 4 5) (a 6 7 8) (a 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(,`(,b ...) ...)])
          '((1 2 3) (4 5) (6 7 8) (9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             (list (list b ...) ...)])
          '((1 2 3) (4 5) (6 7 8) (9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx ,`(y ,b ...) ...)])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx ,@(map (lambda (i) `(y ,@i)) b))])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx ,(cons 'y b) ...)])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx ,`(y ,b ...) ...)])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx ,`(y ,@b) ...)])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `((,b ...) ...)])
          '((1 2 3) (4 5) (6 7 8) (9 10)))

(run-test "quasiquote tests"
          (sxml-match x
            [(d (a ,b ...) ...)
             `(xx (y ,b ...) ...)])
          '(xx (y 1 2 3) (y 4 5) (y 6 7 8) (y 9 10)))

(define (prog-trans p)
  (sxml-match p
    [(Program (Start ,start-time) (Duration ,dur) (Series ,series-title)
              (Description . ,desc)
              ,cl)
     `(div (p ,start-time
              (br) ,series-title
              (br) ,desc)
           ,cl)]
    [(Program (Start ,start-time) (Duration ,dur) (Series ,series-title)
              (Description . ,desc))
     `(div (p ,start-time
              (br) ,series-title
              (br) ,desc))]
    [(Program (Start ,start-time) (Duration ,dur) (Series ,series-title))
     `(div (p ,start-time
              (br) ,series-title))]))

(run-test "test for shrinking-order list of pattern clauses"
          (prog-trans '(Program (Start "2001-07-05T20:00:00") (Duration "PT1H") (Series "HomeFront")))
          '(div (p "2001-07-05T20:00:00" (br) "HomeFront")))

(run-test "test binding of unmatched attributes"
          (sxml-match '(a (@ (z 1) (y 2) (x 3)) 4 5 6)
            [(a (@ (y ,www) . ,qqq) ,t ...)
             (list www qqq t ...)])
          '(2 ((z 1) (x 3)) 4 5 6))

(run-test "test binding all attributes"
          (sxml-match '(a (@ (z 1) (y 2) (x 3)) 4 5 6)
            [(a (@ . ,qqq) ,t ...)
             (list qqq t ...)])
          '(((z 1) (y 2) (x 3)) 4 5 6))

