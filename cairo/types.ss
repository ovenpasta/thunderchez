;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

 (define-ftype unsigned-8* (* unsigned-8))
 (define-ftype unsigned-char unsigned-8)

 (define-ftype cairo-bool-t int)
 (define-ftype cairo-t (struct))

 (define-ftype cairo-surface-t (struct))
 (define-ftype cairo-surface-t* (* cairo-surface-t))
 (define-ftype cairo-device-t void*)

 (define-ftype cairo-matrix-t
   (struct
    [xx double]
    [yx double]
    [xy double]
    [yy double]
    [x0 double]
    [y0 double]))

 (define-ftype-allocator cairo-matrix-create cairo-matrix-t)

 (define-ftype cairo-pattern-t (struct))

					; (define-ftype cairo-destroy-func-t (function (void*) void))
 (define-ftype cairo-destroy-func-t void*)

 (define-ftype cairo-user-data-key-t (struct [unused int]))


 (define-ftype cairo-status-t int)

 (define-enumeration* cairo-status-enum
   (success no-memory invalid-restore invalid-pop-group
	    no-current-point invalid-matrix invalid-status null-pointer
	    invalid-string invalid-path-data read-error write-error
	    surface-finished surface-type-mismatch pattern-type-mismatch
	    invalid-content invalid-format invalid-visual file-not-found
	    invalid-dash invalid-dsc-comment invalid-index
	    clip-not-representable temp-file-error invalid-stride
	    font-type-mismatch user-font-immutable user-font-error
	    negative-count invalid-clusters invalid-slant invalid-weight
	    invalid-size user-font-not-implemented device-type-mismatch
	    device-error invalid-mesh-construction device-finished
	    jbig2-global-missing last-status))

 (define-flags cairo-content
   (color 4096) (alpha 8192) (color-alpha 12288))

 (define-enumeration* cairo-format
   (argb-32 rgb-24 a-8 a-1 rgb-16-565 rgb-30))

 (define cairo-format-invalid -1)

 (define-ftype cairo-write-func-t
   (function (void* void* unsigned-int) cairo-status-t))

 (define-ftype cairo-read-func-t
   (function (void* void* unsigned-int) cairo-status-t))

 (define-ftype cairo-rectangle-int-t
   (struct [x int] [y int] [width int] [height int]))

 (define-ftype-allocator cairo-rectangle-int-create cairo-rectangle-int-t)

 (define-enumeration* cairo-operator
   (clear source over in out atop dest dest-over dest-in
	  dest-out dest-atop xor add saturate multiply screen overlay
	  darken lighten color-dodge color-burn hard-light soft-light
	  difference exclusion hsl-hue hsl-saturation hsl-color
	  hsl-luminosity))

 (define-enumeration* cairo-antialias
   (default none gray subpixel fast good best))

 (define-enumeration* cairo-fill-rule 
   (winding even-odd))

 (define-enumeration* cairo-line-cap 
   (butt round square))

 (define-enumeration* cairo-line-join 
   (miter round bevel))

 (define-ftype double-array (array 0 double))
 (define-ftype-array-allocator double-array-create double-array double)

 (define (double-array-create-from-vector l)
   (let* ([ls (vector->list l)]
	  [size (vector-length l)]
	  [array (double-array-create size)]) 
     (do ([i 0 (fx1+ i)]) 
	 ((fx>= i size))
       (let ([x (vector-ref l i)]
	     [r (ftype-&ref double-array (i) array)])
	 (ftype-set! double () r x)))
     array))

 (define-ftype cairo-rectangle-t
   (struct
    [x double]
    [y double]
    [width double]
    [height double]))

 (define-ftype-allocator cairo-rectangle-create cairo-rectangle-t)

 (define-ftype cairo-rectangle-list-t
   (struct
    [status cairo-status-t]
    [rectangles (* cairo-rectangle-t)]
    [num-rectangles int]))

 (define-ftype-allocator cairo-rectangle-list-create cairo-rectangle-list-t)

 (define-ftype cairo-scaled-font-t void*)

 (define-ftype cairo-font-face-t void*)

 (define-ftype cairo-glyph-t
   (struct [index unsigned-long] [x double] [y double]))

 (define-ftype-allocator cairo-glyph-create cairo-glyph-t)

