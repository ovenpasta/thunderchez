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

(begin
  (define sdl-alpha-opaque 255)
  (define sdl-alpha-transparent 0)

  (define-enumeration* sdl-pixeltype ( unknown index-1 index-4 index-8 packed-8 packed-16 
						packed-32 array-u8 array-u16 array-u32 array-f16 array-f32))

  (define-enumeration* sdl-bitmaporder  (none $4321 $1234))

  (define-enumeration* sdl-packedorder (none xrgb rgbx argb rgba xbgr bgrx abgr bgra))

  (define-enumeration* sdl-arrayorder (none rgb rgba argb bgr bgra abgr))

  (define-enumeration* sdl-packedlayout (none $332 $4444 $1555 $5551 $565 $8888 $2101010 $1010102))

  (define (sdl-define-pixelformat type order layout bits bytes)
    (define << bitwise-arithmetic-shift-left)
    (logor (<< 1 28) (<< type 24) (<< order 20) (<< layout 16) (<< bits 8) (<< bytes 0)))

  (define (sdl-pixelflag% x)
    (logand (bitwise-arithmetic-shift-right x 28) #x0f))
  (define (sdl-pixeltype% x)
    (logand (bitwise-arithmetic-shift-right x 24) #x0f))
  (define (sdl-pixelorder% x)
    (logand (bitwise-arithmetic-shift-right x 20) #x0f))
  (define (sdl-pixellayout x)
    (logand (bitwise-arithmetic-shift-right x 16) #x0f))
  (define (sdl-bitsperpixel% x)
    (logand (bitwise-arithmetic-shift-right x 8) #xff))
  
  (define (sdl-ispixelformat-fourcc format)
    (not (or (zero? format) (= (sdl-pixelflag% format) 1))))

  ;;TODO: NEEDS TEST
  (define (sdl-fourcc a b c d)
    (define << bitwise-arithmetic-shift-left)
    (logor (<< (logand a #xff) 0)
	   (<< (logand b #xff) 8)
	   (<< (logand c #xff) 16)
	   (<< (logand d #xff) 24)))

  (define (sdl-fourcc/char a b c d)
    (sdl-fourcc (char->integer a) (char->integer b) (char->integer c) (char->integer d)))
  
  (define-flags sdl-pixelformat
      (unknown  0)
      (index-1-lsb   (sdl-define-pixelformat (sdl-pixeltype 'index-1) (sdl-bitmaporder '$4321) 0 1 0))
      (index-1-msb   (sdl-define-pixelformat (sdl-pixeltype 'index-1) (sdl-bitmaporder '$1234) 0 1 0))
      (index-4-lsb   (sdl-define-pixelformat (sdl-pixeltype 'index-4) (sdl-bitmaporder '$4321) 0 4 0))
      (index-4-msb   (sdl-define-pixelformat (sdl-pixeltype 'index-4) (sdl-bitmaporder '$1234) 0 4 0))
      (index-8    (sdl-define-pixelformat (sdl-pixeltype 'index-8) 0 0 8 1))
      (rgb-332    (sdl-define-pixelformat (sdl-pixeltype 'packed-8) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$332) 8 1))
      (rgb-444    (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$4444) 12 2))
      (rgb-555    (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$1555) 15 2))
      (bgr-555    (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'xbgr) 
					    (sdl-packedlayout '$1555) 15 2))
      (argb-4444  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'argb) 
					    (sdl-packedlayout '$4444) 16 2))
      (rgba-4444  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'rgba) 
					    (sdl-packedlayout '$4444) 16 2))
      (abgr-4444  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'abgr) 
					    (sdl-packedlayout '$4444) 16 2))
      (bgra-4444  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'bgra) 
					    (sdl-packedlayout '$4444) 16 2))
      (argb-1555  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'argb) 
					    (sdl-packedlayout '$1555) 16 2))
      (rgba-5551  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'rgba) 
					    (sdl-packedlayout '$5551) 16 2))
      (abgr-1555  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'abgr) 
					    (sdl-packedlayout '$1555) 16 2))
      (bgra-5551  (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'bgra) 
					    (sdl-packedlayout '$5551) 16 2))
      (rgb-565    (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$565) 16 2))
      (bgr-565    (sdl-define-pixelformat (sdl-pixeltype 'packed-16) (sdl-packedorder 'xbgr) 
					    (sdl-packedlayout '$565) 16 2))
      (rgb-24     (sdl-define-pixelformat (sdl-pixeltype 'array-u8) (sdl-arrayorder 'rgb) 
					    0 24 3))
      (bgr-24     (sdl-define-pixelformat (sdl-pixeltype 'array-u8) (sdl-arrayorder 'bgr) 
					    0 24 3))
      (rgb-888    (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$8888) 24 4))
      (rgbx-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'rgbx) 
					    (sdl-packedlayout '$8888) 24 4))
      (rgb-888    (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'xrgb) 
					    (sdl-packedlayout '$8888) 24 4))
      (rgbx-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'rgbx) 
					    (sdl-packedlayout '$8888) 24 4))
      (bgr-888    (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'xbgr) 
					    (sdl-packedlayout '$8888) 24 4))
      (bgrx-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'bgrx) 
					    (sdl-packedlayout '$8888) 24 4))
      (argb-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'argb) 
					    (sdl-packedlayout '$8888) 32 4))
      (rgba-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'rgba) 
					    (sdl-packedlayout '$8888) 32 4))
      (abgr-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'abgr) 
					    (sdl-packedlayout '$8888) 32 4))
      (bgra-8888  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'bgra) 
					    (sdl-packedlayout '$8888) 32 4))
      (argb-2101010  (sdl-define-pixelformat (sdl-pixeltype 'packed-32) (sdl-packedorder 'argb) 
					       (sdl-packedlayout '$2101010) 32 4))
      
      (yv12  (sdl-fourcc/char #\Y #\V #\1 #\2))
      (iyuv  (sdl-fourcc/char #\I #\Y #\U #\V))
      (yuy2  (sdl-fourcc/char #\Y #\U #\Y #\2))
      (uyvy  (sdl-fourcc/char #\U #\Y #\V #\Y))
      (yvyu  (sdl-fourcc/char #\Y #\V #\Y #\U))
      ))
  
 (define-ftype sdl-color-t 
   (struct (r uint8) (g uint8) (b uint8) (a uint8)))
 (define-ftype sdl-palette-t 
   (struct (ncolors int) (colors (* sdl-color-t)) (version uint32) (refcount int)))

 (define-ftype sdl-pixel-format-t
   (struct 
    (format uint32)
    (palette (* sdl-palette-t))
    (bits-per-pixel uint8)
    (bytes-per-pixel uint8)
    (padding (array 2 uint8))
    (r-mask uint32)
    (g-mask uint32)
    (b-mask uint32)
    (a-mask uint32)
    (r-loss uint8)
    (g-loss uint8)
    (b-loss uint8)
    (a-loss uint8)
    (r-shift uint8)
    (g-shift uint8)
    (b-shift uint8)
    (a-shift uint8)
    (refcount int)
    (next (* sdl-pixel-format-t))))


