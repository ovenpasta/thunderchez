(import (cairo))

(cairo-library-init)

(define (test-cairo name proc) 
  (let* ([surface (cairo-image-surface-create (cairo-format 'argb-32) 120 120)]
	 [cr (cairo-create surface)])
    (cairo-scale cr 120. 120.)
    (proc surface cr)
    (cairo-surface-write-to-png surface (string-append name ".png"))))


(test-cairo "stroke"
	    (lambda (surface cr)
	      (cairo-set-line-width cr 0.1)
	      (cairo-set-source-rgb cr 0. 0. 0.)
	      (cairo-rectangle cr 0.25 0.25 0.25 0.25)
	      (cairo-stroke cr)))

(test-cairo "showtext"
	    (lambda (surface cr)
	      (cairo-scale cr 120. 120.)
	      (cairo-set-source-rgb cr 0. 0. 0.)
	      (cairo-select-font-face cr "Georgia" (cairo-font-slant 'normal) (cairo-font-weight 'bold))
	      (cairo-set-font-size cr 1.2)
	      (let ([extents (cairo-text-extents-create)])	
		(cairo-text-extents cr "a" extents)
		(cairo-move-to cr 
			       (- 0.5 (/ (ftype-ref cairo-text-extents-t (width) extents) 2) (ftype-ref cairo-text-extents-t (x-bearing) extents))
			       (- 0.5 (/ (ftype-ref cairo-text-extents-t (height) extents) 2) (ftype-ref cairo-text-extents-t (y-bearing) extents)))
		(cairo-show-text cr "a")
		(cairo-surface-write-to-png surface ".png"))))

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
	      (define pi 3.1415926536)
	      (cairo-set-line-width cr 0.1)
	      
	      (cairo-save cr)
	      (cairo-scale cr 0.5 1.)
	      (cairo-arc cr 0.5 0.5 0.40 0. (* 2. pi))
	      (cairo-stroke cr)
	      
	      (cairo-translate cr 1. 0.)
	      (cairo-arc cr 0.5 0.5 0.40 0. (* 2. pi))
	      (cairo-restore cr)
	      (cairo-stroke cr)))


(system "eog .")
