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
            number-field
            stepper
            date-field
            time-field
            date-range-field
            file-field
            dropzone
            combobox
            multi-select))

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
and nothing else -- a control's own type, value and classes are its own."
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
                (list (cons 'aria-invalid "true"))
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
                     (required #f)
                     (label-hidden? #f)
                     control
                     (classes '(my-2 flex flex-col gap-1 w-full))
                     (label-css label-classes)
                     (help-classes helper-classes)
                     (error-css error-classes))
  "Render one labelled, described, validated field shell around a control.

The shell owns the four things every field needs and every hand-written
field eventually gets wrong: the label is bound to the control's id, the
helper copy and the error are linked through @code{aria-describedby}, the
error is announced with @code{role=\"alert\"}, and the required state is
both visible (a marker) and spoken (a visually hidden word plus
@code{aria-required} on the control).

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
Optional error message, rendered above the help text and announced.
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
@end example"
  (let* ((wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (control-id (field-id wiring))
         (help-id (field-help-id wiring))
         (error-id (field-error-id wiring))
         (nodes (let ((rendered (control wiring)))
                  (if (and (list? rendered)
                           (pair? rendered)
                           (not (symbol? (car rendered))))
                      rendered
                      (list rendered)))))
    `((div (@ (class ,(mk-class (append classes '(hg-field)))))
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
                         (class ,(mk-class error-css)))
                      ,error))
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
         (error-id (field-error-id wiring)))
    `((form (@ ,@(attr-when action
                            'action action)
               (method ,(if (symbol? method)
                            (symbol->string method) method))
               (role "search")
               (class ,(mk-class classes)))
             (div (@ (class ,(mk-class '(flex flex-row items-stretch gap-2
                                               w-full))))
                  (div (@ (class ,(mk-class '(flex flex-col gap-1 flex-1))))
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
                                     (class ,(mk-class error-classes)))
                                  ,error))
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
              #:required required
              #:classes classes
              #:control
              (lambda (w)
                (let* ((input `(input (@ ,@(field-control-attributes w)
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
                                         (class ,(mk-class input-css)))))
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
         (error-id (format #f "~a-error" base)))
    `((fieldset (@ (class ,(mk-class (append classes '(hg-field m-0
                                                                border-0
                                                                p-0))))
                   ,@(if error
                         `((aria-invalid "true")
                           (aria-describedby ,(if help-text
                                                  (format #f "~a ~a" help-id
                                                          error-id)
                                                  error-id)))
                         (if help-text
                             `((aria-describedby ,help-id))
                             '())))
                  (legend (@ (class ,(mk-class (append label-classes))))
                          ,label
                          ,@(if required
                                (list `(span (@ (aria-hidden "true")
                                                (class ,(mk-class '(text-redwood-700
                                                                    dark:text-light-coral-100))))
                                             " *"))
                                '()))
                  (div (@ (class ,(mk-class '(grid grid-cols-1
                                                    sm:grid-cols-2 gap-4))))
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
                                (class ,(mk-class error-classes)))
                             ,error))
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
