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

;; The spine of the page: every section, its shelf and its icon.

(define-module (showcase entries)
  #:use-module (hygguile hygguile)
  #:use-module (showcase foundations)
  #:use-module (showcase layout)
  #:use-module (showcase controls)
  #:use-module (showcase data)
  #:use-module (showcase media)
  #:use-module (showcase navigation)
  #:use-module (showcase application)
  #:use-module (showcase overview)
  #:export (showcase-entries showcase-categories category-rank))

;; The page is a grid of component cards, and this is its spine: each entry is
;; the id a link can jump to, the title and Phosphor icon that head the card,
;; the shelf the section belongs on -- which the card shows as a chip and the
;; sort control reads -- and whether the card needs the whole row, since a
;; table, the carousel and the gradient tray are all wider than half of one.
;; The block itself is a thunk, so a card is built only when the page asks for
;; it.
(define showcase-entries
  (list (list 'colors
              "Colors"
              "Foundations"
              'palette
              #t
              (lambda ()
                (custom-colors-section)))
        (list 'typography
              "Typography"
              "Foundations"
              'text-aa
              #t
              (lambda ()
                typography-section))
        (list 'gradients
              "Gradients"
              "Foundations"
              'paint-brush
              #t
              (lambda ()
                (gradients-section)))
        (list 'layout-extras
              "Layout & utility"
              "Layout"
              'layout
              #t
              (lambda ()
                (append layout-extras-section utility-extras-section)))
        (list 'containers
              "Containers"
              "Layout"
              'package
              #t
              (lambda ()
                containers-section))
        (list 'cards
              "Cards"
              "Layout"
              'cards
              #t
              (lambda ()
                cards-section))
        (list 'buttons
              "Buttons"
              "Controls"
              'cursor-click
              #t
              (lambda ()
                button-section))
        (list 'field-extras
              "Form fields"
              "Controls"
              'textbox
              #t
              (lambda ()
                field-extras-section))
        (list 'forms
              "Forms"
              "Controls"
              'check-square
              #t
              (lambda ()
                forms-section))
        (list 'disclosure
              "Disclosure"
              "Controls"
              'caret-double-down
              #f
              (lambda ()
                disclosure-section))
        (list 'tables
              "Data tables"
              "Data"
              'table
              #t
              (lambda ()
                tables-section))
        (list 'data-extras
              "Data display"
              "Data"
              'chart-bar
              #f
              (lambda ()
                data-extras-section))
        (list 'detail-lists
              "Detail lists"
              "Data"
              'list-dashes
              #f
              (lambda ()
                dl-section))
        (list 'media
              "Media"
              "Media"
              'image
              #t
              (lambda ()
                media-section))
        (list 'carousel
              "Carousel"
              "Media"
              'images
              #t
              (lambda ()
                carousel-section))
        (list 'navigation
              "Navigation"
              "Navigation"
              'compass
              #t
              (lambda ()
                (append navigation-section nav-extras-section)))
        (list 'fly-out
              "Fly-out"
              "Navigation"
              'butterfly
              #f
              (lambda ()
                (fly-out-section)))
        (list 'overlays
              "Overlays"
              "Application"
              'stack
              #t
              (lambda ()
                overlays-section))
        (list 'feedback
              "Feedback & states"
              "Application"
              'megaphone
              #t
              (lambda ()
                (append feedback-section states-section)))
        (list 'settings
              "Settings"
              "Application"
              'gear-six
              #t
              (lambda ()
                settings-section))
        (list 'why-ssr
              "Why server-side rendering?"
              "Overview"
              'book-open-text
              #t
              (lambda ()
                ssr-section))))

;; The shelves the sections are grouped into, in the order the page should
;; introduce them when a reader asks for the grouped view. A category is
;; metadata rather than a heading: it rides along on the card as a chip, and
;; its position here is the rank the `By category' sort compares.
(define showcase-categories
  '("Foundations" "Layout"
    "Controls"
    "Data"
    "Media"
    "Navigation"
    "Application"
    "Overview"))

(define (category-rank category)
  "Where @var{category} sits among the shelves above."
  (let loop
    ((rest showcase-categories)
     (rank 0))
    (cond
      ((null? rest)
       rank)
      ((string=? category
                 (car rest))
       rank)
      (else (loop (cdr rest)
                  (+ rank 1))))))
