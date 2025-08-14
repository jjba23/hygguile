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

(define-module (hygguile components carousel)
  #:use-module (hygguile abstraction)
  #:export (image-carousel))

(define* (image-carousel #:key (carousel-list-css '(flex gap-8 p-4 list-none
                                                   overflow-x-scroll snap-x bg-stone-200/70 dark:bg-stone-700/70 rounded-xl my-6))
                   (carousel-item-css '(w-64 h-1/2 snap-center shrink-0))
                   (carousel-item-content-css '(flex align-center
                                                     justify-center
                                                     h-full
                                                     font-sans
                                                     text-xl
                                                     font-bold))
                   (images '()))
  `((ul (@ (class ,(mk-class carousel-list-css)))
        ,(map (lambda (c)
                `(li (@ (class ,(mk-class carousel-item-css)))
                     (div (@ (class ,(mk-class carousel-item-content-css)))
                          ,c))) images))))

