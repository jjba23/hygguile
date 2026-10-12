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

(define-module (veritas unit components input-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components input)
  #:export (spec))

(define (find-tag node tag)
  "Return the first direct child of a rendered field wrapper with @var{tag}."
  (find (lambda (child)
          (and (pair? child)
               (eq? tag
                    (car child))))
        (cddr (car node))))

(define (attr-value node name)
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (find-node node tag)
  "Return the first descendant element of @var{node} whose tag is @var{tag}."
  (cond
    ((and (pair? node)
          (symbol? (car node))
          (eq? tag
               (car node)))
     node)
    ((list? node)
     (any (lambda (child)
            (find-node child tag)) node))
    (else #f)))

(define input-suite
  (suite "Forms"
         (test "hygguile forms"
               (assert-equal #:name "input renders a labelled wrapper"
                             #:got (caar (input #:label "Email"
                                                #:name "email"))
                             #:expect 'div)
               (assert-equal #:name "input renders an <input> element"
                             #:got (car (find-tag (input #:label "Email"
                                                         #:name "email")
                                                  'input))
                             #:expect 'input)
               (assert-equal #:name "input forwards the autocomplete hint"
                             #:got (attr-value (find-tag (input #:label
                                                                "Email"
                                                                #:name "email"
                                                                #:autocomplete
                                                                "email")
                                                         'input)
                                               'autocomplete)
                             #:expect "email")
               (assert-equal #:name "input binds the label to the field id"
                             #:got (attr-value (find-tag (input #:label
                                                                "Email"
                                                                #:name "email")
                                                         'input)
                                               'id)
                             #:expect "email")
               (assert-equal #:name
                             "input marks required fields for assistive tech"
                             #:got (attr-value (find-tag (input #:label
                                                                "Email"
                                                                #:name "email"
                                                                #:required #t)
                                                         'input)
                                               'aria-required)
                             #:expect "true")
               (assert-equal #:name "textarea forwards the autocomplete hint"
                             #:got (attr-value (find-tag (textarea #:label
                                                                   "Bio"
                                                                   #:name
                                                                   "bio"
                                                                   #:autocomplete
                                                                   "off")
                                                         'textarea)
                                               'autocomplete)
                             #:expect "off")
               (assert-equal #:name "checkbox renders an <input>"
                             #:got (car (find-tag (checkbox #:label "Agree"
                                                            #:name "agree")
                                                  'input))
                             #:expect 'input)
               (assert-equal #:name "switch renders a styled checkbox"
                             #:got (car (find-tag (switch #:label "On"
                                                          #:name "on")
                                                  'input))
                             #:expect 'input)
               (assert-equal #:name
                "card-body-style wrapper for range renders a <div>"
                #:got (caar (range #:label "Volume"
                                   #:name "volume"))
                #:expect 'div)
               (assert-equal #:name "fieldset renders a <fieldset> element"
                             #:got (caar (fieldset '()))
                             #:expect 'fieldset)
               (assert-equal #:name "legend renders a <legend> element"
                             #:got (caar (legend "Address"))
                             #:expect 'legend)
               (assert-equal #:name "form renders a <form> element"
                             #:got (caar (form '()))
                             #:expect 'form)
               (assert-equal #:name "form posts its fields by default"
                             #:got (attr-value (car (form '()))
                                               'method)
                             #:expect "post")
               (assert-equal #:name "form forwards its action"
                             #:got (attr-value (car (form '()
                                                          #:action
                                                          "/subscribe"))
                                               'action)
                             #:expect "/subscribe")
               (assert-equal #:name "form supports a get method for searches"
                             #:got (attr-value (car (form '()
                                                          #:method 'get))
                                               'method)
                             #:expect "get")
               (assert-equal #:name "form renders an enctype for file uploads"
                             #:got (attr-value (car (form '()
                                                          #:enctype 'multipart/form-data))
                                               'enctype)
                             #:expect "multipart/form-data")
               (assert-equal #:name
                "form uses native validation unless told otherwise"
                #:got (attr-value (car (form '()))
                                  'novalidate)
                #:expect #f)
               (assert-equal #:name "form can switch off native validation"
                             #:got (attr-value (car (form '()
                                                          #:novalidate #t))
                                               'novalidate)
                             #:expect "")
               (assert-equal #:name "form carries its fields"
                             #:got (car (find-node (form (list (input #:label
                                                                      "Email"
                                                                      #:name
                                                                      "email")))
                                                   'input))
                             #:expect 'input)
               (assert-equal #:name "form appends a submit button when asked"
                             #:got (car (find-node (form '()
                                                         #:submit "Subscribe")
                                                   'button))
                             #:expect 'button)
               (assert-equal #:name "the appended submit button is labelled"
                             #:got (caddr (find-node (form '()
                                                           #:submit
                                                           "Subscribe")
                                                     'button))
                             #:expect "Subscribe"))))

(define (spec)
  (veritas-run input-suite))
