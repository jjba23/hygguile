;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

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
;; sort control reads -- and whether the card takes the whole row instead of
;; one column of it.
;;
;; Two things decide that last flag. A section whose own content is laid out in
;; columns needs the width -- the type specimen, the palette, the table, the
;; gallery -- and so does a section tall enough that half a row would leave a
;; canyon of empty page beside it, since a card in a grid is as tall as the row
;; it stands in and not as tall as itself. The rest stand two to a row, and the
;; order below puts cards of a similar height beside each other wherever the
;; reading order allows, which is why the closing argument stands alone at the
;; bottom rather than beside a two-line card.
;;
;; The order is a reading order rather than an inventory: what a page is *set*
;; in comes first, then the two shapes nearly everything else is built out of
;; -- a card and a container -- and only then the shelves that fill them. A
;; reader who came to be convinced meets the type scale and the two most
;; familiar boxes before meeting a table of available gradients.
(define showcase-entries
  (list
   ;; -- what the page is set in ------------------------------------
   (list 'typography
         "Typography"
         "Type"
         'text-aa
         ;; the specimen sets a display heading, a subheading and a
         ;; preformatted block: it is the page's opening statement, so it
         ;; takes the whole row and is set at full width
         #t
         (lambda ()
           typography-section))
   ;; -- the two shapes everything is built from --------------------
   (list 'cards
         "Cards"
         "Layout"
         'cards
         #f
         (lambda ()
           cards-section))
   (list 'containers
         "Containers"
         "Layout"
         'package
         #f
         (lambda ()
           containers-section))
   ;; -- surfaces ---------------------------------------------------
   (list 'colors
         "Colors"
         "Foundations"
         'palette
         ;; the palette is a band of swatches: it reads as a strip of
         ;; colour across the page, where half a row would stack it into a
         ;; tower of four tiles
         #t
         (lambda ()
           (custom-colors-section)))
   (list 'gradients
         "Gradients"
         "Foundations"
         'paint-brush
         #f
         (lambda ()
           (gradients-section)))
   (list 'layout-extras
         "Layout & utility"
         "Layout"
         'layout
         #f
         (lambda ()
           (append layout-extras-section utility-extras-section)))
   ;; -- controls ---------------------------------------------------
   (list 'buttons
         "Buttons"
         "Controls"
         'cursor-click
         #f
         (lambda ()
           button-section))
   (list 'field-extras
         "Form fields"
         "Controls"
         'textbox
         #f
         (lambda ()
           field-extras-section))
   (list 'forms
         "Forms"
         "Controls"
         'check-square
         ;; the code samples of a form lie beside each other at full
         ;; width, which is what a reader comparing two of them wants
         #t
         (lambda ()
           forms-section))
   (list 'validation
         "Validation"
         "Controls"
         'warning-circle
         #f
         (lambda ()
           validation-section))
   (list 'disclosure
         "Disclosure"
         "Controls"
         'caret-double-down
         #f
         (lambda ()
           disclosure-section))
   ;; -- data -------------------------------------------------------
   (list 'detail-lists
         "Detail lists"
         "Data"
         'list-dashes
         ;; a definition list is a handful of pairs, short enough to stand
         ;; beside a disclosure rather than stretch the page for
         #f
         (lambda ()
           dl-section))
   (list 'tables
         "Data tables"
         "Data"
         'table
         ;; a table is the one thing that cannot be squeezed into half a
         ;; row without asking the reader to scroll sideways
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
   ;; -- media ------------------------------------------------------
   (list 'carousel
         "Carousel"
         "Media"
         'images
         #f
         (lambda ()
           carousel-section))
   (list 'media
         "Media"
         "Media"
         'image
         #t
         (lambda ()
           media-section))
   ;; -- navigation -------------------------------------------------
   (list 'navigation
         "Navigation"
         "Navigation"
         'compass
         #f
         (lambda ()
           (append navigation-section nav-extras-section)))
   (list 'fly-out
         "Fly-out"
         "Navigation"
         'butterfly
         #f
         (lambda ()
           (fly-out-section)))
   ;; -- application chrome -----------------------------------------
   (list 'overlays
         "Overlays"
         "Application"
         'stack
         #f
         (lambda ()
           overlays-section))
   (list 'settings
         "Settings"
         "Application"
         'gear-six
         #f
         (lambda ()
           settings-section))
   (list 'feedback
         "Feedback & states"
         "Application"
         'megaphone
         ;; every state the framework draws, in a gallery that fills the
         ;; row rather than a column of it
         #t
         (lambda ()
           (append feedback-section states-section)))
   ;; -- the closing argument ---------------------------------------
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
;; its position here is the rank the `By category' sort compares -- so the
;; shelves are listed in the same order the page reads them in, `Type' first
;; and the closing argument last.
(define showcase-categories
  '("Type" "Layout"
    "Foundations"
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
