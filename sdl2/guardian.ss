(define sdl-guardian (make-guardian))

 (define (sdl-guard-pointer obj) 
   (sdl-free-garbage) 
   (sdl-guardian obj) 
   obj)
 
 (define sdl-free-garbage-func (lambda () (if #f #f)))
 (define (sdl-free-garbage-set-func f) (set! sdl-free-garbage-func f))
 (define (sdl-free-garbage) (sdl-free-garbage-func))
