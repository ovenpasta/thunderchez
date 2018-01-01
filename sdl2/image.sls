#!r6rs

(library
    (sdl2 image)
  (export

   ;init funcs
   img-init
   img-linked-version
   img-quit

   ;loading
   img-load-typed-rw
   img-load
   img-load-rw
   img-load-texture
   img-load-texture-rw
   img-load-texture-typed-rw

   ;predicates
   img-is-ico
   img-is-cur
   img-is-bmp
   img-is-gif
   img-is-jpg
   img-is-lbm
   img-is-pcx
   img-is-png
   img-is-tif
   img-is-xcf
   img-is-xpm
   img-is-xv
   img-is-webp

   ;specific loading
   img-load-ico-rw
   img-load-cur-rw
   img-load-bmp-rw
   img-load-gif-rw
   img-load-jpg-rw
   img-load-lbm-rw
   img-load-pcx-rw
   img-load-png-rw
   img-load-pnm-rw
   img-load-tga-rw
   img-load-tif-rw
   img-load-xcf-rw
   img-load-xpm-rw
   img-load-xv-rw
   img-load-webp-rw

   ;save and read
   img-read-xpm-from-array
   img-save-png
   img-save-png-rw
   
   ;import libSDL2_image.so
   sdl-image-library-init)

  (import (chezscheme) 
	  (ffi-utils)
	  (sdl2)
	  (only (srfi s1 lists) fold)
	  (only (thunder-utils) string-replace string-split) 
	  (only (srfi s13 strings) string-delete string-suffix? string-prefix?)
	  (srfi s14 char-sets))
  (include "image-functions.ss")
  (include "image-types.ss")
  (define (sdl-image-library-init . l)
    (load-shared-object (if (null? l) "libSDL2_image.so" l))))



