
;; FIXME #ifdef_MSC_VER

 (define-ftype mdb-mode-t int) ;;//?!?!?! FIXME
 (define-ftype mdb-size-t integer-64)

;; FIXME #ifdef _WIN32
 ; (define-ftype mdb-filehandle-t void*)
 (define-ftype mdb-filehandle-t int)

 (define-ftype mdb-env* void*)
 (define-ftype mdb-txn* void*)
 (define-ftype mdb-env (struct))
 (define-ftype mdb-txn (struct))
 (define-ftype mdb-dbi unsigned-int)
 (define-ftype mdb-cursor (struct))
 (define-ftype mdb-cursor* void*)
 (define-ftype mdb-val (struct (mv-size size_t)
			       (mv-data void*)))
 (define-ftype mdb-cmb-func void*);(MDB_cmp_func)(const MDB_val *a, const MDB_val *b);

 (define-ftype mdb-rel-func void*);typedef void (MDB_rel_func)(MDB_val *item, void *oldptr, void *newptr, void *relctx);

 (define-ftype mdb-stat-t
  (struct
   (ms-psize unsigned-int)
   (ms-depth unsigned-int)
   (ms-branch-pages mdb-size-t)
   (ms-leaf-pages mdb-size-t)
   (ms-overflow-pages mdb-size-t)
   (ms-entries mdb-size-t)))

 (define-ftype mdb-envinfo-t
   (struct
    (me-mapsize mdb-size-t)
    (me-last-pgno mdb-size-t)
    (me-last-txnid mdb-size-t)
    (me-maxreaders unsigned-int)
    (me-numreaders unsigned-int)))

