;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
(icon #:type 'heart #:weight 'bold #:icon-css '(text-redwood-500 text-2xl))
@end example"
  (let* ((weight-class (cond
                         ((eq? 'bold weight)
                          'ph-bold)
                         ((eq? 'light weight)
                          'ph-light)
                         (else 'ph)))
         (icon-class (string->symbol (format #f "ph-~a" type))))
    `(i (@ (class ,(mk-class (append (list weight-class icon-class) icon-css
                                     '(select-none shrink-0))))) "")))
