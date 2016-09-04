
(import (cairo))

(cairo-library-init)
(define pi 3.1415926536)

(define (test-cairo name proc) 
  (let* ([surface (cairo-image-surface-create (cairo-format 'argb-32) 120 120)]
	 [cr (cairo-create surface)])
    (cairo-scale cr 120. 120.)
    (proc surface cr)
    (cairo-surface-write-to-png surface (string-append name ".png"))))

(define (sample-cairo name proc) 
  (let* ([surface (cairo-image-surface-create (cairo-format 'argb-32) 256 256)]
	 [cr (cairo-create surface)])
    (proc surface cr)
    (cairo-surface-write-to-png surface (string-append name ".png"))))

;; FROM https://www.cairographics.org/tutorial/

(test-cairo "stroke"
	    (lambda (surface cr)
	      (cairo-set-line-width cr 0.1)
	      (cairo-set-source-rgb cr 0. 0. 0.)
	      (cairo-rectangle cr 0.25 0.25 0.25 0.25)
	      (cairo-stroke cr)))

(test-cairo "showtext"
	    (lambda (surface cr)
	      (cairo-set-source-rgb cr 0. 0. 0.)
	      (cairo-select-font-face cr "Georgia" (cairo-font-slant 'normal) (cairo-font-weight 'bold))
	      (cairo-set-font-size cr 1.2)
	      (let ([extents (cairo-text-extents-create)])
		(cairo-text-extents cr "a" extents)
		(let-struct extents cairo-text-extents-t (width height x-bearing y-bearing)
			    (cairo-move-to cr 
					   (- 0.5 (/ width 2) x-bearing)
					   (- 0.5 (/ height 2) y-bearing)))
		(cairo-show-text cr "a"))))

(test-cairo "paint"
	    (lambda (surface cr)
	      (cairo-set-source-rgb cr 0.0 0.0 0.0)
	      (cairo-paint-with-alpha cr 0.5)))

(test-cairo "mask"
	    (lambda (surface cr)
	      (let* ([linpat (cairo-pattern-create-linear 0. 0. 1. 1.)]
		     [radpat (cairo-pattern-create-radial 0.5 0.5 0.25 0.5 0.5 0.75)])
		(cairo-pattern-add-color-stop-rgb linpat 0. 0. 0.3 0.8)
		(cairo-pattern-add-color-stop-rgb linpat 1. 0. 0.8 0.3)
		(cairo-pattern-add-color-stop-rgba radpat 0. 0. 0. 0. 1.)
		(cairo-pattern-add-color-stop-rgba radpat 0.5 0. 0. 0. 0.)
		(cairo-set-source cr linpat)
		(cairo-mask cr radpat))))

(test-cairo "setsourcergba"
	    (lambda (surface cr)
	     (cairo-set-source-rgb cr 0. 0. 0.) 
	     (cairo-move-to cr 0. 0.)
	     (cairo-line-to cr 1. 1.)
	     (cairo-move-to cr 1. 0.)
	     (cairo-line-to cr 0. 1.)
	     (cairo-set-line-width cr 0.2)
	     (cairo-stroke cr)
	      
	     (cairo-rectangle cr 0. 0. 0.5 0.5)
	     (cairo-set-source-rgba cr 1. 0. 0. 0.80)
	     (cairo-fill cr)
	      
	     (cairo-rectangle cr 0. 0.5 0.5 0.5)
	     (cairo-set-source-rgba cr 0. 1. 0. 0.60)
	     (cairo-fill cr)
	      
	     (cairo-rectangle cr 0.5 0. 0.5 0.5)
	     (cairo-set-source-rgba cr 0. 0. 1. 0.40)
	     (cairo-fill cr)))

(test-cairo "setsourcegradient"
	    (lambda (surface cr)
	      (let ([radpat (cairo-pattern-create-radial 0.25 0.25 0.1  0.5 0.5 0.5)]
		    [linpat (cairo-pattern-create-linear 0.25 0.35 0.75 0.65)])
		(cairo-pattern-add-color-stop-rgb radpat 0.  1.0 0.8 0.8)
		(cairo-pattern-add-color-stop-rgb radpat 1.  0.9 0.0 0.0)
		(for-each (lambda (i) 
			    (for-each (lambda (j) 
					(cairo-rectangle cr (- (/ (1+ i) 10.) 0.04) (- (/ (1+ j) 10.) 0.04) 0.08 0.08))
				      (iota 9)))
			    (iota 9))
		(cairo-set-source cr radpat)
		(cairo-fill cr)
		(cairo-pattern-add-color-stop-rgba linpat 0.00  1. 1. 1. 0.)
		(cairo-pattern-add-color-stop-rgba linpat 0.25  0. 1. 0. 0.5)
		(cairo-pattern-add-color-stop-rgba linpat 0.50  1. 1. 1. 0.)
		(cairo-pattern-add-color-stop-rgba linpat 0.75  0. 0. 1. 0.5)
		(cairo-pattern-add-color-stop-rgba linpat 1.00  1. 1. 1. 0.)

		(cairo-rectangle cr 0.0 0.0 1. 1.)
		(cairo-set-source cr linpat)
		(cairo-fill cr))))

(test-cairo "tips-ellipse" 
	    (lambda (surface cr)
	      (cairo-set-line-width cr 0.1)
	      
	      (cairo-save cr)
	      (cairo-scale cr 0.5 1.)
	      (cairo-arc cr 0.5 0.5 0.40 0. (* 2. pi))
	      (cairo-stroke cr)
	      
	      (cairo-translate cr 1. 0.)
	      (cairo-arc cr 0.5 0.5 0.40 0. (* 2. pi))
	      (cairo-restore cr)
	      (cairo-stroke cr)))



;; FROM https://www.cairographics.org/samples/

(sample-cairo "arc" 
	    (lambda (surface cr)
	      (let ([xc 128.] [yc 128.] [radius 100.] 
		    [angle1 (* 45. (/ pi 180.))] [angle2 (* 180. (/ pi 180.))])
		(cairo-set-line-width cr 10.0)
		(cairo-arc cr xc yc radius angle1 angle2)
		(cairo-stroke cr)

		;;/* draw helping lines */
		(cairo-set-source-rgba cr 1. 0.2 0.2 0.6)
		(cairo-set-line-width cr 6.0)

		(cairo-arc cr xc yc 10.0 0. (* 2 pi))
		(cairo-fill cr)
		
		(cairo-arc cr xc yc radius angle1 angle1)
		(cairo-line-to cr xc yc)
		(cairo-arc cr xc yc radius angle2 angle2)
		(cairo-line-to cr xc yc)
		(cairo-stroke cr))))
		
(sample-cairo "arc-negative" 
	    (lambda (surface cr)
	      (let ([xc 128.] [yc 128.] [radius 100.] 
		    [angle1 (* 45. (/ pi 180.))] [angle2 (* 180. (/ pi 180.))])
		(cairo-set-line-width cr 10.0)
		(cairo-arc-negative cr xc yc radius angle1 angle2)
		(cairo-stroke cr)

		;;/* draw helping lines */
		(cairo-set-source-rgba cr 1. 0.2 0.2 0.6)
		(cairo-set-line-width cr 6.0)

		(cairo-arc cr xc yc 10.0 0. (* 2 pi))
		(cairo-fill cr)
		
		(cairo-arc cr xc yc radius angle1 angle1)
		(cairo-line-to cr xc yc)
		(cairo-arc cr xc yc radius angle2 angle2)
		(cairo-line-to cr xc yc)
		(cairo-stroke cr))))
		

(sample-cairo "clip" 
	    (lambda (surface cr)
	      (cairo-arc cr 128.0 128.0 76.8 0. (* 2. pi))
	      (cairo-clip cr)

	      (cairo-new-path cr)       ;  /* current path is not
			         	;     consumed by (cairo-clip() */
	      (cairo-rectangle cr 0. 0. 256. 256.)
	      (cairo-fill cr)
	      (cairo-set-source-rgb cr 0. 1. 0.)
	      (cairo-move-to cr 0. 0.)
	      (cairo-line-to cr 256. 256.)
	      (cairo-move-to cr 256. 0.)
	      (cairo-line-to cr 0. 256.)
	      (cairo-set-line-width cr 10.0)
	      (cairo-stroke cr)))

(sample-cairo "clip-image"
	      (lambda (surface cr)
		(cairo-arc cr 128.0 128.0 76.8 0. (* 2 pi))
		(cairo-clip cr)
		(cairo-new-path cr); /* path not consumed by clip()*/

		(let* ([image (cairo-image-surface-create-from-png "romedalen.png")]
		       [w (cairo-image-surface-get-width image)]
		       [h (cairo-image-surface-get-height image)])

		  (cairo-scale cr (/ 256.0 w) (/ 256.0 h))
		  (cairo-set-source-surface cr image 0. 0.)
		  (cairo-paint cr))))

(sample-cairo "curve-rectangle"
	      (lambda (surface cr)
		; a custom shape that could be wrapped in a function
		(let* ([x0 25.6] ;   parameters like cairo_rectangle 
		       [y0 25.6]
		       [rect-width 204.8]
		       [rect-height 204.8]
		       [radius  102.4] ;   and an approximate curvature radius 
		       
		       [x1 (+ x0 rect-width)]
		       [y1 (+ y0 rect-height)])
		  ;; WHAT IS THIS?
		  ;;if (!rect_width || !rect_height)
		  ;;return;

		  (cond [(< (/ rect-width 2) radius) 
			 (cond [(< (/ rect-height 2) radius)
				(cairo-move-to  cr x0 (/ (+ y0 y1) 2))
				(cairo-curve-to cr x0 y0 x0 y0 (/ (+ x0 x1) 2) y0)
				(cairo-curve-to cr x1 y0 x1 y0 x1 (/ (+ y0 y1) 2))
				(cairo-curve-to cr x1 y1 x1 y1 (/ (+ x1 x0) 2) y1)
				(cairo-curve-to cr x0 y1 x0 y1 x0 (/ (+ y0 y1) 2))]
			       [else
				(cairo-move-to  cr x0 (+ y0 radius))
				(cairo-curve-to cr x0 y0 x0 y0 (/ (+ x0 x1) 2) y0)
				(cairo-curve-to cr x1 y0 x1 y0 x1 (+ y0 radius))
				(cairo-line-to cr x1  y1 - radius)
				(cairo-curve-to cr x1 y1 x1 y1 (/ (+ x1 x0) 2) y1)
				(cairo-curve-to cr x0 y1 x0 y1 x0 (- y1 radius))])]
			[else
			 (cond  [(< (/ rect-height 2) radius)
				 (cairo-move-to  cr x0 (/ (+ y0 y1) 2))
				 (cairo-curve-to cr x0  y0 x0  y0 (+ x0 radius) y0)
				 (cairo-line-to cr (- x1 radius) y0)
				 (cairo-curve-to cr x1 y0 x1 y0 x1 (/ (+ y0 y1) 2))
				 (cairo-curve-to cr x1 y1 x1 y1 (- x1 radius) y1)
				 (cairo-line-to cr (+ x0 radius) y1)
				 (cairo-curve-to cr x0 y1 x0 y1 x0 (/ (+ y0 y1) 2))]
				[else
				 (cairo-move-to  cr x0 (+ y0 radius))
				 (cairo-curve-to cr x0  y0 x0  y0 (+ x0 radius) y0)
				 (cairo-line-to cr (- x1 radius) y0)
				 (cairo-curve-to cr x1 y0 x1 y0 x1 (+ y0 radius))
				 (cairo-line-to cr x1  (- y1 radius))
				 (cairo-curve-to cr x1 y1 x1 y1 (- x1 radius) y1)
				 (cairo-line-to cr (+ x0 radius) y1)
				 (cairo-curve-to cr x0 y1 x0 y1 x0 (- y1 radius))])])

			 (cairo-close-path cr)
			 (cairo-set-source-rgb cr 0.5 0.5 1.)
			 (cairo-fill-preserve cr)
			 (cairo-set-source-rgba cr 0.5 0. 0. 0.5)
			 (cairo-set-line-width cr 10.0)
			 (cairo-stroke cr))))

(sample-cairo "curve-to"
	      (lambda (surface cr)
		(let ([x 25.6] [y 128.0]
		      [x1 102.4] [y1 230.4]
		      [x2 153.6] [y2 25.6]
		      [x3 230.4] [y3 128.0])

		  (cairo-move-to cr x y)
		  (cairo-curve-to cr x1 y1 x2 y2 x3 y3)
		  
		  (cairo-set-line-width cr 10.0)
		  (cairo-stroke cr)
		  
		  (cairo-set-source-rgba cr 1. 0.2 0.2 0.6)
		  (cairo-set-line-width cr 6.0)
		  (cairo-move-to cr x y)   (cairo-line-to cr x1 y1)
		  (cairo-move-to cr x2 y2) (cairo-line-to cr x3 y3)
		  (cairo-stroke cr))))


(sample-cairo "dash"
	      (lambda (surface cr)
		(let ([dashes '#(50.0    ; ink 
				 10.0    ; skip
				 10.0    ; ink 
				 10.0)]  ; skip
		      [offset -50.])
	       
		  (cairo-set-dash cr dashes (vector-length dashes) offset)
		  (cairo-set-line-width cr 10.0)

		  (cairo-move-to cr 128.0 25.6)
		  (cairo-line-to cr 230.4 230.4)
		  (cairo-rel-line-to cr -102.4 0.0)
		  (cairo-curve-to cr 51.2 230.4 51.2 128.0 128.0 128.0)

		  (cairo-stroke cr))))

(sample-cairo "fill-and-stroke2"
	      (lambda (surface cr)
		(cairo-move-to cr 128.0 25.6)
		(cairo-line-to cr 230.4 230.4)
		(cairo-rel-line-to cr -102.4 0.0)
		(cairo-curve-to cr 51.2 230.4 51.2 128.0 128.0 128.0)
		(cairo-close-path cr)
		
		(cairo-move-to cr 64.0 25.6)
		(cairo-rel-line-to cr 51.2 51.2)
		(cairo-rel-line-to cr -51.2 51.2)
		(cairo-rel-line-to cr -51.2 -51.2)
		(cairo-close-path cr)
		
		(cairo-set-line-width cr 10.0)
		(cairo-set-source-rgb cr 0. 0. 1.)
		(cairo-fill-preserve cr)
		(cairo-set-source-rgb cr 0. 0. 0.)
		(cairo-stroke cr)))

(sample-cairo "fill-style"
	      (lambda (surface cr)
		
		(cairo-set-line-width cr 6.)
		
		(cairo-rectangle cr 12. 12. 232. 70.)
		(cairo-new-sub-path cr) (cairo-arc cr 64. 64. 40. 0. (* 2 pi))
		(cairo-new-sub-path cr) (cairo-arc-negative cr 192. 64. 40. 0. (* -2 pi))

		(cairo-set-fill-rule cr (cairo-fill-rule 'even-odd))
		(cairo-set-source-rgb cr 0. 0.7 0.) (cairo-fill-preserve cr)
		(cairo-set-source-rgb cr 0. 0. 0.) (cairo-stroke cr)

		(cairo-translate cr 0. 128.)
		(cairo-rectangle cr 12. 12. 232. 70.)
		(cairo-new-sub-path cr) (cairo-arc cr 64. 64. 40. 0. (* 2 pi))
		(cairo-new-sub-path cr) (cairo-arc-negative cr 192. 64. 40. 0. (* -2 pi))

		(cairo-set-fill-rule cr (cairo-fill-rule 'winding))
		(cairo-set-source-rgb cr 0. 0. 0.9) (cairo-fill-preserve cr)
		(cairo-set-source-rgb cr 0. 0. 0.) (cairo-stroke cr)))

(sample-cairo "gradient"
	      (lambda (surface cr)
		(let ([pat (cairo-pattern-create-linear 0.0 0.0  0.0 256.0)])
		  (cairo-pattern-add-color-stop-rgba pat 1 0 0 0 1)
		  (cairo-pattern-add-color-stop-rgba pat 0 1 1 1 1)
		  (cairo-rectangle cr 0 0 256 256)
		  (cairo-set-source cr pat)
		  (cairo-fill cr))
		(let ([pat (cairo-pattern-create-radial 115.2 102.4 25.6 102.4  102.4 128.0)])
		  (cairo-pattern-add-color-stop-rgba pat 0 1 1 1 1)
		  (cairo-pattern-add-color-stop-rgba pat 1 0 0 0 1)
		  (cairo-set-source cr pat)
		  (cairo-arc cr 128.0 128.0 76.8 0 (* 2 pi))
		  (cairo-fill cr))))

(sample-cairo "image"
	      (lambda (surface cr)
		(let* ([image (cairo-image-surface-create-from-png "romedalen.png")]
		       [w (cairo-image-surface-get-width image)]
		       [h (cairo-image-surface-get-height image)])

		  (cairo-translate cr 128.0 128.0)
		  (cairo-rotate cr (* 45 (/ pi 180)))
		  (cairo-scale  cr (/ 256.0 w) (/ 256.0 h))
		  (cairo-translate cr (* -0.5 w) (* -0.5 h))
		  
		  (cairo-set-source-surface cr image 0 0)
		  (cairo-paint cr))))

(sample-cairo "image-pattern"
	      (lambda (surface cr)
		(let* ([image (cairo-image-surface-create-from-png "romedalen.png")]
		       [w (cairo-image-surface-get-width image)]
		       [h (cairo-image-surface-get-height image)])
		  (let ([pattern (cairo-pattern-create-for-surface image)]
			[matrix (cairo-matrix-create)])
		    (cairo-pattern-set-extend pattern (cairo-extend 'repeat))

		    (cairo-translate cr 128.0 128.0)
		    (cairo-rotate cr (/ pi 4))
		    (cairo-scale cr (/ 1 (sqrt 2)) (/ 1 (sqrt 2)))
		    (cairo-translate cr -128.0 -128.0)
		    
		    (cairo-matrix-init-scale matrix (* (/ w 256.0) 5.0) (* (/ h 256.0) 5.0))
		    (cairo-pattern-set-matrix pattern matrix)

		    (cairo-set-source cr pattern)

		    (cairo-rectangle cr 0 0 256.0 256.0)
		    (cairo-fill cr)))))


(sample-cairo "multi-segment-caps"
	      (lambda (surface cr)
		(cairo-move-to cr 50.0 75.0)
		(cairo-line-to cr 200.0 75.0)
		
		(cairo-move-to cr 50.0 125.0)
		(cairo-line-to cr 200.0 125.0)
		
		(cairo-move-to cr 50.0 175.0)
		(cairo-line-to cr 200.0 175.0)
		
		(cairo-set-line-width cr 30.0)
		(cairo-set-line-cap cr (cairo-line-cap 'round))
		(cairo-stroke cr)))

(sample-cairo "rounded-rectangle"
	      (lambda (surface cr)
		;/* a custom shape that could be wrapped in a function */
		(let* ([x 25.6] ;/* parameters like (cairo-rectangle */
		       [y 25.6]
		       [width 204.8]
		       [height 204.8]
		       [aspect 1.0] ;     /* aspect ratio */
		       [corner-radius (/ height 10.0)] ;   /* and corner curvature radius */
		       [radius (/ corner-radius aspect)]
		       [degrees (/ pi 180.0)])

		  (cairo-new-sub-path cr)
		  (cairo-arc cr (- (+ x  width) radius) (+ y radius) radius (* -90 degrees) (* 0 degrees))
		  (cairo-arc cr (- (+ x width) radius) (- (+ y height) radius) radius (* 0 degrees) (* 90 degrees))
		  (cairo-arc cr (+ x radius) (- (+ y height) radius) radius (* 90 degrees) (* 180 degrees))
		  (cairo-arc cr (+ x radius) (+ y radius) radius (* 180 degrees) (* 270 degrees))
		  (cairo-close-path cr)
		  
		  (cairo-set-source-rgb cr 0.5 0.5 1)
		  (cairo-fill-preserve cr)
		  (cairo-set-source-rgba cr 0.5 0 0 0.5)
		  (cairo-set-line-width cr 10.0)
		  (cairo-stroke cr))))

(sample-cairo "set-line-cap"
	      (lambda (surface cr)
		(cairo-set-line-width cr 30.0)
		(cairo-set-line-cap cr (cairo-line-cap 'butt)) ;/* default */
		(cairo-move-to cr 64.0 50.0) (cairo-line-to cr 64.0 200.0)
		(cairo-stroke cr)
		(cairo-set-line-cap cr (cairo-line-cap 'round))
		(cairo-move-to cr 128.0 50.0) (cairo-line-to cr 128.0 200.0)
		(cairo-stroke cr)
		(cairo-set-line-cap cr (cairo-line-cap 'square))
		(cairo-move-to cr 192.0 50.0) (cairo-line-to cr 192.0 200.0)
		(cairo-stroke cr)

		;/* draw helping lines */
		(cairo-set-source-rgb cr 1 0.2 0.2)
		(cairo-set-line-width cr 2.56)
		(cairo-move-to cr 64.0 50.0) (cairo-line-to cr 64.0 200.0)
		(cairo-move-to cr 128.0 50.0)  (cairo-line-to cr 128.0 200.0)
		(cairo-move-to cr 192.0 50.0) (cairo-line-to cr 192.0 200.0)
		(cairo-stroke cr)))

(sample-cairo "set-line-join"
	      (lambda (surface cr)
		(cairo-set-line-width cr 40.96)
		(cairo-move-to cr 76.8 84.48)
		(cairo-rel-line-to cr 51.2 -51.2)
		(cairo-rel-line-to cr 51.2 51.2)
		(cairo-set-line-join cr (cairo-line-join 'miter)); /* default */
		(cairo-stroke cr)

		(cairo-move-to cr 76.8 161.28)
		(cairo-rel-line-to cr 51.2 -51.2)
		(cairo-rel-line-to cr 51.2 51.2)
		(cairo-set-line-join cr (cairo-line-join 'bevel))
		(cairo-stroke cr)

		(cairo-move-to cr 76.8 238.08)
		(cairo-rel-line-to cr 51.2 -51.2)
		(cairo-rel-line-to cr 51.2 51.2)
		(cairo-set-line-join cr (cairo-line-join 'round))
		(cairo-stroke cr)))


(sample-cairo "text"
	      (lambda (surface cr)
		(cairo-select-font-face cr "Sans" (cairo-font-slant 'normal)
						   (cairo-font-weight 'bold))
		(cairo-set-font-size cr 90.0)

		(cairo-move-to cr 10.0 135.0)
		(cairo-show-text cr "Hello")

		(cairo-move-to cr 70.0 165.0)
		(cairo-text-path cr "void")
		(cairo-set-source-rgb cr 0.5 0.5 1)
		(cairo-fill-preserve cr)
		(cairo-set-source-rgb cr 0 0 0)
		(cairo-set-line-width cr 2.56)
		(cairo-stroke cr)
		
		;/* draw helping lines */
		(cairo-set-source-rgba cr 1 0.2 0.2 0.6)
		(cairo-arc cr 10.0 135.0 5.12 0 (* 2 pi))
		(cairo-close-path cr)
		(cairo-arc cr 70.0 165.0 5.12 0 (* 2 pi))
		(cairo-fill cr)))



(sample-cairo "text-align-center"
	      (lambda (surface cr)
		(let ([utf8 "cairo"]
		      [extents (cairo-text-extents-create)])
		  (cairo-select-font-face cr "Sans" (cairo-font-slant 'normal) (cairo-font-weight 'normal))
		  (cairo-set-font-size cr 52.0)

		  (cairo-text-extents cr utf8 extents)
		  (let-struct extents cairo-text-extents-t (width height x-bearing y-bearing)
			      (let ([x (- 128.0 (+ (/ width 2) x-bearing))]
				    [y (- 128.0 (+ (/ height 2) y-bearing))])
				(cairo-move-to cr x y)
				(cairo-show-text cr utf8)
				
					;/* draw helping lines */
				(cairo-set-source-rgba cr 1 0.2 0.2 0.6)
				(cairo-set-line-width cr 6.0)
				(cairo-arc cr x y 10.0 0 (* 2 pi))))
		  (cairo-fill cr)
		  (cairo-move-to cr 128.0 0)
		  (cairo-rel-line-to cr 0 256)
		  (cairo-move-to cr 0 128.0)
		  (cairo-rel-line-to cr 256 0)
		  (cairo-stroke cr))))

;; this is an example using with-cairo syntax
;; note that it will not recurse into subforms as you see inside let-struct
(sample-cairo "text-extents"
	      (lambda (surface cr)
		(let ([utf8 "cairo"]
		      [extents (cairo-text-extents-create)]
		      [x 25] [y 150])
		  (with-cairo cr
			      (select-font-face "Sans" (cairo-font-slant 'normal) (cairo-font-weight 'normal))
			      (set-font-size 100.0)
			      (text-extents utf8 extents)
			      
			      (move-to x y)
			      (show-text utf8)
			      
					;;/* draw helping lines */
			      (set-source-rgba 1 0.2 0.2 0.6)
			      (set-line-width 6.0)
			      (arc x y 10.0 0 (* 2 pi))
			      (fill)
			      (move-to x y)
			     
			      (let-struct extents cairo-text-extents-t (width height x-bearing y-bearing)
			      		  (with-cairo cr
			      			      (rel-line-to 0 (- height))
			      			      (rel-line-to width 0)
			      			      (rel-line-to x-bearing (- y-bearing))))
			      (stroke)))))


			      
(system "eog .")
