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
                   (carousel-list-css '(flex gap-24
                                             p-12
                                             list-none
                                             overflow-x-scroll
                                             snap-x
                                             bg-stone-300/75
                                             dark:bg-onyx-700/75
                                             rounded-xl
                                             shadow-md
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
                   (carousel-button-css '(absolute bottom-1/2
                                                   w-18
                                                   h-18
                                                   bg-stone-500/75
                                                   dark:bg-onyx-700/75
                                                   p-2
                                                   rounded-4xl
                                                   text-onyx-500
                                                   dark:text-stone-300
                                                   cursor-pointer
                                                   text-3xl))
                   (carousel-left-button-css '(left-4))
                   (carousel-right-button-css '(right-4))
                   (fragments '()))
  "Construct an S-expression representation of a carousel UI component.

@table @var
@item id
The unique HTML string identifier for the inner carousel list element.
@item carousel-list-css
List of symbols representing CSS classes for the @code{<ul>} element.
@item item-width
List of symbols specifying the width CSS classes for each carousel item.
@item item-height
List of symbols specifying the height CSS classes for each carousel item.
@item carousel-item-css
List of symbols representing CSS classes for each item wrapper @code{<li>}.
@item carousel-item-content-css
List of symbols representing CSS classes for the wrapper @code{<div>} of the content.
@item carousel-list-wrapper-css
List of symbols representing CSS classes for the outer wrapper @code{<div>}.
@item carousel-button-css
List of symbols representing base CSS classes for the previous/next buttons.
@item carousel-left-button-css
List of symbols representing additional CSS classes for the left (previous) button.
@item carousel-right-button-css
List of symbols representing additional CSS classes for the right (next) button.
@item fragments
A list of HTML/component S-expression fragments to be rendered as the carousel items.
@end table

@example
(carousel #:id \"image-carousel\"
          #:fragments '(((img (@@ (src \"img1.png\"))))
                        ((img (@@ (src \"img2.png\"))))))
@end example"
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
