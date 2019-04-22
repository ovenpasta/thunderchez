(define-ftype GLuint unsigned-int)
(define-ftype GLint int)
(define-ftype GLsizei size_t)
(define-ftype nk-draw-null-texture void*)
(define-ftype nk-font-atlas-t void*)

(define-ftype nk-sdl-device-t
  (struct
   (cmds nk-buffer-t)
   (null nk-draw-null-texture)
   (vbo GLuint)
   (ebo GLuint)
   (prog GLuint)
   (vert-shdr GLuint)
   (frag-shdr GLuint)
   (attrib-pos GLint)
   (attrib-uv GLint)
   (attrib-col GLint)
   (uniform-tex GLint)
   (uniform-prof GLint)
   (font-tex GLuint)
   (vs GLsizei)
   (vp size_t)
   (vt size_t)
   (vc size_t)))

(define-ftype nk-sdl-vertex-t
  (struct
   (position float)
   (uv float)
   (col nk-byte-t)))

(define-ftype nk-sdl-t
  (struct
   (win (* sdl-window-t))
   (ogl nk-sdl-device-t)
   (ctx nk-context-t)
   (atlas nk-font-atlas-t)))

