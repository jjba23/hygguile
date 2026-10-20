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

(define-module (veritas unit components field-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components field)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define control
  (lambda (w)
    `((input (@ ,@(field-control-attributes w))))))

(define field-suite
  (suite "Fields"
         (test "the form field abstraction"
               (assert-equal #:name "form-field renders a wrapper <div>"
                             #:got (caar (form-field #:label "Email"
                                                     #:name "email"
                                                     #:control control))
                             #:expect 'div)
               (assert-equal #:name "the label is bound to the control"
                             #:got (has? (render (form-field #:label "Email"
                                                            #:name "email"
                                                            #:control control))
                                         "for=\"email\"")
                             #:expect #t)
               (assert-equal #:name "helper copy is linked to the control"
                             #:got (has? (render (form-field #:label "Email"
                                                            #:name "email"
                                                            #:help-text "Hint"
                                                            #:control control))
                                         "aria-describedby=\"email-help\"")
                             #:expect #t)
               (assert-equal #:name "an error is announced"
                             #:got (has? (render (form-field #:label "Email"
                                                            #:name "email"
                                                            #:error "Required"
                                                            #:control control))
                                         "role=\"alert\"")
                             #:expect #t)
               (assert-equal #:name "a required field says so twice"
                             #:got (has? (render (form-field #:label "Email"
                                                            #:name "email"
                                                            #:required #t
                                                            #:control control))
                                         "aria-required=\"true\"")
                             #:expect #t)
               (assert-equal #:name "the wiring names the ids a control shares"
                             #:got (field-id (field-wiring #:name "email"))
                             #:expect "email"))
         (test "the missing inputs"
               (assert-equal #:name "search-field is a search landmark"
                             #:got (has? (render (search-field #:name "q"))
                                         "role=\"search\"")
                             #:expect #t)
               (assert-equal #:name "search-field uses a search input"
                             #:got (has? (render (search-field #:name "q"))
                                         "type=\"search\"")
                             #:expect #t)
               (assert-equal #:name "number-field uses a number input"
                             #:got (has? (render (number-field #:label "N"
                                                              #:name "n"))
                                         "type=\"number\"")
                             #:expect #t)
               (assert-equal #:name "stepper renders its buttons"
                             #:got (has? (render (stepper #:label "N"
                                                         #:name "n"))
                                         "hygguileStep")
                             #:expect #t)
               (assert-equal #:name "date-field uses a date input"
                             #:got (has? (render (date-field #:label "D"
                                                            #:name "d"))
                                         "type=\"date\"")
                             #:expect #t)
               (assert-equal #:name "date-range-field renders two dates"
                             #:got (has? (render (date-range-field #:label "Stay"
                                                                  #:name "stay"))
                                         "stay-end")
                             #:expect #t)
               (assert-equal #:name "file-field keeps the native file input"
                             #:got (has? (render (file-field #:label "F"
                                                            #:name "f"))
                                         "type=\"file\"")
                             #:expect #t)
               (assert-equal #:name "dropzone offers drag and drop"
                             #:got (has? (render (dropzone #:label "F"
                                                          #:name "f"))
                                         "data-hg-dropzone")
                             #:expect #t)
               (assert-equal #:name "combobox uses a datalist"
                             #:got (has? (render (combobox #:label "C"
                                                          #:name "c"
                                                          #:options '("amber")))
                                         "datalist")
                             #:expect #t)
               (assert-equal #:name "multi-select is a multiple select"
                             #:got (has? (render (multi-select #:label "M"
                                                              #:name "m"
                                                              #:options '(("a" . "A"))))
                                         "multiple")
                             #:expect #t)
               (assert-equal #:name "multi-select shows its selection as tags"
                             #:got (has? (render (multi-select #:label "M"
                                                              #:name "m"
                                                              #:options '(("a" . "A"))
                                                              #:selected '("a")))
                                         "hg-tag")
                             #:expect #t))))

(define (spec)
  (veritas-run field-suite))
