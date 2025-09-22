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
  #:export (footer with-footer
                   hr
                   col
                   row
                   dl
                   dd
                   dt))

(define* (with-footer #:key main footer)
  `((div (@ (class ,(mk-class '(flex flex-col justify-between min-h-screen))))
         ,main
         ,footer)))

(define* (hr #:key (margin '(my-8))
             (color '(text-stone-500 dark:text-stone-500)))
  `((hr (@ (class ,(mk-class (append color margin)))))))

(define* (footer content
                 #:key (background '(bg-stone-200 dark:bg-stone-900))
                 (shadow '(shadow-xl))
                 (footer-classes '(flex flex-col
                                        gap-4
                                        items-left
                                        px-6
                                        md:px-12
                                        justify-left
                                        py-10)))
  `((footer (@ (class ,(mk-class (append background shadow footer-classes))))
            ,content)))

(define* (row content
              #:key (gap '(gap-6))
              (shadow '(shadow-md))
              (wrap '(flex-wrap))
              (padding-y '(py-6))
              (padding-x '(px-4))
              (rounding '(rounded-lg))
              (background '(bg-stone-200/70 dark:bg-stone-900))
              (items '(items-center))
              (row-classes '(flex flex-row)))
  `((div (@ (class ,(mk-class (append row-classes
                                      background
                                      items
                                      wrap
                                      shadow
                                      gap
                                      padding-x
                                      padding-y
                                      rounding))))
         ,content)))

(define* (col content
              #:key (gap '(gap-6))
              (shadow '(shadow-md))
              (wrap '(flex-nowrap))
              (padding-y '(py-6))
              (padding-x '(px-4))
              (rounding '(rounded-lg))
              (background '(bg-stone-200/70 dark:bg-stone-900))
              (items '(items-center))
              (col-classes '(flex flex-col)))
  `((div (@ (class ,(mk-class (append col-classes
                                      background
                                      items
                                      wrap
                                      shadow
                                      gap
                                      padding-x
                                      padding-y
                                      rounding))))
         ,content)))

(define* (dl content
             #:key (dl-classes '(flex flex-col)))
  `((dl (@ (class ,(mk-class dl-classes)))
        ,content)))

(define* (dt content
             #:key (dt-classes '(py-2 pb-1))
             (weight '(font-light))
             (style '(italic))
             (color '(text-stone-600 dark:text-stone-400))
             (size '(text-lg)))
  `((dt (@ (class ,(mk-class (append dt-classes weight style color size))))
        ,content)))

(define* (dd content
             #:key (dd-classes '(px-2 text-stone-600 dark:text-stone-200))
             (weight '(font-medium))
             (color '(text-stone-600 dark:text-stone-400))
             (size '(text-lg)))
  `((dd (@ (class ,(mk-class (append dd-classes weight color size))))
        ,content)))
