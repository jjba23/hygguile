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
  #:use-module (srfi srfi-64))

;; ->css: Convert a list of symbols into a CSS `class` attribute pair.
;;
;; This function takes a list of symbols representing CSS class names and
;; returns an S-expression `(class "class-names")`. The class names are
;; space-separated in a string. If the input is an empty list or `#f`,
;; it returns `(class "")`, ensuring that an empty class attribute is still valid.
;;
;; Examples:
;; (->css '())                       ⇒ ""
;; (->css '(p-2 bg-stone-900/75))    ⇒ "p-2 bg-stone-900/75"
;; (->css #f)                        ⇒ ""
;;
(begin
  (define* (->css xs)
    (cond
     ((nil? xs)
      "")
     (else (string-join (map symbol->string xs) " "))))
  (export ->css))

(begin
  (define* (render-if-nestring expr x)
    (if (and x
             (not (equal? "" x)))
        (expr x)
        '()))
  (export render-if-nestring))

;; module tests
(test-begin "abstraction tests")

(test-equal "->css empty list returns empty class string"
  (->css '()) "")

(test-equal "->css list of symbols is converted to space-separated string"
  (->css '(p-2 bg-stone-900/75)) "p-2 bg-stone-900/75")

(test-equal "->css false value returns empty class string"
  (->css #f) "")

(test-equal "render-if-nestring with valid string" "HELLO"
            (render-if-nestring string-upcase "hello"))
(test-equal "render-if-nestring with empty string"
  '()
  (render-if-nestring string-upcase ""))
(test-equal "render-if-nestring with #f"
  '()
  (render-if-nestring string-upcase #f))


(test-end)
