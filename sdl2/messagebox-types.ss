
 (define-flags sdl-message-box (error  #x10) (warning #x20) (information #x40))
                                     
 (define-flags sdl-message-box-button
   (returnkey-default 1) (escapekey-default 2))
                                       
 (define-enumeration* sdl-message-box-color-type-t
   (background text button-border button-backgrond
	       button-selected color-max))


 (define-ftype sdl-message-box-button-data-t (struct (flags uint32) (buttonid int) (text (* char))))
 (define-ftype sdl-message-box-color-t (struct (r uint8) (g uint8) (b uint8)))
 ;;FIXME USE THE VALUE OF SDL_MESSAGEBOX_COLOR_MAX (=6) ?
 (define-ftype sdl-message-box-color-scheme-t (struct (colors (array 6 sdl-message-box-color-t))))

 (define-ftype sdl-message-box-data-t
   (struct
       (flags unsigned-32)
     (window (* sdl-window-t))
     (title (* char))
     (message (* char))
     (numbuttons int)
     (buttons (* sdl-message-box-button-data-t))
     (color-scheme (* sdl-message-box-color-scheme-t))))

