;;; Chez-Scheme Wrappers for Alex Shinn's Match (Wright Compatible)
;;; 
;;; Copyright (c) 2016 Federico Beffa <beffa@fbengineering.ch>
;;; 
;;; Permission to use, copy, modify, and distribute this software for
;;; any purpose with or without fee is hereby granted, provided that the
;;; above copyright notice and this permission notice appear in all
;;; copies.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;;; PERFORMANCE OF THIS SOFTWARE.

;; The reader in #!r6rs mode doesn't allow the '..1' identifier.
#!chezscheme
(library (matchable)
  (export 
    match
    match-lambda 
    match-lambda* 
    match-let 
    match-let* 
    match-letrec
    match-named-let
    :_ ___ ..1 *** ? $ struct @ object)
  
  #;(import 
   (rnrs base)
   (rnrs lists)
   (rnrs mutable-pairs)
   (rnrs records syntactic)
   (rnrs records procedural)
   (rnrs records inspection)
   (rnrs syntax-case)
   (only (chezscheme) iota include)
   ;; avoid dependence on chez-srfi (apart for tests)
   ;; (srfi private aux-keywords)
   ;; (srfi private include)
   )
   (import (chezscheme))

  ;; We declare end export the symbols used as auxiliary identifiers
  ;; in 'syntax-rules' to make them work in Chez Scheme's interactive
  ;; environment. (FBE)

  ;; Also we replaced '_' with ':_' as the special identifier matching
  ;; anything and not binding.  This is because R6RS forbids its use
  ;; as an auxiliary literal in a syntax-rules form.
  (define-syntax define-auxiliary-keyword
    (syntax-rules ()
      [(_ name)
       (define-syntax name 
         (lambda (x)
           (syntax-violation #f "misplaced use of auxiliary keyword" x)))]))

  (define-syntax define-auxiliary-keywords
    (syntax-rules ()
      [(_ name* ...)
       (begin (define-auxiliary-keyword name*) ...)]))

  (define-auxiliary-keywords :_ ___ ..1 *** ? $ struct @ object)

  (define-syntax is-a?
    (syntax-rules ()
      ((_ rec rtn)
       (and (record? rec)
            (eq? (record-type-name (record-rtd rec)) (quote rtn))))))

  (define-syntax slot-ref
    (syntax-rules ()
      ((_ rtn rec n)
       (if (number? n)
           ((record-accessor (record-rtd rec) n) rec)
           ;; If it's not a number, then it should be a symbol with
           ;; the name of a field.
           (let* ((rtd (record-rtd rec))
                  (fields (record-type-field-names rtd))
                  (fields-idxs (map (lambda (f i) (cons f i))
                                    (vector->list fields)
                                    (iota (vector-length fields))))
                  (idx (cdr (assv n fields-idxs))))
             ((record-accessor rtd idx) rec))))))

  (define-syntax slot-set!
    (syntax-rules ()
      ((_ rtn rec n)
       (if (number? n)
           ((record-mutator (record-rtd rec) n) rec)
           ;; If it's not a number, then it should be a symbol with
           ;; the name of a field.
           (let* ((rtd (record-rtd rec))
                  (fields (record-type-field-names rtd))
                  (fields-idxs (map (lambda (f i) (cons f i))
                                    (vector->list fields)
                                    (iota (vector-length fields))))
                  (idx (cdr (assv n fields-idxs))))
             ((record-mutator rtd idx) rec))))))
  
  (include "match.scm")

  )
