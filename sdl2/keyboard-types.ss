
 (define-ftype sdl-keysym-t
   (struct
       (scancode sdl-scancode-t) 
       (sym sdl-keycode-t) 
       (mod unsigned-16) 
       (unused unsigned-32)))
