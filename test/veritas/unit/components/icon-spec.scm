;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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

