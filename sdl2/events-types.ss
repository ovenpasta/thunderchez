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

(define-flags sdl-event-type
    (firstevent       0 ) ;     /**< unused (do not remove) */

    ;/* application events */
    (quit             #x100) ; /**< user-requested quit */

    ;/* these application events have special meaning on ios, see readme-ios.txt for details */
    (app-terminating   #x101);        /**< the application is being terminated by the os
                                 ;    called on ios in applicationwillterminate()
                                 ;    called on android in ondestroy()
                                
    (app-lowmemory   #x102) ;,          /**< the application is low on memory, free memory if possible.
                                 ;    called on ios in applicationdidreceivememorywarning()
                                 ;    called on android in onlowmemory()
                                
    (app-willenterbackground   #x103) ;,  /**< the application is about to enter the background
                                    ; called on ios in applicationwillresignactive()
                                    ; called on android in onpause()
                                 
    (app-didenterbackground   #x104) ;/**< the application did enter the background and may not get cpu for some time
                                     ;called on ios in applicationdidenterbackground()
                                     ;called on android in onpause()
                                
    (app-willenterforeground   #x105) ;/**< the application is about to enter the foreground
                                 ;    called on ios in applicationwillenterforeground()
                                 ;    called on android in onresume()
        
    (app-didenterforeground   #x106); /**< the application is now interactive
                                     ;called on ios in applicationdidbecomeactive()
                                     ;called on android in onresume()
                                     ;*/

   ;   /* window events */
    (windowevent      #x200); /**< window state change */
    (syswmevent       #x201); /**< system specific event */

    ;/* keyboard events */
    (keydown          #x300); /**< key pressed */
    (keyup            #x301); /**< key released */
    (textediting      #x302); /**< keyboard text editing (composition) */
    (textinput        #x303); /**< keyboard text input */

    ;* mouse events */
   (mousemotion       #x400);/**< mouse moved */
   (mousebuttondown   #x401);**< mouse button pressed */
   (mousebuttonup     #x402);**< mouse button released */
   (mousewheel        #x403);**< mouse wheel motion */

    ;* joystick events */
   (joyaxismotion    #x600);/**< joystick axis motion */
   (joyballmotion    #x601);/**< joystick trackball motion */
   (joyhatmotion     #x602);/**< joystick hat position change */
   (joybuttondown    #x603);/**< joystick button pressed */
   (joybuttonup      #x604);/**< joystick button released */
   (joydeviceadded   #x605);/**< a new joystick has been inserted into the system */
   (joydeviceremoved   #x606);1< an opened joystick has been removed */

   ;/* game controller events */
   (controlleraxismotion    #x650);/**< game controller axis motion */
   (controllerbuttondown    #x651);/**< game controller button pressed */
   (controllerbuttonup      #x652);/**< game controller button released */
   (controllerdeviceadded   #x653);/**< a new game controller has been inserted into the system */
   (controllerdeviceremoved   #x654);*< an opened game controller has been removed */
   (controllerdeviceremapped   #x655);*< the controller mapping was updated */

    ;* touch events */
   (fingerdown        #x700)
   (fingerup          #x701)
   (fingermotion      #x702)

    ;* gesture events */
   (dollargesture     #x800)
   (dollarrecord      #x801)
   (multigesture      #x802)

    ;* clipboard events */
   (clipboardupdate   #x900);/**< the clipboard changed */

    ;* drag and drop events */
   (dropfile          #x1000);/**< the system requests a file open */

    ;* render events */
   (render-targets-reset   #x2000);/**< the render targets have been reset */

  ; /** events ::userevent through ::lastevent are for your use,
  ;  *  and should be allocated with registerevents()
  ;  */
   (userevent      #x8000)

  ; /**
  ;  *  this last event is only for bounding internal arrays
  ;  */
   (lastevent      #xffff))

; Fields shared by every event
(define-ftype sdl-common-event-t
  (struct
   (type uint32)
   (timestamp uint32)))

 (define-ftype sdl-common-event-t* void*)

; Window state change event data (event.window.*)
(define-ftype sdl-window-event-t
  (struct
    (type uint32) ;        /**< ::SDL_WINDOWEVENT */
    (timestamp uint32)
    (window-id uint32);    /**< The associated window */
    (event uint8);        /**< ::SDL_WindowEventID */
    (padding1 uint8)
    (padding2 uint8)
    (padding3 uint8)
    (data1 sint32);       /**< event dependent data */
    (data2 sint32))) ;       /**< event dependent data */

; Keyboard button event structure (event.key.*)
(define-ftype sdl-keyboard-event-t
  (struct
    (type uint32) ;        /**< ::SDL_KEYDOWN or ::SDL_KEYUP */
    (timestamp uint32)
    (window-id uint32) ;    /**< The window with keyboard focus, if any */
    (state uint8) ;        /**< ::SDL_PRESSED or ::SDL_RELEASED */
    (repeat uint8) ;       /**< Non-zero if this is a key repeat */
    (padding2 uint8) 
    (padding3 uint8) 
    (keysym sdl-keysym-t)))  ;  /**< The key that was pressed or released */

(define-syntax sdl-texteditingevent-text-size (identifier-syntax 32))

; Keyboard text editing event structure (event.edit.*)
  (define-ftype sdl-text-editing-event-t
    (struct
     (type uint32)        ;                                /**< ::SDL_TEXTEDITING */
     (timestamp uint32)   
     (window-id uint32)   ;                            /**< The window with keyboard focus, if any */
     (text (array 32 char))     ; sdl-texteditingevent-text-size  /**< The editing text */
     (start sint32)   ;                               /**< The start cursor of selected editing text */
     (length sint32))) ;                              /**< The length of selected editing text */
 
(define-syntax sdl-textinputevent-text-size (identifier-syntax 32))

; Keyboard text input event structure (event.text.*)
(define-ftype sdl-text-input-event-t
  (struct
   (type uint32) ;                              /**< ::SDL_TEXTINPUT */
   (timestamp uint32);
   (window-id uint32);                          /**< The window with keyboard focus, if any */
   (text (array 32 char)))) ;sdl-textinputevent-text-size  /**< The input text */

; Mouse motion event structure (event.motion.*)
(define-ftype sdl-mouse-motion-event-t
  (struct
     (type uint32);        /**< ::SDL_MOUSEMOTION */
     (timestamp uint32);
     (window-id uint32);    /**< The window with mouse focus, if any */
     (which uint32);       /**< The mouse instance id, or SDL_TOUCH_MOUSEID */
     (state uint32);       /**< The current button state */
     (x sint32);           /**< X coordinate, relative to window */
     (y sint32);           /**< Y coordinate, relative to window */
     (xrel sint32);        /**< The relative motion in the X direction */
     (yrel sint32)));        /**< The relative motion in the Y direction */

; Mouse button event structure (event.button.*)
(define-ftype sdl-mouse-button-event-t
  (struct
    (type uint32);        /**< ::SDL_MOUSEBUTTONDOWN or ::SDL_MOUSEBUTTONUP */
    (timestamp uint32);
    (window-id uint32);    /**< The window with mouse focus, if any */
    (which uint32);       /**< The mouse instance id, or SDL_TOUCH_MOUSEID */
    (button uint8);       /**< The mouse button index */
    (state uint8);        /**< ::SDL_PRESSED or ::SDL_RELEASED */
    (clicks uint8);       /**< 1 for single-click, 2 for double-click, etc. */
    (padding1 uint8);
    (x sint32);           /**< X coordinate, relative to window */
    (y sint32)));           /**< Y coordinate, relative to window */

;  Mouse wheel event structure (event.wheel.*)
(define-ftype sdl-mouse-wheel-event-t
  (struct
   (type uint32);        /**< ::SDL_MOUSEWHEEL */
   (timestamp uint32);
   (window-id uint32);     /**< The window with mouse focus, if any */
   (which uint32);       /**< The mouse instance id, or SDL_TOUCH_MOUSEID */
   (x sint32);           /**< The amount scrolled horizontally, positive to the right and negative to the left */
   (y sint32)));           /**< The amount scrolled vertically, positive away from the user and negative toward the user */

;; JOYSTICK AND CONTROLLERS ARE NOT OF MY INTEREST BUT YOU CAN IMPLEMENT THEM AS HOMEWORK


; Touch finger event structure (event.tfinger.*)
(define-ftype sdl-touch-finger-event-t
  (struct
   (type uint32);        /**< ::SDL_FINGERMOTION or ::SDL_FINGERDOWN or ::SDL_FINGERUP */
   (timestamp uint32);
    (touch-id sdl-touch-id-t); /**< The touch device id */
    (finger-id sdl-finger-id-t);
    (x float);            /**< Normalized in the range 0...1 */
    (y float);            /**< Normalized in the range 0...1 */
    (dx float);           /**< Normalized in the range 0...1 */
    (dy float);           /**< Normalized in the range 0...1 */
    (pressure float)))

; Multiple Finger Gesture Event (event.mgesture.*)
(define-ftype sdl-multi-gesture-event-t
  (struct
   (type uint32);        /**< ::SDL_MULTIGESTURE */
    (timestamp uint32);
    (touch-id sdl-touch-id-t); /**< The touch device index */
    (d-theta float)
    (d-dist float)
    (x float)
    (y float)
    (num-fingers uint16)
    (padding uint16)))


; Begin Recording a gesture on the specified touch, or all touches (-1)
;(define-sdl-func int% SDL_RecordGesture ((touch-id sdl-touch-id)))

;; ;(define-sdl-func int SDL_SaverAllDollarTemplates (SDL_RWops*))
;; ;(define-sdl-func int SDL_SaveDollarTemplate (SDL_GestureID SDL_RWops*))

; Dollar Gesture Event (event.dgesture.*)
(define-ftype sdl-dollar-gesture-event-t
  (struct
   (type uint32);        /**< ::SDL_DOLLARGESTURE */
    (timestamp uint32);
    (touch-id sdl-touch-id-t); /**< The touch device id */
    (gesture-id sdl-gesture-id-t);
    (num-fingers uint32)
    (error float);
    (x float);            /**< Normalized center of gesture */
    (y float)))

; An event used to request a file open by the system (event.drop.*)
; This event is disabled by default, you can enable it with SDL_EventState()
;: If you enable this event, you must free the filename in the event.
(define-ftype sdl-drop-event-t
  (struct
   (type uint32);        /**< ::SDL_DROPFILE */
   (timestamp uint32);
   (filename void*)));         /**< The file name, which should be freed with SDL_free() */

; The "quit requested" event
(define-ftype sdl-quit-event-t
  (struct 
   (type uint32) ; /**< ::SDL_QUIT */
   (timestamp uint32)))
; A user-defined event type (event.user.*)

(define-ftype sdl-user-event-t
  (struct
   (type uint32)      ;  /**< ::SDL_USEREVENT through ::SDL_LASTEVENT-1 */
   (timestamp uint32)
   (window-id uint32) ;   /**< The associated window if any */
   (code sint32)  ;      /**< User defined event code */
   (data1 void*)  ;      /**< User defined data pointer */
   (data2 void*)));        /**< User defined data pointer */

(define-ftype sdl-sys-wm-msg (struct))

; *  \brief A video driver dependent system event (event.syswm.*)
; *         This event is disabled by default, you can enable it with SDL_EventState()
; *
; *  \note If you want to use this event, you should include SDL_syswm.h.

(define-ftype sdl-sys-wm-event-t
  (struct
   (type uint32)        ;/**< ::SDL_SYSWMEVENT */
   (timestamp uint32)
   (msg (* sdl-sys-wm-msg))))  ;/**< driver dependent data, defined in SDL_syswm.h */

(define-ftype sdl-joy-axis-event-t (struct))
(define-ftype sdl-joy-hat-event-t (struct))
(define-ftype sdl-joy-device-event-t (struct))
(define-ftype sdl-joy-button-event-t (struct))
(define-ftype sdl-joy-ball-event-t (struct))
(define-ftype sdl-controller-button-event-t (struct))
(define-ftype sdl-controller-device-event-t (struct))
(define-ftype sdl-joystick-id-t sint32)
(define-ftype sdl-controller-axis-event-t 
  (struct
   (type uint32)
   (timestamp uint32)
   (which sdl-joystick-id-t)
   (axis uint8)
   (padding1 uint8)
   (padding2 uint8)
   (padding3 uint8)
   (value sint16)
   (padding4 uint16)))

(define-ftype sdl-event-t
  (union
   (type uint32)                    ; /**< Event type, shared with all events */
   (common sdl-common-event-t)         ; /**< Common event data */
   (window sdl-window-event-t)         ; /**< Window event data */
   (key sdl-keyboard-event-t)          ; /**< Keyboard event data */
   (edit sdl-text-editing-event-t)      ; /**< Text editing event data */
   (text sdl-text-input-event-t)        ; /**< Text input event data */
   (motion sdl-mouse-motion-event-t)    ; /**< Mouse motion event data */
   (button sdl-mouse-button-event-t)    ; /**< Mouse button event data */
   (wheel sdl-mouse-wheel-event-t)      ; /**< Mouse wheel event data */
   (jaxis sdl-joy-axis-event-t)         ; /**< Joystick axis event data */
   (jball sdl-joy-ball-event-t)         ; /**< Joystick ball event data */
   (jhat sdl-joy-hat-event-t)           ; /**< Joystick hat event data */
   (jbutton sdl-joy-button-event-t)     ; /**< Joystick button event data */
   (jdevice sdl-joy-device-event-t)     ; /**< Joystick device change event data */
   (caxis sdl-controller-axis-event-t)      ; /**< Game Controller axis event data */
   (cbutton sdl-controller-button-event-t)  ; /**< Game Controller button event data */
   (cdevice sdl-controller-device-event-t)  ; /**< Game Controller device event data */
   (quit sdl-quit-event-t)             ; /**< Quit request event data */
   (user sdl-user-event-t)             ; /**< Custom event data */
   (syswm sdl-sys-wm-event-t)           ; /**< System dependent window event data */
   (tfinger sdl-touch-finger-event-t)   ; /**< Touch finger event data */
   (mgesture sdl-multi-gesture-event-t) ; /**< Gesture event data */
   (dgesture sdl-dollar-gesture-event-t) ; /**< Gesture event data */
   (drop sdl-drop-event-t)             ; /**< Drag and drop event data */

    ;; /* This is necessary for ABI compatibility between Visual C++ and GCC
    ;;    Visual C++ will respect the push pack pragma and use 52 bytes for
    ;;    this structure, and GCC will use the alignment of the largest datatype
    ;;    within the union, which is 8 bytes.

    ;;    So... we'll add padding to force the size to be 56 bytes for both.
    ;; */
   (padding (array 56 uint8))))

(define-enumeration* sdl-eventaction 
  (add peek get))
 
(define-ftype sdl-event-filter-t void*) ;FIXME (function (void* sdl-event*) int))

(define sdl-query -1)
(define sdl-ignore 0)
(define sdl-disable 0)
(define sdl-enable 1)
