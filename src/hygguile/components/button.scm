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
                 (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                 (hover-background '(hover:bg-stone-900/90
                                     hover:dark:bg-onyx-900))
                 (border-size '(border-2))
                 (border-color '(border-stone-700 dark:border-onyx-300))
                 (shadow '(shadow-md))
                 (color '(text-onyx-300 dark:text-stone-300))
                 (size '(text-md))
                 (active '(active:scale-95))
                 (family '(font-sans))
                 (weight '(font-medium))
                 (rounding '(rounded-2xl))
                 (extra-classes '(py-2 px-4 max-w-prose cursor-pointer)))
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
@end example"
  (let ((button-css (append extra-classes
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
                            weight)))
    `(button (@ (type ,(symbol->string type))
                (id ,id)
                (class ,(mk-class button-css))
                ,(if hidden
                     '(hidden "")
                     '(visible ""))
                (onclick ,on-click))
             ,content)))

(define* (icon-button #:key (id "")
                      icon
                      content
                      (hidden #f)
                      (on-click "")
                      (type 'button)
                      (background '(bg-stone-500/90 dark:bg-onyx-500/90))
                      (hover-background '(hover:bg-stone-900/90
                                          hover:dark:bg-onyx-900))
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
                      (extra-classes '(py-2 px-4 max-w-prose cursor-pointer))
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

@table @var
@item content
The inner content (text string or HTML fragments) of the button.
@end table

@example
(submit-button \"Save Preferences\")
@end example"
  (button content
          #:type 'submit
          #:background '(bg-asparagus-300)
          #:color '(text-stone-300)
          #:hover-background '(hover:bg-asparagus-700)))

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
                                             hover:dark:bg-onyx-900))
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
                         (extra-classes '(py-2 px-4 max-w-prose cursor-pointer))
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
                            extra-classes)))
    `((button (@ (onclick ,on-click)
                 (type ,(symbol->string type))
                 (class ,(mk-class button-css)))
              (div (@ (class ,(mk-class icon-text-container-classes)))
                   ,(hyg:icon #:type icon
                              #:icon-css icon-css)
                   (span ,content))))))
