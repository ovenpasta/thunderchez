
 (define-ftype sdl-audio-device-id-t uint32)
 (define-enumeration* sdl-audio-status
   (stopped playing paused))
 (define-ftype sdl-audio-format-t uint16)
 (define-ftype sdl-audio-callback-t void*)
 (define-ftype sdl-audio-spec-t
   (struct 
    (freq int)
    (format sdl-audio-format-t)
    (channels uint8)
    (silence uint8)
    (samples uint16)
    (padding uint16)
    (size uint32)
    (callback sdl-audio-callback-t)
    (userdata void*)))
 (define-ftype sdl-audio-cvt-t (struct))

