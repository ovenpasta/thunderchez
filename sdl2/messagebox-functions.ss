(define-sdl-func int sdl-show-message-box ((messageboxdata (* sdl-message-box-data-t)) (buttonid (* int))) "SDL_ShowMessageBox")
(define-sdl-func int sdl-show-simple-message-box ((flags uint32) (title string) (message string) (window (* sdl-window-t))) "SDL_ShowSimpleMessageBox")
