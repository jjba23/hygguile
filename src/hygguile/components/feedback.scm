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
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (alert progress spinner skeleton))

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
     (cons '(border-naples-yellow-500 bg-naples-yellow-500/25
                                      text-coffee-900
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
