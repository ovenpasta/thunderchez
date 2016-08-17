
 (define-enumeration* sdl-assert-state
   (retry break abort ignore always-ignore))

 (define-ftype sdl-assert-data-t
   (struct 
    (always-ignore int)
    (trigger-count unsigned-int)
    (condition (* char))
    (filename (* char))
    (linenum int)
    (function (* char))
    (next (* sdl-assert-data-t))))
 (define-ftype sdl-assertion-handler-t void*)

