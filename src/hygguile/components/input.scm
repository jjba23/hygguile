;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright (C) 2025 Josep Bigorra (jjba23) <jjbigorra@gmail.com>

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

(define-module (hygguile components input)
  #:use-module (hygguile abstraction)
  #:use-module (srfi srfi-64))

(begin
  (define* (mk-input #:key label
                     name
                     (value "")
                     (type 'text)
                     (required #f)
                     (input-css '(p-3 max-w-prose rounded-xl border-stone-200
                                      border-2))
                     (label-css '(text-sm font-bold text-stone-600))
                     (input-flex-css '(flex flex-col gap-1)))
    `((div (@ (class ,(->css input-flex-css))))
      (label (@ (class ,(->css label-css))
                (for ,name))
             ,label)
      (input (@ (class ,(->css input-css))
                (name ,name)
                (value ,value)
                (type ,(symbol->string type))
                ,(if required
                     '(required "")
                     '(not-required ""))) "")))
  (export mk-input))

(begin
  (define* (mk-textarea #:key label
                        name
                        (value "")
                        (required #f)
                        (textarea-css '(p-3 max-w-prose rounded-xl border-stone-200
                                            border-2 min-h-64 min-w-prose))
                        (label-css '(text-sm font-bold text-stone-600))
                        (textarea-flex-css '(flex flex-col gap-1)))
    `((div (@ (class ,(->css textarea-flex-css))))
      (label (@ (class ,(->css label-css))
                (for ,name))
             ,label)
      (textarea (@ (class ,(->css textarea-css))
                   (name ,name)
                   ,(if required
                        '(required "")
                        '(not-required ""))) ,value)))
  (export mk-textarea))

;; module tests
(test-begin "inputs")

(test-equal "mk-input"
  (car (car (cdr (mk-input #:label "hygguile-label"
                           #:name "hygguile-name"))))
  'label)

(test-equal "mk-textarea"
  (car (car (cdr (mk-textarea #:label "hygguile-label"
                              #:name "hygguile-name"))))
  'label)

(test-end)
