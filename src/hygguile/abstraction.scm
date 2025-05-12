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

(define-module (hygguile abstraction)
  #:use-module (srfi srfi-64)
  #:use-module (srfi srfi-1)
  #:export (mk-class render-if-nestring render-if-nempty))

;; mk-class: Convert a list of symbols into a CSS `class` attribute pair.
;;
;; This function takes a list of symbols representing CSS class names and
;; returns an S-expression `(class "class-names")`. The class names are
;; space-separated in a string. If the input is an empty list or `#f`,
;; it returns `(class "")`, ensuring that an empty class attribute is still valid.
;;
;; Examples:
;; (mk-class '())                       ⇒ ""
;; (mk-class '(p-2 bg-stone-900/75))    ⇒ "bg-stone-900/75 p-2 "
;; (mk-class #f)                        ⇒ ""
;;
(define* (mk-class xs)
  (cond
    ((nil? xs)
     "")
    (else (string-join (sort (map symbol->string
                                  (delete-duplicates xs)) string<?) " "))))

(define* (render-if-nestring expr x)
  (if (and x
           (not (equal? "" x)))
      (expr x)
      '()))

(define* (render-if-nempty render-func item)
  (cond
    ((or (nil? item)
         (equal? item #f))
     '())
    (else (render-func item))))

;; module tests
(test-begin "abstraction tests")

(test-equal "mk-class empty list returns empty class string"
            (mk-class '()) "")

(test-equal
 "mk-class list of symbols is converted to sorted space-separated string"
 (mk-class '(p-2 my-2 bg-stone-900/75 hover:bg-stone-800))
 "bg-stone-900/75 hover:bg-stone-800 my-2 p-2")

(test-equal "mk-class list of symbols removes duplication"
            (mk-class '(p-2 my-2 p-2 p-2 my-2)) "my-2 p-2")

(test-equal "mk-class false value returns empty class string"
            (mk-class #f) "")

(test-equal "render-if-nestring with valid string" "HELLO"
            (render-if-nestring string-upcase "hello"))
(test-equal "render-if-nestring with empty string"
            '()
            (render-if-nestring string-upcase ""))
(test-equal "render-if-nestring with #f"
            '()
            (render-if-nestring string-upcase #f))

(test-end)
