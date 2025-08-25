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
  #:export (carousel))

(define* (carousel #:key (id #f)
                   (carousel-list-css '(flex gap-8
                                             p-12
                                             list-none
                                             overflow-x-scroll
                                             snap-x
                                             bg-stone-200/70
                                             dark:bg-stone-700/70
                                             rounded-xl
                                             my-6))
                   (item-width '(w-64))
                   (item-height '(h-1/2))
                   (carousel-item-css '(snap-center shrink-0))
                   (carousel-item-content-css '(flex align-center
                                                     justify-center
                                                     h-full
                                                     font-sans
                                                     text-xl
                                                     font-bold))
                   (carousel-list-wrapper-css '(relative))
                   (carousel-button-css '(absolute top-1/4
                                                   w-18
                                                   h-18
                                                   bg-stone-400/25
                                                   dark:bg-stone-800/25
                                                   rounded-xl
                                                   text-stone-800
                                                   dark:text-stone-200
                                                   cursor-pointer
                                                   text-2xl))
                   (carousel-left-button-css '(left-3))
                   (carousel-right-button-css '(right-3))
                   (fragments '()))
  `((div (@ (class ,(mk-class carousel-list-wrapper-css)))
         (ul (@ (id ,(format #f "~a" id))
                (class ,(mk-class (append carousel-list-css
                                          '(carousel-list)))))
             ,(map (lambda (c)
                     `(li (@ (class ,(mk-class (append carousel-item-css
                                                       item-width item-height
                                                       '(carousel-list-item)))))
                          (div (@ (class ,(mk-class carousel-item-content-css)))
                               ,c))) fragments))
         (button (@ (type button)
                    (onclick ,(format #f
                                      "handleCarouselClick('previous', '~a')"
                                      id))
                    (class ,(mk-class (append carousel-button-css
                                              carousel-left-button-css)))) "←")
         (button (@ (type button)
                    (onclick ,(format #f "handleCarouselClick('next', '~a')"
                                      id))
                    (class ,(mk-class (append carousel-button-css
                                              carousel-right-button-css))))
                 "→"))))

