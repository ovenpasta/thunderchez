(define-ftype NK_INT8 char)
(define-ftype NK_UINT8 unsigned-8)
(define-ftype NK_INT16 integer-16)
(define-ftype NK_UINT16 unsigned-16)
(define-ftype NK_INT32 integer-32)
(define-ftype NK_UINT32 unsigned-32)
(define-ftype NK_SIZE_TYPE unsigned-64)
(define-ftype NK_POINTER_TYPE unsigned-64)
(define-ftype NK_UINT unsigned-int)

(define-ftype nk-char-t NK_INT8)
(define-ftype nk-uchar-t NK_UINT8)
(define-ftype nk-short-t NK_UINT16)
(define-ftype nk-byte-t NK_UINT8)
(define-ftype nk-ushort-t NK_UINT16)
(define-ftype nk-int-t NK_INT32)
(define-ftype nk-uint-t NK_UINT32)
(define-ftype nk-size-t NK_SIZE_TYPE)
(define-ftype nk-ptr-t NK_POINTER_TYPE)
(define-ftype nk-hash-t NK_UINT)
(define-ftype nk-flags-t NK_UINT)
(define-ftype nk-rune-t NK_UINT)

(define-ftype nk-buffer-t (struct))
(define-ftype nk-buffer-p (* nk-buffer-t))

(define-ftype nk-context-t (struct))
(define-ftype nk-context-p (* nk-context-t))

(define-ftype nk-user-font-t (struct))
(define-ftype nk-user-font-p (* nk-user-font-t))

(define-ftype nk-allocator-t
  (struct
   (userdata void*)
   (alloc void*)
   (free void*)))

(define-ftype nk-allocator-p (* nk-allocator-t))

(define-ftype nk-command-t (struct))
(define-ftype nk-command-p (* nk-command-t))

#| UNSURE |#
(define-ftype nk-window-t (struct))
(define-ftype nk-panel-t (struct))
(define-ftype nk-list-view-t (struct))
(define-ftype nk-style-button-t (struct))
(define-ftype nk-plugin-filter-t void*)
(define-ftype nk-text-edit-t void*)
(define-ftype nk-style-item-t void*)
(define-ftype nk-memory-status-t (struct))
(define-ftype nk-str-t (struct))
(define-ftype nk-command-custom-callback-t void*)
(define-ftype nk-input-t (struct))
#| ^^^^^^^ |#

(define-ftype nk-command-buffer-t (struct))
(define-ftype nk-command-buffer-p (* nk-command-buffer-t))

(define-ftype nk-draw-command-t (struct))
(define-ftype nk-draw-command-p (* nk-draw-command-t))

(define-enumeration* nk-boolean
  (nk-true nk-false))

(define-ftype nk-color-t
  (struct
   (r nk-byte-t)
   (g nk-byte-t)
   (b nk-byte-t)
   (a nk-byte-t)))

(define-ftype nk-colorf-t
  (struct
   (r float)
   (g float)
   (b float)
   (a float)))

(define-ftype nk-vec2-t
  (struct
   (x float)
   (y float)))

(define-ftype nk-vec2i-t
  (struct
   (x short)
   (y short)))

(define-ftype nk-rect-t
  (struct
   (x float)
   (y float)
   (w float)
   (h float)))

(define-ftype nk-recti-t
  (struct
   (x short)
   (y short)
   (w short)
   (h short)))

(define-ftype nk-handle-t
  (union
   (ptr void*)
   (id int)))

(define-ftype nk-image-t
  (struct
   (handle nk-handle-t)
   (w unsigned-short)
   (h unsigned-short)
   (region unsigned-short))) ;fix region

(define-ftype nk-cursor-t
  (struct
   (img nk-image-t)
   (size nk-vec2-t)
   (offset nk-vec2-t)))

(define-ftype nk-scroll-t
  (struct
   (x nk-uint-t)
   (y nk-uint-t)))

(define-enumeration* nk-heading
  (nk-up nk-right nk-down nk-left))

(define-enumeration* nk-button-behavior
  (nk-button-default nk-button-repeater))

(define-ftype nk-glyph-t unsigned-int)
