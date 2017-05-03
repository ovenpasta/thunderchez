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

#!chezscheme
(library (usb)
 (export 
  c-usb-device-descriptor
  c-usb-device
  usb-device
  usb-device-handle
  usb-device?

  usb-init
  usb-exit
  usb-get-device-list
  usb-get-device-descriptor
  
  usb-get-port-number
  usb-get-port-numbers
  usb-get-bus-number
  usb-get-device
  
  usb-find-vid-pid
  usb-display-device-list
  usb-strerror
  usb-open
  usb-close
  usb-claim-interface
  usb-release-interface
  
  usb-log-level-enum
  usb-log-level-index
  usb-log-level-ref
  usb-set-debug

  usb-control-transfer
  usb-bulk-read
  usb-bulk-write
  usb-interrupt-write
  usb-interrupt-read
  ) ;export

 (import (chezscheme)
	 (only (ffi-utils) cast char*->bytevector))

 (define library-init 
   (begin
     (load-shared-object "libusb-1.0.so.0")))

 (define-ftype c-usb-device (struct))
 (define-ftype c-usb-device*-array (array 0 (* c-usb-device)))
 (define-ftype c-usb-device*** (* c-usb-device*-array))
 (define-ftype usb-device-handle* void*)
 (define-ftype usb-device-handle** (* usb-device-handle*))

 (define-ftype c-usb-device-descriptor 
   (struct 
       [length unsigned-8]
       [type unsigned-8]
       [USB unsigned-16]
       [class unsigned-8]
       [subclass unsigned-8]
       [protocol unsigned-8]
       [max-packet-size unsigned-8]
       [vendor unsigned-16]
       [product unsigned-16]
       [device unsigned-16]
       [manufacturer unsigned-8]
       [product-index unsigned-8]
       [serial-number-index unsigned-8]
       [num-configurations unsigned-8]
     ))

 (define-record-type (usb-device make-usb-device% usb-device?)
   (fields
    (mutable ptr)))
 (define-record-type usb-device-handle
   (fields
    (mutable ptr)))

 (define usb-guardian (make-guardian))

 (define (make-usb-device ptr)
   (usb-guardian ptr)
   (make-usb-device% ptr))

 (define (usb-device-addr dev)
   (ftype-pointer-address (usb-device-ptr dev)))

 (define (usb-device-handle-addr dev)
   (ftype-pointer-address (usb-device-handle-ptr dev)))

 (define (usb-free-garbage)
   (let loop ([p (usb-guardian)])
     (when p
       (when (ftype-pointer? p)
	 ;(printf "freeing memory at ~x\n" p)
	 (cond [(ftype-pointer? c-usb-device*-array p)
		; FIXME THIS HANGS IF ENABLED
		#;((foreign-procedure "libusb_free_device_list" (void* int) void)
		 (ftype-pointer-address p) 0)]
	       [(ftype-pointer? c-usb-device p)
		((foreign-procedure "libusb_unref_device" ((* c-usb-device)) void) p)]
	       [else
		(foreign-free (ftype-pointer-address p))]))
       (loop (usb-guardian)))))
   
 (define (usb-get-device-list)
   (usb-free-garbage)
   (let* ([ptr (make-ftype-pointer c-usb-device*** (foreign-alloc (ftype-sizeof c-usb-device***)))]
	  [f (foreign-procedure "libusb_get_device_list" (void* void*) int)]
	  [%g (usb-guardian ptr)]
	  [e (f 0 (ftype-pointer-address ptr))])
     (if (< e 0)
	 (error 'usb-get-device-list "error" e))
     (let ((devices (ftype-&ref c-usb-device*** (*) ptr)))
       (usb-guardian devices)
       (let loop ((i 0) (l '()))
	 (if (>= i e) l
	     (loop (fx+ i 1) 
		   (cons (make-usb-device
			   (ftype-ref c-usb-device*-array (i) devices)) l)))))))

 (define (usb-get-device-descriptor dev)
   (usb-free-garbage)
   (let* ([ptr (make-ftype-pointer c-usb-device-descriptor 
				   (foreign-alloc (ftype-sizeof c-usb-device-descriptor)))]
	  [%g (usb-guardian ptr)]
	  [f (foreign-procedure "libusb_get_device_descriptor" ((* c-usb-device) (* c-usb-device-descriptor)) int)]
	  [e (f (usb-device-ptr dev) ptr )])
     (if (< e 0)
	 (error 'usb-get-device-descriptor "error" e)
	 ptr)))

  (define (usb-ref-device dev)
   (let* ([f (foreign-procedure "libusb_ref_device" ((* c-usb-device) ) (* c-usb-device))]
	  [ptr (f dev)])
     ptr))

  ;;FIXME: this would cause problems if the device is freed?
  (define (usb-get-device dev)
   (usb-free-garbage)
   (let* ([f (foreign-procedure "libusb_get_device" (usb-device-handle*) (* c-usb-device))]
	  [ptr (f (usb-device-handle-addr dev) )])
     (make-usb-device (usb-ref-device ptr))))

 (define (usb-init) 
   (let ([e ((foreign-procedure "libusb_init" (void*) int) 0)])
     (when (< e 0)
       (error 'usb-init "error" e))
     #t))

 (define (usb-exit) 
   (usb-free-garbage)
   (let ([e ((foreign-procedure "libusb_exit" (void*) int) 0)])
     (when (< e 0)
       (error 'usb-exit "error" e))
     #t))

 (define usb-log-level-enum (make-enumeration '(none error warning info debug)))
 (define usb-log-level-index (enum-set-indexer usb-log-level-enum))
 (define (usb-log-level-ref index)
   (list-ref (enum-set->list usb-log-level-enum) index))

 (define (usb-set-debug level) 
   (let ([e ((foreign-procedure "libusb_set_debug" (void* int) int) 
	     0 ; FIXME: ctx NULL, allow multiple contexts?
	     (usb-log-level-index level))])
     (when (< e 0)
       (error 'usb-exit "error" e))
     (void)))

 (define (usb-strerror code)
    ((foreign-procedure "libusb_strerror" (int) string) code))
 
 (define (usb-find-vid-pid vid pid) 
   (filter 
    (lambda (dev)
      (let ([descriptor (usb-get-device-descriptor dev)])
	(and (equal? (ftype-ref c-usb-device-descriptor (vendor) descriptor) vid)
	     (equal? (ftype-ref c-usb-device-descriptor (product) descriptor) pid))))
    (usb-get-device-list)))

 (define (usb-display-device-list)
   (pretty-print 
    (map
     (lambda (dev) 
       (ftype-pointer->sexpr (usb-get-device-descriptor dev)))
     (usb-get-device-list))))

 (define (usb-get-port-number dev)
   ((foreign-procedure "libusb_get_port_number" (void*) unsigned-8) (usb-device-addr dev)))
 
 (define (usb-get-port-numbers dev)
   (let* ([l (make-bytevector 10)]
	  [p (foreign-procedure "libusb_get_port_numbers" (void* u8* int)
				unsigned-8)]
	  [e (p (usb-device-addr dev) l (bytevector-length l))])
       (when (< e 0)
	 (error 'usb-open (usb-strerror e) e))
       (list-head (bytevector->u8-list l) e)))

 (define (usb-get-bus-number dev)
    ((foreign-procedure "libusb_get_bus_number" (void*) unsigned-8) (usb-device-addr dev)))

 (define (usb-open device)
   (assert (and 'usb-open (usb-device? device)))
   (usb-free-garbage)
   (let* ([ptr (make-ftype-pointer usb-device-handle** 
				   (foreign-alloc (ftype-sizeof usb-device-handle*)))]
	  [%g (usb-guardian ptr)]
	  [f (foreign-procedure "libusb_open" ((* c-usb-device) void*) int)]
	  [e (f (usb-device-ptr device) (ftype-pointer-address ptr))])
     (when (< e 0)
	 (error 'usb-open (usb-strerror e) e))
     (make-usb-device-handle (ftype-&ref usb-device-handle** (*) ptr))))

  (define (usb-close device)
   (assert (and 'usb-close (usb-device-handle? device)))
   (usb-free-garbage)
   (let* ([f (foreign-procedure "libusb_close" (void*) int)]
	  [e (f (usb-device-handle-addr device))])
     (when (< e 0)
       (error 'usb-open (usb-strerror e) e))))

 (define (usb-claim-interface h interface-number)
   (assert (and 'usb-claim-interface (usb-device-handle? h)))
   (usb-free-garbage)
   (let* ([f (foreign-procedure "libusb_claim_interface" (void* int) int)]
	  [e (f (ftype-pointer-address (usb-device-handle-ptr h)) interface-number)])
     (when (< e 0)
       (error 'usb-claim-interface (usb-strerror e) e))))

 (define (usb-release-interface h interface-number)
   (assert (and 'usb-release-interface (usb-device-handle? h)))
   (usb-free-garbage)
   (let* ([f (foreign-procedure "libusb_release_interface" (void* int) int)]
	  [e (f (ftype-pointer-address (usb-device-handle-ptr h)) interface-number)])
     (when (< e 0)
       (error 'usb-release-interface (usb-strerror e) e))))
     
 (define (alloc-int) 
   (let ([ptr (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))])
     (usb-guardian ptr)
     ptr))
 
 (define (usb-control-transfer handle type request value index data timeout)
   (assert (and 'usb-control-transfer (usb-device-handle? handle)))
   (assert (and 'usb-control-transfer (number? type)))
   (assert (and 'usb-control-transfer (number? request)))
   (assert (and 'usb-control-transfer (number? value)))
   (assert (and 'usb-control-transfer (number? index)))
   (assert (and 'usb-control-transfer (bytevector? data)))
   (assert (and 'usb-control-transfer (number? timeout)))

   (let* ([f (foreign-procedure "libusb_control_transfer" 
				(void* unsigned-8 unsigned-8 unsigned-16 unsigned-16 
				       u8* unsigned-16 unsigned-int) int)]
	  [e (f (usb-device-handle-addr handle) type request value index 
		data (bytevector-length data) timeout)])
     (if (< e 0)
	 (error 'usb-control-transfer (usb-strerror e) e))
     (void)))

 (define (usb-*-write handle endpoint data timeout func)
   (assert (and 'usb-*-write (usb-device-handle? handle)))
   (assert (and 'usb-*-write (number? endpoint)))
   (assert (and 'usb-*-write (bytevector? data)))
   (assert (and 'usb-*-write (number? timeout)))
   (usb-free-garbage)
   (let* ([ptr (alloc-int)]
	  [e (func (usb-device-handle-addr handle) endpoint
		   data (bytevector-length data) 
		   (ftype-pointer-address ptr) timeout)])
     (when (< e 0)
       (error 'usb-*-write (usb-strerror e) e))
     ;;(ftype-pointer-address (ftype-ref int* () ptr))
     (void)))
 
 (import (only (thunder-utils) sub-bytevector))
 
 (define (usb-*-read handle endpoint len timeout func)
   (assert (and 'usb-*-read (usb-device-handle? handle)))
   (assert (and 'usb-*-read (number? endpoint)))
   (assert (and 'usb-*-read (number? len)))
   (assert (and 'usb-*-read (number? timeout)))
   (usb-free-garbage)
   (let* ([ptr (alloc-int)]
	  [data (make-bytevector len)]
	  [data% (usb-guardian data)]
	  [e (func (usb-device-handle-addr handle) endpoint
		   data len 
		   (ftype-pointer-address ptr) timeout)])
     (if (< e 0)
	 (error 'usb-*-read (usb-strerror e) e))
     (let ([read-len (ftype-ref int () ptr)])
       (sub-bytevector data 0 read-len))))

(define (usb-bulk-read handle endpoint len timeout)
  (usb-*-read handle endpoint len timeout 
	      (foreign-procedure "libusb_bulk_transfer" 
				 (void* unsigned-8 u8* int void* unsigned-int) int)))
(define (usb-bulk-write handle endpoint data timeout)
  (usb-*-write handle endpoint data timeout 
	       (foreign-procedure "libusb_bulk_transfer" 
				  (void* unsigned-8 u8* int void* unsigned-int) int)))

(define (usb-interrupt-read handle endpoint len timeout)
  (usb-*-read handle endpoint len timeout 
		  (foreign-procedure "libusb_interrupt_transfer" 
				     (void* unsigned-8 u8* int void* unsigned-int) int)))
(define (usb-interrupt-write handle endpoint data timeout)
  (usb-*-write handle endpoint data timeout 
		  (foreign-procedure "libusb_interrupt_transfer" 
				     (void* unsigned-8 u8* int void* unsigned-int) int)))


) ;library usb


