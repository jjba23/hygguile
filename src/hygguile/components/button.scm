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
  #:use-module (hygguile components icon)
  #:use-module (srfi srfi-64))

(begin
  (define* (hyg-button #:key content
                       (type 'button)
                       (background 'bg-stone-700)
                       (hover-background 'hover:bg-stone-900/75)
                       (border-size 'border-2)
                       (border-color 'border-stone-900)
                       (foreground 'text-stone-100))
    (let ((button-css `(py-2 px-3
                             rounded-xl
                             max-w-prose
                             font-bold
                             font-sans
                             text-sm
                             ,border-size
                             ,border-color
                             ,background
                             ,hover-background
                             ,foreground)))
      `(button (@ (type ,(symbol->string type))
                  (class ,(->css button-css)))
               ,content)))
  (export hyg-button))

(begin
  (define* (hyg-icon-button #:key icon content
                            (type 'button)
                            (background 'bg-stone-700)
                            (hover-background 'hover:bg-stone-900/75)
                            (border-size 'border-2)
                            (border-color 'border-stone-900)
                            (foreground 'text-stone-100)
                            (icon-css '(text-stone-100 text-xl)))
    (let ((button-css `(py-2 px-3
                             rounded-xl
                             max-w-prose
                             font-bold
                             font-sans
                             text-sm
                             ,border-size
                             ,border-color
                             ,background
                             ,hover-background
                             ,foreground)))
      `(button (@ (type ,(symbol->string type))
                  (class ,(->css button-css)))
               (div (@(class ,(->css '(flex flex-row gap-1 items-center))))
                    ,(hyg-icon #:type icon #:icon-css icon-css)
                    (span ,content)))))
  (export hyg-icon-button))

(begin
  (define* (hyg-submit-button #:key content)
    (hyg-button #:content content
                #:type 'submit
                #:background 'bg-green-700
                #:hover-background 'hover:bg-green-900
                #:border-color 'border-green-900))
  (export hyg-submit-button))

(begin
  (define* (hyg-danger-submit-button #:key content)
    (hyg-button #:content content
                #:type 'submit
                #:background 'bg-red-700
                #:hover-background 'hover:bg-red-900
                #:border-color 'border-red-900))
  (export hyg-danger-submit-button))



;; module tests
(test-begin "buttons")

(test-equal "hyg-danger-submit-button returns a valid button"
  (car (hyg-danger-submit-button #:content "hygguile"))
  'button)

(test-equal "hyg-submit-button returns a valid button"
  (car (hyg-submit-button #:content "hygguile"))
  'button)

(test-equal "hyg-icon-button returns a valid button"
  (car (hyg-icon-button #:icon 'lightbulb #:content "hygguile"))
  'button)

(test-end)

