
 (define-ftype sdl-blit-map-t (struct))
 (define-ftype sdl-surface-t
  (struct
   (flags uint32)
   (format (* sdl-pixel-format-t))
   (w int)
   (h int)
   (pitch int)
   (pixels void*)
   (userdata void*)
   (locked int)
   (lock_data void*)
   (clip_rect sdl-rect-t)
   (map (* sdl-blit-map-t)) ;; /usr/include/SDL2/SDL_surface.h:881:2
   (refcount int)))


