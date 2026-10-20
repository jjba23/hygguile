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

(define-module (hygguile components layout)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components tokens)
  #:export (stack
            cluster
            grid
            split
            center
            spacer
            aspect-ratio
            ratio-label))

;; ===== Layout primitives =====
;;
;; Everything here renders one plain element and lays its children out with
;; a handful of utilities, which is deliberate: a layout primitive that
;; cannot be seen in the markup is not worth a component, and one that adds
;; its own stylesheet is a second layout system to learn. The value they add
;; is the *decision*: a stack always spaces its rows the same way, a split
;; always collapses in the same place, and a centre always has the same
;; reading width, so a page built out of them is consistent before anyone
;; thinks about consistency.
;;
;; Nothing here takes part in the density scale by default -- these are
;; structural, and a page that tightens its data-heavy parts should not have
;; its page structure jump as well. The components that do read
;; `--hg-density' say so.

(define (align-classes align)
  "Return the cross-axis alignment classes for @var{align}, a symbol.

@table @var
@item align
One of @code{'stretch} (default), @code{'start}, @code{'center} or
@code{'end}.
@end table"
  (cond
    ((eq? 'start align)
     '(items-start))
    ((eq? 'center align)
     '(items-center))
    ((eq? 'end align)
     '(items-end))
    ((eq? 'baseline align)
     '(items-baseline))
    (else '(items-stretch))))

(define* (stack content
                #:key (gap '(gap-4))
                (align 'stretch)
                (tag 'div)
                (classes '())
                (attributes '()))
  "Stack children vertically with one rhythm between them.

This is the most-used layout in an interface: a heading, a paragraph, a
button, all separated by the same gap. Writing the gap once, in the
component, is what keeps two stacks on the same page from being four pixels
apart in one place and six in another.

@table @var
@item content
The children, as a list of nodes.
@item gap
A list of gap utilities. Defaults to @code{(gap-4)}.
@item align
Cross-axis alignment: @code{'stretch} (default), @code{'start},
@code{'center}, @code{'end} or @code{'baseline}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the stack itself.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(stack (list (h2 \"Account\")
             (p \"Signed in as Ada.\")
             (submit-button \"Save\"))
       #:gap '(gap-2))
@end example"
  `((,tag (@ ,@attributes
             (class ,(mk-class (append '(flex flex-col)
                                       (align-classes align)
                                       gap classes))))
          ,@content)))

