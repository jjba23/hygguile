;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components input-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components input)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

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
               (assert-equal #:name
                             "a textarea counts what it holds when asked"
                             #:got (car (find-tag (textarea #:label "Bio"
                                                            #:name "bio"
                                                            #:value "hygge"
                                                            #:maxlength 40
                                                            #:counter #t)
                                                  'p))
                             #:expect 'p)
               (assert-equal #:name "the count is the text's own length"
                             #:got (caddr (caddr (find-tag (textarea #:label
                                                                     "Bio"
                                                                     #:name
                                                                     "bio"
                                                                     #:value
                                                                     "hygge"
                                                                     #:maxlength
                                                                     40
                                                                     #:counter
                                                                     #t)
                                                           'p)))
                             #:expect "5")
               (assert-equal #:name "a textarea without a counter stays plain"
                             #:got (find-tag (textarea #:label "Bio"
                                                       #:name "bio"
                                                       #:maxlength 40)
                                             'p)
                             #:expect #f)
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

(define validation-suite
  (suite "A form that validates itself"
         (test "the form asks for the page's own validation"
               (assert-equal #:name "a validating form is marked for the script"
                             #:got (has? (render (form '()
                                                       #:validate? #t))
                                         "data-hg-validate")
                             #:expect #t)
               (assert-equal #:name "a validating form turns off the browser bubble"
                             #:got (has? (render (form '()
                                                       #:validate? #t))
                                         "novalidate")
                             #:expect #t)
               (assert-equal #:name "a plain form asks for nothing"
                             #:got (has? (render (form '()))
                                         "data-hg-validate")
                             #:expect #f))))

(define (spec)
  (veritas-run input-suite)
  (veritas-run validation-suite))
