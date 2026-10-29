;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components field)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (field-wiring
            field-id
            field-help-id
            field-error-id
            field-described-by
            field-control-attributes
            form-field
            text-field
            search-field
            password-field
            number-field
            stepper
            slider
            date-field
            time-field
            date-range-field
            file-field
            dropzone
            combobox
            multi-select
            otp-field
            input-group
            validation-errors
            validation-summary))

;; ===== The form field abstraction =====
;;
;; Every control on a form asks its page the same four questions: what is
;; this called, how is it described, is it wrong, and is it required. Answer
;; them per control and the answers drift: the label forgets its `for', the
;; error is painted but never announced, the help text exists but no screen
;; reader is told about it, and one of the twenty fields ends up without an
;; `id' at all.
;;
;; `form-field' answers them once. It renders the shell -- the label bound to
;; the control, the required marker (visual and spoken), the hint, the error
;; -- and hands the control a *wiring*: the ids and attributes the control
;; needs. A control is therefore a procedure of the wiring, which is why the
;; same shell serves a native input, a select, a file dropzone and anything
;; a page builds itself:
;;
;;   (form-field #:label "Email" #:name "email" #:required #t
;;               #:help-text "We never share it."
;;               #:control
;;               (lambda (w)
;;                 `((input (@ ,@(field-control-attributes w)
;;                             (type "email"))))))
;;
;; The wiring is data, not magic: `field-id', `field-described-by' and the
;; rest are ordinary accessors, so a control that has to do something
;; unusual can read the same ids and stay in step. Nothing here writes a
;; label twice or guesses at a control's markup.

(define control-classes
  '(p-3
    w-full
    rounded-xl
    border-2
    border-stone-700
    dark:border-onyx-100
    bg-stone-300/75
    dark:bg-onyx-700/75
    text-onyx-500
    dark:text-stone-300
    font-sans
    text-md
    shadow-sm
    transition-colors
    duration-150
    focus-visible:outline-2
    focus-visible:outline-offset-2
    outline-onyx-500))

