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

(define-module (hygguile components container)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components icon)
  #:use-module (srfi srfi-64)
  #:export (hyg-footer hyg-with-footer hyg-hr))

(define* (hyg-with-footer #:key main footer)
  `((div (@ (class ,(->css '(flex flex-col justify-between min-h-screen))))
         ,main
         ,footer)))

(define* (hyg-hr #:key (margin 'my-8))
  `((hr (@ (class ,(->css `(,margin)))))))

(define* (hyg-footer content
                     #:key (background 'bg-stone-300)
                     (shadow 'shadow-2xl))
  `((footer (@ (class ,(->css `(flex flex-col
                                     gap-3
                                     items-left
                                     px-6
                                     md:px-12
                                     justify-left
                                     py-12
                                     ,background
                                     ,shadow))))
            ,content)))
