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

 (define-ftype sdl-display-mode-t ; /usr/include/SDL2/SDL_video.h:53:9
   (struct 
    (format uint32)
    (w int)
    (h int)
    (refresh-rate int)
    (driverdata void*)))

 (define-ftype sdl-window-t (struct))

 (define-flags sdl-window-flags
     (fullscreen   #x00000001)        ; fullscreen window */
     (opengl   #x00000002)            ; window usable with opengl context */
     (shown   #x00000004)             ; window is visible */
     (hidden   #x00000008)            ; window is not visible */
     (borderless   #x00000010)        ; no window decoration */
     (resizable   #x00000020)         ; window can be resized */
     (minimized   #x00000040)         ; window is minimized */
     (maximized   #x00000080)         ; window is maximized */
     (input_grabbed   #x00000100)     ; window has grabbed input focus */
     (input-focus   #x00000200)       ; window has input focus */
     (mouse-focus   #x00000400)       ; window has mouse focus */
     (fullscreen-desktop   #x00001001)
     (foreign   #x00000800)           ; window not created by sdl */
     (allow-highdpi   #x00002000))    ; window should be created in high-dpi mode if supported */



 (define sdl-window-pos-undefined #x1fff0000)
 (define (sdl-window-pos-undefined? x)
   (= (logand x #xffff0000) sdl-window-pos-undefined))

 (define sdl-window-pos-centered #x2fff0000)
 (define (sdl-window-pos-centered? x)
   (= (logand x #xffff0000) sdl-window-pos-centered))

 (define-enumeration* sdl-window-event-enum
    (none       ; never used */
     shown        ; window has been shown */
     hidden       ; window has been hidden */
     exposed      ; window has been exposed and should beredrawn */
     moved        ; window has been moved to data1, data2 */
     resized      ; window has been resized to data1xdata2 */
     size-changed ; the window size has changed, either as a result of an
                                        ; api call or through the system or user changing the window size. */
     minimized    ; window has been minimized */
     maximized    ; window has been maximized */
     restored     ; window has been restored to normal sizeand position */
     enter        ; window has gained mouse focus */
     leave        ; window has lost mouse focus */
     focus-gained ; window has gained keyboard focus */
     focus-lost   ; window has lost keyboard focus */
     close        ; The window manager requests that thewindow be closed */
     ;;; these are in (>= SDL 2.0.5)
     take-focus   ; Window is being offered a focus (should SetWindowInputFocus() on itself or a subwindow, or ignore) 
     hit-test     ; Window had a hit test that wasn't SDL_HITTEST_NORMAL.
     ))

 (define-enumeration* sdl-gl-attr
   (red-size green-size blue-size
	     alpha-size buffer-size doublebuffer depth-size stencil-size
	      accum-red-size accum-green-size accum-blue-size accum-alpha-size
	      stereo multisamplebuffers multisamplesamples accelerated-visual
	      retained-backing context-major-version context-minor-version
	      context-egl context-flags context-profile-mask
	      share-with-current-context framebuffer-srgb-capable))

 (define-flags sdl-gl-profile (core 1) (compatibility 2) (es 4))

 (define-flags sdl-gl-context-flag (debug 1) (forward-compatible 2) (robust-access 4) (reset-isolation 8))

(define-ftype sdl-gl-context-t void*)

(define-ftype sdl-hit-test-t void*) 
 ;; typedef SDL_HitTestResult (SDLCALL *SDL_HitTest)(SDL_Window *win,
 ;;                                                 const SDL_Point *area,
 ;;                                                 void *data);
 (define-enumeration* sdl-hit-test-result
   (normal draggable topleft top topright right bottomright bottom bottomleft left))
