;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

#!r6rs
(library 
 (lmdb) 
 (export
  mdb-version mdb-strerror mdb-env-create mdb-env-open mdb-env-copy
  mdb-env-copyfd mdb-env-copy2 mdb-env-copyfd2 mdb-env-stat mdb-env-info
  mdb-env-sync mdb-env-close mdb-env-set-flags mdb-env-get-flags
  mdb-env-get-path mdb-env-get-fd mdb-env-set-mapsize
  mdb-env-set-maxreaders mdb-env-get-maxreaders mdb-env-set-maxdbs
  mdb-env-get-maxkeysize mdb-env-set-userctx mdb-env-get-userctx
  mdb-env-set-assert mdb-txn-begin mdb-txn-env mdb-txn-id mdb-txn-commit
  mdb-txn-abort mdb-txn-reset mdb-txn-renew mdb-dbi-open mdb-stat
  mdb-dbi-flags mdb-dbi-close mdb-drop mdb-set-compare mdb-set-dupsort
  mdb-set-relfunc mdb-set-relctx mdb-get mdb-put mdb-del mdb-cursor-open
  mdb-cursor-close mdb-cursor-renew mdb-cursor-txn mdb-cursor-dbi
  mdb-cursor-get mdb-cursor-put mdb-cursor-del mdb-cursor-count mdb-cmp
  mdb-dcmp mdb-reader-list mdb-reader-check

  MDB_SUCCESS MDB_KEYEXIST MDB_NOTFOUND MDB_PAGE_NOTFOUND MDB_CORRUPTED
  MDB_PANIC MDB_VERSION_MISMATCH MDB_INVALID MDB_MAP_FULL MDB_DBS_FULL
  MDB_READERS_FULL MDB_TLS_FULL MDB_TXN_FULL MDB_CURSOR_FULL
  MDB_PAGE_FULL MDB_MAP_RESIZED MDB_INCOMPATIBLE MDB_BAD_RSLOT
  MDB_BAD_TXN MDB_BAD_VALSIZE MDB_BAD_DBI MDB_PROBLEM MDB_LAST_ERRCODE


  MDB_FIXEDMAP MDB_NOSUBDIR MDB_NOSYNC MDB_RDONLY MDB_NOMETASYNC
  MDB_WRITEMAP MDB_MAPASYNC MDB_NOTLS MDB_NOLOCK MDB_NORDAHEAD
  MDB_NOMEMINIT MDB_REVERSEKEY MDB_DUPSORT MDB_INTEGERKEY MDB_DUPFIXED
  MDB_INTEGERDUP MDB_REVERSEDUP MDB_CREATE

  MDB_NOOVERWRITE MDB_NODUPDATA MDB_CURRENT MDB_RESERVE MDB_APPEND
  MDB_APPENDDUP MDB_MULTIPLE

  MDB_CP_COMPACT

  MDB_VERSION_MAJOR MDB_VERSION_MINOR MDB_VERSION_PATCH

  mdb-env mdb-txn mdb-dbi mdb-cursor mdb-val mdb-cmb-func mdb-rel-func
  mdb-stat-t mdb-envinfo-t

  mdb-cursor-op mdb-cursor-op-ref mdb-cursor-op-t
  
  mdb-library-init

  mdb-alloc-val mdb-alloc-txn* mdb-alloc-env* mdb-alloc-dbi
  make-mdb-val mdb-val-size-set! mdb-val-data-set!
  mdb-val->bytevector mdb-val-size mdb-val-data
  
  with-mdb-env with-mdb-dbi with-mdb-txn  
  mdb-null-txn mdb-null-val
  mdb-free-garbage mdb-guardian mdb-guard-pointer

  make-mdb-cond mdb-cond? mdb-cond-errno mdb-cond-str
  ) ;export
 (import (ffi-utils) (chezscheme))
 
 (define (mdb-library-init . t)
   (load-shared-object (if (null? t) "liblmdb.so" (car t))))


(include "lmdb/ffi.ss") 
(include "lmdb/constants.ss")
(include "lmdb/enums.ss")
(include "lmdb/ftypes.ss")
(include "lmdb/guardian.ss")

(define-condition-type &mdb-cond &condition
  make-mdb-cond mdb-cond?
  (errno mdb-cond-errno)
  (str mdb-cond-str))

(include "lmdb/lmdb-functions.ss")


(define-mdb-allocator mdb-alloc-val mdb-val)
(define-mdb-allocator mdb-alloc-dbi mdb-dbi)

;(define (mdb-alloc-void) (make-ftype-pointer void* (foreign-alloc (ftype-sizeof void*))))
(define-mdb-allocator mdb-alloc-env* mdb-env*)
(define-mdb-allocator mdb-alloc-txn* mdb-txn*)
(define-mdb-allocator mdb-alloc-cursor* mdb-cursor*)

(define (bytevector->char-array bv)
  (let ([ptr (cast unsigned-8 
		   (foreign-alloc (bytevector-length bv)))])
    (for-each (lambda (i) 
		(ftype-set! unsigned-8 () ptr i (bytevector-u8-ref bv i)))
	      (iota (bytevector-length bv)))
    ptr))

(define (char-array->bytevector ptr len)
  (let ([bv (make-bytevector len)])
    (for-each (lambda (i) 
		(bytevector-u8-set! bv i (ftype-ref unsigned-8 () ptr i)))
	      (iota len))
    bv))

(define make-mdb-val 
  (case-lambda 
   [(data)
    (let ([data (if (bytevector? data) data
		    (string->utf8 data))])
      (let ([val (mdb-alloc-val)])
	(mdb-val-data-set! val data)
	(mdb-val-size-set! val (bytevector-length data))
	val))]
   [() (mdb-alloc-val)]))

(define (mdb-val-size-set! v size)
  (ftype-set! mdb-val (mv-size) v size))

(define (mdb-val-data-set! k data)
  (ftype-set! mdb-val (mv-data) k
	      (ftype-pointer-address
	       (cond [(bytevector? data) (bytevector->char-array data)]
		     [else data]))))

(define (mdb-val-size k)
  (ftype-ref mdb-val (mv-size) k))
(define (mdb-val-data k)
  (make-ftype-pointer unsigned-8 (ftype-ref mdb-val (mv-data) k)))
 
(define (mdb-val->bytevector k)
  (char-array->bytevector (mdb-val-data k) (mdb-val-size k)))

(define mdb-null-txn (make-ftype-pointer mdb-txn 0))
(define mdb-null-val (make-ftype-pointer mdb-val 0))

(define (mdb-txn-begin env parent flags)
  (define (mdb-txn-ref txn*)
    (make-ftype-pointer mdb-txn (ftype-ref mdb-txn* () txn*)))
  (let* ([txn* (mdb-alloc-txn*)]
	 [xxx (ftype-set! mdb-txn* () txn* 0)]
	 [e1 (mdb-txn-begin% env parent flags (ftype-pointer-address txn*))]
	 [txn (mdb-txn-ref txn*)])
    txn))

(define-syntax with-mdb-txn
   (syntax-rules ()
     [(_ (txn-name env parent flags) forms ...)
      (let ([txn-name (mdb-txn-begin env parent flags)]
	    [commit #f])
	(guard (e [(eq? e 'abort-txn) (mdb-txn-abort txn-name)]
		  [(eq? e 'commit-txn) (mdb-txn-commit txn-name)]
		  [else (mdb-txn-abort txn-name) 
			(raise e)])
	        forms ... 
	       (mdb-txn-commit txn-name)))]))

(define-syntax with-mdb-dbi
  (syntax-rules ()
    [(_ (dbi-name txn name flags) forms ...)
     (let ([dbi-name (mdb-dbi-open txn name flags)])
       forms ...
       (mdb-dbi-close (mdb-txn-env txn) dbi-name))]))

(define (mdb-dbi-open txn name flags) 
  (define (mdb-dbi-ref dbi*)
    (ftype-ref unsigned-int () dbi*))
  (let* ([dbi* (mdb-alloc-dbi)]
	 [e2 (mdb-dbi-open% txn name flags dbi*)]
	 [dbi (mdb-dbi-ref dbi*)])
    ;;FIXME; GUARDIAN CANNOT BE APPLIED BECAUSE WE NEED ALSO env
    ;; MAYBE STORE THE ENV SOMEWHERE?
    dbi))
  
(define (mdb-cursor-open txn dbi)
  (define (mdb-cursor-ref cursor*)
    (make-ftype-pointer mdb-cursor (ftype-ref mdb-cursor* () cursor*)))
  (let* ([cursor* (mdb-alloc-cursor*)]
	 [e2 (mdb-cursor-open% txn dbi (ftype-pointer-address cursor*))]
	 [cursor (mdb-guard-pointer (mdb-cursor-ref cursor*))])
    ;;FIXME; GUARDIAN CANNOT BE APPLIED BECAUSE WE NEED ALSO env
    ;; MAYBE STORE THE ENV SOMEWHERE?
    cursor))

(define (mdb-env-create)
  (define (mdb-env-ref env*)
    (make-ftype-pointer mdb-env (ftype-ref mdb-env* () env*)))
  (let* ([env* (mdb-alloc-env*)]
	 [e (mdb-env-create%  (ftype-pointer-address env*))]
	 [env (mdb-guard-pointer (mdb-env-ref env*))])
    env))

(define-syntax with-mdb-env 
  (syntax-rules ()
    [(_ (env-name) forms ...)
     (let* ([env-name (mdb-env-create)])
       forms ...
       (mdb-env-close env-name))]))


 );;library
