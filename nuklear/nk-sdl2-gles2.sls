#!r6rs

(library
    (nuklear sdl2-gles2)
  (export
   nk-sdl-init
   nk-sdl-handle-event
   nk-sdl-shutdown
   nk-sdl-device-destroy
   nk-sdl-device-create
   nk-sdl-device-t
   nk-sdl-vertex-t
   nk-sdl-t
   )
  (import (chezscheme)
          (ffi-utils)
          (only (srfi s1 lists) fold)
          (only (thunder-utils) string-replace string-split)
	        (only (srfi s13 strings) string-delete string-suffix? string-prefix?)
	        (srfi s14 char-sets)
          (nuklear)
          (except (sdl2) define-ftype-allocator))

  (include "nk-types.ss")
  (include "gles-types.ss")
  (include "gles-functions.ss"))
