

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


