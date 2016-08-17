(define-sdl-func int sdl-get-num-touch-devices () "SDL_GetNumTouchDevices")
(define-sdl-func sdl-touch-id-t sdl-get-touch-device ((index int)) "SDL_GetTouchDevice")
(define-sdl-func int sdl-get-num-touch-fingers ((touchID sdl-touch-id-t)) "SDL_GetNumTouchFingers")
(define-sdl-func (* sdl-finger-t) sdl-get-touch-finger ((touchID sdl-touch-id-t) (index int)) "SDL_GetTouchFinger")
