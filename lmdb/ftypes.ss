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

