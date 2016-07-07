
#!chezscheme
(library 
 (usb)
 (export 
  usb-device-descriptor
  usb-device
  usb-device-handle

  usb-init
  usb-get-device-list
  usb-get-device-descriptor
  usb-find-vid-pid
  usb-display-device-list
  )
 (import (chezscheme))
 
 (define-ftype usb-device* void*)
 (define-ftype usb-device*-array (array 0 usb-device*))
 (define-ftype usb-device*** (* usb-device*-array))
 (define-ftype usb-device-handle* void*)

 (define-ftype usb-device-descriptor 
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

 (define-record-type usb-device
   (fields
    (mutable ptr)))
 (define-record-type usb-device-handle
   (fields
    (mutable ptr)))

 (define (usb-device-addr dev)
   (ftype-pointer-address (usb-device-ptr dev)))

 (define (usb-get-device-list) 
   (let* ([ptr (make-ftype-pointer usb-device*** (foreign-alloc (ftype-sizeof usb-device***)))]
	  [f (foreign-procedure "libusb_get_device_list" (void* void*) int)]
	  [e (f 0 (ftype-pointer-address ptr))])
     (if (< e 0)
	 (error 'usb-get-device-list "error" e))
     (let ((devices (ftype-&ref usb-device*** (*) ptr)))
       (let loop ((i 0) (l '()))
	 (if (>= i e) l
	     (loop (fx+ i 1) 
		   (cons (make-usb-device (make-ftype-pointer usb-device* (ftype-ref usb-device*-array (i) devices))) l)))))))

 (define (usb-get-device-descriptor dev) 
   (let* ([ptr (make-ftype-pointer usb-device-descriptor 
				   (foreign-alloc (ftype-sizeof usb-device-descriptor)))]
	  [f (foreign-procedure "libusb_get_device_descriptor" (void* void*) int)]
	  [e (f (usb-device-addr dev) (ftype-pointer-address ptr))])
     (if (< e 0)
	 (error 'usb-get-device-descriptor "error" e)
	 ptr)))

 (define (usb-init) 
   (let ([e ((foreign-procedure "libusb_init" (void*) int) 0)])
     (when (< e 0)
       (error 'usb-init "error" e))
     #t))

 (define (usb-find-vid-pid vid pid) 
   (call/cc 
    (lambda (k)
      (for-each 
       (lambda (dev)
	 (let ([descriptor (usb-get-device-descriptor dev)])
	   (if (and (equal? (ftype-ref usb-device-descriptor (vendor) descriptor) vid)
		    (equal? (ftype-ref usb-device-descriptor (product) descriptor) pid))
	       (k dev))))
       (usb-get-device-list))
      #f)))

 (define (usb-display-device-list)
   (pretty-print 
    (map
     (lambda (dev) 
       (ftype-pointer->sexpr (usb-get-device-descriptor dev)))
     (usb-get-device-list))))
 
) ;library usb

(warning 'usb "remember to load the dynamic library: Example: (load-shared-object \"libusb-1.0.so.0\")")
 
