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
  #:export (button icon-button submit-button danger-submit-button
                   ui-mode-button light-button mono-button))

(define* (button content
                 #:key id
                 (type 'button)
                 (background '(bg-stone-600/90 dark:bg-stone-500/90))
                 (hover-background '(hover:bg-stone-800/90
                                     dark:hover:bg-stone-700))
                 (border-size 'border-2)
                 (border-color '(border-stone-700/75))
                 (shadow 'shadow-md)
                 (color '(text-stone-100))
                 (size 'text-sm)
                 (family 'font-sans)
                 (weight 'font-bold)
                 (hidden #f)
                 (rounding 'rounded-2xl)
                 (on-click ""))
  (let ((button-css (append '(py-2 px-3
                                   max-w-prose
                                   font-bold
                                   font-sans
                                   text-sm
                                   cursor-pointer)
                            color
                            background
                            size
                            family
                            weight
                            hover-background
                            border-color
                            (list rounding shadow border-size))))
    `(button (@ (type ,(symbol->string type))
                (id ,id)
                (class ,(mk-class button-css))
                ,(if hidden
                     '(hidden "")
                     '(visible ""))
                (onclick ,on-click))
             ,content)))

(define* (icon-button #:key id
                      icon
                      content
                      (type 'button)
                      (background '(bg-stone-600/90 dark:bg-stone-500/90))
                      (hover-background '(hover:bg-stone-800/90
                                          dark:hover:bg-stone-700))
                      (border-size 'border-2)
                      (border-color '(border-stone-700/75))
                      (shadow 'shadow-md)
                      (size 'text-sm)
                      (family 'font-sans)
                      (weight 'font-bold)
                      (color '(text-stone-100))
                      (hidden #f)
                      (on-click "")
                      (rounding 'rounded-2xl)
                      (icon-css '(text-stone-100 dark:text-stone-100 text-xl)))
  (let ((button-css (append '(py-2 px-3 max-w-prose cursor-pointer)
                            color
                            hover-background
                            background
                            border-color
                            (list size
                                  rounding
                                  border-size
                                  shadow
                                  family
                                  weight))))
    `(button (@ (onclick ,on-click)
                (id ,id)
                (type ,(symbol->string type))
                (class ,(mk-class button-css))
                ,(if hidden
                     '(hidden "")
                     '(visible "")))
             (div (@ (class ,(mk-class '(flex flex-row gap-1 items-center))))
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
                         (border-size 'border-2)
                         (border-color '(border-stone-700/75))
                         (shadow 'shadow-md)
                         (size 'text-sm)
                         (family 'font-sans)
                         (weight 'font-bold)
                         (foreground '(text-stone-100))
                         (on-click "hygguileToggleDarkTheme()")
                         (rounding 'rounded-2xl)
                         (icon-css '(text-stone-100 text-xl)))
  (let ((button-css (append border-color
                            background
                            hover-background
                            foreground
                            border-size
                            shadow
                            size
                            family
                            weight
                            `(py-2 px-3
                                   ,rounding
                                   max-w-prose
                                   font-bold
                                   cursor-pointer
                                   font-sans
                                   text-sm))))
    `((button (@ (onclick ,on-click)
                 (type ,(symbol->string type))
                 (class ,(mk-class button-css)))
              (div (@ (class ,(mk-class '(flex flex-row gap-1 items-center))))
                   ,(hyg:icon #:type icon
                              #:icon-css icon-css)
                   (span ,content))))))

