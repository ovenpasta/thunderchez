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


 (define mdb-guardian (make-guardian))
 (define (mdb-guard-pointer obj) 
   (mdb-free-garbage) 
   ;(printf "guarding pointer ~d~n" obj)
   (mdb-guardian obj)
   obj)

 (define (mdb-free-garbage)
   (define addr ftype-pointer-address)
   (define (free-ptr p) (foreign-free (addr p)))
   (let loop ([p (mdb-guardian)])
     (when p
	   (when (ftype-pointer? p)
		 ;(printf "mdb-free-garbage: freeing memory at ~x\n" p)
		 ;;[(ftype-pointer? usb-device*-array p)
		 (cond 
		  [(ftype-pointer? mdb-txn* p) (free-ptr p)]
		  [(ftype-pointer? mdb-env* p) (free-ptr p)]
		 ;; [(ftype-pointer? mdb-txn p) (mdb-txn-abort p)]
		  [(ftype-pointer? mdb-env p) (mdb-env-close p)]
		  [(ftype-pointer? mdb-cursor p) (mdb-cursor-close p)]
		  ;;[(ftype-pointer? mdb-dbi p) (mdb-dbi-close env! p)]
		  [else
		   (foreign-free (ftype-pointer-address p))]
		  ))
	   (loop (mdb-guardian)))))		


