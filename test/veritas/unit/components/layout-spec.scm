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

(define-module (veritas unit components layout-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components layout)
  #:use-module (hygguile components typography)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define layout-suite
  (suite "Layout"
         (test "layout primitives"
               (assert-equal #:name "stack renders a <div>"
                             #:got (caar (stack (list (p "a"))))
                             #:expect 'div)
               (assert-equal #:name "grid renders a <div>"
                             #:got (caar (grid (list (p "a"))))
                             #:expect 'div)
               (assert-equal #:name "split renders a <div>"
                             #:got (caar (split #:start (list (p "a"))
                                                #:end (list (p "b"))))
                             #:expect 'div)
               (assert-equal #:name "aspect-ratio writes its ratio"
                             #:got (and (string-contains (render (aspect-ratio
                                                                 (list (p "a"))
                                                                 #:ratio 'video))
                                                         "aspect-ratio: 16 / 9")
                                        #t)
                             #:expect #t))))

(define (spec)
  (veritas-run layout-suite))
