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

(define-ftype ip-address
  (struct 
   (host uint32)
   (port uint16)))

(define-ftype udp-packet
  (struct 
   (channel int)
   (data uint8)
   (len int)
   (maxlen int)
   (status int)
   (address ip-address)))

(define-ftype udp-socket void*)
(define-ftype tcp-socket void*)

(define-syntax INADDR_ANY (identifier-syntax 0))
(define-syntax INADDR_NONE (identifier-syntax #xffffffff))
(define-syntax INADDR_BROADCAST (identifier-syntax #xffffffff))
(define-syntax INADDR_LOOPBACK (identifier-syntax #x7f000001))

(define-ftype sdl-net-version-t
  (struct 
   (major uint8)
   (minor uint8)
   (patch uint8)))

(define-ftype sdl-net-socket-set-t void*)

(define-ftype sdl-net-generic-socket 
  (struct
   (ready int)))
(define-ftype sdl-net-generic-socket-t void*)
