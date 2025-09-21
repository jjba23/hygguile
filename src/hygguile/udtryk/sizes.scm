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

(define-module (hygguile udtryk sizes)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:export (default-tshirt-sizes default-numeric-sizes default-weights))

(define default-tshirt-sizes
  `(("xxs" 1)
    ("xs" 2)
    ("sm" 3)
    ("md" 4)
    ("lg" 5)
    ("xl" 6)
    ("2xl" 7)
    ("3xl" 8)
    ("4xl" 9)
    ("5xl" 10)))

(define default-numeric-sizes
  (list 1
        2
        4
        6
        8
        10
        12
        14
        16
        18
        20
        22
        24
        28
        32
        48
        64
        72
        128))

(define default-weights
  '((100 100)
    (thin 100)
    (200 200)
    (300 300)
    (light 300)
    (400 400)
    (500 500)
    (medium 500)
    (600 600)
    (700 700)
    (bold 700)
    (800 800)
    (900 900)
    (black 900)))

