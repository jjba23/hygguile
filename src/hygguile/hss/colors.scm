;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; hygguile is free software: you can redistribute it and/or modify
;; it under the terms of the Lesser GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; hygguile is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; Lesser GNU General Public License for more details.

;; You should have received a copy of the Lesser GNU General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (hygguile hss colors)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:export (default-colors default-palettes orange red stone))

(define default-colors
  (make-parameter '(orange red)))

(define (darken xs n)
  (map (lambda (x)
         (let* ((comp (- x n)))
           (if (< comp 0) 0 comp))) xs))

(define (lighten xs n)
  (map (lambda (x)
         (let* ((comp (+ n x)))
           (if (> comp 255) 255 comp))) xs))

(define orange-crayola
  '(243 113 43))

(define orange
  (make-parameter `((100 ,(lighten orange-crayola 42))
                    (200 ,(lighten orange-crayola 32))
                    (300 ,(lighten orange-crayola 22))
                    (400 ,(lighten orange-crayola 12))
                    (500 ,orange-crayola)
                    (600 ,(darken orange-crayola 12))
                    (700 ,(darken orange-crayola 22))
                    (800 ,(darken orange-crayola 32))
                    (900 ,(darken orange-crayola 42)))))
(define rojo
  '(222 23 43))

(define red
  (make-parameter `((100 ,(lighten rojo 42))
                    (200 ,(lighten rojo 32))
                    (300 ,(lighten rojo 22))
                    (400 ,(lighten rojo 12))
                    (500 ,rojo)
                    (600 ,(darken rojo 12))
                    (700 ,(darken rojo 22))
                    (800 ,(darken rojo 32))
                    (900 ,(darken rojo 42)))))

(define silver
  '(184 183 184))

(define stone
  (make-parameter `((100 ,(lighten silver 104))
                    (200 ,(lighten silver 84))
                    (300 ,(lighten silver 64))
                    (400 ,(lighten silver 44))
                    (500 ,silver)
                    (600 ,(darken silver 44))
                    (700 ,(darken silver 64))
                    (800 ,(darken silver 84))
                    (900 ,(darken silver 104)))))

(define purple
  (make-parameter '((100 (245 230 255))
                    ;; lavender-ish
                    (200 (230 190 255)) ;thistle
                    (300 (216 191 216)) ;plum
                    (400 (186 85 211)) ;medium orchid
                    (500 (147 112 219)) ;medium purple
                    (600 (138 43 226)) ;blue violet
                    (700 (148 0 211)) ;dark violet
                    (800 (128 0 128)) ;classic purple
                    (900 (75 0 130)))))
; indigo

(define pink
  (make-parameter '((100 (255 228 240))
                    ;; very light pink
                    (200 (255 182 193)) ;light pink
                    (300 (255 192 203)) ;pink
                    (400 (255 105 180)) ;hot pink
                    (500 (255 20 147)) ;deep pink
                    (600 (219 112 147)) ;pale violet red
                    (700 (199 21 133)) ;medium violet red
                    (800 (139 0 98)) ;dark pink/purple-ish
                    (900 (128 0 64)))))
; deep rose/maroon

(define amber
  (make-parameter '((100 (255 248 220))
                    ;; cornsilk
                    (200 (255 236 179)) ;light amber
                    (300 (255 223 128)) ;medium amber
                    (400 (255 191 0)) ;vivid amber
                    (500 (255 165 0)) ;orange / strong amber
                    (600 (255 140 0)) ;dark amber-orange
                    (700 (204 119 0)) ;deep amber
                    (800 (153 76 0)) ;brownish amber
                    (900 (102 51 0)))))
; very dark amber

(define yellow
  (make-parameter '((100 (255 255 224))
                    ;; light yellow
                    (200 (255 255 153)) ;pastel yellow
                    (300 (255 255 102)) ;bright soft yellow
                    (400 (255 255 0)) ;pure yellow
                    (500 (255 215 0)) ;golden yellow
                    (600 (238 201 0)) ;vivid goldenrod
                    (700 (204 173 0)) ;darker golden
                    (800 (153 128 0)) ;mustard / earthy yellow
                    (900 (102 76 0)))))
; very dark yellow-brown

(define green
  (make-parameter '((100 (240 255 240))
                    ;; honeydew
                    (200 (204 255 204)) ;pale mint
                    (300 (144 238 144)) ;light green
                    (400 (60 179 113)) ;medium sea green
                    (500 (0 255 127)) ;spring green
                    (600 (34 139 34)) ;forest green
                    (700 (0 128 0)) ;standard green
                    (800 (0 100 0)) ;dark green
                    (900 (0 64 0)))))
; very deep green

(define default-palettes
  (make-parameter (list (cons 'orange
                              (orange))
                        (cons 'stone
                              (stone))
                        (cons 'purple
                              (purple))
                        (cons 'green
                              (green))
                        (cons 'yellow
                              (yellow))
                        (cons 'amber
                              (amber))
                        (cons 'pink
                              (pink))
                        (cons 'red
                              (red)))))
