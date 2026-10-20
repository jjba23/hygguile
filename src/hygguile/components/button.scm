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

(define-module (hygguile components button)
  #:use-module (hygguile abstraction)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (button icon-button
                   icon-only-button
                   primary-button
                   secondary-button
                   ghost-button
                   danger-button
                   submit-button
                   danger-submit-button
                   ui-mode-button
                   light-button
                   mono-button))

(define* (button content
                 #:key (id "")
                 (type 'button)
                 (hidden #f)
                 (on-click "")
                 (loading #f)
                 (loading-label "Loading")
                 (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                 (hover-background '(hover:bg-stone-900/90
                                     dark:hover:bg-onyx-900))
                 (border-size '(border-2))
                 (border-color '(border-stone-700 dark:border-onyx-300))
                 (shadow '(shadow-md))
                 (color '(text-onyx-300 dark:text-stone-300))
                 (size '(text-md))
                 (active '(active:scale-95))
                 (family '(font-sans))
                 (weight '(font-medium))
                 (rounding '(rounded-2xl))
                 (extra-classes '(py-2 px-4
                                       max-w-prose
                                       cursor-pointer
                                       select-none
                                       transition-colors
                                       duration-200
                                       ease-in-out
                                       focus-visible:outline-2
                                       focus-visible:outline-offset-2
                                       outline-onyx-500)))
  "Create a standard HTML button element.

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@item id
An optional HTML identifier string.
@item type
A symbol representing the HTML button type (e.g., @code{'button}, @code{'submit}).
@item hidden
A boolean indicating whether the button should be hidden.
@item on-click
A JavaScript handler string triggered on click events.
@item loading
A boolean putting the button in its loading state: a spinner appears, the
control is disabled, and @code{aria-busy} says why.
@item loading-label
The spoken label of the loading state. Defaults to @code{\"Loading\"}.
@item background
List of symbols for background CSS classes.
@item hover-background
List of symbols for hover background CSS classes.
@item border-size
List of symbols for border width CSS classes.
@item border-color
List of symbols for border color CSS classes.
@item shadow
List of symbols for container shadow CSS classes.
@item color
List of symbols for text color CSS classes.
@item size
List of symbols for text sizing CSS classes.
@item active
List of symbols for active state transformation CSS classes.
@item family
List of symbols for font family CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item rounding
List of symbols for border radius CSS classes.
@item extra-classes
List of utility formatting layout classes.
@end table

@example
(button \"Click Me\" #:id \"btn-primary\" #:on-click \"alert('Hello!')\")
(button \"Saving\" #:loading #t)
@end example"
  (let* ((button-css (append extra-classes
                             color
                             background
                             hover-background
                             border-color
                             rounding
                             shadow
                             border-size
                             size
                             active
                             family
                             weight
                             (if loading
                                 '(cursor-wait opacity-80)
                                 '())))
         (spinner `(span (@ (class ,(mk-class '(hg-spinner
                                                animate-spin
                                                inline-block
                                                w-4
                                                h-4
                                                mr-2)))
                            (aria-hidden "true"))))
         (busy-label `(span (@ (class "sr-only")) ,loading-label))
         (children (if loading
                       (list spinner busy-label content)
                       content)))
    `(button (@ (type ,(symbol->string type))
                (id ,id)
                (class ,(mk-class button-css))
                ,@(if hidden
                      '((hidden ""))
                      '((visible "")))
                ,@(if loading
                      '((disabled "")
                        (aria-busy "true"))
                      '())
                (onclick ,on-click))
             ,children)))

(define* (icon-button #:key (id "")
                      icon
                      content
                      (hidden #f)
                      (on-click "")
                      (type 'button)
                      (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                      (hover-background '(hover:bg-stone-900/90
                                          dark:hover:bg-onyx-900))
                      (border-size '(border-2))
                      (border-color '(border-stone-700 dark:border-onyx-300))
                      (shadow '(shadow-md))
                      (size '(text-md))
                      (family '(font-sans))
                      (weight '(font-medium))
                      (color '(text-onyx-300 dark:text-stone-300))
                      (rounding '(rounded-2xl))
                      (active '(active:scale-95))
                      (icon-css '(text-onyx-300 dark:text-stone-100 text-md))
                      (extra-classes '(py-2 px-4
                                            max-w-prose
                                            cursor-pointer
                                            select-none
                                            transition-colors
                                            duration-200
                                            ease-in-out
                                            focus-visible:outline-2
                                            focus-visible:outline-offset-2
                                            outline-onyx-500))
                      (icon-text-container-classes '(flex flex-row gap-1
                                                          items-center)))
  "Create a button containing both an icon and text.

@table @var
@item id
An optional HTML identifier string.
@item icon
A symbol identifying the type of icon to render.
@item content
The text string or components positioned next to the icon.
@item hidden
A boolean indicating whether the button should be hidden.
@item on-click
A JavaScript handler string triggered on click events.
@item type
A symbol representing the HTML button type.
@item background
List of symbols for background CSS classes.
@item hover-background
List of symbols for hover background CSS classes.
@item border-size
List of symbols for border width CSS classes.
@item border-color
List of symbols for border color CSS classes.
@item shadow
List of symbols for shadow CSS classes.
@item size
List of symbols for text sizing CSS classes.
@item family
List of symbols for font family CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item color
List of symbols for text color CSS classes.
@item rounding
List of symbols for border radius CSS classes.
@item active
List of symbols for active state transformation CSS classes.
@item icon-css
List of symbols targeting icon coloring and sizing classes.
@item extra-classes
List of utility layout CSS classes.
@item icon-text-container-classes
List of symbols applied to the inner layout wrapper surrounding the icon and content.
@end table

@example
(icon-button #:icon 'download #:content \"Fetch Data\" #:on-click \"downloadData()\")
@end example"
  (let ((button-css (append extra-classes
                            color
                            hover-background
                            background
                            border-color
                            size
                            active
                            rounding
                            border-size
                            shadow
                            family
                            weight)))
    `(button (@ (onclick ,on-click)
                (id ,id)
                (type ,(symbol->string type))
                (class ,(mk-class button-css))
                ,(if hidden
                     '(hidden "")
                     '(visible "")))
             (div (@ (class ,(mk-class icon-text-container-classes)))
                  ,(hyg:icon #:type icon
                             #:icon-css icon-css)
                  (span ,content)))))

(define* (submit-button content)
  "Create a green-themed standard HTML form submission button.

The fill is the dark end of the green ramp with near-white type on the
light theme, and the light end with dark type on the dark theme, so the
label clears WCAG AA (4.5:1) whichever theme is active.

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@end table

@example
(submit-button \"Save Preferences\")
@end example"
  (button content
          #:type 'submit
          #:background '(bg-asparagus-900 dark:bg-asparagus-100)
          #:color '(text-stone-100 dark:text-onyx-900)
          #:hover-background '(hover:bg-black-olive-700
                               dark:hover:bg-asparagus-300)))

(define* (danger-submit-button content)
  "Create a red-themed HTML form submission button meant for destructive actions.

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@end table

@example
(danger-submit-button \"Delete Repository\")
@end example"
  (button content
          #:type 'submit
          #:background '(bg-redwood-700)
          #:color '(text-stone-300)
          #:hover-background '(hover:bg-redwood-900)))

(define* (mono-button content)
  "Create a button pre-configured with a monospace font family.

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@end table

@example
(mono-button \"git commit\")
@end example"
  (button content
          #:family 'font-mono))

(define* (light-button content)
  "Create a button pre-configured with a light font weight.

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@end table

@example
(light-button \"Read More...\")
@end example"
  (button content
          #:weight 'font-light))

(define* (ui-mode-button #:key (icon 'faders)
                         (content "ui mode")
                         (type 'button)
                         (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                         (hover-background '(hover:bg-stone-900/90
                                             dark:hover:bg-onyx-900))
                         (border-size '(border-2))
                         (border-color '(border-stone-700 dark:border-onyx-300))
                         (shadow '(shadow-md))
                         (size '(text-md))
                         (active '(active:scale-95))
                         (family '(font-sans))
                         (weight '(font-medium))
                         (color '(text-onyx-300 dark:text-stone-300))
                         (on-click "hygguileToggleDarkTheme()")
                         (rounding '(rounded-2xl))
                         (icon-css '(text-onyx-300 dark:text-stone-300 text-xl))
                         (extra-classes '(py-2 px-4
                                               max-w-prose
                                               cursor-pointer
                                               select-none
                                               transition-colors
                                               duration-200
                                               ease-in-out
                                               focus-visible:outline-2
                                               focus-visible:outline-offset-2
                                               outline-onyx-500))
                         (icon-text-container-classes '(flex flex-row gap-1
                                                             items-center)))
  "Create a utility button pre-wired to toggle UI dark/light mode themes.

@table @var
@item icon
A symbol identifying the default icon type.
@item content
The description text displayed within the button layout.
@item type
A symbol representing the HTML button type.
@item background
List of symbols for background CSS classes.
@item hover-background
List of symbols for hover background CSS classes.
@item border-size
List of symbols for border width CSS classes.
@item border-color
List of symbols for border color CSS classes.
@item shadow
List of symbols for shadow CSS classes.
@item size
List of symbols for text sizing CSS classes.
@item active
List of symbols for active state transformation CSS classes.
@item family
List of symbols for font family CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item color
List of symbols for text color CSS classes.
@item on-click
The global JavaScript function invocation string triggered to process the theme change.
@item rounding
List of symbols for border radius CSS classes.
@item icon-css
List of symbols targeting icon coloring and sizing classes.
@item extra-classes
List of utility layout CSS classes.
@item icon-text-container-classes
List of symbols applied to the inner layout wrapper surrounding the icon and content.
@end table

@example
(ui-mode-button #:content \"Switch Theme\")
@end example"
  (let ((button-css (append border-color
                            background
                            hover-background
                            color
                            size
                            active
                            shadow
                            family
                            weight
                            border-size
                            rounding
                            extra-classes
                            ;; the theme toggle needs JavaScript, so it
                            ;; hides itself through the no-JS stylesheet
                            '(js-only))))
    `((button (@ (onclick ,on-click)
                 (type ,(symbol->string type))
                 (class ,(mk-class button-css)))
              (div (@ (class ,(mk-class icon-text-container-classes)))
                   ,(hyg:icon #:type icon
                              #:icon-css icon-css)
                   (span ,content))))))

;; ===== Button variants =====
;;
;; A page asks for a button by the role it plays, not by its colours: there is
;; one main action, a handful of secondary ones, some that are only a hint of
;; a surface until hovered, and the destructive one that has to look like
;; what it does. Each variant below is that decision, named, with the inks
;; chosen so the label clears WCAG AA in both themes -- the fill is the dark
;; end of a ramp with near-white type, or the light end with dark type.

(define* (primary-button content
                         #:key (loading #f)
                         (loading-label "Loading")
                         (type 'button)
                         (id "")
                         (on-click "")
                         (extra-classes '()))
  "The one main action of a page or form.

@table @var
@item content
The button's label or nodes.
@item loading
A boolean putting the button in its loading state.
@item loading-label
The spoken label of the loading state.
@item type
The HTML button type.
@item id
An optional identifier.
@item on-click
A JavaScript handler.
@item extra-classes
Extra layout classes.
@end table

@example
(primary-button \"Create account\")
@end example"
  (button content
          #:type type
          #:id id
          #:on-click on-click
          #:loading loading
          #:loading-label loading-label
          #:background '(bg-onyx-500 dark:bg-stone-100)
          #:hover-background '(hover:bg-onyx-700 dark:hover:bg-stone-300)
          #:color '(text-stone-100 dark:text-onyx-900)
          #:border-color '(border-onyx-300 dark:border-stone-300)
          #:extra-classes extra-classes))

(define* (secondary-button content
                           #:key (loading #f)
                           (loading-label "Loading")
                           (type 'button)
                           (id "")
                           (on-click "")
                           (extra-classes '()))
  "A supporting action beside a primary one.

@table @var
@item content
The button's label or nodes.
@item loading
A boolean putting the button in its loading state.
@item loading-label
The spoken label of the loading state.
@item type
The HTML button type.
@item id
An optional identifier.
@item on-click
A JavaScript handler.
@item extra-classes
Extra layout classes.
@end table

@example
(secondary-button \"Cancel\")
@end example"
  (button content
          #:type type
          #:id id
          #:on-click on-click
          #:loading loading
          #:loading-label loading-label
          #:background '(bg-stone-300/75 dark:bg-onyx-700/75)
          #:hover-background '(hover:bg-stone-500/50 dark:hover:bg-onyx-500/50)
          #:color '(text-onyx-500 dark:text-stone-300)
          #:border-color '(border-stone-500/50 dark:border-onyx-100/50)
          #:extra-classes extra-classes))

(define* (ghost-button content
                       #:key (loading #f)
                       (loading-label "Loading")
                       (type 'button)
                       (id "")
                       (on-click "")
                       (extra-classes '()))
  "A quiet action that only shows its surface on hover or focus.

@table @var
@item content
The button's label or nodes.
@item loading
A boolean putting the button in its loading state.
@item loading-label
The spoken label of the loading state.
@item type
The HTML button type.
@item id
An optional identifier.
@item on-click
A JavaScript handler.
@item extra-classes
Extra layout classes.
@end table

@example
(ghost-button \"Skip for now\")
@end example"
  (button content
          #:type type
          #:id id
          #:on-click on-click
          #:loading loading
          #:loading-label loading-label
          #:background '(bg-transparent)
          #:hover-background '(hover:bg-stone-500/25 dark:hover:bg-onyx-500/25)
          #:color '(text-onyx-500 dark:text-stone-300)
          #:border-color '(border-transparent)
          #:shadow '()
          #:extra-classes extra-classes))

(define* (danger-button content
                        #:key (loading #f)
                        (loading-label "Loading")
                        (type 'button)
                        (id "")
                        (on-click "")
                        (extra-classes '()))
  "A destructive action: the colour is a warning, and the label says what it does.

@table @var
@item content
The button's label or nodes.
@item loading
A boolean putting the button in its loading state.
@item loading-label
The spoken label of the loading state.
@item type
The HTML button type.
@item id
An optional identifier.
@item on-click
A JavaScript handler.
@item extra-classes
Extra layout classes.
@end table

@example
(danger-button \"Delete project\")
@end example"
  (button content
          #:type type
          #:id id
          #:on-click on-click
          #:loading loading
          #:loading-label loading-label
          #:background '(bg-redwood-700)
          #:hover-background '(hover:bg-redwood-900)
          #:color '(text-stone-300)
          #:border-color '(border-redwood-700)
          #:extra-classes extra-classes))

(define* (icon-only-button #:key icon
                           label
                           (id "")
                           (type 'button)
                           (on-click "")
                           (loading #f)
                           (loading-label "Loading")
                           (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                           (hover-background '(hover:bg-stone-900/90
                                               dark:hover:bg-onyx-900))
                           (color '(text-stone-100 dark:text-onyx-900))
                           (border-color '(border-stone-700
                                           dark:border-onyx-300))
                           (icon-css '(text-xl))
                           (extra-classes '()))
  "An icon button with no visible text, named for assistive technology.

The label is not decoration: an icon-only control has no accessible name
without it, so it is rendered as a visually hidden @code{<span>} and the
button carries @code{aria-label} as well.

@table @var
@item icon
The Phosphor icon name.
@item label
The accessible name.
@item id
An optional identifier.
@item type
The HTML button type.
@item on-click
A JavaScript handler.
@item loading
A boolean putting the button in its loading state.
@item loading-label
The spoken label of the loading state.
@item background
Background classes.
@item hover-background
Hover background classes.
@item color
Text and icon colour classes.
@item border-color
Border colour classes.
@item icon-css
Icon sizing and colour classes.
@item extra-classes
Extra layout classes.
@end table

@example
(icon-only-button #:icon 'gear #:label \"Settings\")
@end example"
  `((button (@ (type ,(symbol->string type))
               (id ,id)
               (aria-label ,label)
               ,@(if loading
                     '((disabled "")
                       (aria-busy "true"))
                     '())
               (onclick ,on-click)
               (class ,(mk-class (append '(inline-flex items-center
                                            justify-center
                                            p-2
                                            w-10 h-10
                                            rounded-xl
                                            border-2
                                            shadow-sm
                                            cursor-pointer
                                            select-none
                                            transition-colors
                                            duration-150
                                            focus-visible:outline-2
                                            focus-visible:outline-offset-2
                                            outline-onyx-500)
                                         color background hover-background
                                         border-color
                                         (if loading
                                             '(cursor-wait opacity-80)
                                             '())
                                         extra-classes))))
            ,@(if loading
                  (list `(span (@ (class ,(mk-class '(hg-spinner animate-spin
                                                                  inline-block
                                                                  w-4 h-4)))
                                  (aria-hidden "true"))
                       `(span (@ (class "sr-only")) ,loading-label))
                  (list (hyg:icon #:type icon
                                  #:icon-css icon-css)
                        `(span (@ (class "sr-only")) ,label)))))))
