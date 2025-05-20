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
  #:export (footer with-footer hr col row))

(define* (with-footer #:key main footer)
  `((div (@ (class ,(mk-class '(flex flex-col justify-between min-h-screen))))
         ,main
         ,footer)))

(define* (hr #:key (margin 'my-8)
             (color '(text-stone-500 dark:text-stone-500)))
  `((hr (@ (class ,(mk-class (append color
                                     (list margin))))))))

(define* (footer content
                 #:key (background '(bg-stone-200 dark:bg-stone-900))
                 (shadow 'shadow-2xl))
  `((footer (@ (class ,(mk-class (append background
                                         (list shadow)
                                         '(flex flex-col
                                                gap-3
                                                items-left
                                                px-6
                                                md:px-12
                                                justify-left
                                                py-10)))))
            ,content)))

(define* (row content
              #:key (gap 'gap-6)
              (shadow 'shadow-md)
              (wrap 'flex-wrap)
              (padding-y 'py-5)
              (padding-x 'px-3)
              (rounding 'rounded-lg)
              (background '(bg-stone-200/75 dark:bg-stone-900))
              (items 'items-center))
  `((div (@ (class ,(mk-class (append '(flex flex-row)
                                      background
                                      (list items wrap shadow gap padding-x padding-y rounding)))))
         ,content)))

(define* (col content
              #:key (gap 'gap-6)
              (shadow 'shadow-md)
              (wrap 'flex-nowrap)
              (padding-y 'py-5)
              (padding-x 'px-3)
              (rounding 'rounded-lg)
              (background '(bg-stone-200/75 dark:bg-stone-900))
              (items 'items-center))
  `((div (@ (class ,(mk-class (append '(flex flex-col)
                                      background
                                      (list items wrap shadow gap padding-x padding-y rounding )))))
         ,content)))
