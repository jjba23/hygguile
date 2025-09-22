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

(define purple
  (make-parameter '((100 (245 230 255))
                    (300 (216 191 216))
                    (500 (147 112 219))
                    (700 (148 0 211))
                    (900 (75 0 130)))))

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

(define green
  (make-parameter '((100 (240 255 240))
                    (300 (144 238 144))
                    (500 (0 255 127))
                    (700 (0 128 0))
                    (900 (0 64 0)))))

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
