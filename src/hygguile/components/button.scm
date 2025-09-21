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
                 (background '(bg-stone-600/90 dark:bg-stone-500/90))
                 (hover-background '(hover:bg-stone-800/90
                                     dark:hover:bg-stone-700))
                 (border-size '(border-2))
                 (border-color '(border-stone-700))
                 (shadow '(shadow-md))
                 (color '(text-stone-100))
                 (size '(text-sm))
                 (active '(active:scale-95))
                 (family '(font-sans))
                 (weight '(font-bold))
                 (rounding '(rounded-2xl))
                 (extra-classes '(py-2 px-3 max-w-prose cursor-pointer)))
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
                      (background '(bg-stone-600/90 dark:bg-stone-500/90))
                      (hover-background '(hover:bg-stone-800/90
                                          dark:hover:bg-stone-700))
                      (border-size '(border-2))
                      (border-color '(border-stone-700))
                      (shadow '(shadow-md))
                      (size '(text-sm))
                      (family '(font-sans))
                      (weight '(font-bold))
                      (color '(text-stone-100))
                      (rounding '(rounded-2xl))
                      (active '(active:scale-95))
                      (icon-css '(text-stone-100 dark:text-stone-100 text-xl))
                      (extra-classes '(py-2 px-3 max-w-prose cursor-pointer))
                      (icon-text-container-classes '(flex flex-row gap-1
                                                          items-center)))
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
  (button content
          #:type 'submit
          #:background '(bg-green-700)
          #:color '(text-stone-200)
          #:hover-background '(hover:bg-green-900)))

(define* (danger-submit-button content)
  (button content
          #:type 'submit
          #:background '(bg-red-700)
          #:color '(text-stone-200)
          #:hover-background '(hover:bg-red-900)))

(define* (mono-button content)
  (button content
          #:family 'font-mono))

(define* (light-button content)
  (button content
          #:weight 'font-light))

(define* (ui-mode-button #:key (icon 'faders)
                         (content "ui mode")
                         (type 'button)
                         (background '(bg-stone-600/90 dark:bg-stone-500/90))
                         (hover-background '(hover:bg-stone-800/90
                                             dark:hover:bg-stone-700))
                         (border-size '(border-2))
                         (border-color '(border-stone-700))
                         (shadow '(shadow-md))
                         (size '(text-sm))
                         (active '(active:scale-95))
                         (family '(font-sans))
                         (weight '(font-bold))
                         (foreground '(text-stone-100))
                         (on-click "hygguileToggleDarkTheme()")
                         (rounding '(rounded-2xl))
                         (icon-css '(text-stone-100 text-xl))
                         (extra-classes '(py-2 px-3 max-w-prose cursor-pointer))
                         (icon-text-container-classes '(flex flex-row gap-1
                                                             items-center)))
  (let ((button-css (append border-color
                            background
                            hover-background
                            foreground
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

