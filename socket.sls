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

(library (socket)
  (export file-write file-read bytes-ready socket close
	  socket-domain socket-type-flag socket-type gethostbyname
	  connect/inet bind/inet listen accept)
  
  (import (except (chezscheme) bytevector-copy)
	  (posix)
	  (only (posix errno) EAGAIN EINTR)
	  (ffi-utils))

  (meta-cond
   [(memq (machine-type) '(a6le ta6le))
    
    (define-enumeration* socket-domain
      (unspec local inet ax25 ipx appletalk
	      netrom bridge atmpvc x25 inet6 rose decnet netbeui security key
	      netlink packet ash econet atmsvc rds sna irda ppox wanpipe llc ib mpls
	      can tipc bluetooth iucv rxrpc isdn phonet ieee802154 caif alg nfc
	      vsock kcm))

    (define-enumeration* socket-type (unspec stream dgram raw seqpacket dccp))
    (define-flags socket-type-flag
      (close-on-exec #o02000000)
      (non-block #o00004000))
    
    (define-ftype hostent
      (struct
       (h_name (* char))
       (h_aliases void*)
       (h_addrtype int)
       (h_length int)
       (h_addr_list void*)))
    
    (define-ftype sa_family_t unsigned-short)
    (define-ftype in_port_t unsigned-16)
    
    (define-ftype socklen_t unsigned-int)
    (define-ftype sockaddr_un
      (struct (sun_family sa_family_t)
	      (sun_data (array 108 char))))
    
    (define-ftype in_addr_t unsigned-32)
    (define-ftype in_addr
      (struct (s_addr in_addr_t)))
    
    ;; WARNING- here the size of sin_zero should be calculated on your machine as:
    
    #;(import (c-eval))
    #;(parameterize ([c-eval-includes '("stdio.h" "sys/socket.h" "netinet/in.h")])
    (c-eval-printf "%d" "sizeof(((struct sockaddr_in *) NULL)->sin_zero)"))
    ;; in my case  (a6le) -> 8
    
    (define-ftype sockaddr_in
      (struct
       (sin_family sa_family_t)
       (sin_port in_port_t)
       (sin_addr in_addr)
       (sin_zero (array 8 unsigned-8))))
  
    (define INADDR_ANY 0)
    ]
   [else
    (error 'socket.sls "unsupported machine-type ~a" (machine-type))])

  (define (socket domain type type-flags protocol)  
    (define socket* (foreign-procedure "socket" (int int int) int))
    (let ([r (socket* (socket-domain domain)
		      (logior (socket-type type)
			      (apply socket-type-flag type-flags))
		      protocol)])
	  (when (< r 0)
		(errorf 'socket "failed: ~a" (strerror)))
	  (open-fd-input/output-port r)))

  ;; MMM... LINUX MAN PAGES SAYS THIS IS DEPRECATED...
  (define (gethostbyname name)
    (define ghbn* (foreign-procedure "gethostbyname" (string) void*))
    (define hstrerror* (foreign-procedure "hstrerror" (int) string))
    (define (h-errno)
      (foreign-ref 'int (foreign-entry "__h_errno") 0))
    
    (let ([r (ghbn* name)])
      (when (zero? r)
	    (errorf 'gethostbyname "failed: ~a" (hstrerror* (h-errno))))
      (make-ftype-pointer hostent r)))
     
  (define (htons n)
    (define htons* (foreign-procedure "htons" (unsigned-16) unsigned-16))
    (htons* n))
  
  (define (memset dest val n)
    (define memset* (foreign-procedure "memset" (void* int size_t) void*))
    (memset* dest val n)
    (void))
  
  (define (memcpy dest src n)
    (define memcpy* (foreign-procedure "memcpy" (void* void* size_t) void*))
    (memcpy* dest src n)
    (void))
    
  (define (connect/inet socket address port)
    (define connect* (foreign-procedure "connect" (int (* sockaddr_in) socklen_t) int))
    (define server (gethostbyname address))
    (let ([addr (make-ftype-pointer sockaddr_in
				    (foreign-alloc (ftype-sizeof sockaddr_in)))])
      (memset (ftype-pointer-address addr) 0 (ftype-sizeof sockaddr_in))
      (ftype-set! sockaddr_in (sin_family) addr (socket-domain 'inet))
      (memcpy (ftype-pointer-address (ftype-&ref sockaddr_in (sin_addr) addr))
	      (foreign-ref 'void* (ftype-ref hostent (h_addr_list) server) 0)
	      (ftype-ref hostent (h_length) server))
      (ftype-set! sockaddr_in (sin_port) addr (htons port))
      (let ([r (connect* (port-file-descriptor socket)
			 addr (ftype-sizeof sockaddr_in))])
	(foreign-free (ftype-pointer-address addr))
	(when (< r 0)
	    (if (= (errno) EINTR) (connect/inet socket address port)
		(errorf 'connect/inet "failed: ~a" (strerror)))))))

  (define (bind/inet socket address port)
    (define SO_REUSEADDR 2)
    (define SOL_SOCKET 1)
    (define setsockopt* (foreign-procedure "setsockopt" (int int int u8* socklen_t) int))
    (define bind* (foreign-procedure "bind" (int (* sockaddr_in) socklen_t) int))
    (define opt (make-bytevector (ftype-sizeof int)))
    (bytevector-sint-set! opt 0 1 (native-endianness) (ftype-sizeof int))
    (setsockopt* (port-file-descriptor socket) SOL_SOCKET SO_REUSEADDR opt (ftype-sizeof int))
    (let ([addr (make-ftype-pointer sockaddr_in
				    (foreign-alloc (ftype-sizeof sockaddr_in)))])
      (memset (ftype-pointer-address addr) 0 (ftype-sizeof sockaddr_in))
      (ftype-set! sockaddr_in (sin_family) addr (socket-domain 'inet))
      (case address
	[any
	 (ftype-set! in_addr (s_addr) (ftype-&ref sockaddr_in (sin_addr) addr) INADDR_ANY)]
	[else
	 (let ([server (gethostbyname address)])
	   (memcpy (ftype-pointer-address (ftype-&ref sockaddr_in (sin_addr) addr))
		   (foreign-ref 'void* (ftype-ref hostent (h_addr_list) server) 0)
		   (ftype-ref hostent (h_length) server)))])
      (ftype-set! sockaddr_in (sin_port) addr (htons port))
      (let ([r (bind* (port-file-descriptor socket)
		      addr (ftype-sizeof sockaddr_in))])
	(foreign-free (ftype-pointer-address addr))
	(when (< r 0)
	      (errorf 'bind/inet "failed: ~a" (strerror))))))
  
  (define (listen s backlog)
    (define listen* (foreign-procedure "listen" (int int) int))
    (let ([r (listen* (port-file-descriptor s) backlog)])
      (when (< r 0)
	    (errorf 'listen "failed: ~a" (strerror)))
      r))
  
  (define (accept s)
    (define accept* (foreign-procedure "accept" (int void* void*) int))
    ;; TODO: get the client address!
    
    (let ([r (accept* (port-file-descriptor s) 0 0)])
      (cond
       [(< r 0)
	(if (= (errno) EINTR)
	    (accept s)
	    (errorf 'accept "failed: ~a" (strerror)))]
       [else
	(open-fd-input/output-port r)])))
  )


#|
;Example:

(load "socket.sls")

;; client
(import (socket))

(define (http-get hostname port q)
  (define sock (socket 'inet 'stream '() 0))
  (connect/inet sock hostname port)
  (put-bytevector sock (string->utf8 (format #f "GET ~a HTTP/1.1\r\nHost: ~a\r\nConnection: Close\r\n\r\n" q hostname)))
  (flush-output-port sock)
  (do ([c (get-u8 sock) (get-u8 sock)] 
	     [l '() (cons c l)])
    ((eof-object? c) (utf8->string (apply bytevector (reverse l))))))

(substring (http-get "scheme.com" 80 "/tspl4/intro.html") 0 200)

;; server
(import (socket))
(define sock (socket 'inet 'stream '() 0))
(bind/inet sock 'any 8001)
(listen sock 10)
(define clisock (accept sock))
(define (read-all sock) 
  (do ([c (get-u8 sock) (get-u8 sock)] 
	     [l '() (cons c l)])
      ((eof-object? c) (utf8->string (apply bytevector (reverse l))))))
(read-all clisock)
|#