(define* (cluster content
                  #:key (gap '(gap-2))
                  (align 'center)
                  (justify 'start)
                  (tag 'div)
                  (classes '())
                  (attributes '()))
  "Lay children out in a row that wraps when it runs out of room.

A cluster is for the things that belong beside each other but not in a
grid: a row of badges, a toolbar, a list of tags. It wraps rather than
overflowing, which is what keeps a toolbar usable on a phone without a
breakpoint of its own.

@table @var
@item content
The children, as a list of nodes.
@item gap
A list of gap utilities. Defaults to @code{(gap-2)}.
@item align
Cross-axis alignment. Defaults to @code{'center}.
@item justify
Main-axis distribution: @code{'start} (default), @code{'center},
@code{'end} or @code{'between}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the cluster itself.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(cluster (list (badge \"new\") (badge \"beta\" #:variant 'warning)))
@end example"
  (let ((justify-classes (cond
                           ((eq? 'center justify)
                            '(justify-center))
                           ((eq? 'end justify)
                            '(justify-end))
                           ((eq? 'between justify)
                            '(justify-between))
                           (else '(justify-start)))))
    `((,tag (@ ,@attributes
               (class ,(mk-class (append '(flex flex-row flex-wrap)
                                         (align-classes align)
                                         justify-classes
                                         gap classes))))
            ,@content))))

(define* (grid content
               #:key (columns 2)
               (gap '(gap-4))
               (min-column #f)
               (dense? #f)
               (tag 'div)
               (classes '())
               (attributes '()))
  "Lay children out in a responsive grid.

Two modes, and the difference matters. Given @var{columns}, the grid is one
column on a phone, two from the small breakpoint and the requested number
from the medium one -- the familiar shape, expressed with Olive's breakpoint
variants. Given @var{min-column}, the browser fits as many columns as the
track can hold at that minimum width, which is what a gallery of cards
wants: no breakpoint has to guess how wide a card should be, and a wide
screen simply shows more of them.

@table @var
@item content
The children, as a list of nodes.
@item columns
The number of columns from the medium breakpoint up. Defaults to @code{2}.
@item gap
A list of gap utilities. Defaults to @code{(gap-4)}.
@item min-column
An optional CSS length, such as @code{\"16rem\"}, switching the grid to
intrinsic sizing instead of breakpoints.
@item dense?
Whether the grid may backfill holes left by items spanning several tracks.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the grid itself.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(grid (list (card ...) (card ...) (card ...)) #:columns 3)
(grid (list (card ...) (card ...)) #:min-column \"18rem\")
@end example"
  (let* ((n (max 1 columns))
         (column-classes (if min-column
                             '()
                             (append '(grid-cols-1)
                                     (if (> n 1)
                                         '(sm:grid-cols-2)
                                         '())
                                     (if (> n 2)
                                         (list (string->symbol
                                                (format #f "md:grid-cols-~a" n)))
                                         '()))))
         (style (if min-column
                    (mk-style `((grid-template-columns
                                 . ,(format #f
                                            "repeat(auto-fit, minmax(~a, 1fr))"
                                            min-column))))
                    #f)))
    `((,tag (@ ,@attributes
               ,@(if style
                     `((style ,style))
                     '())
               (class ,(mk-class (append '(grid)
                                         column-classes
                                         (if dense?
                                             '(grid-flow-dense)
                                             '())
                                         gap classes))))
            ,@content))))

(define* (split #:key start end
                (ratio '(1 2))
                (gap '(gap-6))
                (breakpoint 'lg)
                (tag 'div)
                (classes '())
                (attributes '()))
  "Lay out a main pane beside a secondary one, collapsing to one column on
narrow screens.

The ratio is the contract: @code{'(1 2)} gives the start pane a third and
the end pane two thirds from the breakpoint up, and each pane simply takes
the whole row below it. That is a sidebar and its content, but also a
summary beside a form and a figure beside its caption.

@table @var
@item start
The first pane's nodes.
@item end
The second pane's nodes.
@item ratio
A pair of positive integers, start then end. Defaults to @code{(1 2)}.
@item gap
A list of gap utilities. Defaults to @code{(gap-6)}.
@item breakpoint
The breakpoint from which the panes sit side by side: @code{'md} or
@code{'lg} (the default).
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(split #:start (list (sidebar ...))
       #:end (list (main ...))
       #:ratio '(1 3))
@end example"
  (let* ((start-parts (max 1 (car ratio)))
         (end-parts (max 1 (cadr ratio)))
         (total (+ start-parts end-parts))
         (prefix (symbol->string breakpoint)))
    (if (> total 12)
        (error "a split ratio may not add up to more than 12 tracks" ratio)
        `((,tag (@ ,@attributes
                   (class ,(mk-class (append (list 'grid 'grid-cols-1
                                                   (string->symbol
                                                    (format #f "~a:grid-cols-~a"
                                                            prefix total)))
                                             gap classes))))
                (div (@ (class ,(mk-class (list (string->symbol
                                                 (format #f "~a:col-span-~a"
                                                         prefix start-parts))))))
                     ,@start)
                (div (@ (class ,(mk-class (list (string->symbol
                                                 (format #f "~a:col-span-~a"
                                                         prefix end-parts))))))
                     ,@end))))))

(define* (center content
                 #:key (max-width '(max-w-prose))
                 (padding '(px-4))
                 (axis 'horizontal)
                 (tag 'div)
                 (classes '())
                 (attributes '()))
  "Centre content horizontally (and optionally vertically) with a maximum
reading width.

Horizontal centring is the default, because that is the one that keeps a
page readable: prose stops growing at @code{max-w-prose} and the gutter on
either side grows instead. Vertical centring -- a sign-in form in the middle
of a page -- is asked for with @code{#:axis 'both}.

@table @var
@item content
The children, as a list of nodes.
@item max-width
A list of max-width utilities. Defaults to @code{(max-w-prose)}.
@item padding
A list of horizontal padding utilities. Defaults to @code{(px-4)}.
@item axis
@code{'horizontal} (default) or @code{'both}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(center (list (h1 \"Sign in\") (form ...)) #:max-width '(max-w-128) #:axis 'both)
@end example"
  `((,tag (@ ,@attributes
             (class ,(mk-class (append '(mx-auto w-full)
                                       max-width
                                       padding
                                       (if (eq? 'both axis)
                                           '(flex flex-col items-center
                                                  justify-center min-h-screen)
                                           '())
                                       classes))))
          ,@content)))

(define* (spacer #:key (axis 'vertical)
                 (size #f)
                 (grow? #f)
                 (classes '())
                 (attributes '()))
  "Insert deliberate empty space, or a flexible gap, between siblings.

A spacer is better than a margin on the thing after it, because it is
visible in the markup as a decision rather than looking like an accident
of one component's defaults. In flexible layouts, @code{#:grow? #t} is the
spacer that pushes what follows to the far end of the row.

@table @var
@item axis
@code{'vertical} (default), @code{'horizontal} or @code{'both}.
@item size
A list of sizing utilities, such as @code{(h-8)}. Ignored when
@var{grow?} is true.
@item grow?
Whether the spacer takes the free space on the main axis instead.
@item classes
Extra classes for the spacer.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(spacer #:size '(h-12))
(cluster (list (brand) (spacer #:grow? #t) (ui-mode-button)))
@end example"
  (let ((size-classes (cond
                        (grow? '(flex-1))
                        (size size)
                        ((eq? 'horizontal axis)
                         '(w-6))
                        ((eq? 'both axis)
                         '(w-6 h-6))
                        (else '(h-6)))))
    (list `(div (@ ,@attributes
                   (aria-hidden "true")
                   (class ,(mk-class (append size-classes classes))))))))

(define (ratio-label ratio)
  "Return @var{ratio} as the CSS @code{aspect-ratio} value it denotes, or
@code{#f} when the value is not a ratio this component understands.

Accepts @code{'video} (16/9), @code{'square} (1/1), @code{'photo} (4/3),
@code{'wide} (21/9), @code{'golden}, a pair such as @code{'(16 . 9)}, a
number, or any string CSS already accepts.

@table @var
@item ratio
A symbol, pair, number or string.
@end table

@example
(ratio-label 'video)
;; => \"16 / 9\"

(ratio-label '(4 . 3))
;; => \"4 / 3\"
@end example"
  (cond
    ((eq? 'video ratio)
     "16 / 9")
    ((eq? 'square ratio)
     "1 / 1")
    ((eq? 'photo ratio)
     "4 / 3")
    ((eq? 'wide ratio)
     "21 / 9")
    ((eq? 'golden ratio)
     "1.618 / 1")
    ((and (pair? ratio)
          (number? (car ratio))
          (number? (cdr ratio)))
     (format #f "~a / ~a" (car ratio) (cdr ratio)))
    ((number? ratio)
     (format #f "~a / 1" ratio))
    ((string? ratio)
     ratio)
    (else #f)))

(define* (aspect-ratio content
                       #:key (ratio 'video)
                       (rounding '(rounded-xl))
                       (overflow? #t)
                       (tag 'div)
                       (classes '())
                       (attributes '()))
  "Reserve a box with a fixed shape for its content, before that content
arrives.

The reserved box is what keeps a page from jumping when an image, a video
or an embed finally loads: the browser knows the shape from the first byte
and lays out around it. A ratio the component does not understand is
written through as given, so CSS's own syntax is always available.

@table @var
@item content
The children, as a list of nodes.
@item ratio
The shape: @code{'video} (default), @code{'square}, @code{'photo},
@code{'wide}, @code{'golden}, a pair, a number, or a CSS string.
@item rounding
A list of rounding utilities. Defaults to @code{(rounded-xl)}.
@item overflow?
Whether the box hides anything that outgrows it. Defaults to true.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the box.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(aspect-ratio (list (img #:src \"hero.jpg\" #:alt \"\"))
              #:ratio 'video)
@end example"
  (let ((label (ratio-label ratio)))
    (if (not label)
        (error "unknown aspect ratio" ratio)
        `((,tag (@ ,@attributes
                   (style ,(mk-style `((aspect-ratio . ,label))))
                   (class ,(mk-class (append '(relative block)
                                             rounding
                                             (if overflow?
                                                 '(overflow-hidden)
                                                 '())
                                             classes))))
                ,@content)))))
