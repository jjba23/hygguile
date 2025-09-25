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

(define-module (hygguile hss decl filters)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (filter-classes blur
                           brightness
                           contrast
                           grayscale
                           sepia
                           saturate
                           invert))

(define blur
  (param (rulv ".blur-~a"
               #:property 'filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem-blur)) tshirt-sizes))))

(define backdrop-blur
  (param (rulv ".backdrop-blur-~a"
               #:property 'backdrop-filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem-blur)) tshirt-sizes))))

(define brightness
  (param (rulv ".brightness-~a"
               #:property 'filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion (to-percent-f 'brightness)))
                               numeric-sizes))))

(define backdrop-brightness
  (param (rulv ".backdrop-brightness-~a"
               #:property 'backdrop-filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion (to-percent-f 'brightness)))
                               numeric-sizes))))

(define contrast
  (param (rulv ".contrast-~a"
               #:property 'filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion (to-percent-f 'contrast)))
                               numeric-sizes))))

(define backdrop-contrast
  (param (rulv ".backdrop-contrast-~a"
               #:property 'backdrop-filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion (to-percent-f 'contrast)))
                               numeric-sizes))))

(define grayscale
  (param (list (rulv ".grayscale-~a"
                     #:property 'filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'grayscale)))
                                     numeric-sizes))
               (rul ".grayscale"
                    (dec 'filter "grayscale(100%)")))))

(define backdrop-grayscale
  (param (list (rulv ".backdrop-grayscale-~a"
                     #:property 'backdrop-filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'grayscale)))
                                     numeric-sizes))
               (rul ".backdrop-grayscale"
                    (dec 'backdrop-filter "grayscale(100%)")))))

(define sepia
  (param (list (rulv ".sepia-~a"
                     #:property 'filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'sepia)))
                                     numeric-sizes))
               (rul ".sepia"
                    (dec 'filter "sepia(100%)")))))

(define backdrop-sepia
  (param (list (rulv ".backdrop-sepia-~a"
                     #:property 'backdrop-filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'sepia)))
                                     numeric-sizes))
               (rul ".backdrop-sepia"
                    (dec 'backdrop-filter "sepia(100%)")))))

(define saturate
  (param (list (rulv ".saturate-~a"
                     #:property 'filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'saturate)))
                                     numeric-sizes))
               (rul ".saturate"
                    (dec 'filter "saturate(100%)")))))

(define backdrop-saturate
  (param (list (rulv ".backdrop-saturate-~a"
                     #:property 'backdrop-filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'saturate)))
                                     numeric-sizes))
               (rul ".backdrop-saturate"
                    (dec 'backdrop-filter "saturate(100%)")))))

(define invert
  (param (list (rulv ".invert-~a"
                     #:property 'filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'invert)))
                                     numeric-sizes))
               (rul ".invert"
                    (dec 'filter "invert(100%)")))))

(define backdrop-invert
  (param (list (rulv ".backdrop-invert-~a"
                     #:property 'backdrop-filter
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion (to-percent-f 'invert)))
                                     numeric-sizes))
               (rul ".backdrop-invert"
                    (dec 'backdrop-filter "invert(100%)")))))

(define filter-classes
  (param (list (blur)
               (backdrop-blur)
               (brightness)
               (backdrop-brightness)
               (contrast)
               (backdrop-contrast)
               (grayscale)
               (backdrop-grayscale)
               (sepia)
               (backdrop-sepia)
               (saturate)
               (backdrop-saturate)
               (invert)
               (backdrop-invert))))
