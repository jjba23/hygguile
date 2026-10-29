;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components feedback-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components feedback)
  #:export (spec))

(define feedback-suite
  (suite "Feedback"
         (test "hygguile feedback"
               (assert-equal #:name "alert renders a <div> element"
                             #:got (caar (alert #:title "T"
                                                #:body "B"))
                             #:expect 'div)
               (assert-equal #:name "progress renders a wrapper <div>"
                             #:got (caar (progress #:value 50))
                             #:expect 'div)
               (assert-equal #:name "progress renders a <progress> element"
                             #:got (car (caddr (car (progress #:value 50))))
                             #:expect 'progress)
               (assert-equal #:name "spinner renders a <span> element"
                             #:got (caar (spinner))
                             #:expect 'span)
               (assert-equal #:name
                             "skeleton renders one row per requested line"
                             #:got (length (cddr (car (skeleton #:lines 3))))
                             #:expect 3))))

(define (spec)
  (veritas-run feedback-suite))
