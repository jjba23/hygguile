;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components code)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components button)
  #:use-module (hygguile components icon)
  #:use-module (hygguile components typography)
  #:use-module (hygguile js)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-13)
  #:use-module (uuid generate)
  #:export (code-sample pretty-code))

;; ====== Reading a specimen's own code ======
;;
;; Documentation pages show a component and the form that produced it, and the
;; form has to be shown the way its author wrote it. A Scheme form written the
;; short way is not what `write' prints -- every quoted list comes back as
;; `(quote ...)' -- and a form left on one line runs off the screen. So the
;; pretty printer below prints a datum as source a reader would recognize:
;; quoted forms in shorthand, the arguments of a form aligned under its head,
;; and a form that does not fit wrapped onto the next line.

;; The width a specimen's code is laid out for, in columns.  A form is code,
;; not prose: it is shown the way a Scheme writer would leave it in a file,
;; wrapped so it stays readable without a horizontal scroll of its own.
(define code-column-width
  72)

;; Render one datum on a single line, spelling a quoted form the short way.
;; `write' alone would leave every quoted list as `(quote ...)', which is what
;; a machine reads, not what a person writes.
(define (code-string datum)
  (cond
    ((and (pair? datum)
          (pair? (cdr datum))
          (null? (cddr datum))
          (eq? (car datum)
               'quote))
     (string-append "'"
                    (code-string (cadr datum))))
    ((and (pair? datum)
          (list? datum))
     (string-append "("
                    (string-join (map code-string datum) " ") ")"))
    ((null? datum)
     "()")
    ((vector? datum)
     (string-append "#("
                    (string-join (map code-string
                                      (vector->list datum)) " ") ")"))
    (else (with-output-to-string (lambda ()
                                   (write datum))))))

;; The columns a rendered line actually occupies: everything after its last
;; newline, since the lines before it are already placed.
(define (code-last-line rendered)
  (let ((nl (string-rindex rendered #\newline)))
    (if nl
        (substring rendered
                   (+ nl 1)
                   (string-length rendered)) rendered)))

(define (code-fits? text column)
  (<= (+ column
         (string-length text)) code-column-width))

;; A keyword and the value it introduces are one thing to a reader, so they
;; travel together: a row may break before the pair, but never between them.
(define (code-unit? items)
  (and (pair? (cdr items))
       (keyword? (car items))))

(define (code-unit-flat items)
  (if (code-unit? items)
      (string-append (code-string (car items)) " "
                     (code-string (cadr items)))
      (code-string (car items))))

(define (code-unit items column)
  (if (code-unit? items)
      (let ((head (code-string (car items))))
        (string-append head " "
                       (code-form (cadr items)
                                  (+ column
                                     (string-length head) 1))))
      (code-form (car items) column)))

(define (code-unit-tail items)
  (if (code-unit? items)
      (cddr items)
      (cdr items)))

;; Lay the arguments of a form out in a row, breaking before a unit that would
;; run past the column width, and indenting the ones that follow under the
;; first -- the way `guix style' leaves a keyword-heavy form.
(define (code-run items column indent)
  (let loop
    ((items items)
     (column column)
     (out ""))
    (if (null? items) out
        (let* ((separator (if (string=? out "") "" " "))
               (next-column (+ column
                               (string-length separator)))
               (flat (code-unit-flat items)))
          (if (and (> (string-length out) 0)
                   (not (code-fits? flat next-column)))
              (let ((rendered (code-unit items indent)))
                (loop (code-unit-tail items)
                      (+ indent
                         (string-length (code-last-line rendered)))
                      (string-append out "\n"
                                     (make-string indent #\space) rendered)))
              (let ((rendered (code-unit items next-column)))
                (loop (code-unit-tail items)
                      (+ next-column
                         (string-length (code-last-line rendered)))
                      (string-append out separator rendered))))))))

;; Render DATUM starting at column @var{column}, leaving it on one line when it
;; fits and breaking a form that does not.
(define (code-form datum column)
  (let ((flat (code-string datum)))
    (cond
      ((code-fits? flat column)
       flat)
      ((and (list? datum)
            (= (length datum) 2)
            (eq? (car datum)
                 'quote))
       (string-append "'"
                      (code-form (cadr datum)
                                 (+ column 1))))
      ((and (pair? datum)
            (list? datum))
       (let* ((head (car datum))
              (args (cdr datum))
              (head-rendered (code-form head
                                        (+ column 1)))
              (after-head (+ column 1
                             (string-length (code-last-line head-rendered)))))
         (if (null? args)
             (string-append "(" head-rendered ")")
             (let ((arg-column (+ after-head 1)))
               (string-append "(" head-rendered " "
                              (code-run args arg-column arg-column) ")")))))
      (else flat))))

(define (pretty-code datum)
  "Render @var{datum} as the source a reader would write: quoted forms in shorthand, the arguments of a form aligned under its head, and a form that does not fit wrapped at a fixed column width.

@table @var
@item datum
The S-expression to render, exactly as the page passes it to the component it shows.
@end table

@example
(pretty-code '(button \"Save\" #:size '(text-sm)))
;; => (button \"Save\"
;;             #:size
;;             '(text-sm))
@end example"
  (code-form datum 0))

;; ====== The specimen card ======

;; Evaluate a specimen the page wrote, so the form shown and the component
;; rendered are the same expression rather than two copies that drift apart.
;; The evaluation happens in a module that carries both the caller's bindings
;; and hygguile's own: a page usually calls `code-sample' from the module that
;; wrote it, but a request-handler serves its page from inside the server's
;; own module, and either way `button' has to be found.
(define* (render-specimen form #:key (value #f))
  (cond
    (value value)
    (else
     (let* ((environment (make-fresh-user-module))
            (source (with-output-to-string (lambda ()
                                             (write form)))))
       (module-use! environment (resolve-module '(hygguile hygguile)))
       (module-use! environment (current-module))
       (eval-string source environment)))))

(define* (code-sample form
                      #:key (value #f)
                      (id #f)
                      (label "Show code")
                      (copy-label "copy")
                      (notice-title "Copied to clipboard!")
                      (classes '(flex flex-col
                                      gap-4
                                      rounded-2xl
                                      border-2
                                      border-stone-500/25
                                      dark:border-onyx-100/25
                                      bg-stone-100/75
                                      dark:bg-onyx-900/50
                                      shadow-sm
                                      p-4))
                      (preview-classes '(flex flex-row flex-wrap gap-2))
                      (panel-classes '(hg-code-sample-panel flex flex-col gap-2))
                      (pre-classes '())
                      (toggle-classes '(js-only font-light
                                                text-sm
                                                text-onyx-300
                                                dark:text-stone-300
                                                cursor-pointer
                                                focus-visible:outline-2
                                                focus-visible:outline-offset-2
                                                outline-onyx-500)))
  "Show a component and the form that produced it, in one card.

The specimen is the form rendered, and the source beside it is the same form
pretty-printed, so the two can never disagree: pass the expression, not a
copy of its output. The source is folded away until a reader asks for it,
and it carries a copy button, which is what a documentation page is for.

The form is evaluated for display, in an environment holding both the
caller's bindings and @code{(hygguile hygguile)}, so a page only writes its
specimen once. Pass @var{value} to hand over an already-rendered fragment
instead -- useful when the specimen is not something that can be evaluated,
or when you would rather it not be.

@table @var
@item form
The S-expression to show and to render, e.g. @code{'(button \"Save\")}.
@item value
An already-rendered fragment to show as the specimen, or @code{#f} to render @var{form}.
@item id
A stable HTML identifier, or @code{#f} for a generated one. Give one when the page has to name the specimen, e.g. to link to it.
@item label
The accessible name of the control that unfolds the source.
@item copy-label
The text of the button that copies the source.
@item notice-title
The title of the notification a copy raises.
@item classes
List of CSS classes for the card.
@item preview-classes
List of CSS classes for the row holding the specimen and the fold control.
@item panel-classes
List of CSS classes for the panel the source lives in.
@item pre-classes
List of CSS classes for the @code{<pre>} itself, replacing the ones @code{pre} chooses; empty leaves the source in the mono face it is set in.
@item toggle-classes
List of CSS classes for the fold control.
@end table

@example
(code-sample '(button \"Save\"
                      #:on-click \"save()\"))
@end example"
  (let* ((uid (if id (format #f "~a" id) (generate-string-uuid)))
         (panel-id (format #f "~a-panel" uid))
         (pre-id (format #f "~a-pre" uid))
         (source (pretty-code form))
         (specimen (render-specimen form #:value value))
         ;; the classes below replace the `pre' component's own list, as they
         ;; do on every component, so an empty list has to leave the source in
         ;; the mono face and the wrap the component already chose for it
         (source-block (if (nil? pre-classes)
                           (pre source #:id pre-id)
                           (pre source #:id pre-id #:pre-classes pre-classes))))
    `((div (@ (class ,(mk-class classes)))
           (div (@ (class ,(mk-class preview-classes)))
                (div ,specimen)
                (button (@ (type "button")
                           (aria-label ,label)
                           (title ,label)
                           (aria-controls ,panel-id)
                           (aria-expanded "false")
                           (class ,(mk-class toggle-classes))
                           (onclick "hygguileToggleCodeSample(this)"))
                        ,(icon #:type 'code
                               #:icon-css '(text-xl cursor-pointer))))
           (div (@ (id ,panel-id)
                   (hidden "")
                   (class ,(mk-class panel-classes)))
                ,source-block
                (div (@ (class ,(mk-class '(w-min))))
                     ,(icon-button #:icon 'copy
                                   #:content copy-label
                                   #:on-click (format #f
                                               "hygguileCopyPreInnerText('~a'); ~a"
                                               uid
                                               (trigger-notification-function-js
                                                #:title notice-title
                                                #:body source
                                                #:body-font-family "font-mono")))))))))
