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

(define-module (hygguile hss sizes)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:export (tshirt-sizes numeric-sizes weights alphas color-weights fractions))

(define tshirt-sizes
  `(("2xs" 1)
    ("xs" 2)
    ("sm" 3)
    ("md" 4)
    ("lg" 5)
    ("xl" 6)
    ("2xl" 7)
    ("3xl" 8)
    ("4xl" 9)
    ("5xl" 10)))

(define numeric-sizes
  '((1 1)
    (2 2)
    (3 3)
    (4 4)
    (5 5)
    (6 6)
    (7 7)
    (8 8)
    (9 9)
    (10 10)
    (12 12)
    (14 14)
    (16 16)
    (20 20)
    (24 24)
    (28 28)
    (32 32)
    (48 48)
    (64 64)
    (72 72)
    (90 90)
    (96 96)
    (100 100)
    (128 128)
    (196 196)
    (256 256)
    (512 512)))

(define weights
  '((thin 100)
    (light 300)
    (medium 500)
    (bold 700)
    (black 900)))

(define fractions
  '(("2\\/3" "66.6%")
    ("1\\/2" "50%")
    ("1\\/3" "33.3%")
    ("1\\/4" "25%")
    ("1\\/5" "20%")
    ("1\\/6" "16.6%")
    ("1\\/8" "12.5%")))

(define color-weights
  '((100 100)
    (300 300)
    (500 500)
    (700 700)
    (900 900)))

(define alphas
  '((1 0.01)
    (5 0.05)
    (10 0.1)
    (25 0.2)
    (50 0.5)
    (75 0.7)
    (90 0.9)
    (95 0.95)
    ("" 1)))
