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

(define-module (hygguile udtryk dsl)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:export (~ css css* display-css))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define* (css* #:key (selector ".")
               class
               properties
               (direct-size? #f)
               multiplier
               (unit "rem")
               sizes)
  (map (lambda (s)
         (~ "~a~a-~a { ~a }" selector class
            (if direct-size? s
                (car s))
            (string-join (map (lambda (p)
                                (~ "~a: ~,2f~a;" p
                                   (* multiplier
                                      (if direct-size? s
                                          (cadr s))) unit)) properties) " ")))
       sizes))

(define* (css #:key class properties
              (selector "."))
  (~ "~a~a { ~a }" selector class
     (string-join (map (lambda (p)
                         (~ "~a: ~a;"
                            (car p)
                            (cadr p))) properties) " ")))

(define* (display-css xs)
  (cond
    ((string? xs)
     (display xs)
     (display " "))
    ((list? xs)
     (for-each display-css xs))
    (else (display xs))))
