
 (define-enumeration* sdl-system-cursor
   (arrow     ; arrow */
    i-beam     ; i-beam */
    wait      ; wait */
    crosshair ; crosshair */
    waitarrow ; small wait cursor (or wait if not available) */
    size-nw-se  ; double arrow pointing northwest and southeast */
    size-ne-sw  ; double arrow pointing northeast and southwest */
    size-we    ; double arrow pointing west and east */
    size-ns    ; double arrow pointing north and south */
    size-all   ; four pointed arrow pointing north, south, east, and west */
    no        ; slashed circle or crossbones */
    hand      ; hand */
    num-system-cursors))

 (define-ftype sdl-cursor-t (struct))

 (define-flags sdl-button (left 1) (middle 2) (right 3) (x1 4) (x2 5))
 (define (sdl-button-mask button)
   (bitwise-arithmetic-shift-left
    1
    (- (cdr (assq button (flags-alist sdl-button-flags)))
       1)))
