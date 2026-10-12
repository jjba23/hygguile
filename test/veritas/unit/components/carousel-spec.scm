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

;; The carousel is the one component in the framework whose behaviour lives
;; in JavaScript: this file pins the markup, the arrow discs, and every hook
;; the paging script reaches for -- the ids, the classes and the direction
;; words -- so a rename on either side of that contract fails a test instead
;; of silently stopping the arrows.

(define-module (veritas unit components carousel-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components carousel)
  #:use-module (hygguile embed css)
  #:use-module (hygguile embed js)
  #:export (spec))

(define (element node)
  "The element itself, whether it arrived bare or in a one-element list."
  (if (symbol? (car node))
      node
      (car node)))

(define (children-of node)
  "The child nodes of a rendered element."
  (let ((root (element node)))
    (if (and (pair? (cdr root))
             (pair? (cadr root))
             (eq? (car (cadr root))
                  '@)) (cddr root) (cdr root))))

(define (nodes-of node)
  "The child nodes of a rendered element, with a list of nodes flattened.

The component hands its items to the track as one unquoted list, so a
caller reading the markup has to look through that list to see the
elements it holds."
  (append-map (lambda (child)
                (if (and (pair? child)
                         (not (symbol? (car child)))) child (list child)))
              (children-of node)))

(define (attrs-of node)
  "The attribute pairs of a rendered element, or the empty list."
  (let* ((root (element node))
         (candidate (and (pair? (cdr root))
                         (cadr root))))
    (if (and (pair? candidate)
             (eq? (car candidate)
                  '@)) (cdr candidate) '())))

(define (attr-value node name)
  "The value of attribute NAME on a rendered element, or #f."
  (let ((hit (assq name
                   (attrs-of node))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (tag-of node)
  "The tag a rendered element is built from."
  (car (element node)))

(define (tagged? node tag)
  "True when NODE is an element rather than text, and is TAG."
  (and (pair? node)
       (eq? (car node)
            tag)))

(define (children-with-tag node tag)
  "Every direct child of NODE whose element is TAG."
  (filter (lambda (child)
            (tagged? child tag))
          (nodes-of node)))

(define (child-with-tag node tag)
  "The first direct child of NODE whose element is TAG, or #f."
  (let ((hits (children-with-tag node tag)))
    (if (null? hits)
        #f
        (car hits))))

(define (class-has? node token)
  "Return #t when the rendered @var{token} appears in the node's class list."
  (let ((classes (attr-value node
                             'class)))
    (and (string? classes)
         (string-contains classes token)
         #t)))

(define (contains? text needle)
  "True when NEEDLE appears in TEXT."
  (and (string? text)
       (string-contains text needle)
       #t))

(define (rule-body css selector)
  "The declarations the stylesheet gives SELECTOR, or #f."
  (let ((at (and css
                 (string-contains css (string-append selector " {")))))
    (and at
         (let* ((start (+ at
                          (string-length selector)
                          2))
                (end (string-contains css "}" start)))
           (and end
                (substring css start end))))))

(define (paged-direction onclick)
  "The direction an arrow's onclick asks the script for, or #f."
  (let ((m (string-match "handleCarouselClick\\('([^']*)'" onclick)))
    (and m (match:substring m 1))))

(define (paged-id onclick)
  "The track an arrow's onclick hands the script, or #f."
  (let ((m (string-match "'([^']*)'\\)$" onclick)))
    (and m (match:substring m 1))))

;; ===== the fixtures =====

(define (fragments)
  "The fragments a carousel is built from: three little paragraphs."
  '(((p "One")) ((p "Two")) ((p "Three"))))

(define photo-track
  (car (carousel #:id "image-carousel"
                 #:fragments (fragments))))

;; The showcase's second carousel, and the reason ids reach the DOM as
;; strings whether they were written as symbols or not.
(define text-track
  (car (carousel #:id 'other-carousel
                 #:item-width '(w-48 sm:w-64)
                 #:fragments (fragments))))

(define bare-track
  (car (carousel #:id "bare-carousel"
                 #:fragments '())))

;; The size the caller asks for replaces the item default.
(define sized-track
  (car (carousel #:id "sized-carousel"
                 #:item-width '(w-96)
                 #:fragments (fragments))))

(define (track-of wrapper)
  "The scrolling @code{<ul>} the items live in."
  (child-with-tag wrapper 'ul))

(define (arrows-of wrapper)
  "The two paging buttons, the previous one first."
  (children-with-tag wrapper 'button))

(define (previous-arrow wrapper)
  "The disc that pages backwards."
  (car (arrows-of wrapper)))

(define (next-arrow wrapper)
  "The disc that pages forwards."
  (cadr (arrows-of wrapper)))

(define (items-of wrapper)
  "The snap points the track holds."
  (children-with-tag (track-of wrapper) 'li))

(define (content-of wrapper)
  "The content wrapper inside the first item."
  (child-with-tag (car (items-of wrapper)) 'div))

(define (track-id wrapper)
  "The id the track answers to, as the DOM has it."
  (attr-value (track-of wrapper)
              'id))

(define (onclick-of arrow)
  "The inline handler an arrow carries."
  (attr-value arrow
              'onclick))

(define (paging-script)
  "The paging script, as it ships inside the library."
  (car (filter string?
               (cdr (car (carousel-button-js))))))

(define (extras-stylesheet)
  "The framework's companion stylesheet, as it ships inside the library."
  (car (filter string?
               (cdr (car (hygguile-extras-css))))))

;; Asked once, because every assertion below reads the same two texts.
(define paging (paging-script))

(define extras (extras-stylesheet))

(define carousel-suite
  (suite "Carousel"
         (test "hygguile carousel"
               (assert-equal #:name
                             "the carousel is a positioned frame, so an arrow can be placed against the track"
                             #:got (list (tag-of photo-track)
                                         (class-has? photo-track "relative"))
                             #:expect (list 'div #t))
               (assert-equal #:name
                             "the track is a <ul> and the first thing in the frame"
                             #:got (list (tag-of (track-of photo-track))
                                         (eq? (car (children-of photo-track))
                                              (track-of photo-track)))
                             #:expect (list 'ul #t))
               (assert-equal #:name
                             "the track carries the caller's id, and the class its own style hangs on"
                             #:got (let ((track (track-of photo-track)))
                                     (list (attr-value track
                                                       'id)
                                           (class-has? track "carousel-list")))
                             #:expect (list "image-carousel" #t))
               (assert-equal #:name
                             "an id written as a symbol reaches the DOM as the string the script looks up"
                             #:got (track-id text-track)
                             #:expect "other-carousel")
               (assert-equal #:name
                             "the track pans by snap, and by hand when scripting is off"
                             #:got (let ((track (track-of photo-track)))
                                     (list (class-has? track "snap-x")
                                           (class-has? track "scroll-smooth")
                                           (class-has? track "overflow-x-scroll")
                                           (class-has? track "list-none")))
                             #:expect (list #t #t #t #t))
               (assert-equal #:name
                             "every fragment becomes one centred snap point"
                             #:got (map (lambda (item)
                                          (list (tag-of item)
                                                (class-has? item "snap-center")
                                                (class-has? item "shrink-0")
                                                (class-has?
                                                 item
                                                 "carousel-list-item")))
                                        (items-of photo-track))
                             #:expect '((li #t #t #t)
                                        (li #t #t #t)
                                        (li #t #t #t)))
               (assert-equal #:name
                             "an item is the width and height the component defaults to"
                             #:got (let ((item (car (items-of photo-track))))
                                     (list (class-has? item "w-64")
                                           (class-has? item "h-1/2")))
                             #:expect (list #t #t))
               (assert-equal #:name
                             "and the size is the caller's when one is given"
                             #:got (let ((item (car (items-of sized-track))))
                                     (list (class-has? item "w-96")
                                           (class-has? item "w-64")))
                             #:expect (list #t #f))
               (assert-equal #:name
                             "a fragment sits inside a content wrapper, which is all the item holds"
                             #:got (let ((item (car (items-of photo-track))))
                                     (list (tag-of (content-of photo-track))
                                           (equal? (nodes-of (content-of photo-track))
                                                   (car (fragments)))
                                           (length (children-of item))))
                             #:expect (list 'div #t 1))
               (assert-equal #:name
                             "the content wrapper is centred in the item"
                             #:got (let ((content (content-of photo-track)))
                                     (list (class-has? content "flex")
                                           (class-has?
                                            content
                                            "items-center")
                                           (class-has? content "h-full")))
                             #:expect (list #t #t #t))
               (assert-equal #:name
                "the item's own classes are the caller's, but the hook the script reads is not"
                #:got (let* ((wrapper (car (carousel #:id "custom-carousel"
                                                     #:carousel-item-css
                                                     '(my-item)
                                                     #:fragments
                                                     (fragments))))
                             (item (car (items-of wrapper))))
                        (list (class-has? item "my-item")
                              (class-has?
                               item
                               "carousel-list-item")))
                #:expect (list #t #t))
               (assert-equal #:name
                             "the frame is a track, an arrow, an arrow and a hint, in that order"
                             #:got (map (lambda (child)
                                          (car child))
                                        (children-of photo-track))
                             #:expect '(ul button button noscript))
               (assert-equal #:name
                             "the arrows are real buttons, not form submitters"
                             #:got (map (lambda (arrow)
                                          (attr-value arrow
                                                      'type))
                                        (arrows-of photo-track))
                             #:expect (list 'button 'button))
               (assert-equal #:name
                             "without scripting the arrows hide themselves"
                             #:got (map (lambda (arrow)
                                          (class-has? arrow "js-only"))
                                        (arrows-of photo-track))
                             #:expect (list #t #t))
               (assert-equal #:name
                             "and a hint says what to do instead"
                             #:got (let ((hint (child-with-tag photo-track
                                                              'noscript)))
                                     (children-of hint))
                             #:expect (list "JavaScript is disabled — scroll horizontally to browse the items."))
               (assert-equal #:name
                             "the hint's copy is the caller's to replace"
                             #:got (let ((wrapper (car (carousel #:id "quiet-carousel"
                                                                 #:no-js-hint
                                                                 "Swipe across the items."
                                                                 #:fragments
                                                                 (fragments)))))
                                     (children-of (child-with-tag wrapper
                                                                  'noscript)))
                             #:expect (list "Swipe across the items."))
               (assert-equal #:name
                             "a carousel with nothing in it is still a carousel"
                             #:got (list (items-of bare-track)
                                         (length (arrows-of bare-track)))
                             #:expect (list '() 2)))
         (test "frosted arrow discs"
               (assert-equal #:name
                "a disc wears the framework's frost layer rather than a backdrop filter of its own"
                #:got (let ((disc (previous-arrow photo-track)))
                        (list (class-has? disc "hg-frost")
                              (class-has? disc "hg-frost-soft")
                              (class-has? disc "backdrop-blur")))
                #:expect (list #t #t #f))
               (assert-equal #:name
                "the layer clips itself to the disc's own radius, which is what keeps the frost round"
                #:got (let ((body (or (rule-body extras
                                                 ".hg-frost::before")
                                      "")))
                        (list (contains? body "border-radius: inherit")
                              (contains? body "overflow: hidden")
                              (contains? body "z-index: -1")
                              (contains?
                               body
                               "backdrop-filter: blur(var(--hg-frost-blur, 4rem))")))
                #:expect (list #t #t #t #t))
               (assert-equal #:name
                "a disc's own step of the frost is the gentle one, because two rems across is all disc"
                #:got (contains? (or (rule-body extras
                                                ".hg-frost-soft")
                                     "")
                                 "--hg-frost-blur: 3rem")
                #:expect #t)
               (assert-equal #:name
                "the gentle step a disc asks for by name is the one the stylesheet defines"
                #:got (let ((step "hg-frost-soft"))
                        (list (contains? extras
                                         (format #f ".~a {" step))
                              (class-has? (previous-arrow photo-track)
                                          step)))
                #:expect (list #t #t))
               (assert-equal #:name
                             "a disc is a circle, not a rounded box"
                             #:got (class-has? (previous-arrow photo-track)
                                               "rounded-512")
                             #:expect #t)
               (assert-equal #:name
                             "a disc floats over the track, centred on it"
                             #:got (let ((disc (previous-arrow photo-track)))
                                     (list (class-has? disc "absolute")
                                           (class-has? disc "top-1/2")
                                           (class-has? disc
                                                       "-translate-y-1/2")))
                             #:expect (list #t #t #t))
               (assert-equal #:name
                "a disc is compact on a phone and roomy from the small breakpoint up, so the track keeps its pixels"
                #:got (let ((disc (previous-arrow photo-track)))
                        (list (class-has? disc "w-9")
                              (class-has? disc "h-9")
                              (class-has? disc "sm:w-14")
                              (class-has? disc "sm:h-14")))
                #:expect (list #t #t #t #t))
               (assert-equal #:name
                             "each disc sits on the side it pages, and only that side"
                             #:got (let ((left (previous-arrow photo-track))
                                         (right (next-arrow photo-track)))
                                     (list (class-has? left "left-2")
                                           (class-has? left "sm:left-4")
                                           (class-has? left "right-2")
                                           (class-has? right "right-2")
                                           (class-has? right "sm:right-4")
                                           (class-has? right "left-2")))
                             #:expect (list #t #t #f #t #t #f))
               (assert-equal #:name
                "a disc is glass, and has to be reachable: a tint, a border and a shadow that follow the theme"
                #:got (let ((disc (previous-arrow photo-track)))
                        (list (class-has? disc "bg-stone-100/50")
                              (class-has? disc "dark:bg-onyx-900/50")
                              (class-has? disc "border-2")
                              (class-has? disc "shadow-lg")
                              (class-has? disc "text-onyx-500")
                              (class-has? disc "dark:text-stone-300")))
                #:expect (list #t #t #t #t #t #t))
               (assert-equal #:name
                "a disc says it is clickable and shows where the keyboard is"
                #:got (let ((disc (previous-arrow photo-track)))
                        (list (class-has? disc "cursor-pointer")
                              (class-has? disc "focus-visible:outline-2")
                              (class-has? disc
                                          "focus-visible:outline-offset-2")))
                #:expect (list #t #t #t))
               (assert-equal #:name
                             "the glyph is the disc's only child, so the frost stays under it"
                             #:got (let ((disc (previous-arrow photo-track)))
                                     (list (children-of disc)
                                           (children-of (next-arrow photo-track))))
                             #:expect (list (list "←")
                                            (list "→")))
               (assert-equal #:name
                             "the side classes are the caller's to replace"
                             #:got (let* ((wrapper (car (carousel #:id "wide-carousel"
                                                                  #:carousel-left-button-css
                                                                  '(left-8)
                                                                  #:fragments
                                                                  (fragments))))
                                          (disc (previous-arrow wrapper)))
                                     (list (class-has? disc "left-8")
                                           (class-has? disc "left-2")
                                           (class-has? disc "hg-frost")))
                             #:expect (list #t #f #t)))
         (test "paging"
               (assert-equal #:name
                "an arrow's inline handler finds the script, which declares the function on the global scope"
                #:got (list (contains?
                             paging
                             "function handleCarouselClick(direction, id)")
                            (contains? paging "const handleCarouselClick"))
                #:expect (list #t #f))
               (assert-equal #:name
                             "each arrow names the track it pages, in the direction it asks for"
                             #:got (map (lambda (arrow)
                                          (let ((onclick (onclick-of arrow)))
                                            (list (paged-direction onclick)
                                                  (equal? (paged-id onclick)
                                                          (track-id
                                                           photo-track)))))
                                        (arrows-of photo-track))
                             #:expect '(("previous" #t) ("next" #t)))
               (assert-equal #:name
                "the script names only the direction that pages back: forward is what anything else is"
                #:got (list (contains? paging "'previous'")
                            (contains? paging "'next'"))
                #:expect (list #t #f))
               (assert-equal #:name
                "an arrow pages the track it sits in, even when the id was written as a symbol"
                #:got (list (paged-id (onclick-of (previous-arrow text-track)))
                            (paged-id (onclick-of (next-arrow text-track)))
                            (track-id text-track))
                #:expect (list "other-carousel" "other-carousel"
                               "other-carousel"))
               (assert-equal #:name
                "paging moves one item at a time, from wherever the track actually sits"
                #:got (list (contains? paging "nearest + step")
                            (contains? paging
                                       "direction === 'previous' ? -1 : 1"))
                #:expect (list #t #t))
               (assert-equal #:name
                "and it stops at the first and the last item instead of scrolling past them"
                #:got (contains? paging
                                 "Math.min(Math.max(nearest + step, 0), items.length - 1)")
                #:expect #t)
               (assert-equal #:name
                "it scrolls to where the target item is centred, smoothly"
                #:got (list (contains? paging
                                       "list.scrollBy({ left: centres[target] - listCentre")
                            (contains? paging "behavior: 'smooth'"))
                #:expect (list #t #t))
               (assert-equal #:name
                "the item centres are measured live, so a breakpoint's gap is honoured"
                #:got (list (contains? paging "getBoundingClientRect()")
                            (contains? paging "clientWidth / 2"))
                #:expect (list #t #t))
               (assert-equal #:name
                "a missing track, or one with nothing in it, is left alone"
                #:got (list (contains? paging "if (!list)")
                            (contains? paging "if (!items.length)"))
                #:expect (list #t #t))
               (assert-equal #:name
                "the hook class the script looks for is the one the item wears"
                #:got (let ((hook "carousel-list-item"))
                        (list (contains? paging
                                         (format #f "'.~a'" hook))
                              (class-has? (car (items-of photo-track))
                                          hook)))
                #:expect (list #t #t)))))

(define (spec)
  (veritas-run carousel-suite))
