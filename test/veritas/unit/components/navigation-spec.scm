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

(define-module (veritas unit components navigation-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components navigation)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (count-tag node tag)
  (length (filter (lambda (child)
                    (and (pair? child)
                         (eq? tag
                              (car child))))
                  (cddr (car node)))))

(define (render node)
  "Serialize an SXML fragment to an HTML string, as a page would be served."
  (call-with-output-string (lambda (port) (sxml->xml node port))))

(define (active-link-classes html)
  "The class string of the pagination link marked aria-current in rendered HTML."
  (let ((m (string-match "aria-current=\"page\" class=\"([^\"]*)\"" html)))
    (and m (match:substring m 1))))

(define (has-class? classes name)
  "True when a space-separated class string contains exactly NAME."
  (and (member name (string-split classes #\space)) #t))

(define (count-colour-utilities classes prefix)
  "Count classes of the shape PREFIX-ramp-shade in a space-separated class string."
  (let ((pattern (format #f "^~a[a-z][a-z-]*-[0-9]{2,3}(/[0-9.]+)?$" prefix)))
    (length (filter (lambda (c) (string-match pattern c))
                    (string-split classes #\space)))))

(define navigation-suite
  (suite "Navigation"
         (test "hygguile navigation"
               (assert-equal #:name "navbar renders a <header> element"
                             #:got (caar (navbar '()))
                             #:expect 'header)
               (assert-equal #:name "nav-link renders an <a> element"
                             #:got (caar (nav-link "Home"
                                                   #:href "/"))
                             #:expect 'a)
               (assert-equal #:name "breadcrumbs renders a <nav> element"
                             #:got (caar (breadcrumbs #:items (list "Home")))
                             #:expect 'nav)
               (assert-equal #:name "pagination renders a <nav> element"
                             #:got (caar (pagination #:total 3))
                             #:expect 'nav)
               (assert-equal #:name
                             "tab describes a (id label content) triple"
                             #:got (car (tab #:id "a"
                                             #:label "A"
                                             #:content "body"))
                             #:expect "a")
               (assert-equal #:name
                             "the current pagination link carries one light-theme text colour"
                             #:got (count-colour-utilities
                                    (active-link-classes
                                     (render (pagination #:current 2
                                                         #:total 3)))
                                    "text-")
                             #:expect 1)
               (assert-equal #:name
                             "the current pagination link carries one dark-theme text colour"
                             #:got (count-colour-utilities
                                    (active-link-classes
                                     (render (pagination #:current 2
                                                         #:total 3)))
                                    "dark:text-")
                             #:expect 1)
               (assert-equal #:name
                             "the current pagination link keeps its border width"
                             #:got (has-class? (active-link-classes
                                                (render (pagination #:current 2
                                                                    #:total 3)))
                                               "border-2")
                             #:expect #t)
               (assert-equal #:name
                             "the base dark-theme ink does not leak into the current link"
                             #:got (has-class? (active-link-classes
                                                (render (pagination #:current 2
                                                                    #:total 3)))
                                               "dark:text-stone-300")
                             #:expect #f)
               (assert-equal #:name "tabs renders a <div> wrapper"
                             #:got (caar (tabs #:tab-items (list (tab #:id "a"
                                                                      #:label
                                                                      "A"
                                                                      #:content
                                                                      "A")
                                                                 (tab #:id "b"
                                                                      #:label
                                                                      "B"
                                                                      #:content
                                                                      "B"))))
                             #:expect 'div)
               (assert-equal #:name "tabs renders one radio input per tab"
                             #:got (count-tag (tabs #:tab-items (list (tab
                                                                       #:id
                                                                       "a"
                                                                       #:label
                                                                       "A"
                                                                       #:content
                                                                       "A")
                                                                      (tab
                                                                       #:id
                                                                       "b"
                                                                       #:label
                                                                       "B"
                                                                       #:content
                                                                       "B")))
                                              'input)
                             #:expect 2))))

(define (spec)
  (veritas-run navigation-suite))
