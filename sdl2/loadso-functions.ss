(define-sdl-func void* sdl-load-object ((sofile string)) "SDL_LoadObject")
(define-sdl-func void* sdl-load-function ((handle void*) (name string)) "SDL_LoadFunction")
(define-sdl-func void sdl-unload-object ((handle void*)) "SDL_UnloadObject")
