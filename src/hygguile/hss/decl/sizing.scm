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

(define-module (hygguile hss decl sizing)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (sizing-classes width height height-multiplier width-multiplier
                           prose-size))

(define width-multiplier
  (param 0.24))

(define height-multiplier
  (param 0.24))

(define prose-size
  (param "84ch"))

(define width
  (param (append (list (rul ".min-w-screen"
                            (dec 'min-width "1vh"))
                       (rul ".max-w-screen"
                            (dec 'max-width "1vh"))
                       (rul ".min-w-prose"
                            (dec 'min-width
                                 (prose-size)))
                       (rul ".max-w-prose"
                            (dec 'max-width
                                 (prose-size))))
                 (map (lambda (d)
                        (rulv (string-append "."
                                             (format #f "~a"
                                                     (car d)) "-" "~a")
                              #:property (cadr d)
                              #:variants (map (lambda (s)
                                                (siz s
                                                     #:conversion to-rem
                                                     #:multiplier (width-multiplier)))
                                              (append numeric-sizes
                                                      tshirt-sizes))))
                      '((w width)
                        (min-w min-width)
                        (max-w max-width))))))

(define height
  (param (append (list (rul ".min-h-screen"
                            (dec 'min-height "1vh"))
                       (rul ".max-h-screen"
                            (dec 'max-height "1vh")))
                 (map (lambda (d)
                        (rulv (string-append "."
                                             (format #f "~a"
                                                     (car d)) "-" "~a")
                              #:property (cadr d)
                              #:variants (map (lambda (s)
                                                (siz s
                                                     #:conversion to-rem
                                                     #:multiplier (height-multiplier)))
                                              (append numeric-sizes
                                                      tshirt-sizes))))
                      '((h height)
                        (min-h min-height)
                        (max-h max-height))))))

(define sizing-classes
  (param (list (width)
               (height))))