(define label-classes
  '(text-lg font-light text-onyx-100 dark:text-stone-300 font-sans))

(define helper-classes
  '(text-sm font-light text-onyx-300 dark:text-stone-500))

(define error-classes
  '(text-sm font-medium text-redwood-700 dark:text-light-coral-100))

(define valid-classes
  '(text-sm font-medium text-asparagus-900 dark:text-asparagus-300))

(define* (field-wiring #:key name
                       (id #f)
                       (help-text #f)
                       (error #f)
                       (required #f))
  "Return the identifiers and attributes one control shares with its field shell.

The wiring is an association list rather than an opaque object, so it can be
inspected, logged and passed between procedures. Read it through the
accessors below, or hand it to @code{field-control-attributes} to get the
attribute pairs a control should carry.

When @var{name} and @var{id} are both absent, a unique id is generated, so a
field can be rendered without a form name (a filters bar, say) and still
have a label bound to it.

@table @var
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item help-text
Optional helper copy, which gets an id and joins the description.
@item error
Optional error message, which gets an id and joins the description.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item required
Whether the control is required.
@end table

@example
(field-wiring #:name \"email\" #:help-text \"We never share it.\")
@end example"
  (let* ((field-id (or id name
                       (symbol->string (gensym "hg-field"))))
         (help-id (format #f "~a-help" field-id))
         (error-id (format #f "~a-error" field-id))
         (described-by (cond
                         ((and help-text error)
                          (format #f "~a ~a" help-id error-id))
                         (error error-id)
                         (help-text help-id)
                         (else #f))))
    (list (cons 'id field-id)
          (cons 'name name)
          (cons 'help-id help-id)
          (cons 'error-id error-id)
          (cons 'described-by described-by)
          (cons 'required (and required #t))
          (cons 'invalid (and error #t)))))

(define (field-id wiring)
  "Return the identifier the control and its label share."
  (assq-ref wiring 'id))

(define (field-help-id wiring)
  "Return the identifier of the field's helper copy."
  (assq-ref wiring 'help-id))

(define (field-error-id wiring)
  "Return the identifier of the field's error message."
  (assq-ref wiring 'error-id))

(define (field-described-by wiring)
  "Return the @code{aria-describedby} value for the control, or @code{#f}."
  (assq-ref wiring 'described-by))

(define (field-control-attributes wiring)
  "Return the attribute pairs a control should carry for @var{wiring}.

Splice them into the control's attribute list:

@example
`((input (@@ ,@@(field-control-attributes wiring)
            (type \"email\"))))
@end example

The result carries the shared @code{id}, the @code{name}, the description
and error links, @code{required} and @code{aria-invalid} when they apply,
and nothing else -- a control's own type, value and classes are its own.

An invalid control carries both @code{aria-invalid} and
@code{aria-errormessage}, pointing at the message itself. The two say
different things -- that the control is wrong, and which words say why --
and a reader that understands only the first still gets the message through
the description link, because the error is part of it."
  (let ((id (field-id wiring))
        (name (assq-ref wiring 'name))
        (described-by (field-described-by wiring))
        (required (assq-ref wiring 'required))
        (invalid (assq-ref wiring 'invalid)))
    (append (list (cons 'id id))
            (if name
                (list (cons 'name name))
                '())
            (if described-by
                (list (cons 'aria-describedby described-by))
                '())
            (if invalid
                (list (cons 'aria-invalid "true")
                      (cons 'aria-errormessage (field-error-id wiring)))
                '())
            (if required
                (list (cons 'required "")
                      (cons 'aria-required "true"))
                '()))))

(define* (form-field #:key label
                     name
                     (id #f)
                     (help-text #f)
                     (error #f)
                     (valid #f)
                     (required #f)
                     (label-hidden? #f)
                     control
                     (classes '(my-2 flex flex-col gap-1 w-full))
                     (label-css label-classes)
                     (help-classes helper-classes)
                     (error-css error-classes)
                     (valid-css valid-classes))
  "Render one labelled, described, validated field shell around a control.

The shell owns the things every field needs and every hand-written field
eventually gets wrong: the label is bound to the control's id, the helper
copy and the error are linked through @code{aria-describedby}, the error is
announced with @code{role=\"alert\"} and named by @code{aria-errormessage},
and the required state is both visible (a marker) and spoken (a visually
hidden word plus @code{aria-required} on the control).

The shell also states which of the three states the field is in, as a class
on the wrapper -- @code{hg-field-invalid}, @code{hg-field-valid}, or
neither. The classes are what the stylesheet colours the control's border
with, so a page never has to pick a border colour per state, and a field
that is invalid looks invalid wherever it sits on the page.

@var{control} is a procedure of one argument, the wiring, and returns the
control's SXML -- a node or a list of nodes. A control that renders more
than one element (a select and its tags, an input and a dropzone) returns
them all and the shell places them in order.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item help-text
Optional helper copy, rendered below the control.
@item error
Optional error message, rendered above the help text and announced. It
wins over @var{valid} when both are given.
@item valid
@code{#t} to mark the field as filled in correctly, or a string to say so
in words as well. Rendered below the control with @code{role=\"status\"}.
@item required
Whether the field is required. Renders a visible marker and a spoken one.
@item label-hidden?
Render the label visually hidden but still available as the control's name.
@item control
A procedure of one argument (the wiring) returning the control's nodes.
@item classes
Classes for the field's wrapper.
@item label-css
Classes for the label.
@item help-classes
Classes for the helper copy.
@item error-css
Classes for the error message.
@item valid-css
Classes for the success message.
@end table

@example
(form-field #:label \"Email\"
            #:name \"email\"
            #:required #t
            #:help-text \"We never share it.\"
            #:control
            (lambda (w)
              `((input (@@ ,@@(field-control-attributes w)
                          (type \"email\")
                          (class ,(mk-class '(p-3 rounded-xl))))))))

(form-field #:label \"Email\"
            #:name \"email\"
            #:error \"Enter an email address.\"
            #:control ...)
@end example"
  (let* ((wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (control-id (field-id wiring))
         (help-id (field-help-id wiring))
         (error-id (field-error-id wiring))
         (valid-id (format #f "~a-valid" control-id))
         (state-classes (cond
                          (error '(hg-field-invalid))
                          (valid '(hg-field-valid))
                          (else '())))
         (success (and valid
                       (not error)
                       (if (string? valid) valid #f)))
         (nodes (let ((rendered (control wiring)))
                  (if (and (list? rendered)
                           (pair? rendered)
                           (not (symbol? (car rendered))))
                      rendered
                      (list rendered)))))
    `((div (@ (class ,(mk-class (append classes
                                        (cons 'hg-field state-classes)))))
           (label (@ (for ,control-id)
                     (class ,(mk-class (append label-css
                                               (if label-hidden?
                                                   '(sr-only)
                                                   '())))))
                  ,label
                  ,@(if required
                        (list `(span (@ (aria-hidden "true")
                                        (class ,(mk-class '(text-redwood-700
                                                            dark:text-light-coral-100))))
                                     " *")
                              `(span (@ (class "sr-only"))
                                     " (required)"))
                        '()))
           ,@nodes
           ,@(if error
                 `((p (@ (id ,error-id)
                         (role alert)
                         (class ,(mk-class (append error-css
                                                   '(hg-error-message)))))
                      ,error))
                 '())
           ,@(if success
                 `((p (@ (id ,valid-id)
                         (role status)
                         (class ,(mk-class (append valid-css
                                                   '(hg-success-message)))))
                      ,success))
                 '())
           ,@(if help-text
                 `((p (@ (id ,help-id)
                         (class ,(mk-class help-classes)))
                      ,help-text))
                 '())))))

;; ===== Text and search =====

(define* (text-field #:key label
                     name
                     (id #f)
                     (value "")
                     (placeholder "")
                     (type 'text)
                     (required #f)
                     (autocomplete #f)
                     (input-mode #f)
                     (pattern #f)
                     (help-text #f)
                     (error #f)
                     (valid #f)
                     (disabled #f)
                     (readonly #f)
                     (classes '(my-2 flex flex-col gap-1 w-full))
                     (input-css control-classes))
  "Render a single-line text field through the field shell.

`input' is still the right component when a page does not need the shell's
wiring (an inline search box, a bare numeric filter); this one is for a
form, where the label, the hint, the error and the required state have to
agree with every other field beside it.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value.
@item placeholder
A hint shown while the field is empty.
@item type
The native input type. Defaults to @code{'text}.
@item required
Whether the field is required.
@item autocomplete
An optional @code{autocomplete} hint.
@item input-mode
An optional virtual-keyboard hint.
@item pattern
An optional validation pattern.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item readonly
Whether the control is read-only.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the input itself.
@end table

@example
(text-field #:label \"Email\" #:name \"email\" #:type 'email #:required #t)
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                `((input (@ ,@(field-control-attributes w)
                            (type ,(symbol->string type))
                            ,@(attr-when value
                                         'value value)
                            ,@(attr-when placeholder
                                         'placeholder placeholder)
                            ,@(attr-when autocomplete
                                         'autocomplete autocomplete)
                            ,@(attr-when input-mode
                                         'inputmode input-mode)
                            ,@(attr-when pattern
                                         'pattern pattern)
                            ,@(if disabled
                                  '((disabled ""))
                                  '())
                            ,@(if readonly
                                  '((readonly ""))
                                  '())
                            (class ,(mk-class input-css))))))))

(define* (search-field #:key (label "Search")
                       name
                       (id #f)
                       (value "")
                       (placeholder "Search…")
                       (action #f)
                       (method 'get)
                       (submit-label "Search")
                       (help-text #f)
                       (error #f)
                       (valid #f)
                       (required #f)
                       (label-hidden? #t)
                       (classes '(hg-search my-2 w-full max-w-prose)))
  "Render a search control as a real search landmark.

The form carries @code{role=\"search\"}, so assistive technology can jump
straight to it, and the field is a native @code{<input type=\"search\">}:
pressing Enter submits, the browser offers its own clear control, and
nothing depends on a script. The submit button is a real submit button, so
the form still works when it is the only way to send the query.

@table @var
@item label
The field's name. Defaults to @code{\"Search\"}.
@item name
The query parameter name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The current query, so a results page shows what was searched for.
@item placeholder
A hint shown while the field is empty.
@item action
The URL the search posts to.
@item method
@code{'get} (the default) or @code{'post}.
@item submit-label
The submit button's label, or @code{#f} for a field that submits on Enter
only.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item required
Whether a query is required.
@item label-hidden?
Hide the label visually while keeping it as the field's name. Defaults to
true, which is what a compact search bar wants.
@item classes
Classes for the search form.
@end table

@example
(search-field #:name \"q\" #:action \"/search\" #:value \"cozy\")
@end example"
  (let* ((wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (control-id (field-id wiring))
         (help-id (field-help-id wiring))
         (error-id (field-error-id wiring))
         (valid-id (format #f "~a-valid" control-id))
         (state-classes (cond
                          (error '(hg-field-invalid))
                          (valid '(hg-field-valid))
                          (else '())))
         (success (and valid
                       (not error)
                       (if (string? valid) valid #f))))
    `((form (@ ,@(attr-when action
                            'action action)
               (method ,(if (symbol? method)
                            (symbol->string method) method))
               (role "search")
               (class ,(mk-class classes)))
             (div (@ (class ,(mk-class '(flex flex-row items-stretch gap-2
                                               w-full))))
                  (div (@ (class ,(mk-class (append '(hg-field flex flex-col
                                                                gap-1 flex-1)
                                                    state-classes))))
                       (label (@ (for ,control-id)
                                 (class ,(mk-class (append label-classes
                                                           (if label-hidden?
                                                               '(sr-only)
                                                               '())))))
                              ,label
                              ,@(if required
                                    (list `(span (@ (aria-hidden "true")
                                                    (class ,(mk-class '(text-redwood-700
                                                                        dark:text-light-coral-100))))
                                                 " *"))
                                    '()))
                       (input (@ ,@(field-control-attributes wiring)
                                 (type "search")
                                 (value ,value)
                                 (placeholder ,placeholder)
                                 (aria-label ,label)
                                 (autocomplete "off")
                                 (enterkeyhint "search")
                                 (class ,(mk-class control-classes))))
                       ,@(if error
                             `((p (@ (id ,error-id)
                                     (role alert)
                                     (class ,(mk-class (append error-classes
                                                               '(hg-error-message)))))
                                  ,error))
                             '())
                       ,@(if success
                             `((p (@ (id ,valid-id)
                                     (role status)
                                     (class ,(mk-class (append valid-classes
                                                               '(hg-success-message)))))
                                  ,success))
                             '())
                       ,@(if help-text
                             `((p (@ (id ,help-id)
                                     (class ,(mk-class helper-classes)))
                                  ,help-text))
                             '()))
                  ,@(if submit-label
                        (list (search-submit-button submit-label))
                        '()))))))

;; `search-field' is the one place a submit button is part of a field rather
;; than of the page, so it builds the smallest button it can without dragging
;; the button component's whole option set into this module. The markup is
;; the same button the rest of the framework renders.
(define (search-submit-button label)
  `(button (@ (type "submit")
              (class ,(mk-class '(shrink-0
                                  px-4
                                  py-3
                                  rounded-xl
                                  border-2
                                  border-stone-700
                                  dark:border-onyx-100
                                  bg-onyx-500
                                  text-stone-100
                                  dark:bg-stone-100
                                  dark:text-onyx-900
                                  text-md
                                  font-medium
                                  font-sans
                                  cursor-pointer
                                  transition-colors
                                  duration-150
                                  focus-visible:outline-2
                                  focus-visible:outline-offset-2
                                  outline-onyx-500))))
           ,label))

;; ===== Numbers =====

(define* (number-field #:key label
                       name
                       (id #f)
                       (value #f)
                       (min #f)
                       (max #f)
                       (step #f)
                       (unit #f)
                       (placeholder #f)
                       (required #f)
                       (help-text #f)
                       (error #f)
                       (valid #f)
                       (disabled #f)
                       (stepper? #f)
                       (classes '(my-2 flex flex-col gap-1 w-full))
                       (input-css control-classes))
  "Render a numeric field with an optional unit and optional stepper buttons.

The control is a native @code{<input type=\"number\">}: the browser's own
spinner, number keyboard on touch, and native validation all come for free.
With @var{stepper?} the field also gets a pair of buttons that step the value
by one @var{step}; those are a progressive enhancement (they carry
@code{js-only}), so with scripting off the native input is still the whole
control rather than a broken one.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value.
@item min
The lowest accepted value.
@item max
The highest accepted value.
@item step
The increment between accepted values.
@item unit
An optional unit shown beside the field, e.g. @code{\"kg\"}.
@item placeholder
A hint shown while the field is empty.
@item required
Whether the field is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item stepper?
Add the decrement/increment buttons. Defaults to false.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the input itself.
@end table

@example
(number-field #:label \"Seats\" #:name \"seats\" #:min 1 #:max 12 #:stepper? #t)
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (let* ((input-classes (append input-css
                                              (if stepper?
                                                  '(max-w-32)
                                                  '())))
                       (input `(input (@ ,@(field-control-attributes w)
                                         (type "number")
                                         (inputmode "numeric")
                                         ,@(attr-when value
                                                      'value value)
                                         ,@(attr-when placeholder
                                                      'placeholder placeholder)
                                         ,@(attr-when (not (equal? #f min))
                                                      'min min)
                                         ,@(attr-when (not (equal? #f max))
                                                      'max max)
                                         ,@(attr-when (not (equal? #f step))
                                                      'step step)
                                         ,@(if disabled
                                               '((disabled ""))
                                               '())
                                         (class ,(mk-class input-classes)))))
                       (unit-mark `(span (@ (aria-hidden "true")
                                            (class ,(mk-class '(text-sm
                                                                font-light
                                                                text-onyx-300
                                                                dark:text-stone-500))))
                                         ,unit))
                       (input-with-unit (if unit
                                            `((div (@ (class ,(mk-class '(flex
                                                                          flex-row
                                                                          items-center
                                                                          gap-2))))
                                                   ,input
                                                   ,unit-mark))
                                            (list input))))
                  (if stepper?
                      (list `(div (@ (class "hg-stepper"))
                                  (button (@ (type "button")
                                             (class "hg-stepper-button js-only")
                                             (aria-label "Decrease")
                                             (onclick "hygguileStep(this, -1)"))
                                          "−")
                                  ,@input-with-unit
                                  (button (@ (type "button")
                                             (class "hg-stepper-button js-only")
                                             (aria-label "Increase")
                                             (onclick "hygguileStep(this, 1)"))
                                          "+")))
                      input-with-unit)))))

(define* (stepper #:key label
                  name
                  (id #f)
                  (value #f)
                  (min #f)
                  (max #f)
                  (step 1)
                  (unit #f)
                  (help-text #f)
                  (error #f)
                  (valid #f)
                  (required #f)
                  (disabled #f)
                  (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a numeric field with the decrement/increment buttons already on.

This is @code{number-field} with @code{#:stepper? #t}, named for the thing a
page asks for. The buttons are an enhancement over the native input, so the
control keeps working with scripting off.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value.
@item min
The lowest accepted value.
@item max
The highest accepted value.
@item step
The increment. Defaults to @code{1}.
@item unit
An optional unit shown beside the field.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item required
Whether the field is required.
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@end table

@example
(stepper #:label \"Quantity\" #:name \"qty\" #:value 1 #:min 1 #:max 9)
@end example"
  (number-field #:label label
                #:name name
                #:id id
                #:value value
                #:min min
                #:max max
                #:step step
                #:unit unit
                #:help-text help-text
                #:error error
                #:valid valid
                #:required required
                #:disabled disabled
                #:stepper? #t
                #:classes classes))

;; ===== Dates and times =====

(define* (date-field #:key label
                     name
                     (id #f)
                     (value #f)
                     (min #f)
                     (max #f)
                     (required #f)
                     (help-text #f)
                     (error #f)
                     (valid #f)
                     (disabled #f)
                     (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a date field backed by the browser's own date control.

The value travels in ISO form (@code{2026-10-11}), which is the only form a
@code{<input type=\"date\">} accepts and the only form a server should have
to parse. The browser draws a calendar in the reader's own locale, so the
page never has to ship a date-picker script or guess at a format.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value, in ISO form.
@item min
The earliest accepted date, in ISO form.
@item max
The latest accepted date, in ISO form.
@item required
Whether the field is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@end table

@example
(date-field #:label \"Starts\" #:name \"start\" #:value \"2026-10-11\")
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                `((input (@ ,@(field-control-attributes w)
                            (type "date")
                            ,@(attr-when value
                                         'value value)
                            ,@(attr-when min
                                         'min min)
                            ,@(attr-when max
                                         'max max)
                            ,@(if disabled
                                  '((disabled ""))
                                  '())
                            (class ,(mk-class control-classes))))))))

(define* (time-field #:key label
                     name
                     (id #f)
                     (value #f)
                     (min #f)
                     (max #f)
                     (step #f)
                     (required #f)
                     (help-text #f)
                     (error #f)
                     (valid #f)
                     (disabled #f)
                     (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a time field backed by the browser's own time control.

The value is the ISO time form (@code{09:30}, or @code{09:30:00} with
seconds), and the browser draws it in the reader's locale. @var{step} is in
seconds, which is how a time input says whether it wants minutes or seconds.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value, in ISO time form.
@item min
The earliest accepted time.
@item max
The latest accepted time.
@item step
The increment between accepted times, in seconds.
@item required
Whether the field is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@end table

@example
(time-field #:label \"Starts at\" #:name \"starts-at\" #:step 900)
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                `((input (@ ,@(field-control-attributes w)
                            (type "time")
                            ,@(attr-when value
                                         'value value)
                            ,@(attr-when min
                                         'min min)
                            ,@(attr-when max
                                         'max max)
                            ,@(attr-when step
                                         'step step)
                            ,@(if disabled
                                  '((disabled ""))
                                  '())
                            (class ,(mk-class control-classes))))))))

(define* (date-range-field #:key label
                           name
                           (start #f)
                           (end #f)
                           (start-label "From")
                           (end-label "To")
                           (min #f)
                           (max #f)
                           (required #f)
                           (help-text #f)
                           (error #f)
                           (valid #f)
                           (disabled #f)
                           (classes '(my-2 flex flex-col gap-2 w-full)))
  "Render a from/to date pair as one field.

The pair is a @code{<fieldset>} with a @code{<legend>}, because that is what
a group of related controls is, and each half keeps its own label and its own
id. The names are derived from @var{name}, so a server reads
@code{start=...&end=...} without the page inventing a second convention.

Both halves are native date inputs, which means the range is usable with
scripting off -- a page that wants the second date to follow the first can
add that behaviour on top, but it is not required for the field to work.

@table @var
@item label
The group's legend, e.g. @code{\"Stay\"}.
@item name
The shared name; the halves become @code{<name>-start} and @code{<name>-end}.
@item start
The initial start date, in ISO form.
@item end
The initial end date, in ISO form.
@item start-label
The first half's label. Defaults to @code{\"From\"}.
@item end-label
The second half's label. Defaults to @code{\"To\"}.
@item min
The earliest accepted date for both halves.
@item max
The latest accepted date for both halves.
@item required
Whether both halves are required.
@item help-text
Optional helper copy for the group.
@item error
Optional error message for the group.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether both halves are disabled.
@item classes
Classes for the fieldset.
@end table

@example
(date-range-field #:label \"Stay\" #:name \"stay\"
                  #:start \"2026-10-11\" #:end \"2026-10-14\")
@end example"
  (let* ((base (or name "range"))
         (help-id (format #f "~a-help" base))
         (error-id (format #f "~a-error" base))
         (valid-id (format #f "~a-valid" base))
         (state-classes (cond
                          (error '(hg-field-invalid))
                          (valid '(hg-field-valid))
                          (else '())))
         (success (and valid
                       (not error)
                       (if (string? valid) valid #f))))
    `((fieldset (@ (class ,(mk-class (append classes
                                              (cons 'hg-field
                                                    (cons 'm-0
                                                          (append state-classes
                                                                  '(border-0
                                                                    p-0)))))))
                   ,@(if error
                         `((aria-invalid "true")
                           (aria-describedby ,(if help-text
                                                  (format #f "~a ~a" help-id
                                                          error-id)
                                                  error-id)))
                         (if help-text
                             `((aria-describedby ,help-id))
                             '())))
                  (legend (@ (class ,(mk-class (append label-classes '(pb-1 mb-2)))))
                          ,label
                          ,@(if required
                                (list `(span (@ (aria-hidden "true")
                                                (class ,(mk-class '(text-redwood-700
                                                                    dark:text-light-coral-100))))
                                             " *"))
                                '()))
                  (div (@ (class ,(mk-class '(grid grid-cols-1
                                                    sm:grid-cols-2 gap-4
                                                    mt-2))))
                       ,(date-field #:label start-label
                                    #:name (format #f "~a-start" base)
                                    #:value start
                                    #:min min
                                    #:max max
                                    #:required required
                                    #:disabled disabled
                                    #:classes '(m-0 flex flex-col gap-1 w-full))
                       ,(date-field #:label end-label
                                    #:name (format #f "~a-end" base)
                                    #:value end
                                    #:min min
                                    #:max max
                                    #:required required
                                    #:disabled disabled
                                    #:classes '(m-0 flex flex-col gap-1 w-full)))
                  ,@(if error
                        `((p (@ (id ,error-id)
                                (role alert)
                                (class ,(mk-class (append error-classes
                                                          '(hg-error-message)))))
                             ,error))
                        '())
                  ,@(if success
                        `((p (@ (id ,valid-id)
                                (role status)
                                (class ,(mk-class (append valid-classes
                                                          '(hg-success-message)))))
                             ,success))
                        '())
                  ,@(if help-text
                        `((p (@ (id ,help-id)
                                (class ,(mk-class helper-classes)))
                             ,help-text))
                        '())))))

;; ===== Files =====

(define* (file-field #:key label
                     name
                     (id #f)
                     (accept #f)
                     (multiple #f)
                     (capture #f)
                     (required #f)
                     (help-text #f)
                     (error #f)
                     (valid #f)
                     (disabled #f)
                     (dropzone? #f)
                     (drop-label "Drop files here or choose a file")
                     (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a file picker, optionally as a drop zone.

The control is a native @code{<input type=\"file\">}, so the browser's own
picker, its filter for @var{accept}, its multi-file handling and its
@code{multipart/form-data} upload all work without a script. The visible
box is a @code{<label>} bound to the input, which means clicking it opens
the picker and a keyboard reader reaches the input itself.

With @var{dropzone?} the box is bigger, says it accepts dropped files, and
carries the attributes a small script uses to list the chosen names. Dropping
is an enhancement: with scripting off the label still opens the picker, and
the filename is still shown by the browser.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item accept
A native accept list, e.g. @code{\"image/*,.pdf\"}.
@item multiple
Whether several files may be chosen.
@item capture
An optional capture hint for a camera on a phone.
@item required
Whether a file is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item dropzone?
Render the larger drop-zone treatment. Defaults to false.
@item drop-label
The text inside the drop zone.
@item classes
Classes for the field wrapper.
@end table

@example
(file-field #:label \"Avatar\" #:name \"avatar\" #:accept \"image/*\")
(dropzone #:label \"Attachments\" #:name \"files\" #:multiple #t)
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (let ((control-id (field-id w)))
                  (list `(input (@ ,@(field-control-attributes w)
                                   (type "file")
                                   ,@(attr-when accept
                                                'accept accept)
                                   ,@(attr-when capture
                                                'capture capture)
                                   ,@(if multiple
                                         '((multiple ""))
                                         '())
                                   ,@(if disabled
                                         '((disabled ""))
                                         '())
                                   (class "hg-file-input sr-only")
                                   (data-hg-file-input "")))
                        `(label (@ (for ,control-id)
                                   (data-hg-dropzone "")
                                   (class ,(mk-class (append '(hg-dropzone
                                                               flex flex-col
                                                               items-center
                                                               justify-center
                                                               gap-2
                                                               text-center
                                                               cursor-pointer
                                                               rounded-xl
                                                               border-2
                                                               transition-colors
                                                               duration-150
                                                               focus-within:outline-2
                                                               focus-within:outline-offset-2
                                                               outline-onyx-500)
                                                             (if dropzone?
                                                                 '(py-8 px-6
                                                                      border-dashed
                                                                      border-stone-500/50
                                                                      dark:border-onyx-100/50
                                                                      bg-stone-300/50
                                                                      dark:bg-onyx-700/50)
                                                                 '(py-3 px-4
                                                                      border-stone-700
                                                                      dark:border-onyx-100
                                                                      bg-stone-300/75
                                                                      dark:bg-onyx-700/75))))))
                                ,(hyg:icon #:type (if dropzone?
                                                      'cloud-arrow-up 'paperclip)
                                           #:icon-css '(text-2xl text-onyx-300
                                                              dark:text-stone-500))
                                (span (@ (class ,(mk-class '(text-md font-medium
                                                                     text-onyx-500
                                                                     dark:text-stone-300))))
                                      ,drop-label)
                                (span (@ (class ,(mk-class '(text-sm font-light
                                                                     text-onyx-300
                                                                     dark:text-stone-500)))
                                          (data-hg-file-list ""))
                                                                             ,@(if accept
                                                                                   (list (format #f "Accepted: ~a" accept))
                                                                                   '()))))))))

(define* (dropzone #:key label
                   name
                   (id #f)
                   (accept #f)
                   (multiple #t)
                   (required #f)
                   (help-text #f)
                   (error #f)
                   (valid #f)
                   (disabled #f)
                   (drop-label "Drop files here or choose files")
                   (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a file field as a drop zone.

This is @code{file-field} with @code{#:dropzone? #t} and multi-file
selection on by default. It is still a native file input under a label, so
the picker, the accept filter and the upload work with scripting off; the
drop-zone treatment and the list of chosen names are the enhancement.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item accept
A native accept list.
@item multiple
Whether several files may be chosen. Defaults to true.
@item required
Whether a file is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item drop-label
The text inside the drop zone.
@item classes
Classes for the field wrapper.
@end table

@example
(dropzone #:label \"Attachments\" #:name \"files\" #:accept \"application/pdf\")
@end example"
  (file-field #:label label
              #:name name
              #:id id
              #:accept accept
              #:multiple multiple
              #:required required
              #:help-text help-text
              #:error error
              #:valid valid
              #:disabled disabled
              #:dropzone? #t
              #:drop-label drop-label
              #:classes classes))

;; ===== Combination =====

(define (choice-value choice)
  "Return the value of a @code{(value . label)} choice, or the choice itself."
  (if (pair? choice)
      (car choice)
      choice))

(define (choice-label choice)
  "Return the label of a @code{(value . label)} choice, or the choice itself."
  (if (pair? choice)
      (cdr choice)
      choice))

(define (choice-selected? choice selected)
  "True when @var{choice} names one of the @var{selected} values."
  (let ((value (choice-value choice)))
    (any (lambda (other)
           (equal? (format #f "~a" value)
                   (format #f "~a" other))) selected)))

(define* (combobox #:key label
                   name
                   (id #f)
                   (options '())
                   (value "")
                   (placeholder "")
                   (required #f)
                   (help-text #f)
                   (error #f)
                   (valid #f)
                   (multiple #f)
                   (disabled #f)
                   (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a free-text field with a list of suggestions.

The suggestion list is a native @code{<datalist>}: the browser draws it in
its own way, filters it as the reader types, and leaves the field free to
accept a value that is not on the list. That is the correct behaviour for a
combobox, and none of it needs a script. A page that needs a fixed set of
choices wants @code{select} instead; a page that needs several values wants
@code{multi-select}.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item options
A list of strings or @code{(value . label)} pairs.
@item value
The initial value.
@item placeholder
A hint shown while the field is empty.
@item required
Whether the field is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item multiple
Whether several values may be entered (the datalist is unchanged; the
field is a normal text input and this only sets @code{multiple}).
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@end table

@example
(combobox #:label \"Colour\" #:name \"colour\"
          #:options '(\"amber\" \"asparagus\" \"jeans-blue\"))
@end example"
  (let* ((wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (control-id (field-id wiring))
         (list-id (format #f "~a-options" control-id)))
    (form-field #:label label
                #:name name
                #:id id
                #:help-text help-text
                #:error error
                #:valid valid
                #:required required
                #:classes classes
                #:control
                (lambda (w)
                  (list `(input (@ ,@(field-control-attributes w)
                                   (type "text")
                                   (list ,list-id)
                                   (value ,value)
                                   ,@(attr-when placeholder
                                                'placeholder placeholder)
                                   (autocomplete "off")
                                   ,@(if multiple
                                         '((multiple ""))
                                         '())
                                   ,@(if disabled
                                         '((disabled ""))
                                         '())
                                   (class ,(mk-class control-classes))))
                        `(datalist (@ (id ,list-id))
                                   ,@(map (lambda (choice)
                                            `(option (@ (value ,(format #f
                                                                       "~a"
                                                                       (choice-value
                                                                        choice))))
                                                     ,(let ((label (choice-label
                                                                    choice)))
                                                        (if (equal? (format #f
                                                                           "~a"
                                                                           label)
                                                                    (format #f
                                                                           "~a"
                                                                           (choice-value
                                                                            choice)))
                                                            '()
                                                            label))))
                                          options)))))))

(define* (multi-select #:key label
                       name
                       (id #f)
                       (options '())
                       (selected '())
                       (size #f)
                       (required #f)
                       (help-text #f)
                       (error #f)
                       (valid #f)
                       (disabled #f)
                       (remove-href #f)
                       (remove-label "Remove")
                       (classes '(my-2 flex flex-col gap-1 w-full)))
  "Render a multi-value choice control with the chosen values shown as tags.

The control is a native @code{<select multiple>}, which is the only
multi-select that works without a script and is announced correctly by
assistive technology. The tags above it are a *second view* of the same
selection, not a replacement: they show what is chosen without opening the
menu, and, when @var{remove-href} is given, each tag is a link that removes
that value -- a plain navigation, so removal works with scripting off too.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item options
A list of strings or @code{(value . label)} pairs.
@item selected
The values that start selected.
@item size
How many rows the menu shows. Defaults to the number of options, capped at 8.
@item required
Whether at least one value is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item remove-href
A procedure of one argument (a selected value) returning the URL that
removes it, or @code{#f} for tags that are not removable.
@item remove-label
The accessible label template for a removal link. Defaults to
@code{\"Remove\"}.
@item classes
Classes for the field wrapper.
@end table

@example
(multi-select #:label \"Topics\" #:name \"topics\"
              #:options '((a . \"Accessibility\") (s . \"SSR\"))
              #:selected '(\"ssr\"))
@end example"
  (let* ((rows (max 2 (min 8 (or size (length options) 2))))
         (selected-choices (filter (lambda (choice)
                                     (choice-selected? choice selected))
                                   options)))
    (form-field #:label label
                #:name name
                #:id id
                #:help-text help-text
                #:error error
                #:valid valid
                #:required required
                #:classes classes
                #:control
                (lambda (w)
                  (append (if (pair? selected-choices)
                              (list `(ul (@ (class ,(mk-class '(hg-tags flex flex-row
                                                                           flex-wrap
                                                                           gap-2
                                                                           list-none
                                                                           p-0
                                                                           m-0)))
                                           (aria-label "Selected values"))
                                         ,@(map (lambda (choice)
                                                  (let ((value (choice-value
                                                                choice))
                                                        (tag-label (choice-label
                                                                    choice)))
                                                    `(li (@ (class ,(mk-class '(hg-tag
                                                                                inline-flex
                                                                                items-center
                                                                                gap-1
                                                                                px-2
                                                                                py-1
                                                                                rounded-lg
                                                                                border-2
                                                                                border-stone-500/50
                                                                                dark:border-onyx-100/50
                                                                                bg-stone-300/75
                                                                                dark:bg-onyx-700/75
                                                                                text-sm
                                                                                font-medium
                                                                                text-onyx-500
                                                                                dark:text-stone-300))))
                                                         (span ,(format #f "~a"
                                                                        tag-label))
                                                         ,@(if remove-href
                                                               (list `(a (@ (href ,(remove-href
                                                                                    value))
                                                                            (aria-label ,(format #f
                                                                                                 "~a ~a"
                                                                                                 remove-label
                                                                                                 tag-label))
                                                                            (class "hg-tag-remove no-underline
                                                                                    text-onyx-300
                                                                                    dark:text-stone-500"))
                                                                         "×"))
                                                               '()))))
                                                selected-choices)))
                              '())
                          (list `(select (@ ,@(field-control-attributes w)
                                            (multiple "")
                                            (size ,(format #f "~a" rows))
                                            ,@(if disabled
                                                  '((disabled ""))
                                                  '())
                                            (class ,(mk-class control-classes)))
                                         ,@(map (lambda (choice)
                                                  (let ((value (choice-value
                                                                choice))
                                                        (tag-label (choice-label
                                                                    choice)))
                                                    `(option (@ (value ,(format #f
                                                                                "~a"
                                                                                value))
                                                               ,@(if (choice-selected?
                                                                      choice
                                                                      selected)
                                                                     '((selected ""))
                                                                     '()))
                                                             ,(format #f "~a"
                                                                      tag-label))))
                                                options))))))))
;; ===== Passwords =====

(define password-toggle-classes
  '(hg-password-toggle
    js-only
    shrink-0
    px-3
    rounded-xl
    border-2
    border-stone-700
    dark:border-onyx-100
    bg-stone-300/75
    dark:bg-onyx-700/75
    text-sm
    font-medium
    text-onyx-500
    dark:text-stone-300
    cursor-pointer
    transition-colors
    duration-150
    focus-visible:outline-2
    focus-visible:outline-offset-2
    outline-onyx-500))

(define (password-toggle control-id)
  "Render the show/hide control of a password field."
  `(button (@ (type "button")
              (class ,(mk-class password-toggle-classes))
              (aria-controls ,control-id)
              (aria-pressed "false")
              (aria-label "Show password")
              (onclick "hygguileTogglePassword(this)"))
           "Show"))

(define* (password-field #:key (label "Password")
                         name
                         (id #f)
                         (value "")
                         (placeholder "")
                         (required #f)
                         (autocomplete "current-password")
                         (reveal? #t)
                         (help-text #f)
                         (error #f)
                         (valid #f)
                         (disabled #f)
                         (readonly #f)
                         (classes '(my-2 flex flex-col gap-1 w-full))
                         (input-css control-classes))
  "Render a password field with an optional reveal control.

The field is a native @code{<input type=\"password\">} and stays one: the
value is masked by the browser, the right keyboard and autofill behaviour
come with the type, and the form works with scripting off. The reveal
button is a progressive enhancement that flips the field to plain text
while the reader asks it to -- it carries @code{js-only}, so a page
rendered without scripts shows the field and its label and nothing that
cannot work.

Give the field an @var{autocomplete} that matches what it is
(@code{\"current-password\"} to sign in, @code{\"new-password\"} to set a
password), which is what lets a password manager fill it, and what tells a
browser offering to generate a password which field it is generating one
for.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value. A page should normally leave this empty.
@item placeholder
A hint shown while the field is empty.
@item required
Whether the field is required.
@item autocomplete
The @code{autocomplete} hint. Defaults to @code{\"current-password\"}.
@item reveal?
Render the show/hide control. Defaults to true.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item readonly
Whether the control is read-only.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the input itself.
@end table

@example
(password-field #:label \"Password\" #:name \"password\" #:required #t
                #:autocomplete \"current-password\")
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (let ((field `(input (@ ,@(field-control-attributes w)
                                        (type "password")
                                        ,@(attr-when value
                                                     'value value)
                                        ,@(attr-when placeholder
                                                     'placeholder placeholder)
                                        ,@(attr-when autocomplete
                                                     'autocomplete autocomplete)
                                        ,@(if disabled
                                              '((disabled ""))
                                              '())
                                        ,@(if readonly
                                              '((readonly ""))
                                              '())
                                        (class ,(mk-class input-css))))))
                  (if reveal?
                      (list `(div (@ (class "hg-password"))
                                  ,field
                                  ,(password-toggle (field-id w))))
                      (list field))))))

;; ===== One-time codes =====

(define otp-classes
  '(p-3
    w-full
    max-w-48
    rounded-xl
    border-2
    border-stone-700
    dark:border-onyx-100
    bg-stone-300/75
    dark:bg-onyx-700/75
    text-onyx-500
    dark:text-stone-300
    font-mono
    text-lg
    text-center
    tracking-widest
    shadow-sm
    transition-colors
    duration-150
    focus-visible:outline-2
    focus-visible:outline-offset-2
    outline-onyx-500))

(define* (otp-field #:key (label "Verification code")
                    name
                    (id #f)
                    (value "")
                    (length 6)
                    (required #f)
                    (autocomplete "one-time-code")
                    (help-text "Enter the code we sent you.")
                    (error #f)
                    (valid #f)
                    (disabled #f)
                    (classes '(my-2 flex flex-col gap-1 w-full))
                    (input-css otp-classes))
  "Render a one-time code field.

The code is one input, not one input per digit. A single field is the shape
the platform expects: @code{autocomplete=\"one-time-code\"} lets a phone
offer the code it just received, a paste fills the whole code at once, and
a screen reader reads one value rather than six boxes it has to count
through. The digits are spaced apart by the stylesheet, which is the part
of a six-box field that actually helps.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value.
@item length
How many digits the code has. Defaults to @code{6}.
@item required
Whether the code is required.
@item autocomplete
The @code{autocomplete} hint. Defaults to @code{\"one-time-code\"}.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the input itself.
@end table

@example
(otp-field #:label \"Verification code\" #:name \"code\" #:length 6)
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (list `(input (@ ,@(field-control-attributes w)
                                 (type "text")
                                 (inputmode "numeric")
                                 (pattern ,(format #f "[0-9]{~a}" length))
                                 (maxlength ,(format #f "~a" length))
                                 ,@(attr-when autocomplete
                                              'autocomplete autocomplete)
                                 (spellcheck "false")
                                 (autocapitalize "off")
                                 (enterkeyhint "done")
                                 ,@(attr-when value
                                              'value value)
                                 ,@(if disabled
                                       '((disabled ""))
                                       '())
                                 (class ,(mk-class input-css))))))))

;; ===== A control with something written beside it =====

(define addon-classes
  '(hg-input-group-addon
    px-3
    self-center
    text-md
    font-light
    text-onyx-300
    dark:text-stone-500))

(define (group-addon node)
  "Return the nodes of one side of an input group, given what the page passed.

A string becomes the group's own addon box; anything else is taken as the
SXML the page wrote, so a unit can be a `select', a `button' or a piece of
prose without this module knowing what it is."
  (cond
    ((not node)
     '())
    ((string? node)
     (list `(span (@ (class ,(mk-class addon-classes)))
                  ,node)))
    ((and (pair? node)
          (symbol? (car node)))
     (list node))
    ((list? node)
     node)
    (else '())))

(define input-group-classes
  '(hg-input-group
    flex flex-row
    items-stretch
    w-full
    rounded-xl
    border-2
    border-stone-700
    dark:border-onyx-100
    bg-stone-300/75
    dark:bg-onyx-700/75
    shadow-sm
    overflow-hidden
    transition-colors
    duration-150
    focus-within:outline-2
    focus-within:outline-offset-2
    outline-onyx-500))

(define bare-input-classes
  '(p-3
    w-full
    border-0
    bg-transparent
    text-onyx-500
    dark:text-stone-300
    font-sans
    text-md
    focus-visible:outline-0))

(define* (input-group #:key label
                      name
                      (id #f)
                      (value "")
                      (placeholder "")
                      (type 'text)
                      (prefix #f)
                      (suffix #f)
                      (required #f)
                      (autocomplete #f)
                      (input-mode #f)
                      (help-text #f)
                      (error #f)
                      (valid #f)
                      (disabled #f)
                      (readonly #f)
                      (classes '(my-2 flex flex-col gap-1 w-full))
                      (input-css bare-input-classes)
                      (group-css input-group-classes))
  "Render a text field with something written inside its edges.

An input group is one bordered box that holds the field and the marks that
belong to it: the currency before an amount, the domain after a handle, the
unit after a quantity. The marks are not part of the value, so a reader
never has to type or delete them, and a screen reader reaches the field
without walking over them -- both sides are decorative text beside the
control, not inside it.

@var{prefix} and @var{suffix} each take a string, which is rendered as the
group's own addon box, or SXML (a node or a list of nodes), which is
rendered as written. That is what keeps the door open for a `select' of
units on the right of a number, or a `button' on the right of a search.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The initial value.
@item placeholder
A hint shown while the field is empty.
@item type
The native input type. Defaults to @code{'text}.
@item prefix
What is written before the field: a string, or SXML.
@item suffix
What is written after the field: a string, or SXML.
@item required
Whether the field is required.
@item autocomplete
An optional @code{autocomplete} hint.
@item input-mode
An optional virtual-keyboard hint.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item readonly
Whether the control is read-only.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the input itself, which carries no border of its own.
@item group-css
Classes for the bordered box around the field and its addons.
@end table

@example
(input-group #:label \"Price\" #:name \"price\" #:type 'number
             #:prefix \"€\" #:suffix \"/ month\")
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (list `(div (@ (class ,(mk-class group-css)))
                            ,@(group-addon prefix)
                            (input (@ ,@(field-control-attributes w)
                                      (type ,(symbol->string type))
                                      ,@(attr-when value
                                                   'value value)
                                      ,@(attr-when placeholder
                                                   'placeholder placeholder)
                                      ,@(attr-when autocomplete
                                                   'autocomplete autocomplete)
                                      ,@(attr-when input-mode
                                                   'inputmode input-mode)
                                      ,@(if disabled
                                            '((disabled ""))
                                            '())
                                      ,@(if readonly
                                            '((readonly ""))
                                            '())
                                      (class ,(mk-class input-css))))
                            ,@(group-addon suffix))))))

;; ===== A range with its value written out =====

(define slider-output-classes
  '(hg-slider-output
    text-sm
    font-medium
    text-onyx-500
    dark:text-stone-300))

(define* (slider #:key label
                 name
                 (id #f)
                 (value 50)
                 (min 0)
                 (max 100)
                 (step 1)
                 (unit #f)
                 (required #f)
                 (help-text #f)
                 (error #f)
                 (valid #f)
                 (disabled #f)
                 (classes '(my-2 flex flex-col gap-1 w-full max-w-prose))
                 (input-css '(w-full cursor-pointer accent-onyx-700)))
  "Render a range slider that prints the value it is at.

The control is a native @code{<input type=\"range\">}: it drags, it takes
arrow keys, and it submits a number with no script. The number beside it is
an @code{<output>} bound to the field, which the browser reads out as the
field's result; a small script keeps it in step while the reader drags, and
without one the number is simply the value the page rendered.

Always give a slider a start value and, where it matters, a scale worth
reading: a reader cannot see the positions between the ends, so the number
is the only place the current value is stated in words.

@table @var
@item label
The field's visible name.
@item name
The form field name.
@item id
An explicit identifier; defaults to @var{name}.
@item value
The value it starts at. Defaults to @code{50}.
@item min
The lowest value. Defaults to @code{0}.
@item max
The highest value. Defaults to @code{100}.
@item step
The increment. Defaults to @code{1}.
@item unit
An optional unit printed beside the number, e.g. @code{\"°C\"}.
@item required
Whether a value is required.
@item help-text
Optional helper copy.
@item error
Optional error message.
@item valid
@code{#t} to mark the field as filled in correctly, or a string
to say so in words as well.
@item disabled
Whether the control is disabled.
@item classes
Classes for the field wrapper.
@item input-css
Classes for the slider itself.
@end table

@example
(slider #:label \"Warmth\" #:name \"warmth\" #:value 21 #:min 16 #:max 26
        #:unit \"°C\")
@end example"
  (form-field #:label label
              #:name name
              #:id id
              #:help-text help-text
              #:error error
              #:valid valid
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (let ((control-id (field-id w))
                      (printed (format #f "~a~a" value (or unit ""))))
                  (list `(div (@ (class "hg-slider"))
                              (input (@ ,@(field-control-attributes w)
                                        (type "range")
                                        (min ,(format #f "~a" min))
                                        (max ,(format #f "~a" max))
                                        (step ,(format #f "~a" step))
                                        (value ,(format #f "~a" value))
                                        (oninput "hygguileSliderValue(this)")
                                        ,@(if disabled
                                              '((disabled ""))
                                              '())
                                        (class ,(mk-class input-css))))
                              (output (@ (for ,control-id)
                                         (class ,(mk-class slider-output-classes)))
                                      ,printed)))))))

;; ===== The form's own error summary =====

(define (validation-errors checks)
  "Return the errors among @var{checks}, in the order they were given.

@var{checks} is a list of @code{(field-id . message)} pairs in which the
message is @code{#f} for a field that passed -- the shape a predicate that
answers with the words to show produces, so a server can write its rules
once and read the failures off them:

@example
(validation-errors
 (list (cons \"email\"
             (and (not (valid-email? email))
                  \"Enter an email address.\"))
       (cons \"password\"
             (and (< (string-length password) 12)
                  \"Use at least 12 characters.\"))))
;; => ((\"email\" . \"Enter an email address.\"))
@end example

The result is exactly what @code{validation-summary} takes, and an empty
result means the form is fine: a page never has to remember which of its
checks failed, or in what order to show them.

A pair whose first element is @code{#f} is a problem with the form rather
than with one field, and is listed without a link."
  (filter-map (lambda (check)
                (and (pair? check)
                     (let ((message (cdr check)))
                       (and message
                            (cons (car check) message)))))
              checks))

(define summary-classes
  '(hg-validation-summary
    p-4
    rounded-xl
    border-2
    border-redwood-500
    dark:border-light-coral-500
    bg-stone-300/75
    dark:bg-onyx-700/75
    text-onyx-500
    dark:text-stone-300
    flex flex-col
    gap-2))

(define (summary-item error)
  "Render one line of a validation summary, linked to its field.

The link carries its own ink rather than the browser's default blue: a
summary is read on the page's own surface, and the default link colour is
picked for a white page, not for a dark one."
  (let ((field (car error))
        (message (cdr error)))
    `(li ,(if field
              `(a (@ (href ,(format #f "#~a" field))
                     (class ,(mk-class '(underline
                                         text-redwood-700
                                         dark:text-light-coral-100))))
                  ,message)
              message))))

(define* (validation-summary #:key errors
                             (title "There is a problem")
                             (id #f)
                             (focus? #f)
                             (classes '(my-4)))
  "Render the form-level summary of what went wrong, at the top of a form.

A field's own error message is announced when the reader reaches the field;
a summary is announced when the page loads, and it lists every problem in
one place with a link to each. That is the pattern WCAG's error
identification asks for, and it is the difference between a form a reader
has to hunt through and a form that says what to fix.

@var{errors} is a list of @code{(field-id . message)} pairs, which is also
the shape a server already has when it re-renders a form it refused --
@code{validation-errors} builds one from the rules themselves. The summary
renders nothing at all when the list is empty, so a page can render it
unconditionally.

@table @var
@item errors
A list of @code{(field-id . message)} pairs; an empty list renders nothing.
@item title
The summary's heading. Defaults to @code{\"There is a problem\"}.
@item id
An explicit identifier; defaults to @code{\"hg-validation-summary\"}.
@item focus?
Ask the page's script to put focus on the summary when it loads, which is
where a reader should start after a refused submit. Off by default: a page
that renders a summary for reasons of its own does not get to move the
reader's focus.
@item classes
Classes for the summary box.
@end table

@example
(validation-summary #:errors '((\"email\" . \"Enter an email address\")
                               (\"password\" . \"Enter your password\")))
@end example"
  (if (null? errors)
      '()
      (let* ((summary-id (or id "hg-validation-summary"))
             (title-id (format #f "~a-title" summary-id)))
        `((div (@ (id ,summary-id)
                  (role alert)
                  (tabindex "-1")
                  (data-hg-validation-summary "")
                  ,@(if focus?
                        '((data-hg-focus-summary ""))
                        '())
                  (aria-labelledby ,title-id)
                  (class ,(mk-class (append classes summary-classes))))
                 (h2 (@ (id ,title-id)
                        (class ,(mk-class '(hg-validation-summary-title
                                            text-lg font-medium
                                            text-redwood-700
                                            dark:text-light-coral-100))))
                     ,title)
                 (ul (@ (class ,(mk-class '(list-disc pl-5 flex flex-col
                                                      gap-1 text-md font-light))))
                     ,@(map summary-item errors)))))))
