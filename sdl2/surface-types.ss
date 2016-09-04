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

 (define-ftype sdl-blit-map-t (struct))
 (define-ftype sdl-surface-t
  (struct
   (flags uint32)
   (format (* sdl-pixel-format-t))
   (w int)
   (h int)
   (pitch int)
   (pixels void*)
   (userdata void*)
   (locked int)
   (lock_data void*)
   (clip_rect sdl-rect-t)
   (map (* sdl-blit-map-t)) ;; /usr/include/SDL2/SDL_surface.h:881:2
   (refcount int)))


