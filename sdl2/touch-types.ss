
(define-ftype sdl-finger-id-t integer-64)
(define-ftype sdl-touch-id-t integer-64)

(define sdl-touch-mouseid #xffffffff)

(define-ftype sdl-finger-t
  (struct 
   (id sdl-finger-id-t)
   (x float)
   (y float)
   (pressure float)))

