
 (define (sdl-library-init . l)  

   #;(import (only (sdl2 video) sdl-window-t sdl-destroy-window)
	   (only (sdl2 surface) sdl-surface-t sdl-free-surface)
	   (only (sdl2 render) sdl-texture-t sdl-destroy-texture sdl-renderer-t sdl-destroy-renderer)
	   (only (sdl2 mutex) sdl-mutex-t sdl-destroy-mutex sdl-cond-t sdl-destroy-cond)
	   (only (sdl2 mouse) sdl-cursor-t sdl-free-cursor)
	   (only (sdl2 pixels) sdl-pixel-format-t sdl-free-format sdl-palette-t sdl-free-palette)
	   (only (sdl2 rwops) sdl-rw-ops-t sdl-free-rw)	   
	   (only (sdl2 guardian) sdl-guardian sdl-free-garbage))
   (load-shared-object (if (null? l) "libSDL2.so" (car l)))
   (sdl-free-garbage-set-func
	 (lambda ()
	   (let loop ([p (sdl-guardian)])
	     (when p
		   (when (ftype-pointer? p)
			 ;(printf "sdl-free-garbage: freeing memory at ~x\n" p)
			 ;;[(ftype-pointer? usb-device*-array p)
			 (cond 
			  [(ftype-pointer? sdl-window-t p) (sdl-destroy-window p)]
			  [(ftype-pointer? sdl-surface-t p) (sdl-free-surface p)]
			  [(ftype-pointer? sdl-texture-t p) (sdl-destroy-texture p)]
			  [(ftype-pointer? sdl-renderer-t p) (sdl-destroy-renderer p)]
			  [(ftype-pointer? sdl-mutex-t p) (sdl-destroy-mutex p)]			 
			  [(ftype-pointer? sdl-sem-t p) (sdl-destroy-semaphore p)]

			  [(ftype-pointer? sdl-cond-t p) (sdl-destroy-cond p)]
			  [(ftype-pointer? sdl-cursor-t p) (sdl-free-cursor p)]
			  [(ftype-pointer? sdl-pixel-format-t p) (sdl-free-format p)]
			  [(ftype-pointer? sdl-palette-t p) (sdl-free-palette p)]
			  [(ftype-pointer? sdl-rw-ops-t p) (sdl-free-rw p)]
			  [else
			   (foreign-free (ftype-pointer-address p))]
			  ))
		   (loop (sdl-guardian)))))))

 (define-flags sdl-initialization
   (timer           #x00000001)
   (audio           #x00000010)
   (video           #x00000020)
   (joystick        #x00000200)
   (haptic          #x00001000)
   (game-controller #x00002000)
   (events          #x00004000)
   (no-parachute    #x00100000))

 ;; calculates 'everything flag
 (define sdl-initialization-everything 
   (fold (lambda (x acc) (logor (cdr x) acc) ) 0 (flags-alist sdl-initialization-flags)))

