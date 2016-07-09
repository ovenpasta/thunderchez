
(library 
 (sdl2)
 (export sdl-init)
 (import (chezscheme))
 
 (define library-init (load-shared-object "libSDL2.so"))
 
 (define sdl-init-flags%  '((timer           . #x00000001)
			    (audio           . #x00000010)
			    (video           . #x00000020)
			    (joystick        . #x00000200)
			    (haptic          . #x00001000)
			    (game-controller . #x00002000)
			    (events          . #x00004000)
			    (no-parachute    . #x00100000)))
 
 ; calculates 'everything flag
 (define sdl-init-flags 
   (append sdl-init-flags% (list (cons 'everything (fold (lambda (x acc) (logor (cdr x) acc) ) 0 sdl-init-flags)))))

 (define (sdl-init-flag-value x)
   (assert (and  sdl-init-flag-value (symbol? x)))
   (let ([v (assq x sdl-init-flags)])
     (assert (and sdl-init-flag-value (pair? v)))
     (cdr v)))

 (define (sdl-init-flags-or l)
   (assert (and sdl-init-flags-or (list? l)))
   (fold (lambda (x acc) (logor (sdl-init-flag-value x) acc)) 0 l))

 (define (sdl-init-flags-list flags)
   (assert (and sdl-init-flags-list (number? flags)))
   (fold (lambda (x acc) 
	   	   (if (not (zero? (logand flags (cdr x)))) 
		       (cons (car x) acc)
		       acc)) 
	 '() sdl-init-flags%))


 (define (sdl-main-ready)
    (let ([f (foreign-procedure "SDL_MainReady" () void)])
     (f)))

 (define (sdl-init sub-systems)
   (assert (and sdl-init (list? sub-systems)))
   (let ([f (foreign-procedure "SDL_Init" (unsigned-32) int)]
	 [x (sdl-init-flags-or sub-systems)])
     (f x)))

 (define (sdl-init-sub-system sub-system)
   (assert (and sdl-init-sub-system (symbol? sub-system)))
   (let ([f (foreign-procedure "SDL_InitSubSystem" (unsigned-32) int)]
	 [x (sdl-init-flag-value sub-system)])
     (f x)))

 (define (sdl-quit-sub-system sub-system)
   (assert (and sdl-quit-sub-system (symbol? sub-system)))
   (let ([f (foreign-procedure "SDL_QuitSubSystem" (unsigned-32) void)]
	 [x (sdl-init-flag-value sub-system)])
     (f x)))

 (define (sdl-was-init sub-systems)
   (assert (and sdl-init (list? sub-systems)))
   (let ([f (foreign-procedure "SDL_WasInit" (unsigned-32) unsigned-32)]
	 [x (sdl-init-flags-or sub-systems)])
     (sdl-init-flags-list (f x))))
   
 (define (sdl-quit)
   (let ([f (foreign-procedure "SDL_Quit" () void)])
     (f)))
 ) ; library sdl2
