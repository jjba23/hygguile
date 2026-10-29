;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
                             #:expect #t))
         (test "passwords and one-time codes"
               (assert-equal #:name "password-field is a masked field"
                             #:got (has? (render (password-field #:label "P"
                                                                #:name "p"))
                                         "type=\"password\"")
                             #:expect #t)
               (assert-equal #:name "password-field offers a reveal control"
                             #:got (has? (render (password-field #:label "P"
                                                                #:name "p"))
                                         "hygguileTogglePassword")
                             #:expect #t)
               (assert-equal #:name "the reveal control points at its field"
                             #:got (has? (render (password-field #:label "P"
                                                                #:name "p"))
                                         "aria-controls=\"p\"")
                             #:expect #t)
               (assert-equal #:name "a password field can do without the reveal control"
                             #:got (has? (render (password-field #:label "P"
                                                                #:name "p"
                                                                #:reveal? #f))
                                         "hygguileTogglePassword")
                             #:expect #f)
               (assert-equal #:name "otp-field takes a one-time code"
                             #:got (has? (render (otp-field #:label "C"
                                                            #:name "c"))
                                         "one-time-code")
                             #:expect #t)
               (assert-equal #:name "otp-field caps the code at its length"
                             #:got (has? (render (otp-field #:label "C"
                                                            #:name "c"
                                                            #:length 4))
                                         "maxlength=\"4\"")
                             #:expect #t))
         (test "input groups and sliders"
               (assert-equal #:name "input-group renders its addon"
                             #:got (has? (render (input-group #:label "Price"
                                                              #:name "price"
                                                              #:prefix "€"))
                                         "hg-input-group-addon")
                             #:expect #t)
               (assert-equal #:name "input-group writes the addon beside the field"
                             #:got (has? (render (input-group #:label "Price"
                                                              #:name "price"
                                                              #:suffix "/ month"))
                                         "/ month")
                             #:expect #t)
               (assert-equal #:name "input-group keeps the addon out of the value"
                             #:got (has? (render (input-group #:label "Price"
                                                              #:name "price"
                                                              #:prefix "€"))
                                         "value=\"\"")
                             #:expect #t)
               (assert-equal #:name "slider is a range control"
                             #:got (has? (render (slider #:label "W"
                                                         #:name "w"))
                                         "type=\"range\"")
                             #:expect #t)
               (assert-equal #:name "slider prints the value it starts at"
                             #:got (has? (render (slider #:label "W"
                                                         #:name "w"
                                                         #:value 21
                                                         #:unit "°C"))
                                         ">21°C<")
                             #:expect #t)
               (assert-equal #:name "slider's output is bound to its field"
                             #:got (has? (render (slider #:label "W"
                                                         #:name "w"))
                                         "<output for=\"w\"")
                             #:expect #t))
         (test "the form's error summary"
               (assert-equal #:name "a form with no errors renders no summary"
                             #:got (validation-summary #:errors '())
                             #:expect '())
               (assert-equal #:name "a validation summary is announced"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter a valid email"))))
                                         "role=\"alert\"")
                             #:expect #t)
               (assert-equal #:name "a validation summary links to each field"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter a valid email"))))
                                         "href=\"#email\"")
                             #:expect #t)
               (assert-equal #:name "a validation summary lists every error"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter a valid email")
                                                            ("password" . "Enter your password"))))
                                         "Enter your password")
                             #:expect #t))))

(define (spec)
  (veritas-run field-suite)
  (veritas-run validation-suite))

(define validation-suite
  (suite "Form validation"
         (test "the three states a field can be in"
               (assert-equal #:name "an invalid field says so on its shell"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:error "Enter an email address."))
                                         "hg-field-invalid")
                             #:expect #t)
               (assert-equal #:name "a valid field says so on its shell"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:valid "Looks good."))
                                         "hg-field-valid")
                             #:expect #t)
               (assert-equal #:name "a field with no state wears neither class"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"))
                                         "hg-field-invalid")
                             #:expect #f)
               (assert-equal #:name "an error wins over a stale success"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:error "Enter an email address."
                                                            #:valid "Looks good."))
                                         "hg-field-valid")
                             #:expect #f))
         (test "what a message says"
               (assert-equal #:name "the error is named, not only described"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:error "Enter an email address."))
                                         "aria-errormessage=\"email-error\"")
                             #:expect #t)
               (assert-equal #:name "the error carries the message style"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:error "Enter an email address."))
                                         "hg-error-message")
                             #:expect #t)
               (assert-equal #:name "a success is announced politely"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:valid "Looks good."))
                                         "role=\"status\"")
                             #:expect #t)
               (assert-equal #:name "a success carries the success style"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:valid "Looks good."))
                                         "hg-success-message")
                             #:expect #t)
               (assert-equal #:name "a bare valid mark says nothing"
                             #:got (has? (render (text-field #:label "Email"
                                                            #:name "email"
                                                            #:valid #t))
                                         "role=\"status\"")
                             #:expect #f))
         (test "collecting the errors of a form"
               (assert-equal #:name "a passing check is not an error"
                             #:got (validation-errors (list (cons "email"
                                                                 (and #f
                                                                      "Enter an email address."))
                                                            (cons "name" #f)))
                             #:expect '())
               (assert-equal #:name "the errors keep the order they were checked in"
                             #:got (validation-errors (list (cons "email" "Enter an email address.")
                                                            (cons "name" "Enter your name.")))
                             #:expect '(("email" . "Enter an email address.")
                                        ("name" . "Enter your name.")))
               (assert-equal #:name "a form-wide problem has no field to point at"
                             #:got (validation-errors (list (cons #f "The form expired.")))
                             #:expect '((#f . "The form expired.")))
               (assert-equal #:name "a summary lists a form-wide problem without a link"
                             #:got (has? (render (validation-summary
                                                 #:errors '((#f . "The form expired."))))
                                         "href")
                             #:expect #f))
         (test "the summary a refused form shows"
               (assert-equal #:name "the summary is marked for the page's script"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter an email address."))))
                                         "data-hg-validation-summary")
                             #:expect #t)
               (assert-equal #:name "the summary does not take focus unless asked"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter an email address."))))
                                         "data-hg-focus-summary")
                             #:expect #f)
               (assert-equal #:name "the summary takes focus when the page asks"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter an email address."))
                                                 #:focus? #t))
                                         "data-hg-focus-summary")
                             #:expect #t)
               (assert-equal #:name "the summary's heading carries a mark"
                             #:got (has? (render (validation-summary
                                                 #:errors '(("email" . "Enter an email address."))))
                                         "hg-validation-summary-title")
                             #:expect #t))))
