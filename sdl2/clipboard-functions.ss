(define-sdl-func int sdl-set-clipboard-text ((text string)) "SDL_SetClipboardText")
(define-sdl-func string sdl-get-clipboard-text () "SDL_GetClipboardText")
(define-sdl-func sdl-bool-t sdl-has-clipboard-text () "SDL_HasClipboardText")
