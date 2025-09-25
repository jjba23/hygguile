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
  #:export (filter-classes blur brightness))

(define blur
  (param (rulv ".blur-~a"
               #:property 'filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem-blur)) tshirt-sizes))))

(define brightness
  (param (rulv ".brightness-~a"
               #:property 'filter
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-percent-brightness)) numeric-sizes))))

(define filter-classes
  (param (list (blur)
               (brightness))))
