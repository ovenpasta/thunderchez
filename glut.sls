
;;; Ypsilon Scheme System
;;; Copyright (c) 2004-2009 Y.FUJITA / LittleWing Company Limited.
;;; See license.txt for terms and conditions of use.

;;; Ported to Chez Scheme by Ed Cavazos (wayo.cavazos@gmail.com)

(library (glut)
  (export GLUT_RGB
          GLUT_RGBA
          GLUT_INDEX
          GLUT_SINGLE
          GLUT_DOUBLE
          GLUT_ACCUM
          GLUT_ALPHA
          GLUT_DEPTH
          GLUT_STENCIL
          GLUT_MULTISAMPLE
          GLUT_STEREO
          GLUT_LUMINANCE
          GLUT_NO_RECOVERY
          GLUT_LEFT_BUTTON
          GLUT_MIDDLE_BUTTON
          GLUT_RIGHT_BUTTON
          GLUT_DOWN
          GLUT_UP
          GLUT_KEY_F1
          GLUT_KEY_F2
          GLUT_KEY_F3
          GLUT_KEY_F4
          GLUT_KEY_F5
          GLUT_KEY_F6
          GLUT_KEY_F7
          GLUT_KEY_F8
          GLUT_KEY_F9
          GLUT_KEY_F10
          GLUT_KEY_F11
          GLUT_KEY_F12
          GLUT_KEY_LEFT
          GLUT_KEY_UP
          GLUT_KEY_RIGHT
          GLUT_KEY_DOWN
          GLUT_KEY_PAGE_UP
          GLUT_KEY_PAGE_DOWN
          GLUT_KEY_HOME
          GLUT_KEY_END
          GLUT_KEY_INSERT
          GLUT_LEFT
          GLUT_ENTERED
          GLUT_MENU_NOT_IN_USE
          GLUT_MENU_IN_USE
          GLUT_NOT_VISIBLE
          GLUT_VISIBLE
          GLUT_HIDDEN
          GLUT_FULLY_RETAINED
          GLUT_PARTIALLY_RETAINED
          GLUT_FULLY_COVERED
          GLUT_RED
          GLUT_GREEN
          GLUT_BLUE
          GLUT_NORMAL
          GLUT_OVERLAY
          glutInit
          glutInitDisplayString
          glutInitDisplayMode
          glutInitWindowPosition
          glutInitWindowSize
          glutMainLoop
          glutCreateWindow
          glutCreateSubWindow
          glutDestroyWindow
          glutPostRedisplay
          glutPostWindowRedisplay
          glutSwapBuffers
          glutGetWindow
          glutSetWindow
          glutSetWindowTitle
          glutSetIconTitle
          glutPositionWindow
          glutReshapeWindow
          glutPopWindow
          glutPushWindow
          glutIconifyWindow
          glutShowWindow
          glutHideWindow
          glutFullScreen
          glutSetCursor
          glutWarpPointer
          glutEstablishOverlay
          glutRemoveOverlay
          glutUseLayer
          glutPostOverlayRedisplay
          glutPostWindowOverlayRedisplay
          glutShowOverlay
          glutHideOverlay
          glutCreateMenu
          glutDestroyMenu
          glutGetMenu
          glutSetMenu
          glutAddMenuEntry
          glutAddSubMenu
          glutChangeToMenuEntry
          glutChangeToSubMenu
          glutRemoveMenuItem
          glutAttachMenu
          glutDetachMenu
          glutDisplayFunc
          glutReshapeFunc
          glutKeyboardFunc
          glutMouseFunc
          glutMotionFunc
          glutPassiveMotionFunc
          glutEntryFunc
          glutVisibilityFunc
          glutIdleFunc
          glutTimerFunc
          glutMenuStateFunc
          glutSpecialFunc
          glutSpaceballMotionFunc
          glutSpaceballRotateFunc
          glutSpaceballButtonFunc
          glutButtonBoxFunc
          glutDialsFunc
          glutTabletMotionFunc
          glutTabletButtonFunc
          glutMenuStatusFunc
          glutOverlayDisplayFunc
          glutWindowStatusFunc
          glutKeyboardUpFunc
          glutSpecialUpFunc
          glutJoystickFunc
          glutSetColor
          glutGetColor
          glutCopyColormap
          glutGet
          glutDeviceGet
          glutExtensionSupported
          glutGetModifiers
          glutLayerGet
          glutGetProcAddress
          glutBitmapCharacter
          glutBitmapWidth
          glutStrokeCharacter
          glutStrokeWidth
          glutBitmapLength
          glutStrokeLength
          glutWireSphere
          glutSolidSphere
          glutWireCone
          glutSolidCone
          glutWireCube
          glutSolidCube
          glutWireTorus
          glutSolidTorus
          glutWireDodecahedron
          glutSolidDodecahedron
          glutWireTeapot
          glutSolidTeapot
          glutWireOctahedron
          glutSolidOctahedron
          glutWireTetrahedron
          glutSolidTetrahedron
          glutWireIcosahedron
          glutSolidIcosahedron
          glutVideoResizeGet
          glutSetupVideoResizing
          glutStopVideoResizing
          glutVideoResize
          glutVideoPan
          glutReportErrors
          glutIgnoreKeyRepeat
          glutSetKeyRepeat
          glutForceJoystickFunc
          glutGameModeString
          glutEnterGameMode
          glutLeaveGameMode
          glutGameModeGet)
  
  (import (chezscheme))

  ;; (define libGLUT
  ;;   (cond (on-darwin  (load-shared-object "GLUT.framework/GLUT"))
  ;;         (on-windows (load-shared-object "glut32.dll"))
  ;;         (on-linux   (load-shared-object "libglut.so.3"))
  ;;         (on-freebsd (load-shared-object "libglut.so"))
  ;;         (on-openbsd (begin
  ;;                       (load-shared-object "libXmu.so.10.0")
  ;;                       (load-shared-object "libGLU.so.7.0")
  ;;                       (load-shared-object "libglut.so.3.7")))
  ;;         (else
  ;;          (assertion-violation
  ;;           #f
  ;;           "can not locate GLUT library, unknown operating system"))))

  (define no-op (load-shared-object "libglut.so.3"))

  ;; Display mode bit masks.
  (define GLUT_RGB                0)
  (define GLUT_RGBA               GLUT_RGB)
  (define GLUT_INDEX              1)
  (define GLUT_SINGLE             0)
  (define GLUT_DOUBLE             2)
  (define GLUT_ACCUM              4)
  (define GLUT_ALPHA              8)
  (define GLUT_DEPTH              16)
  (define GLUT_STENCIL            32)
  (define GLUT_MULTISAMPLE        128)
  (define GLUT_STEREO             256)
  (define GLUT_LUMINANCE          512)
  (define GLUT_NO_RECOVERY        1024)

  ;; Mouse buttons.
  (define GLUT_LEFT_BUTTON        0)
  (define GLUT_MIDDLE_BUTTON      1)
  (define GLUT_RIGHT_BUTTON       2)

  ;; Mouse button  state.
  (define GLUT_DOWN               0)
  (define GLUT_UP                 1)

  ;; function keys
  (define GLUT_KEY_F1             1)
  (define GLUT_KEY_F2             2)
  (define GLUT_KEY_F3             3)
  (define GLUT_KEY_F4             4)
  (define GLUT_KEY_F5             5)
  (define GLUT_KEY_F6             6)
  (define GLUT_KEY_F7             7)
  (define GLUT_KEY_F8             8)
  (define GLUT_KEY_F9             9)
  (define GLUT_KEY_F10            10)
  (define GLUT_KEY_F11            11)
  (define GLUT_KEY_F12            12)

  ;; directional keys
  (define GLUT_KEY_LEFT           100)
  (define GLUT_KEY_UP             101)
  (define GLUT_KEY_RIGHT          102)
  (define GLUT_KEY_DOWN           103)
  (define GLUT_KEY_PAGE_UP        104)
  (define GLUT_KEY_PAGE_DOWN      105)
  (define GLUT_KEY_HOME           106)
  (define GLUT_KEY_END            107)
  (define GLUT_KEY_INSERT         108)

  ;; Entry/exit  state.
  (define GLUT_LEFT               0)
  (define GLUT_ENTERED            1)

  ;; Menu usage  state.
  (define GLUT_MENU_NOT_IN_USE    0)
  (define GLUT_MENU_IN_USE        1)

  ;; Visibility  state.
  (define GLUT_NOT_VISIBLE        0)
  (define GLUT_VISIBLE            1)

  ;; Window status  state.
  (define GLUT_HIDDEN             0)
  (define GLUT_FULLY_RETAINED     1)
  (define GLUT_PARTIALLY_RETAINED 2)
  (define GLUT_FULLY_COVERED      3)

  ;; Color index component selection values.
  (define GLUT_RED                0)
  (define GLUT_GREEN              1)
  (define GLUT_BLUE               2)

  ;; Layers for use.
  (define GLUT_NORMAL             0)
  (define GLUT_OVERLAY            1)

  ;; (define-syntax define-function
  ;;   (syntax-rules ()
  ;;     ((_ ret name args)
  ;;      (define name
  ;;        (c-function libGLUT "GLUT library" ret __stdcall name args)))))

  (define-syntax define-function
    (syntax-rules ()
      ((_ ret name args)
       (define name
         (foreign-procedure (symbol->string 'name) args ret)))))

  (define-syntax define-function/single-callback
    (syntax-rules (callback)
      ((_ ret name ((callback c-ret c-params)))
       (define name
         (let ((f (foreign-procedure (symbol->string 'name) (int) ret)))
           (lambda (proc)
             (let ((code (foreign-callable proc c-params c-ret)))
               (lock-object code)
               (f (foreign-callable-entry-point code)))))))))

  ;; void glutInit(int *argcp, char **argv)
  ;; (define-function void glutInit ([int] [char*]))

  ;; (define glutInit
  ;;   (if on-windows
  ;;       (lambda (a1 a2)
  ;;         #;(c-argument 'glutInit 1 [int] a1)
  ;;         #;(c-argument 'glutInit 2 [char*] a2)
  ;;         ((c-function libGLUT "GLUT library" void __stdcall __glutInitWithExit ([int] [char*] [c-callback void (int)]))
  ;;          a1 a2 (lambda (n) (exit n))))
  ;;       (c-function libGLUT "GLUT library" void __stdcall glutInit ([int] [char*]))))

  ;; (define glutInit
  ;;   (foreign-procedure "glutInit" (u8* u8*) void))

  ;; This version ignores it's arguments.
  
  (define glutInit
    (let ((f (foreign-procedure "glutInit" (u8* u8*) void)))
      (lambda (a b)
        (f (bytevector 0 0 0 0)
           (bytevector 0)))))

  ;; void glutInitDisplayString(const char *string)
  (define-function void glutInitDisplayString (string))

  ;; void glutInitDisplayMode(unsigned int mode)
  (define-function void glutInitDisplayMode (int))

  ;; void glutInitWindowPosition(int x, int y)
  (define-function void glutInitWindowPosition (int int))

  ;; void glutInitWindowSize(int width, int height)
  (define-function void glutInitWindowSize (int int))

  ;; void glutMainLoop(void)
  (define-function void glutMainLoop ())

  ;; int glutCreateWindow(const char *title)
  (define-function int glutCreateWindow (string))

  ;; int glutCreateSubWindow(int win, int x, int y, int width, int height)
  (define-function int glutCreateSubWindow (int int int int int))

  ;; void glutDestroyWindow(int win)
  (define-function void glutDestroyWindow (int))

  ;; void glutPostRedisplay(void)
  (define-function void glutPostRedisplay ())

  ;; void glutPostWindowRedisplay(int win)
  (define-function void glutPostWindowRedisplay (int))

  ;; void glutSwapBuffers(void)
  (define-function void glutSwapBuffers ())

  ;; int glutGetWindow(void)
  (define-function int glutGetWindow ())

  ;; void glutSetWindow(int win)
  (define-function void glutSetWindow (int))

  ;; void glutSetWindowTitle(const char *title)
  (define-function void glutSetWindowTitle (string))

  ;; void glutSetIconTitle(const char *title)
  (define-function void glutSetIconTitle (string))

  ;; void glutPositionWindow(int x, int y)
  (define-function void glutPositionWindow (int int))

  ;; void glutReshapeWindow(int width, int height)
  (define-function void glutReshapeWindow (int int))

  ;; void glutPopWindow(void)
  (define-function void glutPopWindow ())

  ;; void glutPushWindow(void)
  (define-function void glutPushWindow ())

  ;; void glutIconifyWindow(void)
  (define-function void glutIconifyWindow ())

  ;; void glutShowWindow(void)
  (define-function void glutShowWindow ())

  ;; void glutHideWindow(void)
  (define-function void glutHideWindow ())

  ;; void glutFullScreen(void)
  (define-function void glutFullScreen ())

  ;; void glutSetCursor(int cursor)
  (define-function void glutSetCursor (int))

  ;; void glutWarpPointer(int x, int y)
  (define-function void glutWarpPointer (int int))

  ;; void glutEstablishOverlay(void)
  (define-function void glutEstablishOverlay ())

  ;; void glutRemoveOverlay(void)
  (define-function void glutRemoveOverlay ())

  ;; void glutUseLayer(GLenum layer)
  (define-function void glutUseLayer (int))

  ;; void glutPostOverlayRedisplay(void)
  (define-function void glutPostOverlayRedisplay ())

  ;; void glutPostWindowOverlayRedisplay(int win)
  (define-function void glutPostWindowOverlayRedisplay (int))

  ;; void glutShowOverlay(void)
  (define-function void glutShowOverlay ())

  ;; void glutHideOverlay(void)
  (define-function void glutHideOverlay ())

  ;; int glutCreateMenu(void (*)(int))

  ;; (define-function void glutCreateMenu ([c-callback void (int)]))

  (define-function/single-callback void glutCreateMenu ((callback void (int))))

  ;; void glutDestroyMenu(int menu)
  (define-function void glutDestroyMenu (int))

  ;; int glutGetMenu(void)
  (define-function int glutGetMenu ())

  ;; void glutSetMenu(int menu)
  (define-function void glutSetMenu (int))

  ;; void glutAddMenuEntry(const char *label, int value)
  (define-function void glutAddMenuEntry (string int))

  ;; void glutAddSubMenu(const char *label, int submenu)
  (define-function void glutAddSubMenu (string int))

  ;; void glutChangeToMenuEntry(int item, const char *label, int value)
  (define-function void glutChangeToMenuEntry (int string int))

  ;; void glutChangeToSubMenu(int item, const char *label, int submenu)
  (define-function void glutChangeToSubMenu (int string int))

  ;; void glutRemoveMenuItem(int item)
  (define-function void glutRemoveMenuItem (int))

  ;; void glutAttachMenu(int button)
  (define-function void glutAttachMenu (int))

  ;; void glutDetachMenu(int button)
  (define-function void glutDetachMenu (int))

  ;; void glutDisplayFunc(void (*func)(void))
  ;; (define-function void glutDisplayFunc ([c-callback void ()]))

  (define-function/single-callback void glutDisplayFunc ((callback void ())))

  ;; void glutReshapeFunc(void (*func)(int width, int height))
  ;; (define-function void glutReshapeFunc ([c-callback void (int int)]))

  (define-function/single-callback void glutReshapeFunc ([callback void (int int)]))

  ;; void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y))
  (define-function/single-callback void glutKeyboardFunc ([callback void (int int int)]))

  ;; void glutMouseFunc(void (*func)(int button, int state, int x, int y))
  (define-function/single-callback void glutMouseFunc ([callback void (int int int int)]))

  ;; void glutMotionFunc(void (*func)(int x, int y))
  (define-function/single-callback void glutMotionFunc ([callback void (int int)]))

  ;; void glutPassiveMotionFunc(void (*func)(int x, int y))
  (define-function/single-callback void glutPassiveMotionFunc ([callback void (int int)]))

  ;; void glutEntryFunc(void (*func)(int state))
  (define-function/single-callback void glutEntryFunc ([callback void (int)]))

  ;; void glutVisibilityFunc(void (*func)(int state))
  (define-function/single-callback void glutVisibilityFunc ([callback void (int)]))

  ;; void glutIdleFunc(void (*func)(void))
  (define-function/single-callback void glutIdleFunc ([callback void ()]))

  ;; void glutTimerFunc(unsigned int millis, void (*func)(int value), int value)
  ;; (define-function void glutTimerFunc (int [c-callback void (int)] int))

  (define glutTimerFunc
    (let ((f (foreign-procedure "glutTimerFunc" (unsigned-int int int) void)))
      (lambda (millis proc value)
        (let ((code (foreign-callable proc (int) void)))
          (lock-object code)
          (f millis
             (foreign-callable-entry-point code)
             value)))))

  ;; void glutMenuStateFunc(void (*func)(int state))
  (define-function/single-callback void glutMenuStateFunc ([callback void (int)]))

  ;; void glutSpecialFunc(void (*func)(int key, int x, int y))
  (define-function/single-callback void glutSpecialFunc ([callback void (int int int)]))

  ;; void glutSpaceballMotionFunc(void (*func)(int x, int y, int z))
  (define-function/single-callback void glutSpaceballMotionFunc ([callback void (int int int)]))

  ;; void glutSpaceballRotateFunc(void (*func)(int x, int y, int z))
  (define-function/single-callback void glutSpaceballRotateFunc ([callback void (int int int)]))

  ;; void glutSpaceballButtonFunc(void (*func)(int button, int state))
  (define-function/single-callback void glutSpaceballButtonFunc ([callback void (int int)]))

  ;; void glutButtonBoxFunc(void (*func)(int button, int state))
  (define-function/single-callback void glutButtonBoxFunc ([callback void (int int)]))

  ;; void glutDialsFunc(void (*func)(int dial, int value))
  (define-function/single-callback void glutDialsFunc ([callback void (int int)]))

  ;; void glutTabletMotionFunc(void (*func)(int x, int y))
  (define-function/single-callback void glutTabletMotionFunc ([callback void (int int)]))

  ;; void glutTabletButtonFunc(void (*func)(int button, int state, int x, int y))
  (define-function/single-callback void glutTabletButtonFunc ([callback void (int int int int)]))

  ;; void glutMenuStatusFunc(void (*func)(int status, int x, int y))
  (define-function/single-callback void glutMenuStatusFunc ([callback void (int int int)]))

  ;; void glutOverlayDisplayFunc(void (*func)(void))
  (define-function/single-callback void glutOverlayDisplayFunc ([callback void ()]))

  ;; void glutWindowStatusFunc(void (*func)(int state))
  (define-function/single-callback void glutWindowStatusFunc ([callback void (int)]))

  ;; void glutKeyboardUpFunc(void (*func)(unsigned char key, int x, int y))
  (define-function/single-callback void glutKeyboardUpFunc ([callback void (int int int)]))

  ;; void glutSpecialUpFunc(void (*func)(int key, int x, int y))
  (define-function/single-callback void glutSpecialUpFunc ([callback void (int int int)]))

  ;; void glutJoystickFunc(void (*func)(unsigned int buttonMask, int x, int y, int z), int pollInterval)
  ;; (define-function void glutJoystickFunc ([c-callback void (int int int int)] int))

  (define glutJoystickFunc
    (let ((f (foreign-procedure "glutJoystickFunc" (int int) void)))
      (lambda (proc poll-interval)
        (let ((code (foreign-callable proc (unsigned-int int int int) void)))
          (lock-object code)
          (f (foreign-callable-entry-point code)
             poll-interval)))))

  ;; void glutSetColor(int, GLfloat red, GLfloat green, GLfloat blue)
  (define-function void glutSetColor (int float float float))

  ;; GLfloat glutGetColor(int ndx, int component)
  (define-function double glutGetColor (int int))

  ;; void glutCopyColormap(int win)
  (define-function void glutCopyColormap (int))

  ;; int glutGet(GLenum type)
  (define-function int glutGet (int))

  ;; int glutDeviceGet(GLenum type)
  (define-function int glutDeviceGet (int))

  ;; int glutExtensionSupported(const char *name)
  (define-function int glutExtensionSupported (string))

  ;; int glutGetModifiers(void)
  (define-function int glutGetModifiers ())

  ;; int glutLayerGet(GLenum type)
  (define-function int glutLayerGet (int))

  ;; void * glutGetProcAddress(const char *procName)
  (define-function void* glutGetProcAddress (string))

  ;; void glutBitmapCharacter(void *font, int character)
  (define-function void* glutBitmapCharacter (void* int))

  ;; int glutBitmapWidth(void *font, int character)
  (define-function int glutBitmapWidth (void* int))

  ;; void glutStrokeCharacter(void *font, int character)
  (define-function void glutStrokeCharacter (void* int))

  ;; int glutStrokeWidth(void *font, int character)
  (define-function int glutStrokeWidth (void* int))

  ;; int glutBitmapLength(void *font, const unsigned char *string)
  (define-function int glutBitmapLength (void* string))

  ;; int glutStrokeLength(void *font, const unsigned char *string)
  (define-function int glutStrokeLength (void* string))

  ;; void glutWireSphere(GLdouble radius, GLint slices, GLint stacks)
  (define-function int glutWireSphere (double int int))

  ;; void glutSolidSphere(GLdouble radius, GLint slices, GLint stacks)
  (define-function void glutSolidSphere (double int int))

  ;; void glutWireCone(GLdouble base, GLdouble height, GLint slices, GLint stacks)
  (define-function void glutWireCone (double double int int))

  ;; void glutSolidCone(GLdouble base, GLdouble height, GLint slices, GLint stacks)
  (define-function void glutSolidCone (double double int int))

  ;; void glutWireCube(GLdouble size)
  (define-function void glutWireCube (double))

  ;; void glutSolidCube(GLdouble size)
  (define-function void glutSolidCube (double))

  ;; void glutWireTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings)
  (define-function void glutWireTorus (double double int int))

  ;; void glutSolidTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings)
  (define-function void glutSolidTorus (double double int int))

  ;; void glutWireDodecahedron(void)
  (define-function void glutWireDodecahedron ())

  ;; void glutSolidDodecahedron(void)
  (define-function void glutSolidDodecahedron ())

  ;; void glutWireTeapot(GLdouble size)
  (define-function void glutWireTeapot (double))

  ;; void glutSolidTeapot(GLdouble size)
  (define-function void glutSolidTeapot (double))

  ;; void glutWireOctahedron(void)
  (define-function void glutWireOctahedron ())

  ;; void glutSolidOctahedron(void)
  (define-function void glutSolidOctahedron ())

  ;; void glutWireTetrahedron(void)
  (define-function void glutWireTetrahedron ())

  ;; void glutSolidTetrahedron(void)
  (define-function void glutSolidTetrahedron ())

  ;; void glutWireIcosahedron(void)
  (define-function void glutWireIcosahedron ())

  ;; void glutSolidIcosahedron(void)
  (define-function void glutSolidIcosahedron ())

  ;; int glutVideoResizeGet(GLenum param)
  (define-function int glutVideoResizeGet ())

  ;; void glutSetupVideoResizing(void)
  (define-function int glutSetupVideoResizing ())

  ;; void glutStopVideoResizing(void)
  (define-function void glutStopVideoResizing ())

  ;; void glutVideoResize(int x, int y, int width, int height)
  (define-function void glutVideoResize (int int int int))

  ;; void glutVideoPan(int x, int y, int width, int height)
  (define-function void glutVideoPan (int int int int))

  ;; void glutReportErrors(void)
  (define-function void glutReportErrors ())

  ;; void glutIgnoreKeyRepeat(int ignore)
  (define-function void glutIgnoreKeyRepeat (int))

  ;; void glutSetKeyRepeat(int repeatMode)
  (define-function void glutSetKeyRepeat (int))

  ;; void glutForceJoystickFunc(void)
  (define-function void glutForceJoystickFunc ())

  ;; void glutGameModeString(const char *string)
  (define-function void glutGameModeString (string))

  ;; int glutEnterGameMode(void)
  (define-function int glutEnterGameMode ())

  ;; void glutLeaveGameMode(void)
  (define-function void glutLeaveGameMode ())

  ;; int glutGameModeGet(GLenum mode)
  (define-function int glutGameModeGet (int))

  )
