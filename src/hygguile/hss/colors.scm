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
                    (300 ,(lighten orange-crayola 22))
                    (500 ,orange-crayola)
                    (700 ,(darken orange-crayola 22))
                    (900 ,(darken orange-crayola 42)))))
(define rojo
  '(222 23 43))

(define red
  (make-parameter `((100 ,(lighten rojo 42))
                    (300 ,(lighten rojo 22))
                    (500 ,rojo)
                    (700 ,(darken rojo 22))
                    (900 ,(darken rojo 42)))))

(define silver
  '(184 183 184))

(define stone
  (make-parameter `((100 ,(lighten silver 84))
                    (300 ,(lighten silver 44))
                    (500 ,silver)
                    (700 ,(darken silver 64))
                    (900 ,(darken silver 104)))))

(define plump
  '(122 62 114))

(define purple
  (make-parameter `((100 ,(lighten plump 42))
                    (300 ,(lighten plump 22))
                    (500 ,plump)
                    (700 ,(darken plump 22))
                    (900 ,(darken plump 42)))))

(define pink
  (make-parameter '((100 (255 228 240))
                    (300 (255 192 203))
                    (500 (255 20 147))
                    (700 (199 21 133))
                    (900 (128 0 64)))))

(define amber
  (make-parameter '((100 (255 248 220))
                    (300 (255 223 128))
                    (500 (255 165 0))
                    (700 (204 119 0))
                    (900 (102 51 0)))))

(define yellow
  (make-parameter '((100 (255 255 224))
                    (300 (255 255 102))
                    (500 (255 215 0))
                    (700 (204 173 0))
                    (900 (102 76 0)))))

(define blue-hue
  '(40 147 204))

(define blue
  (make-parameter `((100 ,(lighten blue-hue 42))
                    (300 ,(lighten blue-hue 22))
                    (500 ,blue-hue)
                    (700 ,(darken blue-hue 22))
                    (900 ,(darken blue-hue 42)))))

(define asparagus
  '(103 141 88))

(define green
  (make-parameter `((100 ,(lighten asparagus 42))
                    (300 ,(lighten asparagus 22))
                    (500 ,asparagus)
                    (700 ,(darken asparagus 22))
                    (900 ,(darken asparagus 42)))))

(define spiced-terracotta-hue
  '(187 117 70))

(define spiced-terracotta
  (make-parameter `((100 ,(lighten spiced-terracotta-hue 42))
                    (300 ,(lighten spiced-terracotta-hue 22))
                    (500 ,spiced-terracotta-hue)
                    (700 ,(darken spiced-terracotta-hue 22))
                    (900 ,(darken spiced-terracotta-hue 42)))))

(define china-rose-hue
  '(148 76 99))

(define china-rose
  (make-parameter `((100 ,(lighten china-rose-hue 42))
                    (300 ,(lighten china-rose-hue 22))
                    (500 ,china-rose-hue)
                    (700 ,(darken china-rose-hue 22))
                    (900 ,(darken china-rose-hue 42)))))

(define earth-yellow-hue
  '(247 174 80))

(define earth-yellow
  (make-parameter `((100 ,(lighten earth-yellow-hue 42))
                    (300 ,(lighten earth-yellow-hue 22))
                    (500 ,earth-yellow-hue)
                    (700 ,(darken earth-yellow-hue 22))
                    (900 ,(darken earth-yellow-hue 42)))))

(define vin-rouge-hue
  '(141 47 26))

(define vin-rouge
  (make-parameter `((100 ,(lighten vin-rouge-hue 42))
                    (300 ,(lighten vin-rouge-hue 22))
                    (500 ,vin-rouge-hue)
                    (700 ,(darken vin-rouge-hue 22))
                    (900 ,(darken vin-rouge-hue 42)))))

(define papaya-whip-hue
  '(255 241 214))

(define papaya-whip
  (make-parameter `((100 ,(lighten papaya-whip-hue 22))
                    (300 ,(lighten papaya-whip-hue 12))
                    (500 ,papaya-whip-hue)
                    (700 ,(darken papaya-whip-hue 12))
                    (900 ,(darken papaya-whip-hue 22)))))

(define cornsilk-hue
  '(251 243 218))

(define cornsilk
  (make-parameter `((100 ,(lighten cornsilk-hue 42))
                    (300 ,(lighten cornsilk-hue 22))
                    (500 ,cornsilk-hue)
                    (700 ,(darken cornsilk-hue 22))
                    (900 ,(darken cornsilk-hue 42)))))

(define floral-white-hue
  '(253 249 237))

(define floral-white
  (make-parameter `((100 ,(lighten floral-white-hue 42))
                    (300 ,(lighten floral-white-hue 22))
                    (500 ,floral-white-hue)
                    (700 ,(darken floral-white-hue 22))
                    (900 ,(darken floral-white-hue 42)))))

(define teal-hue '(2 128 144))

(define teal
  (make-parameter `((100 ,(lighten teal-hue 42))
                    (300 ,(lighten teal-hue 22))
                    (500 ,teal-hue)
                    (700 ,(darken teal-hue 22))
                    (900 ,(darken teal-hue 42)))))

(define default-palettes
  (make-parameter (list (cons 'orange
                              (orange))
                        (cons 'spicedterracotta
                              (spiced-terracotta))
                        (cons 'vinrouge
                              (vin-rouge))
                        (cons 'earthyellow
                              (earth-yellow))
                        (cons 'chinarose
                              (china-rose))
                        (cons 'floralwhite
                              (floral-white))
                        (cons 'teal (teal))
                        (cons 'cornsilk
                              (cornsilk))
                        (cons 'papayawhip
                              (papaya-whip))
                        (cons 'stone
                              (stone))
                        (cons 'purple
                              (purple))
                          (cons 'blue
                              (blue))
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
