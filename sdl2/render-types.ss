
(define-flags sdl-renderer-flags
  (software 1)
  (accelerated 2)
  (presentvsync 4)
  (targettexture 8))

(define-ftype sdl-renderer-info-t
  (struct 
   (name (* char))
   (flags uint32)
   (num-texture-formats uint32)
   (texture_formats (array 16 uint32))
   (max-texture-width int)
   (max-texture-height int)))

(define-flags sdl-texture-access 
  (static 0)
  (streaming 1)
  (target 2))

(define-flags sdl-texture-modulate 
  (none 0)
  (color 1) 
  (alpha 2))

(define-flags sdl-renderer-flip
  (none 0)
  (horizontal 1)
  (vertical 2))

(define-ftype sdl-renderer-t (struct))
(define-ftype sdl-texture-t (struct))
