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

(define orange
  (make-parameter '((100 (255 218 185))
                    (200 (255 160 122))
                    (300 (255 127 80))
                    (400 (255 165 0))
                    (500 (255 140 0))
                    (600 (255 69 0))
                    (700 (210 105 30))
                    (800 (139 69 19))
                    (900 (128 0 0)))))

(define red
  (make-parameter '((100 (255 240 240))
                    (200 (250 128 114))
                    (300 (233 150 122))
                    (400 (205 92 92))
                    (500 (220 20 60))
                    (600 (255 0 0))
                    (700 (178 34 34))
                    (800 (139 0 0))
                    (900 (128 0 0)))))

(define stone
  (make-parameter '((100 (212 217 217))
                    (200 (190 197 197))
                    (300 (158 169 169))
                    (400 (125 140 140))
                    (500 (86 97 97))
                    (600 (67 76 76))
                    (700 (68 64 59))
                    (800 (48 54 54))
                    (900 (29 32 32)))))

(define default-palettes
  (make-parameter (list (cons 'orange
                              (orange))
                        (cons 'stone
                              (stone))
                        (cons 'red
                              (red)))))
