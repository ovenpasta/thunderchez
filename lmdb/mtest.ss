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

(import (lmdb))
(mdb-library-init)

(random-seed (time-nanosecond (current-time)))

(define count (+ (random 384) 64))

(define values (map (lambda (i) (random 1024)) 
		    (iota count)))


(define env (mdb-env-create))

(mdb-env-set-maxreaders env 1)
(mdb-env-set-mapsize env 10485760)

(guard (x (else (printf "mkdir: ~d~n" (condition-message x)))) (mkdir "testdb"))

(let ([err (mdb-env-open env "./testdb" MDB_FIXEDMAP #o0664)])
  (mdb-strerror err))

(with-mdb-txn 
 (txn env mdb-null-txn 0)
 (define dbi (mdb-dbi-open txn #f 0))
 (let ( [j 0])
   (printf "adding ~d values~n" count)
   (for-each 
    (lambda (i)
      (let ([key (make-mdb-val 
		  (format "~x ~d foo bar" 
			  (list-ref values i)
			  (list-ref values i)))]
	    [data (make-mdb-val 
		   (format "~x ~d foo bar" 
			   (list-ref values i)
			   (list-ref values i)))])
	(guard (x [(and (mdb-cond? x) (= (mdb-cond-errno x) MDB_KEYEXIST))
		   (set! j (+ 1 j))])
	       (mdb-put txn dbi key data MDB_NOOVERWRITE))))
    (iota count))
   (if (> j 0)
       (printf "~d duplicates skipped~n" j))))

(with-mdb-txn 
 (txn env mdb-null-txn MDB_RDONLY)
 (define dbi (mdb-dbi-open txn #f 0))
 (define cursor (mdb-cursor-open txn dbi))
 (guard (e [(and (mdb-cond? e)
		 (= (mdb-cond-errno e) MDB_NOTFOUND)) #t]
	   [else (raise e)])
	(let loop ()
	    (let ([key (make-mdb-val)] [data (make-mdb-val)])
	      (mdb-cursor-get cursor key data (mdb-cursor-op 'next))
	      (printf "key: ~d ~d, data: ~d ~d~n" 
		      (mdb-val-size key) (utf8->string (mdb-val->bytevector key))
		      (mdb-val-size data) (utf8->string (mdb-val->bytevector data)))
	      (loop)))))
(printf "count:~d~n" count)
(let loop ([j 0] [i (- count 1)])
  (if (or (< j 0) (< i 0))
      (printf "deleted ~d values~n" j)
      (let* ([j (+ 1 j)]
	     [txn (mdb-txn-begin env mdb-null-txn 0)]
	     [dbi (mdb-dbi-open txn #f 0)]
	     [sval (format "~03x " (list-ref values i))])
	(guard (e [(and (mdb-cond? e)
			(= (mdb-cond-errno e) MDB_NOTFOUND)) 
		   (mdb-txn-abort txn)
		   (set! j (- j 1))]
		  [else (raise e)])
	       (mdb-del txn dbi (make-mdb-val sval) mdb-null-val)
	       (mdb-txn-commit txn))
	(loop j (- i (random 5))))))
	
