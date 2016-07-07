
(cond-expand
 (chicken
  (load "fmt-js-chicken.scm"))
 (else))

(cond-expand
 (chicken
  (use test)
  (import fmt)
  (import fmt-js))
 (gauche
  (use gauche.test)
  (use text.fmt)
  (use text.fmt.js)
  (define test-begin test-start)
  (define orig-test (with-module gauche.test test))
  (define-syntax test
    (syntax-rules ()
      ((test name expected expr)
       (orig-test name expected (lambda () expr)))
      ((test expected expr)
       (orig-test (let ((s (with-output-to-string (lambda () (write 'expr)))))
                    (substring s 0 (min 60 (string-length s))))
                  expected
                  (lambda () expr)))
      )))
 (else))

(test-begin "fmt-js")

(test "var foo = 1 + 2;\n"
    (fmt #f (js-expr '(%var foo (+ 1 2)))))

(test "var foo = 1 + 2;\n"
    (fmt #f (js-expr '(%begin (%var foo (+ 1 2))))))

(test "function square(x) {
    return x * x;
}"
    (fmt #f (js-function 'square '(x) '(* x x))))

(test "{\"foo\": [1, 2, 3], \"bar\": \"baz\"}"
    (fmt #f (js-expr '(%object ("foo" . #(1 2 3)) ("bar" . "baz")))))

(test-end)
