;;
;; Copyright 2016 Aldo Nicolas Bruno
;;
;; Licensed under the Apache License, Version 2.0 (the "License");
;; you may not use this file except in compliance with the License.
;; You may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;; See the License for the specific language governing permissions and
;; limitations under the License.

(define-flags sdl-scancode
    (unknown   0)

    ;; /**
    ;;  *  \name usage page 0x07
    ;;  *
    ;;  *  these values are from usage page 0x07 (usb keyboard page).
    ;;  */
    ;; /* @{ */

    (a   4)
    (b   5)
    (c   6)
    (d   7)
    (e   8)
    (f   9)
    (g   10)
    (h   11)
    (i   12)
    (j   13)
    (k   14)
    (l   15)
    (m   16)
    (n   17)
    (o   18)
    (p   19)
    (q   20)
    (r   21)
    (s   22)
    (t   23)
    (u   24)
    (v   25)
    (w   26)
    (x   27)
    (y   28)
    (z   29)

    (1   30)
    (2   31)
    (3   32)
    (4   33)
    (5   34)
    (6   35)
    (7   36)
    (8   37)
    (9   38)
    (0   39)

    (return   40)
    (escape   41)
    (backspace   42)
    (tab   43)
    (space   44)

    (minus   45)
    (equals   46)
    (leftbracket   47)
    (rightbracket   48)
    (backslash   49) ;; /**< located at the lower left of the return
    ;;                  *   key on iso keyboards and at the right end
    ;;                  *   of the qwerty row on ansi keyboards.
    ;;                  *   produces reverse solidus (backslash) and
    ;;                  *   vertical line in a us layout, reverse
    ;;                  *   solidus and vertical line in a uk mac
    ;;                  *   layout, number sign and tilde in a uk
    ;;                  *   windows layout, dollar sign and pound sign
    ;;                  *   in a swiss german layout, number sign and
    ;;                  *   apostrophe in a german layout, grave
    ;;                  *   accent and pound sign in a french mac
    ;;                  *   layout, and asterisk and micro sign in a
    ;;                  *   french windows layout.
    ;;                  */
    (nonushash   50) ;; /**< iso usb keyboards actually use this code
    ;;                  *   instead of 49 for the same key, but all
    ;;                  *   oses i've seen treat the two codes
    ;;                  *   identically. so, as an implementor, unless
    ;;                  *   your keyboard generates both of those
    ;;                  *   codes and your os treats them differently,
    ;;                  *   you should generate sdl-scancode-backslash
    ;;                  *   instead of this code. as a user, you
    ;;                  *   should not rely on this code because sdl
    ;;                  *   will never generate it with most (all?)
    ;;                  *   keyboards.
    ;;                  */
    (semicolon   51)
    (apostrophe   52)
    (grave   53) ;; /**< located in the top left corner (on both ansi
    ;;                  *   and iso keyboards). produces grave accent and
    ;;                  *   tilde in a us windows layout and in us and uk
    ;;                  *   mac layouts on ansi keyboards, grave accent
    ;;                  *   and not sign in a uk windows layout, section
    ;;                  *   sign and plus-minus sign in us and uk mac
    ;;                  *   layouts on iso keyboards, section sign and
    ;;                  *   degree sign in a swiss german layout (mac:
    ;;                  *   only on iso keyboards), circumflex accent and
    ;;                  *   degree sign in a german layout (mac: only on
    ;;                  *   iso keyboards), superscript two and tilde in a
    ;;                  *   french windows layout, commercial at and
    ;;                  *   number sign in a french mac layout on iso
    ;;                  *   keyboards, and less-than sign and greater-than
    ;;                  *   sign in a swiss german, german, or french mac
    ;;                  *   layout on ansi keyboards.
    ;;                  */
    (comma   54)
    (period   55)
    (slash   56)

    (capslock   57)

    (f1   58)
    (f2   59)
    (f3   60)
    (f4   61)
    (f5   62)
    (f6   63)
    (f7   64)
    (f8   65)
    (f9   66)
    (f10   67)
    (f11   68)
    (f12   69)

    (printscreen   70)
    (scrolllock   71)
    (pause   72)
    (insert   73); /**< insert on pc, help on some mac keyboards (but
                                        ;                      does send code 73, not 117) */
    (home   74)
    (pageup   75)
    (delete   76)
    (end   77)
    (pagedown   78)
    (right   79)
    (left   80)
    (down   81)
    (up   82)

    (numlockclear   83) ;/**< num lock on pc, clear on mac keyboards
                                        ;               */
    (kp-divide   84)
    (kp-multiply   85)
    (kp-minus   86)
    (kp-plus   87)
    (kp-enter   88)
    (kp-1   89)
    (kp-2   90)
    (kp-3   91)
    (kp-4   92)
    (kp-5   93)
    (kp-6   94)
    (kp-7   95)
    (kp-8   96)
    (kp-9   97)
    (kp-0   98)
    (kp-period   99)

    (nonusbackslash   100) ;/**< this is the additional key that iso
    ;; *   keyboards have over ansi ones,
    ;; *   located between left shift and y.
    ;; *   produces grave accent and tilde in a
    ;; *   us or uk mac layout, reverse solidus
    ;; *   (backslash) and vertical line in a
    ;; *   us or uk windows layout, and
    ;; *   less-than sign and greater-than sign
    ;; *   in a swiss german, german, or french
    ;; *   layout. */
    (application   101); /**< windows contextual menu, compose */
    (power   102) ;/**< the usb document says this is a status flag,
                                        ;                 *   not a physical key - but some mac keyboards
                                        ;                 *   do have a power key. */
    (kp-equals   103)
    (f13   104)
    (f14   105)
    (f15   106)
    (f16   107)
    (f17   108)
    (f18   109)
    (f19   110)
    (f20   111)
    (f21   112)
    (f22   113)
    (f23   114)
    (f24   115)
    (execute   116)
    (help   117)
    (menu   118)
    (select   119)
    (stop   120)
    (again   121)  ; /**< redo */
    (undo   122)
    (cut   123)
    (copy   124)
    (paste   125)
    (find   126)
    (mute   127)
    (volumeup   128)
    (volumedown   129)
                                        ;/* not sure whether there's a reason to enable these */
                                        ;/* (lockingcapslock   130,  */
                                        ;/* (lockingnumlock   131, */
                                        ;/* (lockingscrolllock   132, */
    (kp-comma   133)
    (kp-equalsas400   134)

    (international1   135) ;/**< used on asian keyboards, see
                                        ;footnotes in usb doc */
    (international2   136)
    (international3   137) ;/**< yen */
    (international4   138)
    (international5   139)
    (international6   140)
    (international7   141)
    (international8   142)
    (international9   143)
    (lang1   144) ;/**< hangul/english toggle */
    (lang2   145) ;/**< hanja conversion */
    (lang3   146) ;/**< katakana */
    (lang4   147) ;/**< hiragana */
    (lang5   148) ;/**< zenkaku/hankaku */
    (lang6   149) ;/**< reserved */
    (lang7   150) ;/**< reserved */
    (lang8   151) ;/**< reserved */
    (lang9   152) ;/**< reserved */

    (alterase   153) ;/**< erase-eaze */
    (sysreq   154)
    (cancel   155)
    (clear   156)
    (prior   157)
    (return2   158)
    (separator   159)
    (out   160)
    (oper   161)
    (clearagain   162)
    (crsel   163)
    (exsel   164)

    (kp-00   176)
    (kp-000   177)
    (thousandsseparator   178)
    (decimalseparator   179)
    (currencyunit   180)
    (currencysubunit   181)
    (kp-leftparen   182)
    (kp-rightparen   183)
    (kp-leftbrace   184)
    (kp-rightbrace   185)
    (kp-tab   186)
    (kp-backspace   187)
    (kp-a   188)
    (kp-b   189)
    (kp-c   190)
    (kp-d   191)
    (kp-e   192)
    (kp-f   193)
    (kp-xor   194)
    (kp-power   195)
    (kp-percent   196)
    (kp-less   197)
    (kp-greater   198)
    (kp-ampersand   199)
    (kp-dblampersand   200)
    (kp-verticalbar   201)
    (kp-dblverticalbar   202)
    (kp-colon   203)
    (kp-hash   204)
    (kp-space   205)
    (kp-at   206)
    (kp-exclam   207)
    (kp-memstore   208)
    (kp-memrecall   209)
    (kp-memclear   210)
    (kp-memadd   211)
    (kp-memsubtract   212)
    (kp-memmultiply   213)
    (kp-memdivide   214)
    (kp-plusminus   215)
    (kp-clear   216)
    (kp-clearentry   217)
    (kp-binary   218)
    (kp-octal   219)
    (kp-decimal   220)
    (kp-hexadecimal   221)

    (lctrl   224)
    (lshift   225)
    (lalt   226) ; /**< alt, option */
    (lgui   227) ;/**< windows, command (apple)) meta */
    (rctrl   228)
    (rshift   229)
    (ralt   230) ; /**< alt gr, option */
    (rgui   231) ; /**< windows, command (apple), meta */

    (mode   257)  ;;   /**< i'm not sure if this is really not covered
    ;;                              *   by any of the above, but since there's a
    ;;                              *   special kmod-mode for it i'm adding it here
    ;;                              */

    ;; /* @} *//* usage page 0x07 */

    ;; /**
    ;;  *  \name usage page 0x0c
    ;;  *
    ;;  *  these values are mapped from usage page 0x0c (usb consumer page).
    ;;  */
    ;; /* @{ */

    (audionext   258)
    (audioprev   259)
    (audiostop   260)
    (audioplay   261)
    (audiomute   262)
    (mediaselect   263)
    (www   264)
    (mail   265)
    (calculator   266)
    (computer   267)
    (ac-search   268)
    (ac-home   269)
    (ac-back   270)
    (ac-forward   271)
    (ac-stop   272)
    (ac-refresh   273)
    (ac-bookmarks   274)

    ;; /* @} *//* usage page 0x0c */

    ;; /**
    ;;  *  \name walther keys
    ;;  *
    ;;  *  these are values that christian walther added (for mac keyboard?).
    ;;  */
    ;; /* @{ */

    (brightnessdown   275)
    (brightnessup   276)
    (displayswitch   277) ;; /**< display mirroring/dual display
    ;;                      switch, video mode switch */
    (kbdillumtoggle   278)
    (kbdillumdown   279)
    (kbdillumup   280)
    (eject   281)
    (sleep   282)

    (app1   283)
    (app2   284)

    ;; /* @} *//* walther keys */

    ;; /* add any other keys here. */

    (sdl-num-scancodes   512) ;; /**< not a key, just marks the number of scancodes
    ;;    for array bounds */

    ) ; sdl-scancode
