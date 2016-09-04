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

 (define-ftype sdl-audio-device-id-t uint32)
 (define-enumeration* sdl-audio-status
   (stopped playing paused))
 (define-ftype sdl-audio-format-t uint16)
 (define-ftype sdl-audio-callback-t void*)
 (define-ftype sdl-audio-spec-t
   (struct 
    (freq int)
    (format sdl-audio-format-t)
    (channels uint8)
    (silence uint8)
    (samples uint16)
    (padding uint16)
    (size uint32)
    (callback sdl-audio-callback-t)
    (userdata void*)))
 (define-ftype sdl-audio-cvt-t (struct))

