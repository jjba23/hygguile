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

(define-module (hygguile components input)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components button)
  #:export (form input
                 textarea
                 checkbox
                 radio
                 switch
                 range
                 fieldset
                 legend
                 help-text
                 form-error))

(define* (input #:key label
                name
                (id #f)
                (value "")
                (placeholder "")
                (type 'text)
                (required #f)
                (autocomplete #f)
                (autocapitalize #f)
                (spellcheck #f)
                (input-mode #f)
                (disabled #f)
                (readonly #f)
                (autofocus #f)
                (pattern #f)
                (min #f)
                (max #f)
                (step #f)
                (list #f)
                (help-text #f)
                (error #f)
                (input-css '(p-4 max-w-prose
                                 rounded-xl
                                 border-stone-700
                                 dark:border-onyx-100
                                 dark:text-stone-300
                                 bg-stone-300/75
                                 dark:bg-onyx-700/75
                                 border-2
                                 shadow-md
                                 font-sans
                                 transition-colors
                                 duration-150
                                 focus-visible:outline-2
                                 focus-visible:outline-offset-2
                                 outline-onyx-500))
                (label-css '(text-lg font-light text-onyx-100
                                     dark:text-stone-300 font-sans py-2))
                (input-flex-css '(my-2 flex flex-col gap-1)))
  "Construct an HTML @code{<input>} component with a matching label.

The generated field always carries an @code{id}, and the label is bound to
it through the @code{for} attribute, so clicking the label focuses the
input. Pass @code{#:autocomplete} to help browsers and password managers
fill the field with the right data (e.g. @code{\"name\"}, @code{\"email\"},
@code{\"street-address\"}, @code{\"current-password\"}, @code{\"one-time-code\"}).

@table @var
@item label
The descriptive text string displaying the identity of the field.
@item name
The name mapping configuration string bound onto form serialization attributes.
@item id
An optional explicit HTML identifier; defaults to @var{name}.
@item value
The standard default textual configuration payload string.
@item placeholder
The ambient string text descriptive hint applied when the field boundary is unpopulated.
@item type
A configuration symbol managing browser input rendering choices (e.g., @code{'text}, @code{'password}).
@item required
A boolean property indicating if form verification forces evaluation validation.
@item autocomplete
An optional string forwarding the HTML @code{autocomplete} hint to the browser.
@item autocapitalize
An optional string forwarding the HTML @code{autocapitalize} behaviour (e.g. @code{\"none\"}, @code{\"words\"}).
@item spellcheck
An optional string (@code{\"true\"} or @code{\"false\"}) controlling native spell checking.
@item input-mode
An optional string suggesting a virtual keyboard layout (e.g. @code{\"email\"}, @code{\"numeric\"}).
@item disabled
A boolean that disables the control.
@item readonly
A boolean that makes the control read-only.
@item autofocus
A boolean that focuses the control on page load.
@item pattern
An optional regular expression string enforcing the value format.
@item min
An optional lower bound for numeric or date inputs.
@item max
An optional upper bound for numeric or date inputs.
@item step
An optional numeric increment for numeric inputs.
@item list
An optional datalist identifier offering autocomplete suggestions.
@item help-text
Optional helper copy rendered below the field and linked with @code{aria-describedby}.
@item error
Optional validation message rendered below the field with @code{role=\"alert\"}.
@item input-css
List of symbols representing layout utility CSS classes for the input field.
@item label-css
List of symbols representing presentation utility CSS classes for the label field.
@item input-flex-css
List of symbols regulating structure container box margins and gaps.
@end table

@example
(input #:label \"Email Address\" #:name \"email\" #:type 'email #:autocomplete \"email\" #:required #t)
@end example"
  (let* ((field-id (if id id name))
         (error-id (format #f "~a-error" field-id))
         (help-id (format #f "~a-help" field-id))
         (described-by (cond
                         ((and help-text error)
                          (format #f "~a ~a" help-id error-id))
                         (error error-id)
                         (help-text help-id)
                         (else #f))))
    `((div (@ (class ,(mk-class input-flex-css)))
           (label (@ (class ,(mk-class label-css))
                     (for ,field-id))
                  ,label)
           (input (@ (id ,field-id)
                     (name ,name)
                     (type ,(symbol->string type))
                     ,@(attr-when autocomplete
                                  'autocomplete autocomplete)
                     ,@(attr-when autocapitalize
                                  'autocapitalize autocapitalize)
                     ,@(attr-when spellcheck
                                  'spellcheck
                                  (if (string? spellcheck) spellcheck
                                      (if spellcheck "true" "false")))
                     ,@(attr-when input-mode
                                  'inputmode input-mode)
                     ,@(attr-when pattern
                                  'pattern pattern)
                     ,@(attr-when (not (equal? #f min))
                                  'min min)
                     ,@(attr-when (not (equal? #f max))
                                  'max max)
                     ,@(attr-when (not (equal? #f step))
                                  'step step)
                     ,@(attr-when list
                                  'list list)
                     ,@(attr-when described-by
                                  'aria-describedby described-by)
                     ,@(if (or required error)
                           '((aria-required "true"))
                           '())
                     ,@(attr-when error
                                  'aria-invalid "true")
                     ,@(if required
                           '((required ""))
                           '())
                     ,@(if disabled
                           '((disabled ""))
                           '())
                     ,@(if readonly
                           '((readonly ""))
                           '())
                     ,@(if autofocus
                           '((autofocus ""))
                           '())
                     (class ,(mk-class input-css))
                     (placeholder ,placeholder)
                     (value ,value)))
           ,@(if error
                 `((p (@ (id ,error-id)
                         (role alert)
                         (class ,(mk-class '(text-sm font-medium
                                             text-redwood-700
                                             dark:text-light-coral-100))))
                      ,error))
                 '())
           ,@(if help-text
                 `((p (@ (id ,help-id)
                         (class ,(mk-class '(text-sm font-light text-onyx-300
                                                     dark:text-stone-500))))
                      ,help-text))
                 '())))))

(define* (textarea #:key label
                   name
                   (id #f)
                   (value "")
                   (placeholder "")
                   (rows #f)
                   (cols #f)
                   (required #f)
                   (autocomplete #f)
                   (maxlength #f)
                   (spellcheck #f)
                   (disabled #f)
                   (readonly #f)
                   (autofocus #f)
                   (help-text #f)
                   (error #f)
                   (textarea-css '(p-4 rounded-xl
                                       border-stone-700
                                       dark:border-onyx-100
                                       dark:text-stone-300
                                       dark:bg-onyx-700/75
                                       bg-stone-300/75
                                       border-2
                                       min-h-72
                                       w-full
                                       max-w-prose
                                       shadow-md
                                       resize-y
                                       transition-colors
                                       duration-150
                                       focus-visible:outline-2
                                       focus-visible:outline-offset-2
                                       outline-onyx-500))
                   (label-css '(text-lg font-light text-onyx-100
                                        dark:text-stone-300 font-sans py-2))
                   (textarea-flex-css '(my-2 flex flex-col gap-1 w-full
                                             font-sans)))
  "Construct an HTML @code{<textarea>} multiline field block.

@table @var
@item label
The explicit header string informing users of required field contexts.
@item name
The unique string structural identifier mapping the entity across standard DOM tables.
@item id
An optional explicit HTML identifier; defaults to @var{name}.
@item value
The initial text block paragraph payload string nested inside the block.
@item placeholder
An optional hint string shown while the field is empty.
@item rows
An optional suggested visible number of text rows.
@item cols
An optional suggested visible width in average character widths.
@item required
A field completion mandatory requirement boolean validation gate switch.
@item autocomplete
An optional string forwarding the HTML @code{autocomplete} hint to the browser.
@item maxlength
An optional maximum accepted character count.
@item spellcheck
An optional string (@code{\"true\"} or @code{\"false\"}) controlling native spell checking.
@item disabled
A boolean that disables the control.
@item readonly
A boolean that makes the control read-only.
@item autofocus
A boolean that focuses the control on page load.
@item help-text
Optional helper copy rendered below the field and linked with @code{aria-describedby}.
@item error
Optional validation message rendered below the field with @code{role=\"alert\"}.
@item textarea-css
List of symbols targeting specific dimensions and borders configuration styles.
@item label-css
List of symbols handling sizing constraints applied onto the matching label tags.
@item textarea-flex-css
List of symbols managing outer wrapper responsive card flex constraints.
@end table

@example
(textarea #:label \"User Bio\" #:name \"biography\" #:value \"Born in Scheme...\")
@end example"
  (let* ((field-id (if id id name))
         (error-id (format #f "~a-error" field-id))
         (help-id (format #f "~a-help" field-id))
         (described-by (cond
                         ((and help-text error)
                          (format #f "~a ~a" help-id error-id))
                         (error error-id)
                         (help-text help-id)
                         (else #f))))
    `((div (@ (class ,(mk-class textarea-flex-css)))
           (label (@ (class ,(mk-class label-css))
                     (for ,field-id))
                  ,label)
           (textarea (@ (id ,field-id)
                        (name ,name)
                        ,@(attr-when autocomplete
                                     'autocomplete autocomplete)
                        ,@(attr-when rows
                                     'rows rows)
                        ,@(attr-when cols
                                     'cols cols)
                        ,@(attr-when maxlength
                                     'maxlength maxlength)
                        ,@(attr-when spellcheck
                                     'spellcheck spellcheck)
                        ,@(attr-when described-by
                                     'aria-describedby described-by)
                        ,@(attr-when error
                                     'aria-invalid "true")
                        ,@(if required
                              '((required ""))
                              '())
                        ,@(if disabled
                              '((disabled ""))
                              '())
                        ,@(if readonly
                              '((readonly ""))
                              '())
                        ,@(if autofocus
                              '((autofocus ""))
                              '())
                        (class ,(mk-class textarea-css))
                        (placeholder ,placeholder))
                     ,value)
           ,@(if error
                 `((p (@ (id ,error-id)
                         (role alert)
                         (class ,(mk-class '(text-sm font-medium
                                             text-redwood-700
                                             dark:text-light-coral-100))))
                      ,error))
                 '())
           ,@(if help-text
                 `((p (@ (id ,help-id)
                         (class ,(mk-class '(text-sm font-light text-onyx-300
                                                     dark:text-stone-500))))
                      ,help-text))
                 '())))))

(define* (help-text content
                    #:key (classes '(text-sm font-light text-onyx-300
                                             dark:text-stone-500)))
  "Create a small helper paragraph providing extra field guidance.

@table @var
@item content
The helper copy string or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(help-text \"We will never share your email.\")
@end example"
  `((p (@ (class ,(mk-class classes)))
       ,content)))

(define* (form-error content
                     #:key (classes '(text-sm font-medium text-redwood-700
                                              dark:text-light-coral-100)))
  "Create an accessible inline form validation message.

The message is announced by assistive technology through @code{role=\"alert\"}.

@table @var
@item content
The error message string or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(form-error \"Please provide a valid email address.\")
@end example"
  `((p (@ (role alert)
          (class ,(mk-class classes)))
       ,content)))

(define* (legend content
                 #:key (classes '(text-lg font-medium text-onyx-300
                                          dark:text-stone-300 py-1)))
  "Create an HTML @code{<legend>} caption for a fieldset.

@table @var
@item content
The legend caption string or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(legend \"Shipping address\")
@end example"
  `((legend (@ (class ,(mk-class classes)))
            ,content)))

(define* (fieldset content
                   #:key (legend #f)
                   (fieldset-classes '(flex flex-col
                                            gap-2
                                            border-2
                                            border-stone-500/50
                                            dark:border-onyx-100/50
                                            rounded-xl
                                            p-4
                                            my-2)))
  "Create an HTML @code{<fieldset>} grouping related form controls.

@table @var
@item content
The list of form controls or fragments contained by the group.
@item legend
An optional caption rendered as the fieldset legend.
@item fieldset-classes
List of symbols representing container CSS classes.
@end table

@example
(fieldset (list (input #:label \"City\" #:name \"city\")) #:legend \"Address\")
@end example"
  `((fieldset (@ (class ,(mk-class fieldset-classes)))
              ,@(if legend
                    `((legend (@ (class ,(mk-class '(text-lg font-medium
                                                     text-onyx-300
                                                     dark:text-stone-300 py-1))))
                              ,legend))
                    '())
              ,content)))

(define* (form content
               #:key (action #f)
               (method 'post)
               (enctype #f)
               (target #f)
               (id #f)
               (name #f)
               (autocomplete #f)
               (novalidate #f)
               (aria-label #f)
               (submit #f)
               (form-classes '(my-4 flex flex-col gap-4)))
  "Create a working HTML @code{<form>} around a group of controls.

This is the wrapper for the common case: a form that posts its fields to
a server-rendered page. It works with JavaScript disabled, because the
browser itself serialises the controls and navigates to @var{action}, and
it opts into the browser's native validation unless you pass
@code{#:novalidate #t} and handle the messages yourself.

Pass @code{#:submit} to append a ready-made submit button, or place your
own buttons in @var{content} when a form needs several actions.

@table @var
@item content
The controls and fieldsets that make up the form.
@item action
The URL the browser navigates to on submission.
@item method
A symbol or string, @code{'post} by default; use @code{'get} for searches.
@item enctype
An optional encoding symbol such as @code{'multipart/form-data}, required for file uploads.
@item target
An optional browsing context string, e.g. @code{\"_blank\"}.
@item id
An optional HTML identifier.
@item name
An optional form name string.
@item autocomplete
An optional string (@code{\"on\"} or @code{\"off\"}) for the whole form.
@item novalidate
A boolean switching off native validation, for forms validated by hand.
@item aria-label
An optional accessible name when no visible heading describes the form.
@item submit
An optional label for a submit button appended after the fields.
@item form-classes
List of symbols representing the form layout CSS classes.
@end table

@example
(form (list (fieldset (list (input #:label \"Email\" #:name \"email\"
                                   #:type 'email #:required #t
                                   #:autocomplete \"email\"))
                   #:legend \"Newsletter\"))
      #:action \"/subscribe\"
      #:submit \"Subscribe\")
@end example"
  `((form (@ ,@(attr-when action
                          'action action)
             (method ,(if (symbol? method)
                          (symbol->string method) method))
             ,@(attr-when enctype
                          'enctype
                          (if (symbol? enctype)
                              (symbol->string enctype) enctype))
             ,@(attr-when target
                          'target target)
             ,@(attr-when id
                          'id id)
             ,@(attr-when name
                          'name name)
             ,@(attr-when autocomplete
                          'autocomplete autocomplete)
             ,@(attr-when aria-label
                          'aria-label aria-label)
             ,@(if novalidate
                   '((novalidate ""))
                   '())
             (class ,(mk-class form-classes)))
          ,@content
          ,@(if submit
                ;; submit-button returns a single bare element, so wrap
                ;; it before splicing it into the form's children
                (list (submit-button submit))
                '()))))

(define* (checkbox #:key label
                   name
                   (id #f)
                   (value "on")
                   (checked #f)
                   (required #f)
                   (disabled #f)
                   (help-text #f)
                   (error #f)
                   (input-css '(w-5 h-5
                                    rounded-md
                                    border-2
                                    border-stone-700
                                    dark:border-onyx-100
                                    accent-onyx-700
                                    cursor-pointer))
                   (label-css '(text-md font-light text-onyx-300
                                        dark:text-stone-300 font-sans))
                   (container-css '(my-2 flex flex-row items-center gap-2)))
  "Create a labelled HTML checkbox input.

Native checkboxes work without JavaScript and are keyboard accessible.

@table @var
@item label
The descriptive text shown next to the checkbox.
@item name
The form field name.
@item id
An optional explicit HTML identifier; defaults to @var{name}.
@item value
The value submitted when the box is checked.
@item checked
A boolean rendering the pre-checked state.
@item required
A boolean making the checkbox mandatory.
@item disabled
A boolean disabling the control.
@item help-text
Optional helper copy linked through @code{aria-describedby}.
@item error
Optional validation message rendered with @code{role=\"alert\"}.
@item input-css
List of symbols styling the checkbox control.
@item label-css
List of symbols styling the label text.
@item container-css
List of symbols styling the wrapping row.
@end table

@example
(checkbox #:label \"I accept the terms\" #:name \"terms\" #:required #t)
@end example"
  (let* ((field-id (if id id name))
         (help-id (format #f "~a-help" field-id)))
    `((div (@ (class ,(mk-class container-css)))
           (input (@ (id ,field-id)
                     (name ,name)
                     (type "checkbox")
                     (value ,value)
                     ,@(attr-when help-text
                                  'aria-describedby help-id)
                     ,@(if checked
                           '((checked ""))
                           '())
                     ,@(if required
                           '((required ""))
                           '())
                     ,@(if disabled
                           '((disabled ""))
                           '())
                     (class ,(mk-class input-css))))
           (label (@ (class ,(mk-class label-css))
                     (for ,field-id))
                  ,label)
           ,@(if error
                 (form-error error)
                 '())
           ,@(if help-text
                 (help-text help-text
                            #:classes '(text-sm font-light text-onyx-300
                                                dark:text-stone-500))
                 '())))))

(define* (radio #:key label
                name
                (id #f)
                (value #f)
                (checked #f)
                (required #f)
                (disabled #f)
                (input-css '(w-5 h-5
                                 rounded-lg
                                 border-2
                                 border-stone-700
                                 dark:border-onyx-100
                                 accent-onyx-700
                                 cursor-pointer))
                (label-css '(text-md font-light text-onyx-300
                                     dark:text-stone-300 font-sans))
                (container-css '(my-2 flex flex-row items-center gap-2)))
  "Create a labelled HTML radio button.

Give several radios the same @var{name} to form a mutually exclusive
group. Radios are native controls, so they keep working with JavaScript
disabled.

@table @var
@item label
The descriptive text shown next to the radio.
@item name
The shared form field name identifying the group.
@item id
An optional explicit HTML identifier; defaults to a value derived from @var{value}.
@item value
The value submitted when this radio is selected.
@item checked
A boolean rendering the pre-selected state.
@item required
A boolean making the group mandatory.
@item disabled
A boolean disabling the control.
@item input-css
List of symbols styling the radio control.
@item label-css
List of symbols styling the label text.
@item container-css
List of symbols styling the wrapping row.
@end table

@example
(radio #:label \"Small\" #:name \"size\" #:value \"s\" #:checked #t)
@end example"
  (let* ((field-id (if id id
                       (format #f "~a-~a" name
                               (if value value "option")))))
    `((div (@ (class ,(mk-class container-css)))
           (input (@ (id ,field-id)
                     (name ,name)
                     (type "radio")
                     ,@(attr-when value
                                  'value value)
                     ,@(if checked
                           '((checked ""))
                           '())
                     ,@(if required
                           '((required ""))
                           '())
                     ,@(if disabled
                           '((disabled ""))
                           '())
                     (class ,(mk-class input-css))))
           (label (@ (class ,(mk-class label-css))
                     (for ,field-id))
                  ,label)))))

(define* (switch #:key label
                 name
                 (id #f)
                 (value "on")
                 (checked #f)
                 (disabled #f))
  "Create a styled on/off switch backed by a native checkbox.

The switch is pure CSS and a real checkbox underneath, so it works
without JavaScript. The visual track is styled by @code{.hg-switch}.

@table @var
@item label
The descriptive text shown next to the switch.
@item name
The form field name.
@item id
An optional explicit HTML identifier; defaults to @var{name}.
@item value
The value submitted when the switch is on.
@item checked
A boolean rendering the switch in the on position.
@item disabled
A boolean disabling the control.
@end table

@example
(switch #:label \"Enable notifications\" #:name \"notifications\" #:checked #t)
@end example"
  (let ((field-id (if id id name)))
    `((div (@ (class ,(mk-class '(my-2 flex flex-row items-center gap-3))))
           (input (@ (id ,field-id)
                     (name ,name)
                     (type "checkbox")
                     (value ,value)
                     ,@(if checked
                           '((checked ""))
                           '())
                     ,@(if disabled
                           '((disabled ""))
                           '())
                     (class "hg-switch-input")))
           (span (@ (class "hg-switch")
                    (aria-hidden "true")) "")
           (label (@ (class ,(mk-class '(text-md font-light text-onyx-300
                                                 dark:text-stone-300 font-sans)))
                     (for ,field-id))
                  ,label)))))

(define* (range #:key label
                name
                (id #f)
                (value #f)
                (min 0)
                (max 100)
                (step 1)
                (disabled #f)
                (input-css '(w-full max-w-prose cursor-pointer accent-onyx-700)))
  "Create a labelled HTML range slider.

@table @var
@item label
The descriptive text shown above the slider.
@item name
The form field name.
@item id
An optional explicit HTML identifier; defaults to @var{name}.
@item value
The optional initial slider position.
@item min
The lowest accepted value. Defaults to @code{0}.
@item max
The highest accepted value. Defaults to @code{100}.
@item step
The increment between accepted values. Defaults to @code{1}.
@item disabled
A boolean disabling the control.
@item input-css
List of symbols styling the range control.
@end table

@example
(range #:label \"Volume\" #:name \"volume\" #:min 0 #:max 11 #:value 7)
@end example"
  (let ((field-id (if id id name)))
    `((div (@ (class ,(mk-class '(my-2 flex flex-col gap-1))))
           (label (@ (class ,(mk-class '(text-lg font-light text-onyx-100
                                                 dark:text-stone-300 font-sans
                                                 py-2)))
                     (for ,field-id))
                  ,label)
           (input (@ (id ,field-id)
                     (name ,name)
                     (type "range")
                     (min ,(format #f "~a" min))
                     (max ,(format #f "~a" max))
                     (step ,(format #f "~a" step))
                     ,@(attr-when value
                                  'value value)
                     ,@(if disabled
                           '((disabled ""))
                           '())
                     (class ,(mk-class input-css))))))))
