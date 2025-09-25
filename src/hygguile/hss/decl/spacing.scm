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

(define-module (hygguile hss decl spacing)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (spacing-classes margin padding margin-multiplier padding-multiplier))

(define margin-multiplier
  (make-parameter 0.28))
(define padding-multiplier
  (make-parameter 0.28))

(define padding
  (make-parameter (map (lambda (d)
                         (map (lambda (p)
                                (rulv (string-append "."
                                                     (format #f "~a"
                                                             (car d)) "-" "~a")
                                      #:property p
                                      #:variants (map (lambda (s)
                                                        (siz s
                                                             #:conversion
                                                             to-rem
                                                             #:multiplier (padding-multiplier)))
                                                      (append numeric-sizes
                                                              tshirt-sizes))))
                              (cdr d)))
                       '((p padding-top padding-bottom padding-left
                            padding-right)
                         (px padding-left padding-right)
                         (py padding-top padding-bottom)
                         (pt padding-top)
                         (pb padding-bottom)
                         (pl padding-left)
                         (pr padding-right)))))

(define margin
  (make-parameter (map (lambda (d)
                         (map (lambda (p)
                                (rulv (string-append "."
                                                     (format #f "~a"
                                                             (car d)) "-" "~a")
                                      #:property p
                                      #:variants (map (lambda (s)
                                                        (siz s
                                                             #:conversion
                                                             to-rem
                                                             #:multiplier (margin-multiplier)))
                                                      (append numeric-sizes
                                                              tshirt-sizes))))
                              (cdr d)))
                       '((m margin-top margin-bottom margin-left margin-right)
                         (mx margin-left margin-right)
                         (my margin-top margin-bottom)
                         (mt margin-top)
                         (mb margin-bottom)
                         (ml margin-left)
                         (mr margin-right)))))

(define spacing-classes
  (make-parameter (list (margin) (padding))))
