(define-sdl-func int sdl-record-gesture ((touchId sdl-touch-id-t)) "SDL_RecordGesture")
(define-sdl-func int sdl-save-all-dollar-templates ((dst (* sdl-rw-ops-t))) "SDL_SaveAllDollarTemplates")
(define-sdl-func int sdl-save-dollar-template ((gestureId sdl-gesture-id-t) (dst (* sdl-rw-ops-t))) "SDL_SaveDollarTemplate")
(define-sdl-func int sdl-load-dollar-templates ((touchId sdl-touch-id-t) (src (* sdl-rw-ops-t))) "SDL_LoadDollarTemplates")
