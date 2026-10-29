;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components color)
  #:use-module (hygguile abstraction)
  #:export (color-swatch))

;; ====== A colour a reader can step through ======
;;
;; A palette page shows one tile per colour, and a reader who wants to compare
;; the shades of one of them has no way to ask. A swatch therefore shows a
;; colour *and* offers to show it again in the next variant: clicking the tile
;; steps `apple-green-500' to `apple-green-700' and on through the palette,
;; which is what makes a grid of tiles a reader can read rather than a
;; poster of fifty colours.
;;
;; The step is `resources/js/color-show.js', which is why the tile is a real
;; `<button>`: the tile is interactive, so it is reachable by keyboard and
;; announced as a control rather than as a picture. The script reads the
;; swatch's own `bg-*' class and rewrites the label from it, so the label
;; always names the shade on the tile -- and the label carries its own frost,
;; because a swatch can be any lightness and a fixed white or black ink would
;; be illegible on half of them.

(define* (color-swatch #:key color
                       (label #f)
                       (aria-label #f)
                       (swatch-classes '(rounded-2xl
                                         shadow-md
                                         p-4
                                         cursor-pointer
                                         w-32
                                         h-32
                                         flex
                                         flex-col
                                         justify-end))
                       (label-classes '(self-start
                                        rounded-2xs
                                        bg-stone-100/75
                                        dark:bg-onyx-900/75
                                        hg-frost
                                        hg-frost-pill
                                        px-2
                                        py-1
                                        text-sm
                                        font-medium
                                        text-onyx-500
                                        dark:text-stone-100
                                        pointer-events-none)))
  "Create a clickable colour tile that steps through the shades of a palette colour.

The tile carries @code{bg-<color>} and shows that colour's name; the script
it calls replaces the class with the next variant of the same colour every
time it is clicked -- 100, 300, 500, 700, 900 and back to 100 -- and relabels
the tile to match, so the tile always names the shade it is showing.

@table @var
@item color
The palette colour to show, named the way a class names it: @code{apple-green-500}.
@item label
The text on the tile, or @code{#f} for the colour's own name.
@item aria-label
The accessible name of the tile, or @code{#f} for a sentence naming the colour and what a click does.
@item swatch-classes
List of CSS classes for the tile itself.
@item label-classes
List of CSS classes for the frosted caption inside it.
@end table

@example
(color-swatch #:color 'apple-green-500)
@end example"
  (let* ((name (format #f "~a" color))
         (tile-class (string->symbol (format #f "bg-~a" name))))
    `((button (@ (type "button")
                 (aria-label ,(if aria-label
                                  aria-label
                                  (format #f
                                          "Show ~a in the next shade of its colour"
                                          name)))
                 (class ,(mk-class (append (list tile-class) swatch-classes)))
                 (onclick "cycleColorShow(this)"))
              (span (@ (class ,(mk-class label-classes)))
                    ,(if label label name))))))
