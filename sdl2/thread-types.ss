 (define-ftype sdl-thread-t (struct))
 (define-ftype sdl-thread-function-t void*)
 (define-ftype sdl-thread-id-t unsigned-long)
 (define-ftype sdl-tlsid-t unsigned-int)

 (define-enumeration* sdl-thread-priority
   ( low normal high ))
