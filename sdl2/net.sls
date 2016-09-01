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
 (sdl2 net)
 (export
  sdl-net-linked-version
  sdl-net-init
  sdl-net-quit
  sdl-net-resolve-host
  sdl-net-resolve-ip
  sdl-net-get-local-addresses
  sdl-net-tcp-get-peer-address
  sdl-net-tcp-open
  sdl-net-tcp-accept 
  sdl-net-tcp-send
  sdl-net-tcp-recv
  sdl-net-tcp-close
  sdl-net-alloc-packet
  sdl-net-resize-packet
  sdl-net-alloc-packetv
  sdl-net-free-packet
  sdl-net-free-packetv
  sdl-net-udp-open
  sdl-net-udp-set-packet-loss
  sdl-net-udp-get-peer-address
  sdl-net-udp-bind
  sdl-net-udp-unbind
  sdl-net-udp-sendv
  sdl-net-udp-send
  sdl-net-udp-recvv
  sdl-net-udp-recv
  sdl-net-udp-close
  sdl-net-alloc-socket-set
  sdl-net-add-socket
  sdl-net-tcp-add-socket
  sdl-net-udp-add-socket
  sdl-net-del-socket
  sdl-net-tcp-del-socket
  sdl-net-udp-del-socket
  sdl-net-check-sockets
  sdl-net-free-socket-set
  sdl-net-set-error
  sdl-net-get-error

  sdl-net-library-init 

  ;;types
  ip-address 
  tcp-socket udp-socket udp-packet
  INADDR_ANY INADDR_NONE INADDR_LOOPBACK INADDR_BROADCAST

  sdl-net-socket-set-t
  sdl-net-generic-socket
  sdl-net-generic-socket-t
  sdl-net-version-t

  )

 (import (chezscheme) 
	 (ffi-utils)	 
	 (only (srfi s1 lists) fold)
	 (only (thunder-utils) string-replace string-split) 
	 (only (srfi s13 strings) string-delete string-suffix? string-prefix?)
	 (srfi s14 char-sets))

(include "ffi.ss")
(include "base-types.ss")

(include "net-types.ss")

(include "net-functions.ss")

(define (sdl-net-library-init . l)
   (load-shared-object (if (null? l) "libSDL2_net.so" l)))

)
