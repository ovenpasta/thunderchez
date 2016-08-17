
 (define-ftype sdl-game-controller-t (struct))

 (define-enumeration* sdl-controller-bind-type 
   (none button axis hat))
 
 (define sdl-controller-axis-invalid -1)
 (define-enumeration*  sdl-controller-axis
   (left-x left-y right-x right-y trigger-left trigger-right))
 
;;TODO IMPLEMENT THIS
 (define-ftype sdl-game-controller-axis-t void*)
 (define-ftype sdl-game-controller-button-bind-t void*)
(define-ftype sdl-game-controller-button-t void*)
