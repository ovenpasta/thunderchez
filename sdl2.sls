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
 (sdl2)
 (export sdl-library-init sdl-initialization sdl-initialization-everything
	 sdl-init sdl-init-sub-system sdl-quit-sub-system sdl-was-init sdl-quit

	 ;;BASE TYPES
	 uint8 uint16 sint16 uint32 sint32 sint64 uint64 va-list
	 int% 
	 file sdl-bool-t
	 sdl-iconv-t

	 ;;FFI
	 define-ftype-allocator define-sdl-func sdl-let-ref-call new-struct
	 ;;GUARDIAN
	 sdl-guardian sdl-guard-pointer sdl-free-garbage sdl-free-garbage-set-func
	 
	 ;;HINT
	 sdl-set-hint-with-priority
	 sdl-set-hint
	 sdl-get-hint
	 sdl-get-hint-boolean
	 sdl-add-hint-callback
	 sdl-del-hint-callback
	 sdl-clear-hints
	 ;types
	 sdl-hint-priority

	 ;;JOYSTICK
	 sdl-num-joysticks
	 sdl-joystick-name-for-index
	 sdl-joystick-open
	 sdl-joystick-name
	 sdl-joystick-get-device-guid
	 sdl-joystick-get-guid
	 sdl-joystick-get-guid-string
	 sdl-joystick-get-guid-from-string
	 sdl-joystick-get-attached
	 sdl-joystick-instance-id
	 sdl-joystick-num-axes
	 sdl-joystick-num-balls
	 sdl-joystick-num-hats
	 sdl-joystick-num-buttons
	 sdl-joystick-update
	 sdl-joystick-event-state
	 sdl-joystick-get-axis
	 sdl-joystick-get-hat
	 sdl-joystick-get-ball
	 sdl-joystick-get-button
	 sdl-joystick-close

	 ;;types
	 sdl-joystick-t
	 sdl-joystick-guid-t
	 
	 ;;KEYBOARD
	 sdl-get-keyboard-focus
	 sdl-get-keyboard-state
	 sdl-get-mod-state
	 sdl-set-mod-state
	 sdl-get-key-from-scancode
	 sdl-get-scancode-from-key
	 sdl-get-scancode-name
	 sdl-get-scancode-from-name
	 sdl-get-key-name
	 sdl-get-key-from-name
	 sdl-start-text-input
	 sdl-is-text-input-active
	 sdl-stop-text-input
	 sdl-set-text-input-rect
	 sdl-has-screen-keyboard-support
	 sdl-is-screen-keyboard-shown

	 ;;types 
	 sdl-keysym-t

	 ;;KEYCODE
	 scancode->keycode
	 sdl-keycode
	 sdl-keycode-ref
	 sdl-keycode-decode
	 sdl-keycode-t
	 sdl-keymod-t
	 sdl-keymod-ref
	 sdl-keymod-decode

	 ;;MAIN
	 sdl-main sdl-set-main-ready 

	 ;;MESSAGEBOX
	  sdl-show-message-box
	  sdl-show-simple-message-box
	  ;types
	  sdl-message-box
	  sdl-message-box-button
	  sdl-message-box-color-type-t
	  sdl-message-box-button-data-t
	  sdl-message-box-color-t
	  sdl-message-box-color-scheme-t
	  sdl-message-box-data-t

	  ;;MOUSE
	 sdl-get-mouse-focus
	 sdl-get-mouse-state
         sdl-get-global-mouse-state
	 sdl-get-relative-mouse-state
	 sdl-warp-mouse-in-window
	 sdl-warp-mouse-global
	 sdl-set-relative-mouse-mode
	 sdl-capture-mouse
	 sdl-get-relative-mouse-mode
	 
	 sdl-create-cursor
	 sdl-create-color-cursor
	 sdl-create-system-cursor
	 sdl-set-cursor
	 sdl-get-cursor
	 sdl-get-default-cursor
	 sdl-free-cursor
	 sdl-show-cursor

	 ;types
	 sdl-system-cursor
	 sdl-cursor-t

	 sdl-button
	 sdl-button-ref
	 sdl-button-mask

	 ;;MUTEX
	 sdl-create-mutex
	 sdl-lock-mutex
	 sdl-try-lock-mutex
	 sdl-unlock-mutex
	 sdl-destroy-mutex
	 sdl-create-semaphore
	 sdl-destroy-semaphore
	 sdl-sem-wait
	 sdl-sem-try-wait
	 sdl-sem-wait-timeout
	 sdl-sem-post
	 sdl-sem-value
	 sdl-create-cond
	 sdl-destroy-cond
	 sdl-cond-signal
	 sdl-cond-broadcast
	 sdl-cond-wait
	 sdl-cond-wait-timeout

	 ;; types
	 sdl-mutex-t
	 sdl-sem-t
	 sdl-cond-t

	 ;;PIXELS
	 sdl-get-pixel-format-name
	 sdl-pixel-format-enum-to-masks
	 sdl-masks-to-pixel-format-enum
	 sdl-alloc-format
	 sdl-free-format
	 sdl-alloc-palette
	 sdl-set-pixel-format-palette
	 sdl-set-palette-colors
	 sdl-free-palette
	 sdl-map-rgb
	 sdl-map-rgba
	 sdl-get-rgb
	 sdl-get-rgba
	 sdl-calculate-gamma-ramp

	 ;;types
	 sdl-alpha-opaque
	 sdl-alpha-transparent
	 sdl-pixeltype
	 sdl-bitmaporder
	 sdl-packedorder
	 sdl-arrayorder
	 sdl-packedlayout
	 sdl-define-pixelformat

	 sdl-pixelflag%
	 sdl-pixeltype%
	 sdl-pixelorder%
	 sdl-pixellayout
	 sdl-bitsperpixel%
	 sdl-ispixelformat-fourcc
	 sdl-fourcc

	 sdl-fourcc/char
	 sdl-pixelformat
	 
	 sdl-pixel-format-t
	 sdl-color-t
	 sdl-palette-t

	 ;;RECT
	 sdl-rect-empty
	 sdl-rect-equals
	 sdl-has-intersection
	 sdl-intersect-rect
	 sdl-union-rect
	 sdl-enclose-points
	 sdl-intersect-rect-and-line
	 ;; types
	 sdl-point-t
	 sdl-rect-t
	 
	 ;;RENDER
	 sdl-get-num-render-drivers
	 sdl-get-render-driver-info
	 sdl-create-window-and-renderer
	 sdl-create-renderer
	 sdl-create-software-renderer
	 sdl-get-renderer
	 sdl-get-renderer-info
	 sdl-get-renderer-output-size
	 sdl-create-texture
	 sdl-create-texture-from-surface
	 sdl-query-texture
	 sdl-set-texture-color-mod
	 sdl-get-texture-color-mod
	 sdl-set-texture-alpha-mod
	 sdl-get-texture-alpha-mod
	 sdl-set-texture-blend-mode
	 sdl-get-texture-blend-mode
	 sdl-update-texture
	 sdl-update-yuv-texture
	 sdl-lock-texture
	 sdl-unlock-texture
	 sdl-render-target-supported
	 sdl-set-render-target
	 sdl-get-render-target
	 sdl-render-set-logical-size
	 sdl-render-get-logical-size
	 sdl-render-set-integer-scale
	 sdl-render-get-integer-scale 
	 sdl-render-set-viewport
	 sdl-render-get-viewport
	 sdl-render-set-clip-rect
	 sdl-render-get-clip-rect
	 sdl-render-set-scale
	 sdl-render-get-scale
	 sdl-set-render-draw-color
	 sdl-get-render-draw-color
	 sdl-set-render-draw-blend-mode
	 sdl-get-render-draw-blend-mode
	 sdl-render-clear
	 sdl-render-draw-point
	 sdl-render-draw-points
	 sdl-render-draw-line
	 sdl-render-draw-lines
	 sdl-render-draw-rect
	 sdl-render-draw-rects
	 sdl-render-fill-rect
	 sdl-render-fill-rects
	 sdl-render-copy
	 sdl-render-copy-ex
	 sdl-render-read-pixels
	 sdl-render-present
	 sdl-destroy-texture
	 sdl-destroy-renderer
	 sdl-gl-bind-texture
	 sdl-gl-unbind-texture

	 sdl-renderer-flags
	 sdl-renderer-info-t
	 sdl-texture-access
	 sdl-texture-modulate
	 sdl-renderer-flip
	 sdl-renderer-t
	 sdl-texture-t
	 ;;types
	 sdl-renderer-flags
	 sdl-renderer-info-t
	 sdl-texture-access
	 sdl-texture-modulate
	 sdl-renderer-flip
	 sdl-renderer-t
	 sdl-texture-t

	 ;;BLENDMODE
	 sdl-blend-mode sdl-blend-mode-t

	 ;;CLIPBOARD
	 sdl-set-clipboard-text
	 sdl-get-clipboard-text
	 sdl-has-clipboard-text

	 ;;CPUINFO
	 sdl-get-cpu-count
	 sdl-get-cpu-cache-line-size
	 sdl-has-rdtsc
	 sdl-has-alti-vec
	 sdl-has-mmx
	 sdl-has3-d-now
	 sdl-has-sse
	 sdl-has-ss-e2
	 sdl-has-ss-e3
	 sdl-has-ss-e41
	 sdl-has-ss-e42
	 sdl-has-avx
	 sdl-get-system-ram

	 ;;ENDIAN
	 sdl-swap16
	 sdl-swap32
	 sdl-swap64
	 sdl-swap-float

	 ;;ERROR
	 sdl-errorcode sdl-errorcode-t 
	 sdl-set-error
	 sdl-get-error
	 sdl-clear-error
	 sdl-error

	 ;;EVENTS
	 sdl-pump-events
	 sdl-peep-events
	 sdl-has-event
	 sdl-has-events
	 sdl-flush-event
	 sdl-flush-events
	 sdl-poll-event
	 sdl-wait-event
	 sdl-wait-event-timeout
	 sdl-push-event
	 sdl-set-event-filter
	 sdl-get-event-filter
	 sdl-add-event-watch
	 sdl-del-event-watch
	 sdl-filter-events
	 sdl-event-state
	 sdl-register-events

	 ;; types

	 sdl-event-type
	 sdl-event-type-ref
	 sdl-common-event-t
	 sdl-window-event-t
	 sdl-keyboard-event-t
	 sdl-texteditingevent-text-size
	 sdl-textinputevent-text-size
	 sdl-text-input-event-t
	 sdl-mouse-motion-event-t
	 sdl-mouse-button-event-t
	 sdl-mouse-wheel-event-t
	 sdl-touch-finger-event-t
	 sdl-multi-gesture-event-t
	 sdl-dollar-gesture-event-t
	 sdl-drop-event-t
	 sdl-quit-event-t
	 sdl-user-event-t
	 sdl-sys-wm-msg
	 sdl-sys-wm-event-t
	 sdl-joy-axis-event-t
	 sdl-joy-hat-event-t
	 sdl-joy-device-event-t
	 sdl-joy-button-event-t
	 sdl-joy-ball-event-t
	 sdl-controller-button-event-t
	 sdl-controller-device-event-t
	 sdl-joystick-id-t
	 sdl-controller-axis-event-t
	 sdl-event-t
	 sdl-eventaction
	 sdl-event-filter-t
	 
	 ;;FILESYSTEM
	 sdl-get-base-path
	 sdl-get-pref-path

	 ;;VIDEO
	 sdl-get-num-video-drivers
	 sdl-get-video-driver
	 sdl-video-init
	 sdl-video-quit
	 sdl-get-current-video-driver
	 sdl-get-num-video-displays
	 sdl-get-display-name
	 sdl-get-display-usable-bounds
	 sdl-get-display-bounds
	 sdl-get-num-display-modes
	 sdl-get-display-mode
	 sdl-get-desktop-display-mode
	 sdl-get-current-display-mode
	 sdl-get-closest-display-mode
	 sdl-get-window-display-index
	 sdl-set-window-display-mode
	 sdl-get-window-display-mode
	 sdl-get-window-pixel-format
	 sdl-create-window
	 sdl-create-window-from
	 sdl-get-window-id
	 sdl-get-window-from-id
	 sdl-get-window-flags
	 sdl-set-window-title
	 sdl-get-window-title
	 sdl-set-window-icon
	 sdl-set-window-data
	 sdl-get-window-data
	 sdl-set-window-position
	 sdl-get-window-position
	 sdl-set-window-size
	 sdl-get-window-size
	 sdl-get-window-borders-size 
	 sdl-set-window-minimum-size
	 sdl-get-window-minimum-size
	 sdl-set-window-maximum-size
	 sdl-get-window-maximum-size
	 sdl-set-window-bordered
	 sdl-set-window-resizable
	 sdl-show-window
	 sdl-hide-window
	 sdl-raise-window
	 sdl-maximize-window
	 sdl-minimize-window
	 sdl-restore-window
	 sdl-set-window-fullscreen
	 sdl-get-window-surface
	 sdl-update-window-surface
	 sdl-update-window-surface-rects
	 sdl-set-window-grab
	 sdl-get-window-grab
	 sdl-set-window-brightness
	 sdl-get-window-brightness
	 sdl-set-window-opacity
	 sdl-get-window-opacity
	 sdl-set-window-modal-for
	 sdl-set-window-input-focus
	 sdl-set-window-gamma-ramp
	 sdl-get-window-gamma-ramp
	 sdl-destroy-window
	 sdl-is-screen-saver-enabled
	 sdl-enable-screen-saver
	 sdl-disable-screen-saver
	 sdl-gl-load-library
	 sdl-gl-get-proc-address
	 sdl-gl-unload-library
	 sdl-gl-extension-supported
	 sdl-gl-reset-attributes
	 sdl-gl-set-attribute
	 sdl-gl-get-attribute
	 sdl-gl-create-context
	 sdl-gl-make-current
	 sdl-gl-get-current-window
	 sdl-gl-get-current-context
	 sdl-gl-get-drawable-size
	 sdl-gl-set-swap-interval
	 sdl-gl-get-swap-interval
	 sdl-gl-swap-window
	 sdl-gl-delete-context

	 ;; types 
	 sdl-display-mode-t
	 sdl-window-t

	 ;; FIXME: any way to export all this stuff with a single entry?
	 sdl-window-flags
	 sdl-window-flags-ref
	 sdl-window-flags-t
	 sdl-window-flags-decode
	 sdl-window-flags-flags

	 sdl-window-pos-undefined
	 sdl-window-pos-undefined?
	 sdl-window-pos-centered
	 sdl-window-pos-centered?
	 sdl-window-event-enum
	 sdl-window-event-enum-ref
	 sdl-gl-attr
	 sdl-gl-attr-t
	 sdl-gl-profile
	 sdl-gl-context-flag
	 sdl-gl-context-t

	 ;;VERSION
	 sdl-get-version
	 sdl-get-revision
	 sdl-get-revision-number
	 ;;types
	 sdl-version-t

	 ;;TOUCH
	 sdl-get-num-touch-devices
	 sdl-get-touch-device
	 sdl-get-num-touch-fingers
	 sdl-get-touch-finger

	 ;;types
	 sdl-finger-id-t
	 sdl-touch-id-t
	 sdl-finger-t

	 ;;TIMER
	 sdl-get-ticks
	 sdl-get-performance-counter
	 sdl-get-performance-frequency
	 sdl-delay
	 sdl-add-timer
	 sdl-remove-timer

	 sdl-timer-id-t
	 sdl-timer-callback-t

	 ;;THREAD 
	 sdl-create-thread
	 sdl-get-thread-name
	 sdl-thread-id
	 sdl-get-thread-id
	 sdl-set-thread-priority
	 sdl-wait-thread
	 sdl-detach-thread
	 sdl-tls-create
	 sdl-tls-get
	 sdl-tls-set
	 
	 ;; types
	 sdl-thread-t
	 sdl-thread-function-t
	 sdl-thread-id-t
	 sdl-tlsid-t
	 sdl-thread-priority
	 
	 sdl-create-rgb-surface
	 sdl-create-rgb-surface-with-format
	 sdl-create-rgb-surface-from
	 sdl-create-rgb-surface-with-format-from
	 sdl-free-surface
	 sdl-set-surface-palette
	 sdl-lock-surface
	 sdl-unlock-surface
	 sdl-load-bmp-rw
	 sdl-save-bmp-rw
	 sdl-load-bmp
	 sdl-save-bmp
	 sdl-set-surface-rle
	 sdl-set-color-key
	 sdl-get-color-key
	 sdl-set-surface-color-mod
	 sdl-get-surface-color-mod
	 sdl-set-surface-alpha-mod
	 sdl-get-surface-alpha-mod
	 sdl-set-surface-blend-mode
	 sdl-get-surface-blend-mode
	 sdl-set-clip-rect
	 sdl-get-clip-rect
	 sdl-convert-surface
	 sdl-convert-surface-format
	 sdl-convert-pixels
	 sdl-fill-rect
	 sdl-fill-rects
	 sdl-upper-blit
	 sdl-lower-blit
	 sdl-soft-stretch
	 sdl-upper-blit-scaled
	 sdl-lower-blit-scaled

	 ;;types
	 sdl-surface-t
	 sdl-blit-map-t

	 ;;SCANCODE
	 sdl-scancode sdl-scancode-t

	 ;;RWOPS
	 sdl-rw-from-file
	 sdl-rw-from-fp
	 sdl-rw-from-mem
	 sdl-rw-from-const-mem
	 sdl-alloc-rw
	 sdl-free-rw
	 sdl-read-u8
	 sdl-read-l-e16
	 sdl-read-b-e16
	 sdl-read-l-e32
	 sdl-read-b-e32
	 sdl-read-l-e64
	 sdl-read-b-e64

	 ;;types
	 sdl-rw-ops-t

	 ;;GESTURE
	 sdl-record-gesture
	 sdl-save-all-dollar-templates
	 sdl-save-dollar-template
	 sdl-load-dollar-templates
	 ;;types
	 sdl-gesture-id-t

	 ;;GAMECONTROLLER
	 sdl-game-controller-add-mappings-from-rw
	 sdl-game-controller-add-mapping
	 ;sdl-game-controller-mapping-for-guid
	 sdl-game-controller-mapping
	 sdl-is-game-controller
	 sdl-game-controller-name-for-index
	 sdl-game-controller-open
	 sdl-game-controller-name
	 sdl-game-controller-get-attached
	 sdl-game-controller-get-joystick
	 sdl-game-controller-event-state
	 sdl-game-controller-update
	 sdl-game-controller-get-axis-from-string
	 sdl-game-controller-get-string-for-axis
	 sdl-game-controller-get-bind-for-axis
	 sdl-game-controller-get-axis
	 sdl-game-controller-get-button-from-string
	 sdl-game-controller-get-string-for-button
	 sdl-game-controller-get-bind-for-button
	 sdl-game-controller-get-button
	 sdl-game-controller-close

	 ;types
	 sdl-game-controller-t
	 sdl-controller-bind-type
	 sdl-controller-bind-type-t
	 sdl-controller-axis-invalid
	 
	 sdl-game-controller-axis-t

	 ;;AUDIO
	 sdl-get-num-audio-drivers
	 sdl-get-audio-driver
	 sdl-audio-init
	 sdl-audio-quit
	 sdl-get-current-audio-driver
	 sdl-open-audio
	 sdl-get-num-audio-devices
	 sdl-get-audio-device-name
	 sdl-open-audio-device
	 sdl-get-audio-status
	 sdl-get-audio-device-status
	 sdl-pause-audio
	 sdl-pause-audio-device
	 sdl-load-wav-rw
	 sdl-free-wav
	 sdl-build-audio-cvt
	 sdl-convert-audio
	 sdl-mix-audio
	 sdl-mix-audio-format
	 sdl-lock-audio
	 sdl-lock-audio-device
	 sdl-unlock-audio
	 sdl-unlock-audio-device
	 sdl-close-audio
	 sdl-close-audio-device
					;types
	 sdl-audio-device-id-t
	 sdl-audio-status
	 sdl-audio-format-t
	 sdl-audio-callback-t
	 sdl-audio-spec-t
	 sdl-audio-cvt-t

	 ;;ATOMIC
	 sdl-atomic-try-lock
	 sdl-atomic-lock
	 sdl-atomic-unlock
	 sdl-atomic-cas
	 sdl-atomic-set
	 sdl-atomic-get
	 sdl-atomic-add
	 sdl-atomic-cas-ptr
	 sdl-atomic-set-ptr
	 sdl-atomic-get-ptr

	 ;;types
	 sdl-spin-lock-t
	 sdl-atomic-t

	 ;;ASSERT
	 sdl-report-assertion
	 sdl-set-assertion-handler
	 sdl-get-default-assertion-handler
	 sdl-get-assertion-handler
	 sdl-get-assertion-report
	 sdl-reset-assertion-report

	 ;;EXTRAS

	 sdl-event-keyboard-keysym-sym
	 sdl-event-keyboard-keysym-mod
	 sdl-event-mouse-button
	 char-array
	 char*-array->string
	 )

 (import (chezscheme) 
	 (ffi-utils)
	 (only (srfi s1 lists) fold)
	 (only (thunder-utils) string-replace string-split) 
	 (only (srfi s13 strings) string-delete string-suffix? string-prefix?)
	 (srfi s14 char-sets))
 
 (include "sdl2/ffi.ss")
 (include "sdl2/base-types.ss")
 
 (include "sdl2/guardian.ss")

 (include "sdl2/error-types.ss")
 (include "sdl2/error-functions.ss")

 (include "sdl2/assert-types.ss")
 (include "sdl2/assert-functions.ss")
 (include "sdl2/render-types.ss")
 (include "sdl2/render-functions.ss")
 
 (include "sdl2/blendmode-types.ss")

 (include "sdl2/clipboard-functions.ss")

 (include "sdl2/cpuinfo-functions.ss")

 (include "sdl2/endian-functions.ss")

 (include "sdl2/hints-types.ss")
 (include "sdl2/hints-functions.ss")

 (include "sdl2/rect-types.ss")
 (include "sdl2/rect-functions.ss")

 (include "sdl2/scancode-types.ss")

 (include "sdl2/keycode-types.ss")

 (include "sdl2/keyboard-types.ss")
 (include "sdl2/keyboard-functions.ss")


 (include "sdl2/pixels-types.ss")
 (include "sdl2/pixels-functions.ss")

 (include "sdl2/surface-types.ss")
 (include "sdl2/surface-functions.ss")


 (define (sdl-load-bmp filename) 
   (let ([rw (sdl-rw-from-file filename "rb")])
     (assert (not (ftype-pointer-null? rw)))
     (sdl-load-bmp-rw rw 0)))

 (define (sdl-save-bmp surface filename) 
   (let ([rw (sdl-rw-from-file filename  "wb")])
     (assert (not (ftype-pointer-null? rw)))
     (sdl-save-bmp-rw surface rw 0)))



 (include "sdl2/filesystem-functions.ss")

 (include "sdl2/video-types.ss")
 (include "sdl2/video-functions.ss")

 (include "sdl2/messagebox-types.ss")
 (include "sdl2/messagebox-functions.ss")

 (include "sdl2/version-types.ss")
 (include "sdl2/version-functions.ss")

 (include "sdl2/mouse-types.ss")
 (include "sdl2/mouse-functions.ss")

 (include "sdl2/touch-types.ss")
 (include "sdl2/touch-functions.ss")

 (include "sdl2/mutex-types.ss")
 (include "sdl2/mutex-functions.ss")

 (include "sdl2/rwops-types.ss")
 (include "sdl2/rwops-functions.ss")

 (include "sdl2/timer-types.ss")
 (include "sdl2/timer-functions.ss")


 (include "sdl2/thread-types.ss")
 (include "sdl2/thread-functions.ss")

 (include "sdl2/gesture-types.ss")
 (include "sdl2/gesture-functions.ss")

 (include "sdl2/joystick-types.ss")
 (include "sdl2/joystick-functions.ss")

 (include "sdl2/gamecontroller-types.ss")
 (include "sdl2/gamecontroller-functions.ss")

 (include "sdl2/audio-types.ss")
 (include "sdl2/audio-functions.ss")

 (include "sdl2/events-types.ss")
 (include "sdl2/events-functions.ss")
 (include "sdl2/atomic-types.ss")
 (include "sdl2/atomic-functions.ss")

 (include "sdl2/main-functions.ss") 

 (include "sdl2/sdl-functions.ss")

 (include "sdl2/init.ss")

 (include "sdl2/extras.ss")
)
