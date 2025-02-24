;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright (C) 2025 Josep Bigorra (jjba23) <jjbigorra@gmail.com>

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

(define-module (hygguile abstraction)
  #:use-module (srfi srfi-64)
  )

(begin
  (define* (symbols->css xs)
    (cond
     ((nil? xs) '(class ""))
     (else `(class ,(string-join (map symbol->string xs) " ")))))
  (export symbols->css))

;; module tests
(test-begin "symbols->css")
(test-equal (symbols->css '()) '(class ""))
(test-equal (symbols->css '(p-2 bg-stone-900/75)) '(class "p-2 bg-stone-900/75"))
(test-equal (symbols->css #f) '(class ""))
(test-end)
