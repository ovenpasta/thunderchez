

(define (sdl-event-keyboard-keysym-sym e)
  (let* ([keyboard (ftype-&ref sdl-event-t (key) e)]
	 [keysym (ftype-&ref sdl-keyboard-event-t (keysym) keyboard)]
	 [sym (ftype-ref sdl-keysym-t (sym) keysym)])
	 sym))

(define (sdl-event-keyboard-keysym-mod e)
  (let* ([keyboard (ftype-&ref sdl-event-t (key) e)]
	 [keysym (ftype-&ref sdl-keyboard-event-t (keysym) keyboard)]
	 [mod (ftype-ref sdl-keysym-t (mod) keysym)])
	 mod))

(define (sdl-event-mouse-button e)
  (let* ([button (ftype-&ref sdl-event-t (button) e)]
	 [button* (ftype-ref sdl-mouse-button-event-t (button) button)])
	 button*))

(define-ftype char-array (array 0 char))

;; THIS IS FOR DECODING sdl-text-input-event text
(define (char*-array->string ptr max)
  (let loop ([i 0] [r '()])
    (let ([x (ftype-ref char-array (i) 
			(make-ftype-pointer char-array 
					    (ftype-pointer-address ptr)))])
      (if (or (eqv? x #\nul) (>= i max))
	  (utf8->string (u8-list->bytevector (reverse r)))
	  (loop (+ i 1) (cons (char->integer x) r))))))
