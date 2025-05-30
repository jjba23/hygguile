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

(define-module (hygguile components input)
  #:use-module (hygguile abstraction)
  #:export (input textarea))

(define* (input #:key label
                name
                (value "")
                (placeholder "")
                (type 'text)
                (required #f)
                (input-css '(p-3 max-w-prose
                                 rounded-xl
                                 border-stone-200
                                 dark:border-stone-700
                                 dark:text-stone-300
                                 bg-stone-200/75
                                 dark:bg-stone-700/75
                                 border-2
                                 shadow-md))
                (label-css '(text-sm font-bold text-stone-600
                                     dark:text-stone-300))
                (input-flex-css '(my-2 flex flex-col gap-1)))
  `((div (@ (class ,(mk-class input-flex-css))))
    (label (@ (class ,(mk-class label-css))
              (for ,name))
           ,label)
    (input (@ (class ,(mk-class input-css))
              (name ,name)
              (placeholder ,placeholder)
              (value ,value)
              (type ,(symbol->string type))
              ,(if required
                   '(required "")
                   '(not-required ""))) "")))

(define* (textarea #:key label
                   name
                   (value "")
                   (required #f)
                   (textarea-css '(p-3 rounded-xl
                                       border-stone-200
                                       dark:border-stone-700
                                       dark:text-stone-300
                                       dark:bg-stone-700/75
                                       bg-stone-200/75
                                       border-2
                                       min-h-72
                                       shadow-md
                                       min-w-prose))
                   (label-css '(text-sm font-bold text-stone-600
                                        dark:text-stone-300))
                   (textarea-flex-css '(my-2 flex flex-col gap-1 w-full)))
  `((div (@ (class ,(mk-class textarea-flex-css))))
    (label (@ (class ,(mk-class label-css))
              (for ,name))
           ,label)
    (textarea (@ (class ,(mk-class textarea-css))
                 (name ,name)
                 ,(if required
                      '(required "")
                      '(not-required "")))
              ,value)))

