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
  #:export (default-tshirt-sizes default-numeric-sizes default-weights
                                 default-alphas default-color-weights))

(define default-tshirt-sizes
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
        24
        28
        32
        48
        64
        72
        96
        128))

(define default-weights
  '((thin 100)
    (light 300)
    (medium 500)
    (bold 700)
    (black 900)))

(define default-color-weights
  '((100 100)
    (300 300)
    (500 500)
    (700 700)
    (900 900)))

(define default-alphas
  '((0 0.0)
    (5 0.05)
    (10 0.1)
    (25 0.2)
    (50 0.5)
    (75 0.7)
    (90 0.9)
    (95 0.95)
    ("" 1)))
