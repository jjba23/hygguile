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

(define-module (veritas unit components card-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components card)
  #:export (spec))

(define card-suite
  (suite "Cards"
         (test "hygguile cards"
               (assert-equal #:name "card renders a <div> element"
                             #:got (caar (card '()))
                             #:expect 'div)
               (assert-equal #:name "card-header renders a <header> element"
                             #:got (caar (card-header "Title"))
                             #:expect 'header)
               (assert-equal #:name "card-body renders a <div> element"
                             #:got (caar (card-body "Body"))
                             #:expect 'div)
               (assert-equal #:name "card-footer renders a <footer> element"
                             #:got (caar (card-footer "Footer"))
                             #:expect 'footer)
               (assert-equal #:name "card-title renders an <h3> element"
                             #:got (caar (card-title "Title"))
                             #:expect 'h3)
               (assert-equal #:name "card-description renders a <p> element"
                             #:got (caar (card-description "Text"))
                             #:expect 'p)
               (assert-equal #:name "badge renders a <span> element"
                             #:got (caar (badge "New"))
                             #:expect 'span)
               (assert-equal #:name "stat-card renders a <div> element"
                             #:got (caar (stat-card #:value "1"
                                                    #:label "One"))
                             #:expect 'div))))

(define (spec)
  (veritas-run card-suite))
