(define-ftype mix-chunk
  (struct

      (allocated int)
    (abuf uint8)
    (alen uint32)
    (volume uint8)))

(define-ftype mix-music
  (struct))

(define-ftype mix-music-type uint8)

(define-ftype mix-fading uint8)
;;;Fixme enum ^

(define-ftype mix-effect-func-t (function (int void* int void*) void))
(define-ftype mix-effect-done-t (function (int void*) void))