(define-ftype cairo-glyph-t* (* cairo-glyph-t))
(define-ftype-allocator cairo-glyph*-create cairo-glyph-t*)

 (define-ftype cairo-text-cluster-t
   (struct [num-bytes int] [num-glyphs int]))

 (define-ftype-allocator cairo-text-cluster-create cairo-text-cluster-t)

 (define-ftype cairo-text-cluster-t* (* cairo-text-cluster-t))
 (define-ftype-allocator cairo-text-cluster*-create cairo-text-cluster-t*)
 
 (define-enumeration* cairo-text-cluster-flag
   (none backward))

 (define-ftype cairo-text-cluster-flags-t int)

 (define-ftype-allocator cairo-text-cluster-flags-create cairo-text-cluster-flags-t)

 (define-ftype-allocator cairo-int-create int)
 (define-ftype-allocator cairo-void*-create void*)

 (define-ftype cairo-text-extents-t
   (struct
    [x-bearing double]
    [y-bearing double]
    [width double]
    [height double]
    [x-advance double]
    [y-advance double]))

 (define-ftype-allocator cairo-text-extents-create cairo-text-extents-t)

 (define-ftype cairo-font-extents-t
   (struct
    [ascent double]
    [descent double]
    [height double]
    [max-x-advance double]
    [max-y-advance double]))

 (define-ftype-allocator cairo-font-extents-create cairo-font-extents-t)
					;(define-ftype cairo-font-extents-t int)

 (define-enumeration* cairo-font-slant
   (normal italic oblique))

 (define-enumeration* cairo-font-weight 
   (normal bold))

 (define-enumeration* cairo-subpixel-order
   (default rgb bgr vrgb vbgr))

 (define-enumeration* cairo-hint-style
   (default none slight medium full))

 (define-enumeration* cairo-hint-metrics 
   (default off on))

 (define-ftype cairo-font-options-t void*)

 (define-enumeration* cairo-font-type
   (toy ft win32 quartz user))

 (define-ftype cairo-user-scaled-font-init-func-t
   (function
    (cairo-scaled-font-t (* cairo-t) (* cairo-font-extents-t))
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-render-glyph-func-t
   (function
    (cairo-scaled-font-t
     unsigned-long
     (* cairo-t)
     (*  cairo-font-extents-t ))
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-text-to-glyphs-func-t
   (function
    (cairo-scaled-font-t string int (* cairo-glyph-t) int
			 (* cairo-text-cluster-t) int (* cairo-text-cluster-flags-t))
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-unicode-to-glyph-func-t
   (function
    (cairo-scaled-font-t unsigned-long (* unsigned-long))
    cairo-status-t))

 (define-enumeration* cairo-path-data-type
   (move-to line-to curve-to close-path))

 (define-ftype cairo-path-data-t
   (union
    [header (struct [type cairo-path-data-type-t] [length int])]
    [point (struct [x double] [y double])]))

 (define-ftype cairo-path-t
   (struct
    [status cairo-status-t]
    [data (* cairo-path-data-t)]
    [num-data int]))

 (define-ftype-allocator cairo-path-create cairo-path-t)

 (define-enumeration* cairo-device-type
   (drm gl script xcb xlib xml cogl win32))

 (define cairo-device-type-invalid -1)

 (define-enumeration* cairo-surface-observer-mode
   (normal record-operations))

 (define-ftype cairo-surface-observer-callback-t
   (function ((* cairo-surface-t) (* cairo-surface-t) void*) void))

 (define-enumeration* cairo-surface-type
   (image pdf ps xlib xcb gliz quartz win32 beos directfb svg
	  os2 win32-printing quartz-image script qt recording vg gl
	  drm tee xml skia subsurface cogl))

 (define cairo-mime-types
   '((jpeg . "image/jpeg") (png . "image/png") (jp2 . "image/jp2")
     (uri . "text/x-uri")
     (unique-id . "application/x-cairo.uuid")
     (jbig2 . "application/x-cairo.jbig2")
     (jbig2-global . "application/x-cairo.jbig2-global")
     (jbig2-global-id . "application/x-cairo.jbig2-global-id")))

 (define-ftype cairo-raster-source-acquire-func-t
   (function
    ((* cairo-pattern-t)
     void*
     (* cairo-surface-t)
     (* cairo-rectangle-int-t))
    cairo-status-t))

 (define-ftype cairo-raster-source-acquire-func-t*
   (* cairo-raster-source-acquire-func-t))

 (define-ftype cairo-raster-source-release-func-t
   (function
    ((* cairo-pattern-t) void* (* cairo-surface-t))
    cairo-status-t))

 (define-ftype cairo-raster-source-release-func-t*
  (* cairo-raster-source-release-func-t))

 (define-ftype cairo-raster-source-snapshot-func-t
   (function ((* cairo-pattern-t) void*) cairo-status-t))

 (define-ftype cairo-raster-source-copy-func-t
   (function
    ((* cairo-pattern-t) void* (* cairo-pattern-t))
    cairo-status-t))

 (define-ftype cairo-raster-source-finish-func-t
   (function ((* cairo-pattern-t) void*) cairo-status-t))

 (define-enumeration* cairo-pattern-type
   (solid surface linear radial mesh raster-source))

 (define-enumeration* cairo-extend
   (none repeat reflect pad))

 (define-enumeration* cairo-filter
   (fast good best nearest bilinear gaussian))

 (define-ftype cairo-region-t void*)

 (define-enumeration* cairo-region-overlap
   (in out part))

 (define-ftype cairo-pdf-version-t int)
 (define-ftype cairo-pdf-version-t* (* cairo-pdf-version-t))
 (define-ftype cairo-pdf-version-t-const cairo-pdf-version-t)
