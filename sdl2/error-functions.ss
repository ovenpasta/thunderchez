(define-sdl-func int sdl-set-error ((fmt string)) "SDL_SetError")
(define-sdl-func string sdl-get-error () "SDL_GetError")
(define-sdl-func void sdl-clear-error () "SDL_ClearError")
(define-sdl-func int sdl-error ((code sdl-errorcode-t)) "SDL_Error")
