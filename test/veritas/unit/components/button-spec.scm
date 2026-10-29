;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components button-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components button)
  #:export (spec))

(define button-suite
  (suite "Buttons"
         (test "hygguile buttons"
               (assert-equal #:name
                             "danger-submit-button returns a valid button"
                             #:got (car (danger-submit-button "hygguile"))
                             #:expect 'button)

               (assert-equal #:name "submit-button returns a valid button"
                             #:got (car (submit-button "hygguile"))
                             #:expect 'button)

               (assert-equal #:name "icon-button returns a valid button"
                             #:got (car (icon-button #:icon 'lightbulb
                                                     #:content "hygguile"))
                             #:expect 'button)

               (assert-equal #:name "button returns a valid button"
                             #:got (car (button "hygguile"))
                             #:expect 'button))))

(define (spec)
  (veritas-run button-suite))
