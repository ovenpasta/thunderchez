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
 (nanomsg) 
 (export 
  nanomsg-library-init
  nn-errno nn-strerror  nn-bind nn-send nn-recv nn-connect nn-poll nn-close
  nn-socket nn-assert nn-shutdown nn-freemsg nn-recvmsg nn-sendmsg
  nn-strerror nn-setsockopt nn-setsockopt/int
  nn-getsockopt nn-get-statistic nn-device nn-symbol

  NN_MSG

  NN_SOCKADDR_MAX
  NN_SOL_SOCKET
  NN_LINGER
  NN_SNDBUF
  NN_RCVBUF
  NN_SNDTIMEO
  NN_RCVTIMEO
  NN_RECONNECT_IVL
  NN_RECONNECT_IVL_MAX
  NN_SNDPRIO
  NN_RCVPRIO
  NN_SNDFD
  NN_RCVFD
  NN_DOMAIN
  NN_PROTOCOL
  NN_IPV4ONLY
  NN_SOCKET_NAME
  NN_RCVMAXSIZE
  NN_MAXTTL
  NN_DONTWAIT
  NN_POLLIN
  NN_POLLOUT
  NN_STAT_ESTABLISHED_CONNECTIONS
  NN_STAT_ACCEPTED_CONNECTIONS
  NN_STAT_DROPPED_CONNECTIONS
  NN_STAT_BROKEN_CONNECTIONS
  NN_STAT_CONNECT_ERRORS
  NN_STAT_BIND_ERRORS
  NN_STAT_ACCEPT_ERRORS
  NN_STAT_CURRENT_CONNECTIONS
  NN_STAT_INPROGRESS_CONNECTIONS
  NN_STAT_CURRENT_EP_ERRORS
  NN_STAT_MESSAGES_SENT
  NN_STAT_MESSAGES_RECEIVED
  NN_STAT_BYTES_SENT
  NN_STAT_BYTES_RECEIVED
  NN_STAT_CURRENT_SND_PRIORITY
					;NN_PROTO_PAIR
  NN_PAIR
					;NN_PROTO_PUBSUB
  NN_PUB
  NN_SUB
  NN_SUB_SUBSCRIBE
  NN_SUB_UNSUBSCRIBE
					;NN_PROTO_REQREP
  NN_REQ
  NN_REP
  NN_REQ_RESEND_IVL
  NN_TCP
  NN_TCP_NODELAY
					;NN_PROTO_PIPELINE
  NN_PUSH
  NN_PULL
					;NN_PROTO_BUS
					;NN_PROTO_SURVEY
  NN_SURVEYOR
  NN_RESPONDENT
  NN_SURVEYOR_DEADLINE
  NN_INPROC
  NN_IPC
					;NN_IPC_SEC_ATTR
					;NN_IPC_OUTBUFSZ
					;NN_IPC_INBUFSZ
  NN_WS
  NN_WS_MSG_TYPE
  NN_WS_MSG_TYPE_TEXT
  NN_WS_MSG_TYPE_BINARY
  NN_BUS
  
  NN_NS_NAMESPACE
  NN_NS_VERSION
  NN_NS_DOMAIN
  NN_NS_TRANSPORT
  NN_NS_PROTOCOL
  NN_NS_OPTION_LEVEL
  NN_NS_SOCKET_OPTION
  NN_NS_TRANSPORT_OPTION
  NN_NS_OPTION_TYPE
  NN_NS_OPTION_UNIT
  NN_NS_FLAG
  NN_NS_ERROR
  NN_NS_LIMIT
  NN_NS_EVENT
  NN_NS_STATISTIC
  NN_TYPE_NONE
  NN_TYPE_INT
  NN_TYPE_STR
  NN_UNIT_NONE
  NN_UNIT_BYTES
  NN_UNIT_MILLISECONDS
  NN_UNIT_PRIORITY
  NN_UNIT_BOOLEAN
  NN_UNIT_MESSAGES
  NN_UNIT_COUNTER

  AF_SP AF_SP_RAW

  NN_NOTSUP
  NN_EPROTONOSUPPORT
  NN_ENOBUFS
  NN_ENETDOWN
  NN_EADDRINUSE
  NN_EADDRNOTAVAIL
  NN_ECONNREFUSED
  NN_EINPROGRESS
  NN_ENOTSOCK
  NN_EAFNOSUPPORT
  NN_EPROTO
  NN_EAGAIN
  NN_EBADF
  NN_EINVAL
  NN_EMFILE
  NN_EFAULT
  NN_EACCES
  NN_EACCESS
  NN_ENETRESET
  NN_ENETUNREACH
  NN_EHOSTUNREACH
  NN_ENOTCONN
  NN_EMSGSIZE
  NN_ETIMEDOUT
  NN_ECONNABORTED
  NN_ECONNRESET
  NN_ENOPROTOOPT
  NN_EISCONN
  NN_ESOCKTNOSUPPORT
  NN_ETERM
  NN_EFSM


  EADDRINUSE
  EADDRNOTAVAIL
  EAFNOSUPPORT
  EAGAIN
  EBADF
  ECONNREFUSED
  EFAULT
  EFSM
  EINPROGRESS
  EINTR
  EINVAL
  EMFILE
  ENAMETOOLONG
  ENETDOWN
  ENOBUFS
  ENODEV
  ENOMEM
  ENOPROTOOPT
  ENOTSOCK
  ENOTSUP
  EPROTO
  EPROTONOSUPPORT
  ETERM
  ETIMEDOUT
  EACCES
  ECONNABORTED
  ECONNRESET
  EHOSTUNREACH
  EMSGSIZE
  ENETRESET
  ENETUNREACH
  ENOTCONN

  NN_VERSION_CURRENT
  NN_VERSION_REVISION
  NN_VERSION_AGE
  ) ;export
 (import (ffi-utils) (chezscheme))
 
 (define (nanomsg-library-init . t)
   (load-shared-object (if (null? t) "libnanomsg.so" (car t))))

 (define-syntax define-nn-func
   (lambda (x)
     (syntax-case x ()
       [(_ ret-type name ((arg-name arg-type) ...) c-name) 
	(with-syntax 
	 ([function-ftype 
	   (datum->syntax #'name 
			  (string->symbol 
			   (string-append 
			    (symbol->string 
			     (syntax->datum #'name)) "-ft")))] )
	 #`(begin
	     (define (name arg-name ...) 
	       (define-ftype function-ftype (function (arg-type ...) ret-type))
	       (let* ([function-fptr  (make-ftype-pointer function-ftype c-name)]
		      [function       (ftype-ref function-ftype () function-fptr)])
		 (let ([result (function arg-name ...)])
		   #,(if (and (eq? (datum ret-type) 'int) 
			      (not (eq? (datum name) 'nn-errno)))
			 #'(if (< result 0)
			       (let ([errno (nn-errno)])
				 (if (= errno EAGAIN) 
				     #f 
				     (errorf 'name "returned error ~d: ~d"
					     errno (nn-strerror errno))))
			       result)
			 #'result))))))])))
 
 
 (define-syntax nn-error
   (syntax-rules ()
     ((_ name n )
      (define-syntax name (identifier-syntax (+ 156384712 n))))))
 
 (nn-error  NN_NOTSUP          1)
 (nn-error  NN_EPROTONOSUPPORT 2)
 (nn-error  NN_ENOBUFS         3)
 (nn-error  NN_ENETDOWN        4)
 (nn-error  NN_EADDRINUSE      5)
 (nn-error  NN_EADDRNOTAVAIL   6)
 (nn-error  NN_ECONNREFUSED    7)
 (nn-error  NN_EINPROGRESS     8)
 (nn-error  NN_ENOTSOCK        9)
 (nn-error  NN_EAFNOSUPPORT   10)
 (nn-error  NN_EPROTO         11)
 (nn-error  NN_EAGAIN         12)
 (nn-error  NN_EBADF          13)
 (nn-error  NN_EINVAL         14)
 (nn-error  NN_EMFILE         15)
 (nn-error  NN_EFAULT         16)
 (nn-error  NN_EACCES         17)
 (nn-error  NN_EACCESS        17)
 (nn-error  NN_ENETRESET      18)
 (nn-error  NN_ENETUNREACH    19)
 (nn-error  NN_EHOSTUNREACH   20)
 (nn-error  NN_ENOTCONN       21)
 (nn-error  NN_EMSGSIZE       22)
 (nn-error  NN_ETIMEDOUT      23)
 (nn-error  NN_ECONNABORTED   24)
 (nn-error  NN_ECONNRESET     25)
 (nn-error  NN_ENOPROTOOPT    26)
 (nn-error  NN_EISCONN        27)
 (nn-error  NN_ESOCKTNOSUPPORT 28)
 (nn-error  NN_ETERM          53)
 (nn-error  NN_EFSM           54)

 (define NN_MSG -1)
 (define-syntax nn-define
   (syntax-rules ()
     ((_ name n) 
      (define-syntax name (identifier-syntax n)))))

 (define-nn-func int nn-errno () "nn_errno")

 (define-nn-func int nn-socket ((domain int) (protocol int))
   "nn_socket")

 (define-nn-func string nn-symbol ((index int) (value (* int)))
   "nn_symbol")

 ;; THIS WAS/CAN BE USED TO GENERATE THE nn-define stuff in nanomsg/symbols.ss
 ;; TODO: can this be a macro that we call after loading the library?
 ;; but still. it will not be possible to export these because we cannot
 ;; dynamically add export entries? 

 (define (nn-gen-symbols)
   (define ptr (make-ftype-pointer int (foreign-alloc (ftype-sizeof int))))
   (let loop ([i 0])
     (let ([sym (nn-symbol i ptr)])
       (if sym
	   (begin
	     (printf "(nn-define ~d ~d)~n" sym (ftype-ref int () ptr))
	     (loop (+ 1 i))))))
   (foreign-free (ftype-pointer-address ptr)))

 (include "nanomsg/symbols.ss")

 (define-nn-func int nn-close ((s int)) "nn_close")

 (define-nn-func int nn-setsockopt ((s int) (level int) (option int)
				    (optval void*) (optval-len size_t))
   "nn_setsockopt")


(define (nn-setsockopt/int s level option optval)
  (define o #f)
  (define r #f)
  (dynamic-wind 
      (lambda ()
	(set! o (make-ftype-pointer int (foreign-alloc (ftype-sizeof int)))))
      (lambda () 
	(ftype-set! int () o optval)
	(set! r (nn-setsockopt s level option (ftype-pointer-address o)
			       (ftype-sizeof int))))
      (lambda ()
	(if o (foreign-free (ftype-pointer-address o)))))
  r)

 (define-nn-func int nn-getsockopt ((s int) (level int) (option int)
				    (optval void*) (optval-len (* size_t)))
   "nn_getsockopt")

 (define-nn-func int nn-bind ((s int) (addr string)) "nn_bind")

 (define-nn-func int nn-connect ((s int) (addr string)) "nn_connect")

 (define-nn-func int nn-shutdown ((s int) (how int)) "nn_shutdown")

 (define-nn-func int nn-send% ((s int) (buf u8*) (len size_t) (flags int))
   "nn_send")

 (define (nn-send s buf flags)
   (let* ([len (bytevector-length buf)]
	  [r (nn-send% s buf len flags)])
     (if (not (= r len))
	 (errorf 'nn-send "bytes sent ~d/~d" r len)
	 r)))

 (define-nn-func int nn-recv% ((s int) (buf void*) (len size_t) (flags int))
   "nn_recv")

 ;; (define (char*->string fptr . bytes)
 ;;   (let f ([i 0])
 ;;     (let ([c (ftype-ref char () fptr i)])
 ;;       (if (or (char=? c #\nul) (and bytes (>= (+ 1 i) (car bytes))))
 ;; 	   (make-string i)
 ;; 	   (let ([str (f (fx+ i 1))])
 ;; 	     (string-set! str i c)
 ;; 	     str)))))

 (define (nn-recv s buf len flags)
   (define b #f)
   (define r #f)
   (dynamic-wind 
       (lambda ()
	 (set! b (make-ftype-pointer void* (foreign-alloc (ftype-sizeof void*))))
	 (set! r (nn-recv% s (ftype-pointer-address b) len flags)))
       (lambda ()
	 (if (and r (> r 0))
	     (let ([c (make-ftype-pointer char (ftype-ref void* () b))])
	       (set-box! buf (char*->bytevector c r)))
	     (set-box! buf #f)))
       (lambda ()
	 (if (and r (> r 0))
	     (nn-freemsg (ftype-ref void* () b)))
	 (if b (foreign-free (ftype-pointer-address b)))))
   r)

 (define-nn-func int nn-sendmsg ((s int) (msghdr (* nn-msghdr)) (flags int))
   "nn_sendmsg")

 (define-nn-func int nn-freemsg ((msg void*)) "nn_freemsg")

 (define-ftype nn-iovec
   (struct 
    (iov_base void*) 
    (iov_len size_t)))

 (define-ftype nn-msghdr
   (struct
    (msg_iov (* nn-iovec))
    (msg_iovlen int) 
    (msg_control void*)
    (msg_controllen size_t)))

 (define-ftype nn-cmsghdr
   (struct 
    (cmsg_len size_t) 
    (cmsg_level int)
    (cmsg_type int)))

 (define-nn-func int nn-recvmsg ((s int) (msghdr (* nn-cmsghdr)) (flags int))
   "nn_recvmsg")

 (define-ftype nn-pollfd 
   (struct (fd int) (events short) (revents short)))

 (define-nn-func int nn-poll ((fds (* nn-pollfd)) (nfds int) (timeout int))
   "nn_poll")


 (define-nn-func int nn-device ((s1 int) (s2 int)) "nn_device")

 (define-nn-func int nn-get-statistic ((s int) (stat int)) 
   "nn_get_statistic")

 (define-ftype nn_req_handle 
   (union
    (i int)
    (ptr void*)))

 (define-flags nn_protocol
   (pair NN_PAIR)
   (pub  NN_PUB)  (sub  NN_SUB)
   (pull NN_PULL) (push NN_PUSH)
   (req  NN_REQ)  (rep  NN_REP)
   (surveyor NN_SURVEYOR)  (respondent NN_RESPONDENT)
   (bus NN_BUS))

 ;; nanomsg domain (AF_SP)
 (define-flags nn_domain
   (sp AF_SP)
   (raw AF_SP_RAW))

 ;; ==================== socket flags

 (define-nn-func string nn-strerror ((errno int)) "nn_strerror")

 ;; let val pass unless it is negative, in which case gulp with the nn
 ;; error-string. on EAGAIN, return #f.
 (define (nn-assert val)
   (if (< val 0)
       (if (= (nn-errno)
	      NN_EAGAIN
	      #f ;; signal EGAIN with #f, other errors will throw
	      (error (nn-strerror (nn-errno)) val))
	   val)))
 );;library
