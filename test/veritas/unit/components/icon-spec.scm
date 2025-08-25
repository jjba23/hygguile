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

(define-module (veritas unit components icon-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components icon)
  #:export (spec))

(define icon-suite
  (suite "Icons"
         (test "hygguile icons"
               (assert-equal #:name "icon is an <i> element"
                             #:got (car (icon #:type "lightbulb"))
                             #:expect 'i))))

(define (spec)
  (veritas-run icon-suite))

