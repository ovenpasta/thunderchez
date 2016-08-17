(define-sdl-func void sdl-get-version ((ver (* sdl-version-t))) "SDL_GetVersion")
(define-sdl-func string sdl-get-revision () "SDL_GetRevision")
(define-sdl-func int sdl-get-revision-number () "SDL_GetRevisionNumber")
