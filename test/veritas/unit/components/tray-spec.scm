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

(define-module (veritas unit components tray-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components tray)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (count-tag node tag)
  "How many direct children of NODE are elements named TAG."
  (length (filter (lambda (child)
                    (and (pair? child)
                         (eq? tag
                              (car child))))
                  (cddr (car node)))))

(define (render node)
  "Serialize an SXML fragment to an HTML string, as a page would be served."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has-attribute? html text)
  "True when the rendered HTML carries TEXT."
  (and (string-contains html text) #t))

(define tray-suite
  (suite "Trays"
         (test "hygguile tray controls"
               (assert-equal #:name "sort-control renders a <div> group"
                             #:got (caar (sort-control #:target "cards"
                                                       #:modes '(("title" . "A to Z"))))
                             #:expect 'div)
               (assert-equal #:name "sort-control renders one button per mode"
                             #:got (count-tag (sort-control #:target "cards"
                                                            #:modes '(("page" . "Page order")
                                                                      ("title" . "A to Z")
                                                                      ("category-rank" . "By category")))
                                              'button)
                             #:expect 3)
               (assert-equal #:name "sort-control names the tray it orders"
                             #:got (has-attribute? (render (sort-control
                                                            #:target "cards"
                                                            #:modes '(("title" . "A to Z"))))
                                    "data-hg-sort-target=\"cards\"")
                             #:expect #t)
               (assert-equal #:name
                "every sort button calls the tray script with its mode"
                #:got (has-attribute? (render (sort-control #:target "cards"
                                                            #:modes '(("category-rank" . "By category"))))
                       "hygguileSortTray(this, 'category-rank')")
                #:expect #t)
               (assert-equal #:name "disclosure-controls renders a <div> pair"
                             #:got (caar (disclosure-controls))
                             #:expect 'div)
               (assert-equal #:name
                "disclosure-controls renders exactly two buttons"
                #:got (count-tag (disclosure-controls)
                                 'button)
                #:expect 2)
               (assert-equal #:name
                "disclosure-controls toggles the selector it was given"
                #:got (has-attribute? (render (disclosure-controls #:selector
                                               "details.hg-expandable-card"))
                       "hygguileToggleTray(true, 'details.hg-expandable-card')")
                #:expect #t))))

(define (spec)
  (veritas-run tray-suite))
