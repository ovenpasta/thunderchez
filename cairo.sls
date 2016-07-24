#!chezscheme

(library
 (cairo)
 (export 
	 cairo-library-init
	 cairo-version cairo-version-string cairo-create 
	 ;cairo-reference cairo-destroy cairo-get-reference-count 
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
	 cairo-arc cairo-arc-negative cairo-arc-to cairo-rel-move-to

	 cairo-rel-line-to cairo-rel-curve-to cairo-rectangle
	 cairo-stroke-to-path cairo-close-path cairo-path-extents cairo-paint
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
	 cairo-bool-t
	 int*
	 const-char*
	 unsigned-int*
	 cairo-t
	 cairo-t*
	 cairo-surface-t
	 cairo-surface-t*
	 cairo-device-t
	 cairo-device-t*
	 cairo-matrix-t
	 cairo-matrix-t*
	 cairo-pattern-t
	 cairo-destroy-func-t
	 cairo-destroy-func-t*
	 cairo-user-data-key-t
	 cairo-user-data-key-t*
	 cairo-status-t
	 cairo-content-t
	 cairo-format-t
	 cairo-write-func-t
	 cairo-write-func-t*
	 cairo-read-func-t
	 cairo-read-func-t*
	 cairo-rectangle-int-t
	 cairo-rectangle-int-t*
	 cairo-operator-t
	 cairo-antialias-t
	 cairo-fill-rule-t
	 cairo-line-cap-t
	 cairo-line-join-t
	 double*
	 double-array
	 cairo-rectangle-t
	 cairo-rectangle-t*
	 cairo-rectangle-list-t
	 cairo-rectangle-list-t*
	 cairo-scaled-font-t
	 cairo-font-face-t
	 cairo-glyph-t
	 cairo-glyph-t*
	 cairo-text-cluster-t
	 cairo-text-cluster-t*
	 cairo-text-cluster-flags-t
	 cairo-text-cluster-flags-t*
	 cairo-text-extents-t
	 cairo-text-extents-t
	 cairo-text-extents-t*
	 cairo-font-extents-t
	 cairo-font-extents-t
	 cairo-font-extents-t*
	 cairo-font-slant-t
	 cairo-font-weight-t
	 cairo-subpixel-order-t
	 cairo-hint-style-t
	 cairo-hint-metrics-t
	 cairo-font-options-t
	 cairo-font-type-t
	 cairo-user-scaled-font-init-func-t
	 cairo-user-scaled-font-init-func-t*
	 cairo-user-scaled-font-render-glyph-func-t
	 cairo-user-scaled-font-render-glyph-func-t*
	 cairo-user-scaled-font-text-to-glyphs-func-t
	 cairo-user-scaled-font-text-to-glyphs-func-t*
	 unsigned-long*
	 cairo-user-scaled-font-unicode-to-glyph-func-t
	 cairo-user-scaled-font-unicode-to-glyph-func-t*
	 cairo-path-data-type-t
	 cairo-path-data-t
	 cairo-path-t
	 cairo-path-t*
	 cairo-device-type-t
	 cairo-surface-observer-mode-t
	 cairo-surface-observer-callback-t
	 cairo-surface-observer-callback-t*
	 cairo-surface-type-t
	 cairo-raster-source-acquire-func-t
	 cairo-raster-source-acquire-func-t*
	 cairo-raster-source-release-func-t
	 cairo-raster-source-release-func-t*
	 cairo-raster-source-snapshot-func-t
	 cairo-raster-source-snapshot-func-t*
	 cairo-raster-source-copy-func-t
	 cairo-raster-source-copy-func-t*
	 cairo-raster-source-finish-func-t
	 cairo-raster-source-finish-func-t*
	 cairo-pattern-type-t
	 cairo-extend-t
	 cairo-filter-t
	 cairo-region-t
	 cairo-region-t*
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
	  cairo-text-cluster-create
	  cairo-text-extents-create
	  cairo-font-extents-create
	  cairo-path-create
	  double-array-create 
	  double-array-create-from-vector

	  cairo-matrix-create

	  cairo-guardian
	  cairo-free-garbage
	  cairo-guard-pointer
	 )
 (import (chezscheme) (ffi-utils))


 (define-syntax define-function*
   (lambda (x)
     (define (string-replace s x y)
       (list->string  
	(let ([cmp (if (list? x) memq eq?)])
	  (map (lambda (z) (if (cmp z x) y z)) (string->list s)))))
     
     (define (rename-scheme->c type)
       (cond [(case (syntax->datum type)
					;[(cairo-t*) 'cairo-t]
		[(const-char*) 'string]
		[(const-unsigned-char*) 'u8*]
		[(unsigned-char*) 'u8*]
		[(const-double*) 'double*]
		[(const-cairo-user-data-key-t*)  'cairo-user-data-key-t*]
		[(cairo-destroy-func-t)  'cairo-destroy-func-t*]
		[(const-cairo-matrix-t*) 'cairo-matrix-t*]
		[(cairo-font-options-t*) 'cairo-font-options-t]
		[(const-cairo-font-options-t*) 'cairo-font-options-t]
		[(cairo-font-face-t*) 'cairo-font-face-t]
		[(const-cairo-scaled-font-t*) 'cairo-scaled-font-t]
		[(cairo-scaled-font-t*) 'cairo-scaled-font-t]
		[(const-cairo-glyph-t*) 'cairo-glyph-t*]
		[(const-cairo-text-cluster-t*) 'cairo-text-cluster-t*]
		[(cairo-user-scaled-font-init-func-t) 'cairo-user-scaled-font-init-func-t*]
		[(cairo-user-scaled-font-render-glyph-func-t) 'cairo-user-scaled-font-render-glyph-func-t*]
		[(cairo-user-scaled-font-text-to-glyphs-func-t) 'cairo-user-scaled-font-text-to-glyphs-func-t*]
		[(cairo-user-scaled-font-unicode-to-glyph-func-t) 'cairo-user-scaled-font-unicode-to-glyph-func-t*]
		[(const-cairo-path-t*) 'cairo-path-t*]
		[(const-cairo-rectangle-int-t*) 'cairo-rectangle-int-t*]
		[(const-cairo-rectangle-t*) 'cairo-rectangle-t*]
		[(cairo-surface-observer-callback-t) 'cairo-surface-observer-callback-t*]
		[(cairo-write-func-t) 'cairo-write-func-t*]
		[(cairo-read-func-t) 'cairo-read-func-t*]	       
		[(cairo-raster-source-release-func-t) 'cairo-raster-source-release-func-t*]
		[(cairo-raster-source-acquire-func-t) 'cairo-raster-source-acquire-func-t*]
		[(cairo-raster-source-snapshot-func-t) 'cairo-raster-source-snapshot-func-t*]
		[(cairo-raster-source-copy-func-t) 'cairo-raster-source-copy-func-t*]
		[(cairo-raster-source-finish-func-t) 'cairo-raster-source-finish-func-t*]
		[(const-cairo-region-t*) 'cairo-region-t*]
		[(cairo-pdf-version-t-const*) 'cairo-pdf-version-t*]
		[else #f])
	      => (lambda (t)
		   (datum->syntax type t))]
	     [else type]))

     (define (convert-scheme->c function-name name type)
       (import (only (srfi s13 strings) 
		     string-delete string-suffix? string-prefix?))
       (define (remove-* x)
	 (string->symbol (string-delete #\* (symbol->string x))))
       
       (let ([t (syntax->datum (rename-scheme->c type))]
	     [t* (syntax->datum type)])
	 (cond 
	  [(eq? t* 'const-double*) 
	   #`(ftype-pointer-address 
	      (double-array-create-from-vector #,name))]
	  [(eq? t* 'double) #`(real->flonum #,name)]
	  [(and (string-prefix? "cairo-" (symbol->string t))
		(string-suffix? "*" (symbol->string t)))
	   #`(if (ftype-pointer? #,(datum->syntax type (remove-* t)) #,name) 
		 (ftype-pointer-address #,name) 
		 (assertion-violation 'convert-scheme->c "wrong pointer type for argument" (quote #,function-name) (quote #,name) (quote #,type) #,name))]
	  [else name])))

     (define (datum->string x)
       (symbol->string (syntax->datum x)))

     (define (string->datum t x)
       (datum->syntax t (string->symbol x)))

     (syntax-case x ()
       [(_ name ((arg-name arg-type) ...) ret-type) 
	(with-syntax ([name/string (datum->string #'name)]
		      [name (string->datum #'name (string-replace (datum->string #'name) #\_ #\-))]
		      [(renamed-type ...) (map rename-scheme->c #'(arg-type ...))]
		      [renamed-ret (rename-scheme->c #'ret-type)]
		      [function-ftype (datum->syntax #'name (string->symbol (string-append (symbol->string (syntax->datum #'name)) "-ft")))]
		      [((arg-name arg-convert) ...) (map (lambda (n t) 
							   (list n (convert-scheme->c #'name n t))) 
							 #'(arg-name ...) #'(arg-type ...))])
		     #`(begin
			 (define (name arg-name ...) 
			   (define-ftype function-ftype (function (renamed-type ...) renamed-ret))
			   (let* ([function-fptr  (make-ftype-pointer function-ftype name/string)]
				  [function       (ftype-ref function-ftype () function-fptr)]
				  [arg-name arg-convert] ...)
			     (let ([result (function arg-name ...)])
			       #,(case (syntax->datum #'ret-type)
				   [(cairo-status-t)          #'(cairo-status-enum-ref result)]
				   [(cairo-t*)                #'(cairo-guard-pointer (make-ftype-pointer cairo-t result))]
				   [(cairo-surface-t*)        #'(cairo-guard-pointer (make-ftype-pointer cairo-surface-t result))]
				   [(cairo-pattern-t*)        #'(cairo-guard-pointer (make-ftype-pointer cairo-pattern-t result))]
				   [(cairo-region-t*)         #'(cairo-guard-pointer (make-ftype-pointer cairo-region-t result))]
				   [(cairo-rectangle-list-t*) #'(cairo-guard-pointer (make-ftype-pointer cairo-rectangle-list-t result))]
				   [(cairo-font-options-t*)   #'(cairo-guard-pointer (make-ftype-pointer cairo-font-options-t result))]
				   [(cairo-font-face-t*)      #'(cairo-guard-pointer (make-ftype-pointer cairo-font-face-t result))]
				   [(cairo-scaled-font-t*)    #'(cairo-guard-pointer (make-ftype-pointer cairo-scaled-font-t result))]
				   [(cairo-path-t*)           #'(cairo-guard-pointer (make-ftype-pointer cairo-path-t result))]
				   [(cairo-device-t*)         #'(cairo-guard-pointer (make-ftype-pointer cairo-device-t result))]
				   [else #'result]))))))])))

 (define-syntax define-ftype-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type) 
	#'(define (name) 
	    (cairo-guard-pointer (make-ftype-pointer type (foreign-alloc (ftype-sizeof type)))))])))

 (define-syntax define-ftype-array-allocator 
   (lambda (x)
     (syntax-case x () 
       [(_ name type element-type) 
	#'(define (name size) 
	    (cairo-guard-pointer (make-ftype-pointer type (foreign-alloc (* (ftype-sizeof element-type) size)))))])))


 (define (cairo-library-init . t) (load-shared-object (if (null? t) "libcairo.so" (car t))))

 (define-ftype cairo-bool-t int)

 (define-ftype int* void*)
 (define-ftype const-char* (array 0 unsigned-8))

 (define-ftype unsigned-int* void*)

 (define-ftype cairo-t (struct))
 (define-ftype cairo-t* void*)


 (define-ftype cairo-surface-t (struct))

 (define-ftype cairo-surface-t* void*)

 (define-ftype cairo-device-t void*)
 (define-ftype cairo-device-t* void*)

 (define-ftype cairo-matrix-t
   (struct
    [xx double]
    [yx double]
    [xy double]
    [yy double]
    [x0 double]
    [y0 double]))

 (define-ftype cairo-matrix-t* void*)
 (define-ftype-allocator cairo-matrix-create cairo-matrix-t)

 (define-ftype cairo-pattern-t (struct))
 (define-ftype cairo-pattern-t* void*)

 (define-ftype cairo-destroy-func-t (function (void*) void))

 (define-ftype cairo-destroy-func-t* void*)

 (define-ftype cairo-user-data-key-t (struct [unused int]))

 (define-ftype cairo-user-data-key-t* void*)

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

 (define cairo-content
   '((color . 4096) (alpha . 8192) (color-alpha . 12288)))

 (define-ftype cairo-content-t int)

 (define-enumeration* cairo-format
   (argb-32 rgb-24 a-8 a-1 rgb-16-565 rgb-30))

 (define cairo-format-invalid -1)

 (define-ftype cairo-format-t int)

 (define-ftype cairo-write-func-t
   (function (void* void* unsigned-int) cairo-status-t))

 (define-ftype cairo-write-func-t* void*)

 (define-ftype cairo-read-func-t
   (function (void* void* unsigned-int) cairo-status-t))

 (define-ftype cairo-read-func-t* void*)

 (define-ftype cairo-rectangle-int-t
   (struct [x int] [y int] [width int] [height int]))

 (define-ftype-allocator cairo-rectangle-int-create cairo-rectangle-int-t)

 (define-ftype cairo-rectangle-int-t* void*)

 (define-enumeration* cairo-operator
   (clear source over in out atop dest dest-over dest-in
	  dest-out dest-atop xor add saturate multiply screen overlay
	  darken lighten color-dodge color-burn hard-light soft-light
	  difference exclusion hsl-hue hsl-saturation hsl-color
	  hsl-luminosity))

 (define-ftype cairo-operator-t int)

 (define-enumeration* cairo-antialias
   (default none gray subpixel fast good best))

 (define-ftype cairo-antialias-t int)

 (define-enumeration* cairo-fill-rule 
   (winding even-odd))

 (define-ftype cairo-fill-rule-t int)

 (define-enumeration* cairo-line-cap 
   (butt round square))

 (define-ftype cairo-line-cap-t int)

 (define-enumeration* cairo-line-join 
   (miter round bevel))

 (define-ftype cairo-line-join-t int)

 (define-ftype double* void*)
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

 (define-ftype cairo-rectangle-t* void*)

 (define-ftype cairo-rectangle-list-t
   (struct
    [status cairo-status-t]
    [rectangles (* cairo-rectangle-t)]
    [num-rectangles int]))

 (define-ftype-allocator cairo-rectangle-list-create cairo-rectangle-list-t)

 (define-ftype cairo-rectangle-list-t* void*)

 (define-ftype cairo-scaled-font-t void*)

 (define-ftype cairo-font-face-t void*)

 (define-ftype cairo-glyph-t
   (struct [index unsigned-long] [x double] [y double]))

 (define-ftype-allocator cairo-glyph-create cairo-glyph-t)

 (define-ftype cairo-glyph-t* void*)

 (define-ftype cairo-text-cluster-t
   (struct [num-bytes int] [num-glyphs int]))

 (define-ftype-allocator cairo-text-cluster-create cairo-text-cluster-t)


 (define-ftype cairo-text-cluster-t* void*)

 (define-enumeration* cairo-text-cluster-flag
   (none backward))

 (define-ftype cairo-text-cluster-flags-t int)

 (define-ftype cairo-text-cluster-flags-t* void*)

 (define-ftype cairo-text-extents-t
   (struct
    [x-bearing double]
    [y-bearing double]
    [width double]
    [height double]
    [x-advance double]
    [y-advance double]))

 (define-ftype-allocator cairo-text-extents-create cairo-text-extents-t)


 (define-ftype cairo-text-extents-t* void*)

 (define-ftype cairo-font-extents-t
   (struct
    [ascent double]
    [descent double]
    [height double]
    [max-x-advance double]
    [max-y-advance double]))

 (define-ftype-allocator cairo-font-extents-create cairo-font-extents-t)
					;(define-ftype cairo-font-extents-t int)

 (define-ftype cairo-font-extents-t* void*)

 (define-enumeration* cairo-font-slant
   (normal italic oblique))

 (define-ftype cairo-font-slant-t int)

 (define-enumeration* cairo-font-weight 
   (normal bold))

 (define-ftype cairo-font-weight-t int)

 (define-enumeration* cairo-subpixel-order
   (default rgb bgr vrgb vbgr))

 (define-ftype cairo-subpixel-order-t int)

 (define-enumeration* cairo-hint-style
   (default none slight medium full))

 (define-ftype cairo-hint-style-t int)

 (define-enumeration* cairo-hint-metrics 
   (default off on))

 (define-ftype cairo-hint-metrics-t int)

 (define-ftype cairo-font-options-t void*)

 (define-enumeration* cairo-font-type
   (toy ft win32 quartz user))

 (define-ftype cairo-font-type-t int)

 (define-ftype cairo-user-scaled-font-init-func-t
   (function
    (cairo-scaled-font-t cairo-t* cairo-font-extents-t*)
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-init-func-t* void*)

 (define-ftype cairo-user-scaled-font-render-glyph-func-t
   (function
    (cairo-scaled-font-t
     unsigned-long
     cairo-t*
     cairo-font-extents-t*)
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-render-glyph-func-t*
   void*)

 (define-ftype cairo-user-scaled-font-text-to-glyphs-func-t
   (function
    (cairo-scaled-font-t string int cairo-glyph-t* int
			 cairo-text-cluster-t* int cairo-text-cluster-flags-t*)
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-text-to-glyphs-func-t*
   void*)

 (define-ftype unsigned-long* void*)

 (define-ftype cairo-user-scaled-font-unicode-to-glyph-func-t
   (function
    (cairo-scaled-font-t unsigned-long unsigned-long*)
    cairo-status-t))

 (define-ftype cairo-user-scaled-font-unicode-to-glyph-func-t*
   void*)

 (define-enumeration* cairo-path-data-type
   (move-to line-to curve-to close-path))

 (define-ftype cairo-path-data-type-t int)

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

 (define-ftype cairo-path-t* void*)

 (define-enumeration* cairo-device-type
   (drm gl script xcb xlib xml cogl win32))

 (define-ftype cairo-device-type-t int)

 (define cairo-device-type-invalid -1)

 (define-enumeration* cairo-surface-observer-mode
   (normal record-operations))

 (define-ftype cairo-surface-observer-mode-t int)

 (define-ftype cairo-surface-observer-callback-t
   (function (cairo-surface-t* cairo-surface-t* void*) void))

 (define-ftype cairo-surface-observer-callback-t* void*)

 (define-enumeration* cairo-surface-type
   (image pdf ps xlib xcb gliz quartz win32 beos directfb svg
	  os2 win32-printing quartz-image script qt recording vg gl
	  drm tee xml skia subsurface cogl))

 (define-ftype cairo-surface-type-t int)

 (define cairo-mime-types
   '((jpeg . "image/jpeg") (png . "image/png") (jp2 . "image/jp2")
     (uri . "text/x-uri")
     (unique-id . "application/x-cairo.uuid")
     (jbig2 . "application/x-cairo.jbig2")
     (jbig2-global . "application/x-cairo.jbig2-global")
     (jbig2-global-id . "application/x-cairo.jbig2-global-id")))

 (define-ftype cairo-raster-source-acquire-func-t
   (function
    (cairo-pattern-t*
     void*
     cairo-surface-t*
     cairo-rectangle-int-t*)
    cairo-status-t))

 (define-ftype cairo-raster-source-acquire-func-t* void*)

 (define-ftype cairo-raster-source-release-func-t
   (function
    (cairo-pattern-t* void* cairo-surface-t*)
    cairo-status-t))

 (define-ftype cairo-raster-source-release-func-t* void*)

 (define-ftype cairo-raster-source-snapshot-func-t
   (function (cairo-pattern-t* void*) cairo-status-t))

 (define-ftype cairo-raster-source-snapshot-func-t* void*)

 (define-ftype cairo-raster-source-copy-func-t
   (function
    (cairo-pattern-t* void* cairo-pattern-t*)
    cairo-status-t))

 (define-ftype cairo-raster-source-copy-func-t* void*)

 (define-ftype cairo-raster-source-finish-func-t
   (function (cairo-pattern-t* void*) cairo-status-t))

 (define-ftype cairo-raster-source-finish-func-t* void*)

 (define-enumeration* cairo-pattern-type
   (solid surface linear radial mesh raster-source))

 (define-ftype cairo-pattern-type-t int)

 (define-enumeration* cairo-extend
   (none repeat reflect pad))

 (define-ftype cairo-extend-t int)

 (define-enumeration* cairo-filter
   (fast good best nearest bilinear gaussian))

 (define-ftype cairo-filter-t int)

 (define-ftype cairo-region-t void*)
 (define-ftype cairo-region-t* void*)

 (define-enumeration* cairo-region-overlap
   (in out part))

 (define-ftype cairo-region-overlap-t int)

 (define-ftype cairo-pdf-version-t int)
 (define-ftype cairo-pdf-version-t* void*)
 
 (define cairo-guardian (make-guardian))

 (define (cairo-guard-pointer obj) 
   (cairo-free-garbage) 
   (cairo-guardian obj) 
   obj)

 (define (cairo-free-garbage)
   (let loop ([p (cairo-guardian)])
     (when p
	   (when (ftype-pointer? p)
		 (printf "cairo-free-garbage: freeing memory at ~x\n" p)
		 ;;[(ftype-pointer? usb-device*-array p)
		 (cond 
		  [(ftype-pointer? cairo-t p) (cairo-destroy p)]
		  [(ftype-pointer? cairo-surface-t p) (cairo-surface-destroy p)]
		  [(ftype-pointer? cairo-pattern-t p) (cairo-pattern-destroy p)]
		  [(ftype-pointer? cairo-region-t p) (cairo-region-destroy p)]
		  [(ftype-pointer? cairo-rectangle-list-t p) (cairo-rectangle-list-destroy p)]
		  [(ftype-pointer? cairo-font-options-t p) (cairo-font-options-destroy p)]
		  [(ftype-pointer? cairo-font-face-t p) (cairo-font-face-destroy p)]
		  [(ftype-pointer? cairo-scaled-font-t p) (cairo-scaled-font-destroy p)]
		  [(ftype-pointer? cairo-path-t p) (cairo-path-destroy p)]
		  [(ftype-pointer? cairo-device-t p) (cairo-device-destroy p)]
		  [else
		   (foreign-free (ftype-pointer-address p))]
		  ))
	   (loop (cairo-guardian)))))
 (include "cairo-functions.scm")

 ) ; library cairo


#!eof

;; HERE IS THE CODE TO GENERATE cairo-functions.scm from cairo.h
;; (ugly hack) :D
;; would be nice to write a general parser for c headers

(import (srfi s13 strings))
(import (srfi s14 char-sets))
(load "fmt/read-line.scm")
(import (oleg util)) ; is this still needed?

;; POSSIBLE THAT NOT EXISTS THIS FUNCTION???
					; s is a string , c is a character-set
					; null strings are discarded from result
(define (string-split s c)
  (define res '())
  (let loop ([l (string->list s)] [t '()])
    (if (null? l) 
	(if (null? t) res (append res (list(list->string t))))
	(if (char-set-contains? c (car l))
	    (begin 
	      (unless (null? t) 
		      (set! res (append res (list (list->string t)))))
	      (loop (cdr l) '()))
	    (loop (cdr l) (append t (list (car l))))))))

;; POSSIBLE THAT THIS NOT EXIST?
;; if x is a character: (eq?  s[i] x) => s[i] = y
;; if x is a list:      (memq s[i] x) => s[i] = y

(define (string-replace s x y)
  (list->string  
   (let ([cmp (if (list? x) memq eq?)])
     (map (lambda (z) (if (cmp z x) y z)) (string->list s)))))

(define (split-args l)
  (let* ([s (string-join l " ")]
	 [t (map string-trim (string-split s (char-set #\,)))])
    t))
(define (dashize x)
  (string-replace x #\_ #\-))

(define (decode-arg x)
  (let* ([s (string-delete (string->char-set "(),;") x)]
	 [i (string-index-right s #\space)])
    (if i 
	(let ([type (string-trim (string-take s i))]
	      [name (string-trim (string-drop s i))])
	  (when (string-prefix? "*" name)
		(set! type (string-append type "*"))
		(set! name (string-drop name 1)))
	  (list name (string-replace type #\space #\-)))
	(list))))

(define (fix-type x)
  (if (< (length x) 2)
      (dashize (string-join x))
      (if (equal? (last x) "*")
	  (string-append (dashize (string-join (take x (- (length x) 1)) "-")) "*")
	  (dashize (string-join x "-")))))

(define (gen-cairo-bindings filename)
  (with-input-from-file filename
    (lambda () 
      (let loop ([s (read-line)] [l '()])
	(unless 
	 (not s)
	 (let ([start (string-prefix? "cairo_public" s)])
	   (if (or start (not (null? l)))
	       (let* ([s (string-split s char-set:whitespace)]
		      [l (if start s (append l s))])
		 (if (string-suffix? ";"  (last l))
		     (let* ([first-arg-index (list-index (lambda (x) (string-prefix? "(" x)) l)]
			    [args (list-tail l first-arg-index)]
			    [name (list-ref l (- first-arg-index 1))]
			    [type (fix-type (take (cdr l) (- first-arg-index 2)))]
			    [args-list (map (lambda (x) (decode-arg (dashize x))) 
					    (split-args args))])
		       (printf "(define-function* ~d ~d ~d)\n"
			       name (if (null? (car args-list)) '() args-list) type)
		       (loop (read-line) '())))
		 (loop (read-line) l))
	       (loop (read-line) '()))))))))

(with-output-to-file "cairo-functions.scm"
  (lambda ()
    (printf "; THIS FILE WAS AUTOMATICALLY GENERATED, see at the end of cairo.sls \n")
    (let ([the '(miracle happen)])
      (gen-cairo-bindings "/usr/include/cairo/cairo.h")
      (gen-cairo-bindings "/usr/include/cairo/cairo-pdf.h")
      ;;(gen-cairo-bindings "/usr/include/cairo/cairo-xlib.h")
      ;;(gen-cairo-bindings "/usr/include/cairo/cairo-svg.h")
      ;;(gen-cairo-bindings "/usr/include/cairo/cairo-ft.h")
      ))'(truncate))
