;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components carousel)
  #:use-module (hygguile abstraction)
  #:export (carousel))

(define* (carousel #:key (id #f)
                   (carousel-list-css '(flex gap-4
                                             sm:gap-8
                                             md:gap-24
                                             p-4
                                             sm:p-8
                                             md:p-12
                                             list-none
                                             overflow-x-scroll
                                             scroll-smooth
                                             snap-x
                                             bg-stone-300/75
                                             dark:bg-onyx-700/75
                                             rounded-xl
                                             shadow-md
                                             my-6))
                   (item-width '(w-64))
                   (item-height '(h-1/2))
                   (carousel-item-css '(snap-center shrink-0))
                   (carousel-item-content-css '(flex items-center
                                                     justify-center
                                                     h-full
                                                     font-sans
                                                     text-xl
                                                     font-bold))
                   (carousel-list-wrapper-css '(relative))
                   ;; the arrows are glass discs: compact on a phone, where
                   ;; every pixel of the track counts, and roomy from the
                   ;; small breakpoint up; they are vertically centred with
                   ;; translate, not an offset. Their frost is the
                   ;; framework's own `hg-frost' layer, so a disc standing
                   ;; over a slide has no square corner behind it, and at
                   ;; `hg-frost-soft' because a disc this small wants the
                   ;; gentler blur
                   (carousel-button-css '(absolute top-1/2
                                          -translate-y-1/2
                                          flex
                                          items-center
                                          justify-center
                                          w-9
                                          h-9
                                          sm:w-14
                                          sm:h-14
                                          p-0
                                          leading-none
                                          bg-stone-100/50
                                          dark:bg-onyx-900/50
                                          hg-frost
                                          hg-frost-soft
                                          hover:bg-stone-100/75
                                          dark:hover:bg-onyx-900/75
                                          hover:scale-105
                                          border-2
                                          border-stone-500/25
                                          dark:border-onyx-100/25
                                          rounded-512
                                          shadow-lg
                                          text-onyx-500
                                          dark:text-stone-300
                                          cursor-pointer
                                          transition-colors
                                          duration-200
                                          focus-visible:outline-2
                                          focus-visible:outline-offset-2
                                          outline-onyx-500
                                          text-lg
                                          sm:text-2xl))
                   (carousel-left-button-css '(left-2 sm:left-4))
                   (carousel-right-button-css '(right-2 sm:right-4))
                   (no-js-hint
                    "JavaScript is disabled — scroll horizontally to browse the items.")
                   (fragments '()))
  "Construct a carousel UI component.

Items are centred on a scroll-snap track that pans with a swipe, and the
previous/next arrows page exactly one item at a time using the live gap
between items. The arrows themselves are frosted glass discs: compact on
phones, where the track needs every pixel it can get, and larger from the
small breakpoint up. A disc wears the framework's own frost layer, at the
gentle end of its strength, so the glass is round where the disc is round.

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
@item no-js-hint
Fallback copy shown inside a @code{<noscript>} element when JavaScript is disabled.
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
                                              carousel-left-button-css
                                              '(js-only))))) "←")
         (button (@ (type button)
                    (onclick ,(format #f "handleCarouselClick('next', '~a')"
                                      id))
                    (class ,(mk-class (append carousel-button-css
                                              carousel-right-button-css
                                              '(js-only))))) "→")
         (noscript (@ (class ,(mk-class '(block text-center
                                                text-sm
                                                font-light
                                                text-onyx-300
                                                dark:text-stone-500
                                                font-sans
                                                py-2))))
                   ,no-js-hint))))
