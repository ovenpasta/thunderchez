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

(define-flags sdl-renderer-flags
  (software 1)
  (accelerated 2)
  (presentvsync 4)
  (targettexture 8))

(define-ftype sdl-renderer-info-t
  (struct 
   (name (* char))
   (flags uint32)
   (num-texture-formats uint32)
   (texture_formats (array 16 uint32))
   (max-texture-width int)
   (max-texture-height int)))

(define-flags sdl-texture-access 
  (static 0)
  (streaming 1)
  (target 2))

(define-flags sdl-texture-modulate 
  (none 0)
  (color 1) 
  (alpha 2))

(define-flags sdl-renderer-flip
  (none 0)
  (horizontal 1)
  (vertical 2))

(define-ftype sdl-renderer-t (struct))
(define-ftype sdl-texture-t (struct))
