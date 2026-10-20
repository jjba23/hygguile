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

;; The hero at the top of the page, and the glossary it names.

(define-module (showcase hero)
  #:use-module (hygguile hygguile)
  #:export (showcase-hero))

;; ====== Naming a technology ======

;; Where a technology the hero names is documented, and what an abbreviation
;; stands for. Both lists live here so the prose writes a term once: the
;; sentence says "CSS", and the link and the expansion follow from that name
;; rather than from a second copy of it that has to be kept in step by hand.
(define technology-docs
  '(("Guile Scheme" . "https://www.gnu.org/software/guile/")
    ("S-expressions" . "https://en.wikipedia.org/wiki/S-expression")
    ("SXML" . "https://en.wikipedia.org/wiki/SXML")
    ("Olive CSS" . "https://codeberg.org/jjba23/olive-css")
    ("Tailwind" . "https://tailwindcss.com/")
    ("CSS" . "https://developer.mozilla.org/en-US/docs/Web/CSS")
    ("HTML" . "https://developer.mozilla.org/en-US/docs/Web/HTML")
    ("JavaScript" . "https://developer.mozilla.org/en-US/docs/Web/JavaScript")))

(define technology-expansions
  '(("SXML" . "Scheme XML: XML written as S-expressions")
    ("CSS" . "Cascading Style Sheets")
    ("HTML" . "HyperText Markup Language")
    ("DSL" . "domain-specific language")
    ("S-expressions" . "symbolic expressions")))

;; A technology as the hero names it. The framework's `glossary-term' renders
;; the word, its link and -- for an abbreviation -- the tooltip that spells it
;; out; the two tables below are the page's own content, the only part of a
;; glossary that is not the framework's.
(define (tech term)
  (glossary-term term
                 #:href (assoc-ref technology-docs term)
                 #:note (assoc-ref technology-expansions term)))

;; The hero itself: a glass pane with soft, out-of-focus colour washes
;; behind it -- the macOS wallpaper trick done with plain Olive
;; utilities -- over the tagline, the links and the opening prose.
(define (showcase-hero)
  ;; a glass hero: soft, out-of-focus colour washes
  ;; behind frosted glass, the macOS wallpaper trick
  ;; done with plain Olive utilities -- the same panel
  ;; any page can have, shown again in the containers
  ;; section below
  (glass-panel
   ;; a real list of nodes, not `(list ...)`: a
   ;; literal head would render as a <list> element
   `((div (@ (id "top")
             (class ,(mk-class '(flex flex-col gap-2))))
          ,(h1 "Hygguile"
               ;; the class list of `color` is
               ;; simply appended, so a gradient
               ;; treatment belongs here
               #:color '(hg-gradient-text))
          ,(sub-h3 "cozy and professional user-interfaces for everyone"))
     (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2))))
          ,(a "Source on Codeberg"
              #:href "https://codeberg.org/jjba23/hygguile"
              #:size '(text-sm)
              #:weight '(font-medium)
              #:extra-classes '(no-underline rounded-lg
                                             px-3
                                             py-1
                                             bg-stone-100/50
                                             dark:bg-onyx-900/50
                                             hg-frost
                                             hg-frost-pill
                                             border-2
                                             border-stone-500/25
                                             dark:border-onyx-100/25
                                             hover:bg-stone-100/75
                                             dark:hover:bg-onyx-900/75
                                             transition-colors
                                             duration-150))
          ,(a "API documentation"
              #:href "https://jointhefreeworld.org/api-docs/hygguile/API.html"
              #:size '(text-sm)
              #:weight '(font-medium)
              #:extra-classes '(no-underline rounded-lg
                                             px-3
                                             py-1
                                             bg-stone-100/50
                                             dark:bg-onyx-900/50
                                             hg-frost
                                             hg-frost-pill
                                             border-2
                                             border-stone-500/25
                                             dark:border-onyx-100/25
                                             hover:bg-stone-100/75
                                             dark:hover:bg-onyx-900/75
                                             transition-colors
                                             duration-150))
          ,(a "LGPL-3.0-or-later"
              #:href "https://www.gnu.org/licenses/lgpl-3.0.html"
              #:size '(text-sm)
              #:weight '(font-medium)
              #:extra-classes '(no-underline rounded-lg
                                             px-3
                                             py-1
                                             bg-stone-100/50
                                             dark:bg-onyx-900/50
                                             hg-frost
                                             hg-frost-pill
                                             border-2
                                             border-stone-500/25
                                             dark:border-onyx-100/25
                                             hover:bg-stone-100/75
                                             dark:hover:bg-onyx-900/75
                                             transition-colors
                                             duration-150)))
     (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-5))))
          ,(p (list
               "Hygguile is an opinionated, batteries-included UI framework written in "
               (tech "Guile Scheme")
               ". It gives you a small, expressive "
               (tech "DSL")
               " for building cozy and professional interfaces from "
               (tech "S-expressions")
               ", "
               (tech "SXML")
               " and modern "
               (tech "CSS")
               ".")
              #:weight '(font-light))
          ,(p (list "It is built on "
               (tech "Olive CSS")
               ": a utility-class framework whose syntax will feel familiar to anyone who has used "
               (tech "Tailwind")
               ", but which is plain "
               (tech "CSS")
               " rather than "
               (tech "JavaScript")
               ".")
              #:weight '(font-light))
          ,(p (list "Every component renders to real "
               (tech "HTML")
               " on the server and is enhanced in the browser only where that helps. Pages stay fast, accessible, and fully usable without "
               (tech "JavaScript") ".")
              #:weight '(font-light))
          ,(noscript (alert #:title "JavaScript is disabled"
                      #:body
                      "hygguile progressively enhances. Theme toggles and carousel arrows hide themselves, fly-out submenus open up, and tabs, accordions, modals, tooltips and every form control keep working without a single line of JavaScript."
                      #:variant 'info))))
   ;; a generous gap between the rows, so the
   ;; tagline is not crowded by the links that
   ;; follow it
   #:content-classes '(flex flex-col gap-10)
   ;; the washes drift very slowly, and out of phase,
   ;; so the glass has something to frost without
   ;; ever stealing attention
   #:washes (list (glass-wash '(bg-naples-yellow-500/75 w-96 h-96 left-4 top-4)
                              #:delay -6)
                  (glass-wash '(bg-china-rose-500/50 w-72 h-72 right-4 top-4)
                              #:delay -14)
                  (glass-wash '(bg-jeans-blue-500/50 w-96 h-96 right-24
                                                     bottom-4)
                              #:delay -22)
                  (glass-wash '(bg-asparagus-500/50 w-72 h-72 left-4 bottom-4)
                              #:delay -9))
   #:drift? #t
   ;; a hairline of the title's own gradient along
   ;; the top edge of the glass
   #:accent (linear-gradient '()
                             #:container-class (mk-class '(absolute top-0
                                                           left-0 h-1 w-full
                                                           opacity-90))
                             #:direction 'right
                             #:steps '("oklch(0.7404 0.1399 91.55 / 1)"
                                       "oklch(0.6183 0.1557 45.26 / 1)"
                                       "oklch(0.4929 0.161 279.98 / 1)"
                                       "oklch(0.6609 0.0708 213.97 / 1)"))))
