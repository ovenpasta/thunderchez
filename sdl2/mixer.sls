#!r6rs

(library
    (sdl2 mixer)
  (export
   ;;;init
   sdl-mixer-library-init
   mix-init
   mix-quit
   mix-linked-version

   ;;;open func
   mix-open-audio
   mix-open-audio-device
   mix-allocate-channels
   mix-query-spec
   mix-load-wav-rw
   mix-load-mus
   mix-load-mus-rw
   mix-load-mus-type-rw
   mix-quick-load-wav
   mix-quick-load-raw

   ;;;memory
   mix-free-chunk
   mix-free-music
   mix-get-num-chunk-decoders
   mix-get-chunk-decoder
   mix-has-chunk-decoder
   mix-get-num-music-decoders
   mix-get-music-decoder
   mix-has-music-decoder
   mix-get-music-type
   mix-set-post-mix
   mix-hook-music
   mix-hook-music-finished
   mix-get-music-hook-data
   mix-channel-finished
   mix-register-effect
   mix-unregister-effect
   mix-unregister-all-effects
   mix-set-panning
   mix-set-position
   mix-set-distance
   mix-set-reverse-stereo
   mix-reserve-channels
   mix-group-channel
   mix-group-channels
   mix-group-available
   mix-group-count
   mix-group-oldest
   mix-group-newer
   mix-play-channel-timed
   mix-play-music
   mix-fade-in-music
   mix-fade-in-music-pos
   mix-fade-in-channel-timed
   mix-volume
   mix-volume-chunk
   mix-volume-music
   mix-halt-channel
   mix-halt-group
   mix-halt-music
   mix-expire-channel
   mix-fade-out-channel
   mix-fade-out-group
   mix-fade-out-music
   mix-fading-music
   mix-fading-channel
   mix-pause
   mix-resume
   mix-paused
   mix-pause-music
   mix-resume-music
   mix-rewind-music
   mix-paused-music
   mix-set-music-position
   mix-playing
   mix-playing-music
   mix-set-music-cmd
   mix-set-synchro-value
   mix-get-synchro-value
   mix-set-sound-fonts
   mix-get-sound-fonts
   mix-each-sound-font
   mix-get-chunk
   mix-close-audio
   )
   (import (chezscheme) 
	   (ffi-utils)
	   (sdl2)
	   (only (srfi s1 lists) fold)
	   (only (thunder-utils) string-replace string-split) 
	   (only (srfi s13 strings) string-delete string-suffix? string-prefix?)
	   (srfi s14 char-sets))
   (include "mix-functions.ss")
   (include "mix-types.ss")
   (define (sdl-mixer-library-init . l)
     (load-shared-object (if (null? l) "libSDL2_mixer.so" l))))




