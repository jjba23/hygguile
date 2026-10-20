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
                 #:size '(text-sm)) ,(em
                                      "licensed under the LGPL v3, or newer at your convenience"
                                      #:size '(text-sm))
            (div (@ (class ,(mk-class '(flex flex-col
                                             gap-2
                                             sm:flex-row
                                             sm:flex-wrap
                                             sm:items-center
                                             sm:gap-6))))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "source:"
                           #:size '(text-sm))
                      ,(a "codeberg.org/jjba23/hygguile"
                          #:href "https://codeberg.org/jjba23/hygguile"
                          #:size '(text-sm)
                          #:weight '(font-medium)))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "version:"
                           #:size '(text-sm))
                      ,(mono (format #f "~a"
                                     (get-short-commit-sha))
                             #:size '(text-sm)
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
;; breakpoint up
(define showcase-toc
  (section-nav (map (lambda (entry)
                      (cons (car entry)
                            (cadr entry))) showcase-entries)))

;; the grid itself: two columns once the viewport is wide enough, one on a
;; phone, with the widest cards -- the tables, the carousel, the gradients --
;; spanning both, so a section is never squeezed into a column it cannot fill.
;; Its id is the tray the sort control reorders.
(define (showcase-grid)
  `((div (@ (id "showcase-grid")
            (class ,(mk-class '(grid grid-cols-1 lg:grid-cols-2 gap-6
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
                                     gap-2
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
                                                          max-w-256
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
