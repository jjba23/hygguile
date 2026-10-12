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

(define-module (veritas unit components disclosure-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components disclosure)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  "Serialize an SXML fragment to an HTML string, as a page would be served."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (attr-value node name)
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define disclosure-suite
  (suite "Disclosure"
         (test "hygguile disclosure"
               (assert-equal #:name "summary renders a <summary> element"
                             #:got (caar (summary "Title"))
                             #:expect 'summary)
               (assert-equal #:name "details renders a <details> element"
                             #:got (caar (details '()
                                                  #:summary "Title"))
                             #:expect 'details)
               (assert-equal #:name
                             "accordion-item renders a <details> element"
                             #:got (caar (accordion-item #:summary "Q"
                                                         #:content "A"))
                             #:expect 'details)
               (assert-equal #:name "accordion renders a <div> wrapper"
                             #:got (caar (accordion #:items '()))
                             #:expect 'div)
               (assert-equal #:name "modal renders a dialog with role=dialog"
                             #:got (attr-value (modal #:id "m"
                                                      #:title "T"
                                                      #:content "C")
                                               'role)
                             #:expect 'dialog)
               (assert-equal #:name
                             "tooltip renders a <span> with tooltip data"
                             #:got (attr-value (tooltip "Hover"
                                                        #:text "Hint")
                                               'data-hg-tooltip)
                             #:expect "Hint")
               (assert-equal #:name
                             "tooltip describes itself to assistive technology"
                             #:got (attr-value (tooltip "Hover"
                                                        #:text "Hint"
                                                        #:id "t")
                                               'aria-describedby)
                             #:expect "t")
               (assert-equal #:name
                             "the description is a real text node, hidden from sight"
                             #:got (let* ((node (car (tooltip "Hover"
                                                            #:text "Hint"
                                                            #:id "t")))
                                          (hidden (car (cddr node))))
                                     (list (car hidden)
                                           (attr-value hidden
                                                       'id)
                                           (attr-value hidden
                                                       'class)
                                           (caddr hidden)))
                             #:expect (list 'span
                                            "t"
                                            "sr-only"
                                            "Hint"))
               (assert-equal #:name
                             "and the expansion is not drawn a second time on hover"
                             #:got (attr-value (tooltip "Hover"
                                                        #:text "Hint")
                                               'title)
                             #:expect #f))))

(define (spec)
  (veritas-run disclosure-suite))
