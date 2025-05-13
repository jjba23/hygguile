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
  #:use-module (srfi srfi-64)
  #:export (button icon-button submit-button danger-submit-button
                   ui-mode-button))

(define* (button content
                 #:key (type 'button)
                 (background 'bg-stone-700)
                 (hover-background 'hover:bg-stone-900/75)
                 (border-size 'border-2)
                 (border-color 'border-stone-700/75)
                 (shadow 'shadow-md)
                 (foreground 'text-stone-100)
                 (rounding 'rounded-2xl)
                 (on-click ""))
  (let ((button-css `(py-2 px-3
                           ,rounding
                           max-w-prose
                           font-bold
                           font-sans
                           text-sm
                           ,shadow
                           ,border-size
                           cursor-pointer
                           ,border-color
                           ,background
                           ,hover-background
                           ,foreground)))
    `(button (@ (type ,(symbol->string type))
                (class ,(mk-class button-css))
                (onclick ,on-click))
             ,content)))

(define* (icon-button #:key icon
                      content
                      (type 'button)
                      (background 'bg-stone-700)
                      (hover-background 'hover:bg-stone-900/75)
                      (border-size 'border-2)
                      (border-color 'border-stone-700/75)
                      (shadow 'shadow-md)
                      (foreground 'text-stone-100)
                      (on-click "")
                      (rounding 'rounded-2xl)
                      (icon-css '(text-stone-100 text-xl)))
  (let ((button-css `(py-2 px-3
                           ,rounding
                           max-w-prose
                           font-bold
                           cursor-pointer
                           font-sans
                           text-sm
                           ,border-size
                           ,border-color
                           ,background
                           ,shadow
                           ,hover-background
                           ,foreground)))
    `(button (@ (onclick ,on-click)
                (type ,(symbol->string type))
                (class ,(mk-class button-css)))
             (div (@ (class ,(mk-class '(flex flex-row gap-1 items-center))))
                  ,(hyg:icon #:type icon
                             #:icon-css icon-css)
                  (span ,content)))))

(define* (submit-button content)
  (button content
          #:type 'submit
          #:background 'bg-green-700
          #:hover-background 'hover:bg-green-900))

(define* (danger-submit-button content)
  (button content
          #:type 'submit
          #:background 'bg-red-700
          #:hover-background 'hover:bg-red-900))

(define* (ui-mode-button #:key (icon 'faders)
                         (content "ui mode")
                         (type 'button)
                         (background '(bg-stone-700 dark:bg-stone-300))
                         (hover-background '(hover:bg-stone-900/75
                                             dark:hover:bg-stone-100/75))
                         (border-size 'border-2)
                         (border-color '(border-stone-700/75
                                         dark:border-stone-300/75))
                         (shadow 'shadow-md)
                         (foreground '(text-stone-100 dark:text-stone-900))
                         (on-click "toggleDarkTheme()")
                         (rounding 'rounded-2xl)
                         (icon-css '(text-stone-100 dark:text-stone-900
                                                    text-xl)))
  (let ((button-css (append border-color background hover-background
                            foreground
                            `(py-2 px-3
                                   ,rounding
                                   max-w-prose
                                   font-bold
                                   cursor-pointer
                                   font-sans
                                   text-sm
                                   ,border-size
                                   ,shadow))))
    `((script
       "
function toggleDarkTheme() {
  if (document.documentElement.getAttribute('data-theme') == null) {
    document.documentElement.setAttribute('data-theme','dark');
    localStorage.setItem('data-theme', 'dark');
  }else {
    if (document.documentElement.getAttribute('data-theme') == 'dark') {
      document.documentElement.setAttribute('data-theme','light');
      localStorage.setItem('data-theme', 'light');
    }else {
      document.documentElement.setAttribute('data-theme','dark');
      localStorage.setItem('data-theme', 'dark');
    }
  }
}
")
      (button (@ (onclick ,on-click)
                 (type ,(symbol->string type))
                 (class ,(mk-class button-css)))
              (div (@ (class ,(mk-class '(flex flex-row gap-1 items-center))))
                   ,(hyg:icon #:type icon
                              #:icon-css icon-css)
                   (span ,content))))))

;; module tests
(test-begin "buttons")

(test-equal "danger-submit-button returns a valid button"
            (car (danger-submit-button "hygguile"))
            'button)

(test-equal "submit-button returns a valid button"
            (car (submit-button "hygguile"))
            'button)

(test-equal "icon-button returns a valid button"
            (car (icon-button #:icon 'lightbulb
                              #:content "hygguile"))
            'button)

(test-equal "button returns a valid button"
            (car (button "hygguile"))
            'button)

(test-end)

