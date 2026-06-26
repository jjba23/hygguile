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

(define-module (hygguile components icon)
  #:use-module (hygguile abstraction)
  #:export (icon))

(define* (icon #:key type
               (weight 'regular)
               (icon-css '(text-xl)))
  "Construct an inline HTML icon element using Phosphor formatting.

@table @var
@item type
A symbol designating the core identifier name of the Phosphor icon asset (e.g., @code{'star}, @code{'gear}).
@item weight
A configuration symbol defining line weight thickness variants. Accepts @code{'bold}, @code{'light}, or defaults to @code{'regular}.
@item icon-css
List of symbols representing additional layout formatting rules or sizing CSS classes.
@end table

@example
(icon #:type 'heart #:weight 'bold #:icon-css '(text-red-500 text-2xl))
@end example"
  (let* ((weight-class (cond
                         ((eq? 'bold weight)
                          'ph-bold)
                         ((eq? 'light weight)
                          'ph-light)
                         (else 'ph)))
         (icon-class (string->symbol (format #f "ph-~a" type))))
    `(i (@ (class ,(mk-class (append (list weight-class icon-class) icon-css))))
        "")))
