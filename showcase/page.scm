;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The tray around the sections: its cards, its sort control and the writer.
;;
;;   guix shell -m manifest.scm -- guile -L ./src -L . showcase.scm

(define-module (showcase page)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (hygguile hygguile)
  #:use-module (hygguile sxml)
  #:use-module (showcase entries)
  #:use-module (showcase hero)
  #:export (showcase-body showcase))

;; The page's own footer. It has to be named apart from the framework's
;; `footer' component: a module creates its variables before it evaluates
;; them, so `(define footer (footer ...))' would refer to itself.
(define showcase-footer
  (footer `(,(em "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;"
                 #:size '(text-md)) ,(em
                                      "licensed under the MIT license, like the rest of the framework"
                                      #:size '(text-md))
            (div (@ (class ,(mk-class '(flex flex-col
                                             gap-2
                                             sm:flex-row
                                             sm:flex-wrap
                                             sm:items-center
                                             sm:gap-6))))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "source:"
                           #:size '(text-md))
                      ,(a "codeberg.org/jjba23/hygguile"
                          #:href "https://codeberg.org/jjba23/hygguile"
                          #:size '(text-md)
                          #:weight '(font-medium)))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "version:"
                           #:size '(text-md))
                      ;; the version the framework reports about itself, from
                      ;; (hygguile version), beside the commit this copy of the
                      ;; showcase was rendered from -- the number tells a reader
                      ;; what they are reading, the commit tells them which build
                      ;; of it
                      ,(mono (format #f "~a (~a)"
                                     hygguile-version
                                     (get-short-commit-sha))
                             #:size '(text-md)
                             #:weight '(font-light)))))))

;; One card of the grid. The card itself -- a native <details> with an icon, a
;; heading, a chip and a chevron -- is the framework's `expandable-card'; what
;; is the showcase's own is the data it hands over: the place the entry stands
;; in the page's narrative, the title the `A-Z' order reads, and the shelf,
;; with the rank the `By category' order reads. The chip shows the shelf's
;; name while the ordering uses its rank, so the grouping is the one the page
;; means rather than the one the alphabet would pick.
(define (showcase-card entry order)
  (match entry
    ((card-id card-title card-category card-icon card-wide? card-body)
     (expandable-card (card-body)
                      #:id (format #f "~a" card-id)
                      #:title card-title
                      #:icon card-icon
                      #:tag card-category
                      #:wide? card-wide?
                      ;; the whole tray opens on the first paint: the
                      ;; showcase is meant to be read, and `Collapse all'
                      ;; above the grid folds it again for a reader who would
                      ;; rather scan headers
                      #:open #t
                      #:data (list (cons 'order
                                         (format #f "~a" order))
                                   (cons 'title card-title)
                                   (cons 'category card-category)
                                   (cons 'category-rank
                                         (format #f "~a"
                                                 (category-rank card-category))))))))

;; the rail of section links, built from the same entries as the grid: any
;; section is one tap away, and the rail follows the page from the small
;; breakpoint up. Its links are sized as controls rather than as captions --
;; a rail of 12px targets is a rail a reader has to aim at -- and the padding
;; gives each one a target a finger can land on.
;;
;; The rail always wraps, on a phone as much as on a wide screen: it is the
;; index of the page, and an index whose last entries sit behind a sideways
;; scroll is one a reader never learns is complete.
(define showcase-toc
  (section-nav (map (lambda (entry)
                      (cons (car entry)
                            (cadr entry))) showcase-entries)
               #:list-classes '(flex flex-row
                                     flex-wrap
                                     gap-x-3
                                     gap-y-6
                                     list-none
                                     p-0)
               #:link-classes '(no-underline rounded-512
                                             px-3
                                             py-2
                                             text-md
                                             font-medium
                                             bg-stone-100/50
                                             dark:bg-onyx-900/50
                                             border-2
                                             border-stone-500/25
                                             dark:border-onyx-100/25
                                             hover:bg-stone-100/90
                                             dark:hover:bg-onyx-900/75
                                             transition-colors
                                             duration-150
                                             focus-visible:outline-2
                                             focus-visible:outline-offset-2
                                             outline-onyx-500)
               #:active-classes '(bg-stone-300/90 dark:bg-onyx-700/90
                                                  text-onyx-500
                                                  dark:text-stone-100)
               #:inactive-classes '(text-onyx-500 dark:text-stone-300)
               ;; the theme toggle rides at the end of the rail rather than
               ;; inside a card: it is a setting for the whole document, and the
               ;; one bar that follows the page is where a reader looks for it
               #:controls (ui-mode-button #:content "Light / dark")))

;; the grid itself: two cards to a row once the viewport is wide enough, one on
;; a phone. Only the sections that are wider than a column -- the type specimen,
;; the palette, the form samples, a table, the gallery, the states and the
;; closing argument -- ask for the whole row, so the page reads as a tray of
;; cards rather than as a list of sections with a border around each. The rows
;; are aligned to their top rather than stretched, so a short card beside a long
;; one keeps its own height instead of growing a hollow body. Its id is the tray
;; the sort control reorders.
(define (showcase-grid)
  `((div (@ (id "showcase-grid")
            (class ,(mk-class '(grid grid-cols-1 lg:grid-cols-2 gap-5
                                     items-start my-6))))
         ,@(let loop
             ((entries showcase-entries)
              (order 0))
             (if (null? entries)
                 '()
                 (cons (showcase-card (car entries) order)
                       (loop (cdr entries)
                             (+ order 1))))))))

;; The two controls above the grid, both the framework's own: the orders a
;; reader can put the tray in, and the pair that opens or folds all of it. The
;; first mode is the order the page opens in, so `Page order' needs no
;; attribute on any card -- a mode nothing carries is the order the page wrote
;; -- while `By category' reads the rank each card carries beside the shelf it
;; shows.
(define showcase-controls
  `((div (@ (class ,(mk-class '(flex flex-row
                                     flex-wrap
                                     items-center
                                     justify-between
                                     gap-3
                                     my-4))))
         ,(sort-control #:target "showcase-grid"
                        #:modes '(("page" . "Page order") ("title" . "A-Z")
                                  ("category-rank" . "By category"))
                        #:aria-label "Order the sections")
         ,(disclosure-controls #:selector "details.hg-expandable-card"))))

(define (showcase-body)
  (with-footer #:main `((div (@ (class ,(mk-class '(pt-16 sm:pt-24
                                                          pb-8
                                                          px-4
                                                          sm:px-6
                                                          lg:px-8
                                                          max-w-360
                                                          mx-auto))))
                             ,@(showcase-hero)
                             ,showcase-toc
                             ,showcase-controls
                             ,(showcase-grid)))
               #:footer showcase-footer))

(define* (html-template #:key title body)
  `(,doctype-html (html (@ (lang en)
                           (class ,(mk-class '(scroll-smooth))))
                        (head (title ,title)
                              ,(hygguile-recommended-meta)
                              ,(hygguile-recommended-resources)
                              (link (@ (rel stylesheet)
                                       (href "olive.min.css")))
                              (body (@ (class ,(mk-class '(bg-stone-100
                                                           dark:bg-onyx-900
                                                           font-sans))))
                                    ,notification-tray
                                    ,@body)))))

(define (showcase)
  (with-output-to-string (lambda ()
                           (sxml->xml (html-template #:title
                                                     "hygguile showcase"
                                                     #:body (showcase-body))))))
