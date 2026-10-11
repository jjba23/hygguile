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

(define-module (hygguile components select)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:export (option glyph-option optgroup select))

;; A control's value travels as text. In Scheme a page is free to write
;; `en_US' or "en_US" and mean the same option either way, but the markup
;; can only carry one of them, and comparing the two without saying so is
;; how a server-rendered selection silently disappears. Both sides of the
;; comparison are therefore read as the text they will be written as.
(define (control-value value)
  "Return @var{value} as the text a form control carries.

A string is already that text; a symbol or a number is written the way the
serializer would write it, so a value and a @code{selected-value} given in
different shapes still name the same option."
  (cond
    ((string? value) value)
    ((symbol? value) (symbol->string value))
    (else (format #f "~a" value))))

(define (control-value= one two)
  "True when @var{one} and @var{two} name the same control value."
  (and one
       two
       (string=? (control-value one)
                 (control-value two))))

(define (attribute? node name)
  "True when @var{node} carries an attribute called @var{name}."
  (and (pair? node)
       (pair? (cdr node))
       (pair? (cadr node))
       (eq? (car (cadr node)) '@)
       (pair? (assq name (cdr (cadr node))))
       #t))

(define* (option #:key value
                 (content #f)
                 (family '(font-sans))
                 (selected-value #f)
                 (disabled #f))
  "Construct an HTML @code{<option>} element.

The option is selected when its @var{value} names the @var{selected-value},
which is how a server-rendered page says which row a dropdown is showing.
The two are compared as the text they are written as, so @code{en_US} and
@code{\"en_US\"} are the same option; comparing them as Scheme values is how
a selection goes missing between the server and the browser.

@table @var
@item value
The value submitted when this option is chosen.
@item content
The text shown for the option. Defaults to @var{value}.
@item family
List of symbols representing font family CSS classes for the option.
@item selected-value
The value the dropdown is currently showing, so that the matching option
renders as selected.
@item disabled
A boolean marking the option as not choosable, which is what a placeholder
row such as a bare @code{\"Choose one...\"} wants.
@end table

@example
(option #:value \"light\" #:content \"Cozy Light Theme\" #:selected-value \"dark\")
@end example"
  (let ((text (control-value value)))
    `((option (@ (value ,text)
                 (class ,(mk-class family))
                 ,@(if (control-value= value selected-value)
                       '((selected ""))
                       '())
                 ,@(if disabled
                       '((disabled ""))
                       '()))
              ,(if content content text)))))

(define* (optgroup #:key label
                   (options '())
                   (disabled #f))
  "Construct an HTML @code{<optgroup>}: a heading inside a menu.

A long menu reads as a list of headings rather than a list of rows once its
options are grouped, and the group is the browser's own idea rather than a
class of ours -- a native dropdown draws its header and indents the rows
under it, so there is nothing in the companion stylesheet to go with this.

The label is the group's whole purpose and the attribute is required by
HTML; it is written when given, and omitted rather than written as
@code{#f} when it is not, so a group with no heading is a group with no
heading attribute rather than one claiming to be called @code{#f}.

A disabled group takes its rows out of play with it: none of them can be
chosen, which is why a menu never states one of them as its selection.

@table @var
@item label
The heading shown above the group's rows.
@item options
List of option or glyph-option S-expressions making up the group.
@item disabled
A boolean disabling every row of the group at once.
@end table

@example
(optgroup #:label \"Europe\"
          #:options (list (glyph-option #:value \"nl\" #:glyph \"🇳🇱\" #:content \"Nederlands\")
                          (glyph-option #:value \"es\" #:glyph \"🇪🇸\" #:content \"Español\")))
@end example"
  `((optgroup (@ ,@(attr-when label 'label label)
                 ,@(if disabled
                       '((disabled ""))
                       '()))
              ,@options)))

(define* (glyph-option #:key value
                       glyph
                       (content #f)
                       (family '(font-sans))
                       (selected-value #f)
                       (disabled #f))
  "Construct an HTML option introduced by an inline glyph.

The glyph and the label are written as the option's own text, because that
is all an @code{<option>} may hold: a native dropdown is drawn by the
browser or the operating system, which lays out the text of a row and
ignores any element nested inside it. A glyph here is therefore a character
or an emoji rather than an icon component, and it appears wherever the
option is shown.

@table @var
@item value
The value submitted when this option is chosen.
@item glyph
The character or emoji introducing the row, e.g. @code{\"🇳🇱\"}.
@item content
The text of the row. Defaults to @var{value}.
@item family
List of symbols representing font family CSS classes for the option.
@item selected-value
The value the dropdown is currently showing.
@item disabled
A boolean marking the option as not choosable.
@end table

@example
(glyph-option #:value \"nl\" #:glyph \"🇳🇱\" #:content \"Nederlands\")
@end example"
  (option #:value value
          #:selected-value selected-value
          #:disabled disabled
          #:family family
          #:content (format #f "~a ~a"
                            glyph
                            (if content content (control-value value)))))

;; Every dropdown states its selection. A menu whose rows all say nothing
;; is drawn by the browser with its own fallback -- the first row that is
;; not disabled -- so a page that renders no `selected' attribute cannot be
;; read back as the state the reader is looking at, and a form submitted
;; without touching the field sends a value the server never chose.
(define (option-entry? entry)
  "True when @var{entry} is one option of a menu."
  (and (pair? entry)
       (pair? (car entry))
       (eq? (car (car entry)) 'option)))

(define (optgroup-entry? entry)
  "True when @var{entry} is one group of options standing in a menu."
  (and (pair? entry)
       (pair? (car entry))
       (eq? (car (car entry)) 'optgroup)))

(define (group-rows entry)
  "The rows of a group, in the order they are written."
  (cddr (car entry)))

(define (choosable-option? entry)
  "True when @var{entry} is an option a reader can pick."
  (and (option-entry? entry)
       (not (attribute? (car entry) 'disabled))))

(define (selected-entry? entry)
  "True when @var{entry} states a selection, its own or a group's."
  (cond
    ((option-entry? entry) (attribute? (car entry) 'selected))
    ((optgroup-entry? entry) (any selected-entry? (group-rows entry)))
    (else #f)))

(define (mark-selected entry)
  "Return @var{entry} with its option marked selected."
  (let ((node (car entry)))
    (list (cons* 'option
                 (cons '@ (append (cdr (cadr node))
                                  '((selected ""))))
                 (cddr node)))))

(define (mark-group entry rows)
  "Return @var{entry}, a group, over its own rows."
  (list (cons* 'optgroup (cadr (car entry)) rows)))

(define (mark-first-choosable entries blocked?)
  "Return @code{(@var{marked} . @var{entries})} with the first choosable
row of @var{entries} marked selected, or, when there is none, the rows
themselves and @code{#f}.

The rows are walked in the order a reader sees them, groups and all, so a
menu whose rows are grouped still states the row at the top. Nothing is
marked inside a disabled group, and the rows of such a group are left
exactly as they were."
  (if (null? entries)
      (cons #f '())
      (let ((entry (car entries)))
        (cond
          ((and (not blocked?) (choosable-option? entry))
           (cons #t (cons (mark-selected entry) (cdr entries))))
          ((and (not blocked?) (optgroup-entry? entry))
           (let ((inside (mark-first-choosable
                          (group-rows entry)
                          (attribute? (car entry) 'disabled))))
             (if (car inside)
                 (cons #t (cons (mark-group entry (cdr inside))
                                (cdr entries)))
                 (let ((rest (mark-first-choosable (cdr entries) blocked?)))
                   (cons (car rest) (cons entry (cdr rest)))))))
          (else (let ((rest (mark-first-choosable (cdr entries) blocked?)))
                  (cons (car rest) (cons entry (cdr rest)))))))))

(define (state-selection options)
  "Return @var{options} with one row marked selected.

An option that already carries the attribute is left alone, group or not:
the page has said which row it is showing. When none does, the first row
that can be chosen is marked, which is the row the browser would have
shown anyway. A menu that is empty, or whose rows are all disabled, is
left as it is."
  (if (any selected-entry? options)
      options
      (cdr (mark-first-choosable options #f))))

(define* (select #:key options
                 (on-change #f)
                 name
                 (id #f)
                 (label #f)
                 (help-text #f)
                 (error #f)
                 (required #f)
                 (disabled #f)
                 (family '(font-sans))
                 (select-classes '(w-full max-w-full
                                        px-3 py-2
                                        border-2
                                        border-stone-700
                                        dark:border-onyx-100
                                        bg-stone-300/75
                                        text-onyx-500
                                        dark:bg-onyx-700
                                        dark:text-stone-300
                                        text-md
                                        rounded-xl
                                        shadow-md
                                        cursor-pointer
                                        transition-colors
                                        duration-150
                                        focus-visible:outline-2
                                        focus-visible:outline-offset-2
                                        outline-onyx-500))
                 (label-css '(text-lg font-light text-onyx-100
                                      dark:text-stone-300 font-sans py-2))
                 (select-flex-css '(my-2 flex flex-col gap-2 w-full
                                         sm:w-fit)))
  "Construct a dropdown list interactive selection menu wrapper.

The menu fills its container on phones and, from the small breakpoint up,
takes the width it needs and no more: a row such as a flag beside a
language name is shown whole, while a label long enough to matter stops at
the edge of its container instead of pushing a narrow page sideways.
A menu of a fixed width would instead clip the row it is showing, which is
what @code{min-content} does to a control the browser draws itself.

Which row the menu shows is markup, not script: it is carried by the
@code{selected} attribute of exactly one option, rendered from the
@var{selected-value} the options were built with, so the field a reader
sees is the field that is submitted. A menu whose rows match nothing -- a
stale value, or a hand-built list -- gets its first choosable row marked,
because that is the row the browser would display regardless.

A label is bound to the control through @code{for} whenever the menu has a
@var{name} or an @var{id} to bind to, and @var{help-text} and @var{error}
are linked by @code{aria-describedby} the same way, so the description of a
field reaches assistive technology with it. Give the menu a name (the
normal case for a form) and both bindings come for free.

The rows are a flat list, or groups of them: an @code{optgroup} entry stands
in the list beside the options and holds rows of its own, which is how a
long menu is read as a handful of headings instead of one run of rows.

@table @var
@item options
A list of option, glyph-option or optgroup S-expressions making up the menu.
@item on-change
A string JavaScript execution statement evaluated during interaction changes.
@item name
The element name context configuration string bound onto target HTML form tracking.
@item id
The unique DOM string selector matching layout identifier tables; defaults
to @var{name} for binding the label and the description.
@item label
The text introducing the field, rendered as a @code{<label>} bound to the control.
@item help-text
Optional helper copy rendered below the field and linked with @code{aria-describedby}.
@item error
Optional validation message rendered below the field with @code{role=\"alert\"}.
@item required
A boolean making the browser refuse to submit an empty menu.
@item disabled
A boolean disabling the control.
@item family
List of symbols representing base structural font choices.
@item select-classes
List of symbols specifying visual layout styles for the component wrapper card.
@item label-css
List of symbols representing presentation utility CSS classes for the label.
@item select-flex-css
List of symbols regulating structure container box margins and gaps.
@end table

@example
(select #:label \"Plan\"
        #:name 'plan
        #:options (list (option #:value \"cozy\" #:content \"Cozy (free)\"
                                #:selected-value \"cozy\")
                        (option #:value \"calm\" #:content \"Calm\"))
        #:on-change \"console.log('Changed!')\")
@end example"
  (let* ((field-id (if id id name))
         (error-id (and field-id (format #f "~a-error" field-id)))
         (help-id (and field-id (format #f "~a-help" field-id)))
         (described-by (cond
                         ((and help-text error) (format #f "~a ~a" help-id error-id))
                         (error error-id)
                         (help-text help-id)
                         (else #f)))
         (rows (state-selection options)))
    `((div (@ (class ,(mk-class select-flex-css)))
           ,@(if label
                 `((label (@ (class ,(mk-class label-css))
                             ,@(attr-when field-id 'for field-id))
                          ,label))
                 '())
           (select (@ ,@(attr-when name 'name name)
                      ,@(attr-when field-id 'id field-id)
                      ,@(attr-when on-change 'onchange on-change)
                      ,@(attr-when described-by 'aria-describedby described-by)
                      ,@(if (or required error)
                            '((aria-required "true"))
                            '())
                      ,@(attr-when error 'aria-invalid "true")
                      ,@(if required
                            '((required ""))
                            '())
                      ,@(if disabled
                            '((disabled ""))
                            '())
                      (class ,(mk-class (append select-classes family))))
                   ;; each row is one element of its own, so the menu's
                   ;; children are the rows and not a list of rows
                   ,@rows)
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
