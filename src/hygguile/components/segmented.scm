;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components segmented)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components field)
  #:export (segmented-control segmented-item))

;; ===== A segmented control =====
;;
;; A segmented control is the small set of mutually exclusive choices a page
;; shows as one bar -- day / week / month, list / grid, free / paid -- and it
;; is a radio group wearing a different surface. Written as a radio group it
;; keeps the properties that matter: one tab stop, arrow keys inside it, the
;; choice announced with its state, and a value that a form submits with no
;; script at all. The only thing the stylesheet adds is the shared bar and
;; the moving highlight, which it draws from the radio that is checked.

(define (choice-value choice)
  "Return the value of a @code{(value . label)} choice, or the choice itself."
  (if (pair? choice)
      (car choice) choice))

(define (choice-label choice)
  "Return the label of a @code{(value . label)} choice, or the choice itself."
  (if (pair? choice)
      (cdr choice) choice))

(define (option-id base choice)
  "Return the identifier one choice of the control is written with."
  (format #f "~a-option-~a" base
          (string-map (lambda (c)
                        (if (char-alphabetic? c) c #\-))
                      (format #f "~a"
                              (choice-value choice)))))

(define* (segmented-item #:key value
                         label
                         name
                         (id #f)
                         (checked #f)
                         (disabled #f)
                         (classes '()))
  "Render one choice of a segmented control.

A page normally asks for the whole control with @code{segmented-control} and
never writes an item itself; this is exported for the case where a page has
to lay the choices out around something else (a divider, a disabled group).

The item is a `<label>` holding its own radio, so the label and the control
are one target, and the stylesheet can style the checked state with a
sibling selector rather than a script.

@table @var
@item value
The value submitted when this choice is chosen.
@item label
The text shown on the choice.
@item name
The shared form field name identifying the group.
@item id
An explicit identifier; defaults to one derived from @var{value}.
@item checked
Whether this choice starts chosen.
@item disabled
Whether this choice cannot be chosen.
@item classes
Classes for the label.
@end table

@example
(segmented-item #:value \"day\" #:label \"Day\" #:name \"range\" #:checked #t)
@end example"
  (let ((item-id (or id
                     (option-id "hg-segmented"
                                (cons value label)))))
    `((label (@ (class ,(mk-class (append '(hg-segmented-item) classes)))
                (for ,item-id))
             (input (@ (type "radio")
                       (id ,item-id)
                       (name ,(format #f "~a" name))
                       (value ,(format #f "~a" value))
                       (class "hg-segmented-input")
                       ,@(if checked
                             '((checked ""))
                             '())
                       ,@(if disabled
                             '((disabled ""))
                             '())))
             (span (@ (class "hg-segmented-label"))
                   ,label)))))
;; The bar itself: the box the choices sit in. Its rounding, border and
;; shadow are the whole visual difference between a segmented control and the
;; radio group it is.
(define segmented-bar-classes
  '(hg-segmented inline-flex
                 flex-row
                 flex-wrap
                 items-stretch
                 border-2
                 border-stone-700
                 dark:border-onyx-100
                 rounded-xl
                 shadow-sm
                 overflow-hidden))

(define (segmented-choice group-id
                          name
                          choice
                          chosen
                          disabled
                          full-width?)
  "Render one choice of the control, marked when it names @var{chosen}."
  (let* ((item-id (option-id group-id choice))
         (picked (and chosen
                      (string=? (format #f "~a"
                                        (choice-value choice))
                                (format #f "~a" chosen))))
         (item-classes (append '(hg-segmented-item)
                               (if full-width?
                                   '(flex-1)
                                   '()))))
    `(label (@ (class ,(mk-class item-classes))
               (for ,item-id))
            (input (@ (type "radio")
                      (id ,item-id)
                      (name ,(format #f "~a" name))
                      (value ,(format #f "~a"
                                      (choice-value choice)))
                      (class "hg-segmented-input")
                      ,@(if picked
                            '((checked ""))
                            '())
                      ,@(if disabled
                            '((disabled ""))
                            '())))
            (span (@ (class "hg-segmented-label"))
                  ,(format #f "~a"
                           (choice-label choice))))))

(define* (field-note id classes text
                     #:key (role #f))
  "Render the paragraph a field shows under its control.

The role decides which of the two message styles the paragraph wears, and
so which glyph the stylesheet puts in front of it: an error is announced
(@var{role} is @code{\"alert\"}) as well as shown, which is what makes a
server-rendered error reach a reader who is not looking at the field."
  `((p (@ (id ,id)
          ,@(if role
                (list (cons 'role role))
                '())
          (class ,(mk-class (append classes
                                    (cond
                                      ((equal? role "alert")
                                       '(hg-error-message))
                                      ((equal? role "status")
                                       '(hg-success-message))
                                      (else '()))))))
       ,text)))

(define* (segmented-control #:key label
                            name
                            (id #f)
                            (options '())
                            (selected #f)
                            (required #f)
                            (disabled #f)
                            (help-text #f)
                            (error #f)
                            (valid #f)
                            (full-width? #f)
                            (classes '(my-2 flex flex-col gap-1))
                            (label-css '(text-lg font-light text-onyx-100
                                                 dark:text-stone-300 font-sans))
                            (help-classes '(text-sm font-light text-onyx-300
                                                    dark:text-stone-500))
                            (error-css '(text-sm font-medium text-redwood-700
                                                 dark:text-light-coral-100))
                            (valid-css '(text-sm font-medium text-asparagus-900
                                                     dark:text-asparagus-300)))
  "Render a segmented control: a radio group drawn as one bar of choices.

The control is a `<fieldset>` named by its `<legend>`, holding one radio per
choice. It therefore behaves exactly like every other choice in a form --
one tab stop, arrow keys to move, the chosen row announced as checked -- and
it submits its value with scripting off. Nothing about the bar is a script:
the highlight follows the checked radio in the stylesheet.

Keep the set small. A segmented control says \"one of these few, and you can
see them all\"; a list of more than about five choices reads better as a
`select' or as radios stacked down the page.

@table @var
@item label
The name of the group, rendered as a `<legend>`.
@item name
The form field name.
@item id
An explicit identifier for the group; defaults to @var{name}.
@item options
A list of strings or @code{(value . label)} pairs.
@item selected
The value that starts chosen; the first choice when nothing is given.
@item required
Whether a choice has to be made.
@item disabled
Whether the whole control is disabled.
@item help-text
Optional helper copy, linked with @code{aria-describedby}.
@item error
Optional validation message, announced with @code{role=\"alert\"}.
@item valid
@code{#t} to mark the control as answered, or a string to say so in words.
@item full-width?
Stretch the bar across its container and share the width between choices.
@item classes
Classes for the field wrapper.
@item label-css
Classes for the legend.
@item help-classes
Classes for the helper copy.
@item error-css
Classes for the error message.
@item valid-css
Classes for the success message.
@end table

@example
(segmented-control #:label \"Range\"
                   #:name \"range\"
                   #:options '((day . \"Day\") (week . \"Week\") (month . \"Month\"))
                   #:selected \"week\")
@end example"
  (let* ((wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (group-id (field-id wiring))
         (help-id (field-help-id wiring))
         (error-id (field-error-id wiring))
         (described-by (field-described-by wiring))
         (chosen (or selected
                     (and (pair? options)
                          (choice-value (car options)))))
         (bar-classes (append segmented-bar-classes
                              (if full-width?
                                  '(w-full)
                                  '(w-fit))))
         (state-classes (cond
                          (error '(hg-field-invalid))
                          (valid '(hg-field-valid))
                          (else '())))
         (success (and valid
                       (not error)
                       (if (string? valid) valid #f))))
    `((div (@ (class ,(mk-class (append classes
                                        (cons 'hg-segmented-field
                                              state-classes)))))
           (fieldset (@ ,@(if described-by
                              (list (cons 'aria-describedby described-by))
                              '())
                        ,@(if required
                              '((aria-required "true"))
                              '())
                        ,@(if error
                              '((aria-invalid "true"))
                              '()))
                     (legend (@ (class ,(mk-class label-css)))
                             ,label
                             ,@(if required
                                   (list `(span (@ (aria-hidden "true")
                                                   (class ,(mk-class '(text-redwood-700
                                                                       dark:text-light-coral-100))))
                                                " *")
                                         `(span (@ (class "sr-only"))
                                                " (required)"))
                                   '()))
                     (div (@ (class ,(mk-class bar-classes)))
                          ,@(map (lambda (choice)
                                   (segmented-choice group-id
                                                     name
                                                     choice
                                                     chosen
                                                     disabled
                                                     full-width?)) options)))
                      ,@(if error
                            (field-note error-id error-css error #:role "alert")
                            '())
                      ,@(if success
                            (field-note (format #f "~a-valid" group-id)
                                        valid-css success #:role "status")
                            '())
                      ,@(if help-text
                            (field-note help-id help-classes help-text)
                            '())))))
