

 (define-ftype sdl-bool-t boolean)
 (define-ftype uint8 unsigned-8)
 (define-ftype uint16 unsigned-16)
 (define-ftype sint16 integer-16)
 (define-ftype uint32 unsigned-32)
 (define-ftype sint32 integer-32)
 (define-ftype sint64 integer-64)
 (define-ftype uint64 integer-64)
 (define-ftype va-list void*)
 (define-ftype int% int)
 (define-ftype file (struct))

 (define-ftype sdl-iconv-t void*)

 ;; Conditions
 (define-record-type (&sdl2 make-sdl2-condition $sdl2-condition?)
   (parent &condition)
   (fields (immutable status $sdl2-condition-status)))

 (define rtd (record-type-descriptor &sdl2))
 (define sdl2-condition? (condition-predicate rtd))
 (define sdl2-status (condition-accessor rtd $sdl2-condition-status))

