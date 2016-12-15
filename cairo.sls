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

#!chezscheme

(library
 (cairo)
 (export 
  cairo-library-init
  cairo-version cairo-version-string cairo-create 
  ;;cairo-reference cairo-destroy cairo-get-reference-count 
  cairo-get-user-data
  cairo-set-user-data cairo-save cairo-restore cairo-push-group
  cairo-push-group-with-content cairo-pop-group
  cairo-pop-group-to-source cairo-set-operator cairo-set-source
  cairo-set-source-rgb cairo-set-source-rgba cairo-set-source-surface
  cairo-set-tolerance cairo-set-antialias cairo-set-fill-rule
  cairo-set-line-width cairo-set-line-cap cairo-set-line-join
  cairo-set-dash cairo-set-miter-limit cairo-translate cairo-scale
  cairo-rotate cairo-transform cairo-set-matrix cairo-identity-matrix
  cairo-user-to-device cairo-user-to-device-distance
  cairo-device-to-user cairo-device-to-user-distance cairo-new-path
  cairo-move-to cairo-new-sub-path cairo-line-to cairo-curve-to
  cairo-arc cairo-arc-negative cairo-rel-move-to

  cairo-rel-line-to cairo-rel-curve-to cairo-rectangle
  cairo-close-path cairo-path-extents cairo-paint
  cairo-paint-with-alpha cairo-mask cairo-mask-surface cairo-stroke
  cairo-stroke-preserve cairo-fill cairo-fill-preserve cairo-copy-page
  cairo-show-page cairo-in-stroke cairo-in-fill cairo-in-clip
  cairo-stroke-extents cairo-fill-extents cairo-reset-clip cairo-clip
  cairo-clip-preserve cairo-clip-extents cairo-copy-clip-rectangle-list
					;cairo-rectangle-list-destroy 
  cairo-glyph-allocate cairo-glyph-free
  cairo-text-cluster-allocate cairo-text-cluster-free
  cairo-font-options-create cairo-font-options-copy
					;cairo-font-options-destroy 
  cairo-font-options-status
  cairo-font-options-merge cairo-font-options-equal
  cairo-font-options-hash cairo-font-options-set-antialias
  cairo-font-options-get-antialias cairo-font-options-set-subpixel-order
  cairo-font-options-get-subpixel-order
  cairo-font-options-set-hint-style cairo-font-options-get-hint-style
  cairo-font-options-set-hint-metrics
  cairo-font-options-get-hint-metrics cairo-select-font-face
  cairo-set-font-size cairo-set-font-matrix cairo-get-font-matrix
  cairo-set-font-options cairo-get-font-options cairo-set-font-face
  cairo-get-font-face cairo-set-scaled-font cairo-get-scaled-font
  cairo-show-text cairo-show-glyphs cairo-show-text-glyphs
  cairo-text-path cairo-glyph-path cairo-text-extents
  cairo-glyph-extents cairo-font-extents 
					;cairo-font-face-reference cairo-font-face-destroy cairo-font-face-get-reference-count
  cairo-font-face-status cairo-font-face-get-type
  cairo-font-face-get-user-data cairo-font-face-set-user-data
  cairo-scaled-font-create 
					;cairo-scaled-font-reference cairo-scaled-font-destroy cairo-scaled-font-get-reference-count
  cairo-scaled-font-status cairo-scaled-font-get-type
  cairo-scaled-font-get-user-data cairo-scaled-font-set-user-data
  cairo-scaled-font-extents cairo-scaled-font-text-extents
  cairo-scaled-font-glyph-extents cairo-scaled-font-text-to-glyphs
  cairo-scaled-font-get-font-face cairo-scaled-font-get-font-matrix
  cairo-scaled-font-get-ctm cairo-scaled-font-get-scale-matrix
  cairo-scaled-font-get-font-options cairo-toy-font-face-create
  cairo-toy-font-face-get-family cairo-toy-font-face-get-slant
  cairo-toy-font-face-get-weight cairo-user-font-face-create
  cairo-user-font-face-set-init-func
  cairo-user-font-face-set-render-glyph-func
  cairo-user-font-face-set-text-to-glyphs-func
  cairo-user-font-face-set-unicode-to-glyph-func
  cairo-user-font-face-get-init-func
  cairo-user-font-face-get-render-glyph-func
  cairo-user-font-face-get-text-to-glyphs-func
  cairo-user-font-face-get-unicode-to-glyph-func cairo-get-operator
  cairo-get-source cairo-get-tolerance cairo-get-antialias
  cairo-has-current-point cairo-get-current-point cairo-get-fill-rule
  cairo-get-line-width cairo-get-line-cap cairo-get-line-join
  cairo-get-miter-limit cairo-get-dash-count cairo-get-dash
  cairo-get-matrix cairo-get-target cairo-get-group-target
  cairo-copy-path cairo-copy-path-flat cairo-append-path
					;cairo-path-destroy 
  cairo-status cairo-status-to-string
					;cairo-device-reference 
  cairo-device-get-type cairo-device-status
  cairo-device-acquire cairo-device-release cairo-device-flush
  cairo-device-finish 
					;cairo-device-destroy cairo-device-get-reference-count 
  cairo-device-get-user-data
  cairo-device-set-user-data cairo-surface-create-similar
  cairo-surface-create-similar-image cairo-surface-map-to-image
  cairo-surface-unmap-image cairo-surface-create-for-rectangle
  cairo-surface-create-observer
  cairo-surface-observer-add-paint-callback
  cairo-surface-observer-add-mask-callback
  cairo-surface-observer-add-fill-callback
  cairo-surface-observer-add-stroke-callback
  cairo-surface-observer-add-glyphs-callback
  cairo-surface-observer-add-flush-callback
  cairo-surface-observer-add-finish-callback
  cairo-surface-observer-print cairo-surface-observer-elapsed
  cairo-device-observer-print cairo-device-observer-elapsed
  cairo-device-observer-paint-elapsed cairo-device-observer-mask-elapsed
  cairo-device-observer-fill-elapsed
  cairo-device-observer-stroke-elapsed
  cairo-device-observer-glyphs-elapsed 
					;cairo-surface-reference
  cairo-surface-finish 
					;cairo-surface-destroy 
  cairo-surface-get-device
					;cairo-surface-get-reference-count 
  cairo-surface-status
  cairo-surface-get-type cairo-surface-get-content
  cairo-surface-write-to-png cairo-surface-write-to-png-stream
  cairo-surface-get-user-data cairo-surface-set-user-data
  cairo-surface-get-mime-data cairo-surface-set-mime-data
  cairo-surface-supports-mime-type cairo-surface-get-font-options
  cairo-surface-flush cairo-surface-mark-dirty
  cairo-surface-mark-dirty-rectangle cairo-surface-set-device-scale
  cairo-surface-get-device-scale cairo-surface-set-device-offset
  cairo-surface-get-device-offset cairo-surface-set-fallback-resolution
  cairo-surface-get-fallback-resolution cairo-surface-copy-page
  cairo-surface-show-page cairo-surface-has-show-text-glyphs
  cairo-image-surface-create cairo-format-stride-for-width
  cairo-image-surface-create-for-data cairo-image-surface-get-data
  cairo-image-surface-get-format cairo-image-surface-get-width
  cairo-image-surface-get-height cairo-image-surface-get-stride
  cairo-image-surface-create-from-png
  cairo-image-surface-create-from-png-stream
  cairo-recording-surface-create cairo-recording-surface-ink-extents
  cairo-recording-surface-get-extents cairo-pattern-create-raster-source
  cairo-raster-source-pattern-set-callback-data
  cairo-raster-source-pattern-get-callback-data
  cairo-raster-source-pattern-set-acquire
  cairo-raster-source-pattern-get-acquire
  cairo-raster-source-pattern-set-snapshot
  cairo-raster-source-pattern-get-snapshot
  cairo-raster-source-pattern-set-copy
  cairo-raster-source-pattern-get-copy
  cairo-raster-source-pattern-set-finish
  cairo-raster-source-pattern-get-finish cairo-pattern-create-rgb
  cairo-pattern-create-rgba cairo-pattern-create-for-surface
  cairo-pattern-create-linear cairo-pattern-create-radial
  cairo-pattern-create-mesh 
					;cairo-pattern-reference cairo-pattern-destroy cairo-pattern-get-reference-count
  cairo-pattern-status cairo-pattern-get-user-data
  cairo-pattern-set-user-data cairo-pattern-get-type
  cairo-pattern-add-color-stop-rgb cairo-pattern-add-color-stop-rgba
  cairo-mesh-pattern-begin-patch cairo-mesh-pattern-end-patch
  cairo-mesh-pattern-curve-to cairo-mesh-pattern-line-to
  cairo-mesh-pattern-move-to cairo-mesh-pattern-set-control-point
  cairo-mesh-pattern-set-corner-color-rgb
  cairo-mesh-pattern-set-corner-color-rgba cairo-pattern-set-matrix
  cairo-pattern-get-matrix cairo-pattern-set-extend
  cairo-pattern-get-extend cairo-pattern-set-filter
  cairo-pattern-get-filter cairo-pattern-get-rgba
  cairo-pattern-get-surface cairo-pattern-get-color-stop-rgba
  cairo-pattern-get-color-stop-count cairo-pattern-get-linear-points
  cairo-pattern-get-radial-circles cairo-mesh-pattern-get-patch-count
  cairo-mesh-pattern-get-path cairo-mesh-pattern-get-corner-color-rgba
  cairo-mesh-pattern-get-control-point cairo-matrix-init
  cairo-matrix-init-identity cairo-matrix-init-translate
  cairo-matrix-init-scale cairo-matrix-init-rotate
  cairo-matrix-translate cairo-matrix-scale cairo-matrix-rotate
  cairo-matrix-invert cairo-matrix-multiply
  cairo-matrix-transform-distance cairo-matrix-transform-point
  cairo-region-create cairo-region-create-rectangle
  cairo-region-create-rectangles cairo-region-copy
					;cairo-region-reference cairo-region-destroy 
  cairo-region-equal
  cairo-region-status cairo-region-get-extents
  cairo-region-num-rectangles cairo-region-get-rectangle
  cairo-region-is-empty cairo-region-contains-rectangle
  cairo-region-contains-point cairo-region-translate
  cairo-region-subtract cairo-region-subtract-rectangle
  cairo-region-intersect cairo-region-intersect-rectangle
  cairo-region-union cairo-region-union-rectangle cairo-region-xor
  cairo-region-xor-rectangle cairo-debug-reset-static-data
  cairo-pdf-surface-create cairo-pdf-surface-create-for-stream
  cairo-pdf-surface-restrict-to-version cairo-pdf-get-versions
  cairo-pdf-version-to-string cairo-pdf-surface-set-size

  cairo-set-source-color
  color-r color-g color-b color-a
  make-color color?
  
  unsigned-8*
  cairo-bool-t
  cairo-t
  cairo-surface-t
  cairo-surface-t*
  cairo-device-t
  cairo-matrix-t
  cairo-pattern-t
  cairo-destroy-func-t
  cairo-user-data-key-t
  cairo-status-t
  cairo-content-t
  cairo-format-t
  cairo-write-func-t
  cairo-read-func-t
  cairo-rectangle-int-t
  cairo-operator-t
  cairo-antialias-t
  cairo-fill-rule-t
  cairo-line-cap-t
  cairo-line-join-t
  double-array
  cairo-rectangle-t
  cairo-rectangle-list-t
  cairo-scaled-font-t
  cairo-font-face-t
  cairo-glyph-t
  cairo-glyph-t*
  cairo-text-cluster-t
  cairo-text-cluster-t*
  cairo-text-cluster-flags-t
  cairo-text-extents-t
  cairo-font-extents-t
  cairo-font-slant-t
  cairo-font-weight-t
  cairo-subpixel-order-t
  cairo-hint-style-t
  cairo-hint-metrics-t
  cairo-font-options-t
  cairo-font-type-t
  cairo-user-scaled-font-init-func-t
  cairo-user-scaled-font-render-glyph-func-t
  cairo-user-scaled-font-text-to-glyphs-func-t
  cairo-user-scaled-font-unicode-to-glyph-func-t
  cairo-path-data-type-t
  cairo-path-data-t
  cairo-path-t
  cairo-device-type-t
  cairo-surface-observer-mode-t
  cairo-surface-observer-callback-t
  cairo-surface-type-t
  cairo-raster-source-acquire-func-t
  cairo-raster-source-acquire-func-t*
  cairo-raster-source-release-func-t
  cairo-raster-source-release-func-t*
  cairo-raster-source-snapshot-func-t
  cairo-raster-source-copy-func-t
  cairo-raster-source-finish-func-t
  cairo-pattern-type-t
  cairo-extend-t
  cairo-filter-t
  cairo-region-t
  cairo-region-overlap-t
  cairo-pdf-version-t
  cairo-pdf-version-t*
					;enums
  cairo-status-enum
  cairo-format
  cairo-operator
  cairo-antialias
  cairo-fill-rule
  cairo-line-cap
  cairo-line-join
  cairo-text-cluster-flag
  cairo-font-slant
  cairo-font-weight
  cairo-subpixel-order
  cairo-hint-style
  cairo-hint-metrics
  cairo-font-type
  cairo-path-data-type
  cairo-device-type
  cairo-surface-observer-mode
  cairo-surface-type
  cairo-pattern-type
  cairo-extend
  cairo-filter
  cairo-region-overlap
  ;; ALLOCATORS	 
  cairo-rectangle-create
  cairo-rectangle-list-create
  cairo-glyph-create
  cairo-glyph*-create
  cairo-text-cluster-create
  cairo-text-cluster*-create
  cairo-text-extents-create
  cairo-text-cluster-flags-create
  cairo-font-extents-create
  cairo-path-create
  double-array-create 
  double-array-create-from-vector
  cairo-matrix-create
  cairo-int-create
  cairo-void*-create
  cairo-guardian
  cairo-free-garbage
  cairo-guard-pointer
  with-cairo
  let-struct
  )
 (import (chezscheme) (ffi-utils))
 
 (include "cairo/ffi-utils.ss")

 (define (cairo-library-init . t) (load-shared-object (if (null? t) "libcairo.so.2" (car t))))

 (include "cairo/types.ss")

 (define cairo-guardian (make-guardian))
 (define (cairo-guard-pointer obj) 
   (cairo-free-garbage) 
   (cairo-guardian obj)
   obj)
 (include "cairo/cairo-functions.ss")
 (define (cairo-free-garbage)
   (let loop ([p (cairo-guardian)])
     (when p
	   (when (ftype-pointer? p)
		 ;(printf "cairo-free-garbage: freeing memory at ~x\n" p)
		 ;;[(ftype-pointer? usb-device*-array p)
		 (cond 
		  [(ftype-pointer? cairo-t p) (cairo-destroy p)]
		  [(ftype-pointer? cairo-surface-t p) (cairo-surface-destroy p)]
		  [(ftype-pointer? cairo-pattern-t p) (cairo-pattern-destroy p)]
		  [(ftype-pointer? cairo-region-t p) (void)]; (cairo-region-destroy p)]
		  [(ftype-pointer? cairo-rectangle-list-t p) (cairo-rectangle-list-destroy p)]
		  [(ftype-pointer? cairo-font-options-t p) (cairo-font-options-destroy p)]
		  [(ftype-pointer? cairo-font-face-t p) (cairo-font-face-destroy p)]
		  [(ftype-pointer? cairo-scaled-font-t p) (cairo-scaled-font-destroy p)]
		  [(ftype-pointer? cairo-path-t p) (cairo-path-destroy p)]
		  [(ftype-pointer? cairo-device-t p) (cairo-device-destroy p)]
		  [(ftype-pointer? cairo-glyph-t p) (cairo-glyph-free p)]
		  [(ftype-pointer? cairo-text-cluster-t p) (cairo-text-cluster-free p)]
		  [else
		   (foreign-free (ftype-pointer-address p))]
		  ))
	   (loop (cairo-guardian)))))



(include "cairo/cairo-pdf-functions.ss")

(define-record-type (color mkcolor color?) 
  (fields r g b a))

(define make-color
  (case-lambda
   [(r g b) (mkcolor r g b 1.0)]
   [(r g b a) (mkcolor r g b a)]))
  
(define (cairo-set-source-color ctx c)
  (cairo-set-source-rgba ctx (color-r c) (color-g c) (color-b c) (color-a c)))

) ; library cairo
