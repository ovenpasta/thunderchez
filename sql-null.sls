;;; "sql-null.scm" -- SQL NULL object and the ternary logic  -*- Scheme -*-

;;; Ivan Shmakov, 2007  This code is in public domain.

(library (sql-null)
  (export sql-null sql-null? sql-not sql-or sql-or sql-and sql-coalesce)

  (import (chezscheme))

  ;;from chicken data-structures.scm  Copyright (c) 2008-2014, The Chicken Team
  (define (constantly . xs)
    (if (eq? 1 (length xs))
	(let ([x (car xs)])
	  (lambda _ x) )
	(lambda _ (apply values xs)) ) )

  ;; We could also (define-record sql-null) and alias sql-null to make-sql-null
  ;; but that implies creating many new objects, which we don't want.
  (define-record-type sql-null-type)
  (define sql-null-object (make-sql-null-type))
  (define sql-null (constantly sql-null-object))
  (define sql-null? sql-null-type?)

  (define (sql-not o)
    (if (sql-null? o) o (not o)))

  (define-syntax sql-or
    (syntax-rules ()
      ((sql-or a ...)
       (sql-or/null #f a ...))))

  (define-syntax sql-or/null
    (syntax-rules ()
      ((sql-or/null null)
       null)
      ((sql-or/null null a b ...)
       (let ((ea a))
	 (cond ((sql-null? ea) (sql-or/null ea    b ...))
	       ((not ea)       (sql-or/null null b ...))
	       (else           ea))))))

  (define-syntax sql-and
    (syntax-rules ()
      ((sql-and a ...)
       (sql-and/null #t a ...))))

  (define-syntax sql-and/null
    (syntax-rules ()
      ((sql-and/null null)
       null)
      ((sql-and/null null a b ...)
       (let ((ea a))
	 (cond ((sql-null? ea) (sql-and/null ea    b ...))
	       (ea             (sql-and/null null b ...))
	       (else           ea))))))

  (define-syntax sql-coalesce
    (syntax-rules ()
      ((sql-coalesce)
       (sql-null))
      ((sql-coalesce a b ...)
       (let ((ea a))
	 (if (sql-null? ea)
	     (sql-coalesce b ...)
	     ea)))))

  )
