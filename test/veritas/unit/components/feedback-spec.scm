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
