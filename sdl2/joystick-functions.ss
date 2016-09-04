(define-sdl-func int sdl-num-joysticks () "SDL_NumJoysticks")
(define-sdl-func string sdl-joystick-name-for-index ((device_index int)) "SDL_JoystickNameForIndex")
(define-sdl-func (* sdl-joystick-t) sdl-joystick-open ((device_index int)) "SDL_JoystickOpen")
(define-sdl-func (* sdl-joystick-t) sdl-joystick-from-instance-id ((joyid sdl-joystick-id-t)) "SDL_JoystickFromInstanceID")
(define-sdl-func string sdl-joystick-name ((joystick (* sdl-joystick-t))) "SDL_JoystickName")
;;blacklisted probably because it uses a struct as value.
(define sdl-joystick-get-device-guid #f)
;;blacklisted probably because it uses a struct as value.
(define sdl-joystick-get-guid #f)
;;blacklisted probably because it uses a struct as value.
(define sdl-joystick-get-guid-string #f)
;;blacklisted probably because it uses a struct as value.
(define sdl-joystick-get-guid-from-string #f)
(define-sdl-func sdl-bool-t sdl-joystick-get-attached ((joystick (* sdl-joystick-t))) "SDL_JoystickGetAttached")
;;blacklisted probably because it uses a struct as value.
(define sdl-joystick-instance-id #f)
(define-sdl-func int sdl-joystick-num-axes ((joystick (* sdl-joystick-t))) "SDL_JoystickNumAxes")
(define-sdl-func int sdl-joystick-num-balls ((joystick (* sdl-joystick-t))) "SDL_JoystickNumBalls")
(define-sdl-func int sdl-joystick-num-hats ((joystick (* sdl-joystick-t))) "SDL_JoystickNumHats")
(define-sdl-func int sdl-joystick-num-buttons ((joystick (* sdl-joystick-t))) "SDL_JoystickNumButtons")
(define-sdl-func void sdl-joystick-update () "SDL_JoystickUpdate")
(define-sdl-func int sdl-joystick-event-state ((state int)) "SDL_JoystickEventState")
(define-sdl-func sint16 sdl-joystick-get-axis ((joystick (* sdl-joystick-t)) (axis int)) "SDL_JoystickGetAxis")
(define-sdl-func uint8 sdl-joystick-get-hat ((joystick (* sdl-joystick-t)) (hat int)) "SDL_JoystickGetHat")
(define-sdl-func int sdl-joystick-get-ball ((joystick (* sdl-joystick-t)) (ball int) (dx (* int)) (dy (* int))) "SDL_JoystickGetBall")
(define-sdl-func uint8 sdl-joystick-get-button ((joystick (* sdl-joystick-t)) (button int)) "SDL_JoystickGetButton")
(define-sdl-func void sdl-joystick-close ((joystick (* sdl-joystick-t))) "SDL_JoystickClose")
(define-sdl-func sdl-joystick-power-level-t sdl-joystick-current-power-level ((joystick (* sdl-joystick-t))) "SDL_JoystickCurrentPowerLevel")
