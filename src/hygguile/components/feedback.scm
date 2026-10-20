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

(define-module (hygguile components feedback)
  #:use-module (hygguile abstraction)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 format)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:use-module (hygguile components glass)
  #:export (alert progress spinner skeleton
                   circular-progress
                   toast toast-tray
                   empty-state error-state
                   skeleton-heading skeleton-text skeleton-avatar
                   skeleton-card skeleton-table skeleton-form))

(define (alert-variant variant)
  "Return the border, background and text CSS classes for an alert @var{variant}.

Each variant keeps its hue in the border, the icon and the translucent
tint, while the ink is chosen for contrast: the dark end of the ramp on
the light theme, and a light ink on the dark theme. Some ramps (yellow,
blue) do not reach a readable end of their own, so their ink comes from a
darker sibling hue (@code{coffee}, @code{black-olive}) or a lighter one
(@code{moonstone}, @code{light-coral}), which is what keeps every variant
above the 4.5:1 contrast ratio of WCAG AA."
  (cond
    ((eq? 'success variant)
     (cons '(border-asparagus-500 bg-asparagus-500/25 text-black-olive-900
                                  dark:text-mantis-100)
           'check-circle))
    ((eq? 'warning variant)
     (cons '(border-naples-yellow-500 bg-naples-yellow-500/25 text-coffee-900
                                      dark:text-naples-yellow-100)
           'warning))
    ((eq? 'danger variant)
     (cons '(border-redwood-500 bg-redwood-500/25 text-claret-900
                                dark:text-light-coral-100)
           'warning-octagon))
    ((eq? 'neutral variant)
     (cons '(border-stone-500 bg-stone-500/25 text-onyx-500
                              dark:text-stone-300)
           'info))
    (else (cons '(border-jeans-blue-500 bg-jeans-blue-500/25
                                        text-jeans-blue-900
                                        dark:text-moonstone-100)
                'info))))

(define* (alert #:key title
                body
                (variant 'info)
                (role #f)
                (icon #f)
                (alert-classes '(border-2 rounded-xl
                                          px-4
                                          py-3
                                          my-2
                                          flex
                                          flex-row
                                          items-start
                                          gap-3
                                          shadow-sm
                                          font-sans
                                          transition-colors
                                          duration-200)))
  "Create an accessible inline alert or callout box.

Alerts are plain HTML and CSS, so they continue to render and be
announced by assistive technology when JavaScript is disabled.

@table @var
@item title
An optional short, bold heading for the alert.
@item body
The alert message text or inline nodes.
@item variant
A semantic keyword: @code{'info} (default), @code{'success}, @code{'warning}, @code{'danger} or @code{'neutral}.
@item role
An optional ARIA role override. Defaults to @code{alert} for danger and
@code{status} for every other variant.
@item icon
An optional Phosphor icon name overriding the variant default.
@item alert-classes
List of symbols representing container CSS classes.
@end table

@example
(alert #:title \"Heads up\" #:body \"Your session expires soon.\" #:variant 'warning)
@end example"
  (let* ((variant-info (alert-variant variant))
         (variant-classes (car variant-info))
         (default-icon (cdr variant-info))
         (resolved-role (if role role
                            (if (eq? 'danger variant)
                                'alert
                                'status))))
    `((div (@ (role ,(symbol->string resolved-role))
              (class ,(mk-class (append alert-classes variant-classes))))
           ,(hyg:icon #:type (if icon icon default-icon)
                      #:icon-css '(text-xl shrink-0))
           (div (@ (class ,(mk-class '(flex flex-col gap-1))))
                ,@(if title
                      `((strong (@ (class ,(mk-class '(text-md font-semibold))))
                                ,title))
                      '())
                ,@(if body
                      `((p (@ (class ,(mk-class '(text-md font-light leading-6))))
                           ,body))
                      '()))))))

(define* (progress #:key value
                   (max 100)
                   label
                   (show-value #f)
                   (progress-classes '(w-full max-w-prose
                                              h-4
                                              rounded-512
                                              overflow-hidden
                                              bg-stone-500/25
                                              dark:bg-onyx-500/25))
                   (bar-classes '()))
  "Create a native HTML @code{<progress>} bar.

@table @var
@item value
The current value. When omitted the bar renders in an indeterminate state.
@item max
The maximum value. Defaults to @code{100}.
@item label
An optional text label shown above the bar and used for accessibility.
@item show-value
A boolean rendering the percentage next to the label.
@item progress-classes
List of symbols representing the progress bar CSS classes.
@item bar-classes
List of additional utility CSS classes.
@end table

@example
(progress #:value 42 #:label \"Uploading\" #:show-value #t)
@end example"
  (let* ((label-id (and label "hg-progress-label"))
         (percentage (if value
                         (inexact->exact (round (* 100
                                                   (/ (if (number? value)
                                                          value
                                                          (string->number (format
                                                                           #f
                                                                           "~a"
                                                                           value)))
                                                      max)))) 0)))
    `((div (@ (class ,(mk-class (append '(flex flex-col gap-1 my-2 w-full)
                                        bar-classes))))
           ,@(if label
                 `((div (@ (class ,(mk-class '(flex flex-row justify-between
                                                    items-center gap-2))))
                        (span (@ (id ,label-id)
                                 (class ,(mk-class '(text-sm font-light
                                                     text-onyx-300
                                                     dark:text-stone-500
                                                     font-sans))))
                              ,label)
                        ,@(if show-value
                              `((span (@ (class ,(mk-class '(text-sm
                                                             font-medium
                                                             text-onyx-500
                                                             dark:text-stone-300
                                                             font-sans
                                                             tabular-nums))))
                                      ,(format #f "~a%" percentage)))
                              '())))
                 '())
           (progress (@ (class "hg-progress")
                        ,@(attr-when label
                                     'aria-label label)
                        ,@(attr-when value
                                     'value value)
                        (max ,(format #f "~a" max))) "")))))

(define* (spinner #:key (size 'md)
                  (label "Loading...")
                  (classes '()))
  "Create an accessible CSS loading spinner.

The spinner animates through CSS only and exposes a screen-reader label
through @code{role=\"status\"}, so it works without JavaScript.

@table @var
@item size
A size keyword: @code{'xs}, @code{'sm}, @code{'md}, @code{'lg} or @code{'xl}.
@item label
The screen-reader status text. Defaults to @code{\"Loading...\"}.
@item classes
List of additional utility CSS classes.
@end table

@example
(spinner #:size 'lg #:label \"Fetching results\")
@end example"
  (let ((size-classes (cond
                        ((eq? 'xs size)
                         '(w-4 h-4))
                        ((eq? 'sm size)
                         '(w-6 h-6))
                        ((eq? 'lg size)
                         '(w-12 h-12))
                        ((eq? 'xl size)
                         '(w-16 h-16))
                        (else '(w-8 h-8)))))
    `((span (@ (role status)
               (aria-live polite)
               (class ,(mk-class (append classes size-classes
                                         '(hg-spinner animate-spin
                                                      inline-block)))))
            (span (@ (class "sr-only"))
                  ,label)))))

(define* (skeleton #:key (lines 1)
                   (height 'md)
                   (rounded 'md)
                   (classes '()))
  "Create a pulsing placeholder shown while content loads.

@table @var
@item lines
The number of placeholder rows to render.
@item height
A height keyword: @code{'sm}, @code{'md} or @code{'lg}.
@item rounded
A rounding keyword: @code{'none}, @code{'sm}, @code{'md} or @code{'full}.
@item classes
List of additional utility CSS classes.
@end table

@example
(skeleton #:lines 3 #:height 'md)
@end example"
  (let ((height-classes (cond
                          ((eq? 'sm height)
                           '(h-4))
                          ((eq? 'lg height)
                           '(h-10))
                          (else '(h-6))))
        (rounded-classes (cond
                           ((eq? 'none rounded)
                            '())
                           ((eq? 'sm rounded)
                            '(rounded-md))
                           ((eq? 'full rounded)
                            '(rounded-512))
                           (else '(rounded-xl)))))
    `((div (@ (class ,(mk-class (append classes
                                        '(flex flex-col gap-2 my-2 w-full)))))
           ,@(map (lambda (n)
                    `(div (@ (class ,(mk-class (append '(animate-pulse
                                                         bg-stone-500/25
                                                         dark:bg-onyx-500/25
                                                         w-full)
                                                       height-classes
                                                       rounded-classes))))))
                  (iota lines))))))





;; ===== Progress, in both shapes =====

(define* (circular-progress #:key value
                            (max 100)
                            (size 'md)
                            (label #f)
                            (show-value #f)
                            (stroke-width 4)
                            (classes '()))
  "Create a circular progress ring.

The ring is an SVG with a normalised @code{pathLength} of 100, so the
fraction is written as a dash of that length and the browser does the
geometry; no trigonometric value has to be computed in Scheme. With no
@var{value} the ring is indeterminate: it spins through CSS and the
accessible value is left out, which is what tells assistive technology that
the work has no known end.

@table @var
@item value
The current value, or @code{#f} for an indeterminate ring.
@item max
The maximum value. Defaults to @code{100}.
@item size
@code{'xs}, @code{'sm}, @code{'md}, @code{'lg} or @code{'xl}.
@item label
An accessible name for the ring.
@item show-value
Whether the percentage is written in the middle. Defaults to false.
@item stroke-width
The ring's stroke width in the SVG's own units. Defaults to @code{4}.
@item classes
Extra classes for the wrapper.
@end table

@example
(circular-progress #:value 68 #:label \"Importing\" #:show-value #t)
@end example"
  (let* ((numeric (and value (number? value) value))
         (percent (and numeric
                       (let ((pct (round (* 100 (/ numeric
                                                   (if (zero? max)
                                                       100
                                                       max))))))
                         (cond
                           ((< pct 0) 0)
                           ((> pct 100) 100)
                           (else pct)))))
         (size-classes (cond
                         ((eq? 'xs size) '(w-8 h-8))
                         ((eq? 'sm size) '(w-12 h-12))
                         ((eq? 'lg size) '(w-24 h-24))
                         ((eq? 'xl size) '(w-32 h-32))
                         (else '(w-16 h-16))))
         (text-size (cond
                      ((eq? 'xs size) '(text-sm))
                      ((eq? 'sm size) '(text-sm))
                      ((eq? 'lg size) '(text-xl))
                      ((eq? 'xl size) '(text-2xl))
                      (else '(text-md))))
         (ring-classes (append '(hg-ring -rotate-90 w-full h-full)
                               (if percent
                                   '()
                                   '(hg-ring-indeterminate))))
         (value-label (if percent
                          (format #f "~a%" percent)
                          "…")))
    (list `(div (@ (class ,(mk-class (append '(inline-flex flex-col
                                                       items-center gap-2)
                                             classes))))
                (span (@ (class ,(mk-class (append '(hg-ring-wrapper
                                                     relative inline-flex
                                                     items-center
                                                     justify-center)
                                                   size-classes)))
                         (role "progressbar")
                         ,@(attr-when label 'aria-label label)
                         (aria-valuemin "0")
                         (aria-valuemax ,(format #f "~a" max))
                         ,@(if percent
                               (list (cons 'aria-valuenow
                                           (format #f "~a" numeric)))
                               '((aria-valuetext "Loading"))))
                      (svg (@ (viewBox "0 0 42 42")
                              (class ,(mk-class ring-classes)))
                           (circle (@ (cx "21")
                                      (cy "21")
                                      (r "18")
                                      (fill "none")
                                      (stroke-width ,(format #f "~a"
                                                            stroke-width))
                                      (pathLength "100")
                                      (class "hg-ring-track")))
                           (circle (@ (cx "21")
                                      (cy "21")
                                      (r "18")
                                      (fill "none")
                                      (stroke-width ,(format #f "~a"
                                                            stroke-width))
                                      (pathLength "100")
                                      (stroke-dasharray ,(if percent
                                                             (format #f "~a 100"
                                                                     percent)
                                                             "25 75"))
                                      (class "hg-ring-value"))))
                      ,@(if show-value
                            (list `(span (@ (class ,(mk-class (append
                                                               '(absolute inset-0
                                                                 flex items-center
                                                                 justify-center
                                                                 font-sans
                                                                 font-semibold
                                                                 tabular-nums
                                                                 text-onyx-500
                                                                 dark:text-stone-300)
                                                               text-size))))
                                         ,value-label))
                            '()))
                ,@(if label
                      (list `(span (@ (class ,(mk-class '(text-sm font-light
                                                                  text-onyx-300
                                                                  dark:text-stone-500
                                                                  font-sans))))
                                   ,label))
                      '())))))

;; ===== Toasts =====

(define (toast-icon variant)
  "Return the Phosphor icon name for a toast @var{variant}."
  (cond
    ((eq? 'success variant) 'check-circle)
    ((eq? 'warning variant) 'warning)
    ((eq? 'danger variant) 'warning-octagon)
    (else 'info)))

(define (toast-icon-classes variant)
  "Return the icon colour classes for a toast @var{variant}."
  (cond
    ((eq? 'success variant) '(text-asparagus-900 dark:text-mantis-100))
    ((eq? 'warning variant) '(text-coffee-900 dark:text-naples-yellow-100))
    ((eq? 'danger variant) '(text-claret-900 dark:text-light-coral-100))
    (else '(text-jeans-blue-900 dark:text-moonstone-100))))

(define* (toast #:key title
                (body #f)
                (variant 'info)
                (duration 5000)
                (dismissible? #t)
                (dismiss-label "Dismiss notification")
                (id #f)
                (classes '()))
  "Create one toast: a small frosted card that arrives, says one thing, and
can leave again.

The toast is a live region of its own -- @code{status} for a quiet variant
and @code{alert} for a danger -- so a screen reader announces it without the
page having to move focus. The dismiss control is a progressive enhancement
(@code{js-only}); a toast rendered by the server is still readable and still
carries its text, and the script that queues toasts is what makes it leave on
its own.

Toast markup is also the template @code{toast-tray} clones, which is why the
title and body carry @code{data-hg-toast-title} and
@code{data-hg-toast-body}: one shape serves both the server-rendered case and
the queued one.

@table @var
@item title
The toast's heading.
@item body
Optional supporting copy.
@item variant
@code{'info} (default), @code{'success}, @code{'warning} or @code{'danger}.
@item duration
How long the toast stays, in milliseconds. Defaults to @code{5000}; the
script reads it from the markup.
@item dismissible?
Whether the dismiss control is rendered. Defaults to true.
@item dismiss-label
The accessible name of the dismiss control.
@item id
An optional identifier.
@item classes
Extra classes for the card.
@end table

@example
(toast #:title \"Saved\" #:body \"Your changes are live.\" #:variant 'success)
@end example"
  (let* ((role (if (eq? 'danger variant) "alert" "status"))
         (live (if (eq? 'danger variant) "assertive" "polite"))
         (icon-name (toast-icon variant))
         (icon-class (string->symbol (format #f "ph-~a" icon-name)))
         (icon `(i (@ (class ,(mk-class (append (list 'ph icon-class 'text-xl
                                                      'shrink-0)
                                                (toast-icon-classes variant))))
                      (aria-hidden "true"))))
         (title-node `(p (@ (class ,(mk-class '(text-md font-semibold
                                                       text-onyx-500
                                                       dark:text-stone-300
                                                       font-sans)))
                            (data-hg-toast-title ""))
                         ,(or title "")))
         (body-node (if body
                        (list `(p (@ (class ,(mk-class '(text-sm font-light
                                                                  text-onyx-300
                                                                  dark:text-stone-500
                                                                  font-sans
                                                                  leading-6)))
                                     (data-hg-toast-body ""))
                                  ,body))
                        '()))
         (dismiss (if dismissible?
                      (list `(button (@ (type "button")
                                         (class "hg-toast-dismiss js-only p-1
                                                 cursor-pointer
                                                 text-onyx-300
                                                 dark:text-stone-500
                                                 transition-colors duration-150")
                                         (aria-label ,dismiss-label)
                                         (onclick "hygguileDismissToast(this)"))
                                      "×"))
                      '()))
         (attributes (append (list (cons 'role role)
                                   (cons 'aria-live live)
                                   (cons 'aria-atomic "true")
                                   (cons 'data-hg-toast "")
                                   (cons 'data-hg-toast-duration
                                         (format #f "~a" duration)))
                             (if id
                                 (list (cons 'id id))
                                 '()))))
    (glass-panel (list icon
                       `(div (@ (class ,(mk-class '(flex flex-col gap-1
                                                           flex-1
                                                           min-w-0))))
                             ,title-node
                             ,@body-node)
                       dismiss)
                 #:tag 'div
                 #:attributes attributes
                 #:tint '(bg-stone-300/90 dark:bg-onyx-700/90)
                 #:rounding '(rounded-xl)
                 #:border '(border-2 border-stone-500/25
                                    dark:border-onyx-100/25)
                 #:shadow '(shadow-lg)
                 #:padding '(py-4 px-4)
                 #:classes (append '(hg-toast w-full max-w-sm
                                              pointer-events-auto
                                              flex flex-row
                                              items-start
                                              gap-3)
                                   classes))))

(define* (toast-tray #:key (id "hg-toast-tray")
                     (label "Notifications")
                     (max 4)
                     (position 'bottom-end)
                     (template-id "hg-toast-template")
                     (classes '()))
  "Create the live region a page's toasts arrive in, and its template.

The tray is one polite region, never one region per toast: a screen reader
announces an addition once, and the page keeps a single place where its
notifications live. The template inside it is a toast with empty slots; the
queue script clones it, fills the slots with @code{textContent}, appends the
clone, and removes it after its duration. Nothing a notification says is
ever parsed as markup, so a title cannot smuggle an element into the page.

@table @var
@item id
The tray's identifier.
@item label
Its accessible name.
@item max
How many toasts the tray keeps at once, oldest first.
@item position
@code{'bottom-end} (default), @code{'bottom-start}, @code{'top-end} or
@code{'top-start}.
@item template-id
The identifier of the template the script clones.
@item classes
Extra classes for the tray.
@end table

@example
(toast-tray)
@end example"
  (let* ((position-classes (cond
                             ((eq? 'bottom-start position)
                              '(bottom-4 left-4 items-start))
                             ((eq? 'top-end position)
                              '(top-4 right-4 items-end))
                             ((eq? 'top-start position)
                              '(top-4 left-4 items-start))
                             (else '(bottom-4 right-4 items-end))))
         (tray-classes (append '(hg-toast-tray fixed z-32 flex flex-col
                                               gap-2 pointer-events-none)
                               position-classes classes))
         (template (toast #:title "" #:body "" #:duration 5000)))
    (list `(div (@ (id ,id)
                   (role "region")
                   (aria-label ,label)
                   (data-hg-toast-tray "")
                   (data-hg-toast-max ,(format #f "~a" max))
                   (class ,(mk-class tray-classes)))
                (template (@ (id ,template-id))
                          ,template)))))

;; ===== Empty and error states =====

(define* (empty-state #:key (icon 'tray)
                      title
                      (body #f)
                      (action #f)
                      (classes '()))
  "Create the first-class empty state a data component falls back to.

An empty list is not an error and should not look like one: the icon is a
quiet object, the copy says what is missing and, when there is one, the
action says what to do about it. Assistive technology gets the heading it
needs to understand the region, because the title is a real @code{<h3>}.

@table @var
@item icon
The Phosphor icon name. Defaults to @code{'tray}.
@item title
The heading that names the state.
@item body
Optional explanatory copy.
@item action
An optional node -- usually a link or a button -- offering the next step.
@item classes
Extra classes for the wrapper.
@end table

@example
(empty-state #:title \"No projects yet\"
             #:body \"Create one to get started.\"
             #:action (primary-button \"New project\"))
@end example"
  (list `(div (@ (class ,(mk-class (append '(hg-empty flex flex-col
                                                       items-center
                                                       text-center
                                                       gap-3 py-12 px-6)
                                             classes))))
              (span (@ (aria-hidden "true")
                       (class ,(mk-class '(inline-flex items-center
                                                       justify-center
                                                       p-4
                                                       rounded-512
                                                       bg-stone-500/25
                                                       dark:bg-onyx-500/25))))
                    ,(hyg:icon #:type icon
                               #:icon-css '(text-4xl text-onyx-300
                                                   dark:text-stone-500)))
              (h3 (@ (class ,(mk-class '(text-xl font-semibold
                                                 text-onyx-500
                                                 dark:text-stone-300
                                                 font-sans))))
                  ,title)
              ,@(if body
                    (list `(p (@ (class ,(mk-class '(text-md font-light
                                                             text-onyx-300
                                                             dark:text-stone-500
                                                             font-sans
                                                             leading-6
                                                             max-w-prose))))
                                ,body))
                    '())
              ,@(if action (list action) '()))))

(define (retry-link-node label)
  "Return the default retry link of an error state."
  `(a (@ (href "")
         (class ,(mk-class '(inline-flex items-center px-4 py-2 rounded-xl
                                        border-2 border-stone-700
                                        dark:border-onyx-100
                                        bg-redwood-700 text-stone-100
                                        font-medium font-sans text-md
                                        no-underline))))
      ,label))

(define (error-detail-node details)
  "Return the folded technical detail of an error state, or an empty list."
  (if details
      (list `(details (@ (class ,(mk-class '(my-2 max-w-prose))))
                      (summary (@ (class ,(mk-class
                                           '(cursor-pointer text-sm font-medium
                                                             text-onyx-300
                                                             dark:text-stone-500))))
                               "Technical details")
                      (pre (@ (class ,(mk-class
                                       '(mt-2 p-3 rounded-lg
                                              bg-stone-300/75
                                              dark:bg-onyx-700/75
                                              text-sm font-mono
                                              text-onyx-500
                                              dark:text-stone-300
                                              overflow-x-auto))))
                           ,details)))
      '()))

(define* (error-state #:key (title "Something went wrong")
                      (body "The page could not load its data.")
                      (retry #f)
                      (retry-label "Try again")
                      (details #f)
                      (classes '()))
  "Create the error state a data component shows when a request failed.

It is an empty state with a different voice -- a warning mark, a danger ink,
and a retry action -- because \"there is nothing here\" and \"this did not
load\" call for different responses from the reader. The retry is just a
link or a button the page passes, so it works with a normal navigation and
no client-side store has to be asked to try again.

@table @var
@item title
The heading. Defaults to a generic failure sentence.
@item body
The explanation. Defaults to a generic one.
@item retry
An optional retry node, usually a link back to the same URL.
@item retry-label
The text of the default retry link, used when no @var{retry} node is given.
@item details
Optional technical detail, folded away in a disclosure.
@item classes
Extra classes for the wrapper.
@end table

@example
(error-state #:retry (a \"Try again\" #:href \"/reports\"))
@end example"
  (list `(div (@ (class ,(mk-class (append '(hg-error) classes))))
              ,@(empty-state #:icon 'warning-octagon
                             #:title title
                             #:body body
                             #:action (if retry
                                          retry
                                          (list (retry-link-node retry-label))))
              ,@(error-detail-node details))))

;; ===== Skeletons, per component =====

(define skeleton-block-classes
  '(animate-pulse bg-stone-500/25 dark:bg-onyx-500/25 rounded-xl))

(define* (skeleton-heading #:key (width '(w-1/2)) (classes '()))
  "A placeholder for a heading line.

@table @var
@item width
A width utility list. Defaults to @code{(w-1/2)}.
@item classes
Extra classes.
@end table

@example
(skeleton-heading #:width '(w-1/3))
@end example"
  (list `(div (@ (aria-hidden "true")
                 (class ,(mk-class (append skeleton-block-classes
                                           '(h-8 my-2)
                                           width classes)))))))

(define* (skeleton-text #:key (lines 3)
                        (last-width '(w-2/3))
                        (classes '()))
  "A placeholder for a paragraph, one block per line.

The last line is shorter, which is what makes the block read as text rather
than as a table. The whole placeholder is hidden from assistive technology;
the loading state is announced once by whatever region owns it.

@table @var
@item lines
How many lines to draw.
@item last-width
The width of the final line. Defaults to @code{(w-2/3)}.
@item classes
Extra classes.
@end table

@example
(skeleton-text #:lines 4)
@end example"
  (let* ((count (max 1 lines))
         (rows (map (lambda (index)
                      (let ((last? (= index (- count 1))))
                        `(div (@ (class ,(mk-class
                                          (append skeleton-block-classes
                                                  '(h-4)
                                                  (if last?
                                                      last-width
                                                      '(w-full)))))))))
                    (iota count))))
    (list `(div (@ (aria-hidden "true")
                   (class ,(mk-class (append '(flex flex-col gap-2
                                                      my-2 w-full)
                                             classes))))
                ,@rows))))

(define* (skeleton-avatar #:key (size 'md) (classes '()))
  "A placeholder for an avatar.

@table @var
@item size
@code{'sm}, @code{'md} or @code{'lg}.
@item classes
Extra classes.
@end table

@example
(skeleton-avatar #:size 'lg)
@end example"
  (let ((size-classes (cond
                        ((eq? 'sm size) '(w-10 h-10))
                        ((eq? 'lg size) '(w-16 h-16))
                        (else '(w-12 h-12)))))
    (list `(div (@ (aria-hidden "true")
                   (class ,(mk-class (append skeleton-block-classes
                                             '(rounded-512 shrink-0)
                                             size-classes classes))))))))

(define* (skeleton-card #:key (lines 3) (avatar? #f) (classes '()))
  "A placeholder for a card: a header row and a few lines of copy.

@table @var
@item lines
How many body lines to draw.
@item avatar?
Whether the header carries an avatar placeholder.
@item classes
Extra classes.
@end table

@example
(skeleton-card #:lines 2 #:avatar? #t)
@end example"
  (let ((header (append (if avatar? (skeleton-avatar) '())
                        (list `(div (@ (class ,(mk-class '(flex flex-col
                                                                  gap-2 flex-1))))
                                    ,@(skeleton-heading #:width '(w-2/5)))))))
    (list `(div (@ (aria-hidden "true")
                   (class ,(mk-class (append '(hg-skeleton-card flex flex-col
                                                                gap-3 p-5
                                                                my-4 rounded-2xl
                                                                border-2
                                                                border-stone-500/25
                                                                dark:border-onyx-100/25
                                                                bg-stone-100/75
                                                                dark:bg-onyx-900/50)
                                             classes))))
                (div (@ (class ,(mk-class '(flex flex-row items-center
                                                   gap-3))))
                     ,@header)
                ,@(skeleton-text #:lines lines #:last-width '(w-3/4))))))

(define* (skeleton-table #:key (rows 3)
                         (columns 4)
                         (classes '()))
  "A placeholder for a data table: a header rule and the requested rows.

@table @var
@item rows
How many body rows to draw.
@item columns
How many cells per row.
@item classes
Extra classes.
@end table

@example
(skeleton-table #:rows 5 #:columns 3)
@end example"
  (let* ((cols (max 1 columns))
         (header-cells (map (lambda (index)
                              `(div (@ (class ,(mk-class
                                                (append skeleton-block-classes
                                                        '(h-4 flex-1)))))))
                            (iota cols)))
         (row-cells (map (lambda (column)
                           `(div (@ (class ,(mk-class
                                             (append skeleton-block-classes
                                                     '(h-4 flex-1)))))))
                         (iota cols)))
         (body-rows (map (lambda (row)
                           `(div (@ (class ,(mk-class '(flex flex-row gap-4
                                                               p-3
                                                               border-t-2
                                                               border-stone-500/25
                                                               dark:border-onyx-100/25))))
                                 ,@row-cells))
                         (iota (max 1 rows)))))
    (list `(div (@ (aria-hidden "true")
                   (class ,(mk-class (append '(hg-skeleton-table my-4 w-full
                                                                rounded-xl
                                                                border-2
                                                                border-stone-500/25
                                                                dark:border-onyx-100/25
                                                                overflow-hidden)
                                             classes))))
                (div (@ (class ,(mk-class '(flex flex-row gap-4 p-3
                                                   bg-stone-500/25
                                                   dark:bg-onyx-500/25))))
                     ,@header-cells)
                ,@body-rows))))

(define* (skeleton-form #:key (fields 3) (classes '()))
  "A placeholder for a form: one field block per control.

@table @var
@item fields
How many field blocks to draw.
@item classes
Extra classes.
@end table

@example
(skeleton-form #:fields 4)
@end example"
  (let ((blocks (map (lambda (index)
                       `(div (@ (class ,(mk-class '(flex flex-col gap-2))))
                             ,@(skeleton-heading #:width '(w-1/4))
                             (div (@ (class ,(mk-class
                                              (append skeleton-block-classes
                                                      '(h-12 w-full))))))))
                     (iota (max 1 fields)))))
    (list `(div (@ (aria-hidden "true")
                   (class ,(mk-class (append '(hg-skeleton-form flex flex-col
                                                                gap-5 my-2
                                                                w-full)
                                             classes))))
                ,@blocks))))
