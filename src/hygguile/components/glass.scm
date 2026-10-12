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

;; You should have received a copy of the GNU Lesser General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (hygguile components glass)
  #:use-module (ice-9 format)
  #:use-module (hygguile abstraction)
  #:export (glass-panel glass-wash))

;; What makes a surface frosted, whatever silhouette it wears: whatever is
;; behind the pane arrives coloured and blurred through it. This is the one
;; line every frosted surface in the framework has in common -- the navbar,
;; a fly-out menu and a notification all reach it through `glass-panel'.
;;
;; The class is the framework's own rather than an Olive blur utility,
;; because the frost cannot be a backdrop-filter on the pane itself:
;; browsers paint a filtered backdrop in the pane's square box and ignore
;; its radius, which leaves a square patch of frost at every rounded
;; corner, and neither a radius nor a clip path on that element cures it.
;; `hg-frost' paints the frost one level in, in a layer of the pane's own
;; that rounds itself to the pane's radius and clips itself, so the pane
;; keeps its shape, keeps letting a child escape, and still frosts what is
;; behind it. See `hygguile-extras.css' for the whole story.
(define glass-frost-classes
  '(hg-frost))

;; The dress a pane wears unless it says otherwise: a tint, a deep
;; rounding, the border that draws the edge of the glass, and the shadow
;; that lifts it off the page. A surface whose silhouette genuinely differs
;; -- a bar that spans the viewport, a dropdown that drops out of one --
;; passes `#:rounding', `#:border' or `#:shadow' instead of restating the
;; frost for itself.
(define glass-default-tint
  '(bg-stone-100/75 dark:bg-onyx-900/75))

(define glass-default-rounding
  '(rounded-3xl))

(define glass-default-border
  '(border-2 border-stone-500/25 dark:border-onyx-100/25))

(define glass-default-shadow
  '(shadow-lg))

;; What every wash is made of regardless of its colour: the size, the
;; place and the tint belong to the caller, the rest is mechanics. The
;; drift itself is one more class, added only when the panel asks for it.
(define glass-wash-classes
  '(absolute pointer-events-none select-none rounded-512 blur-3xl opacity-75))

(define (glass-wash-ref wash key)
  "Return @var{key} from a @code{glass-wash} descriptor, or @code{#f}."
  (and (pair? wash)
       (assq-ref wash key)))

(define (glass-time value)
  "Return @var{value} as a CSS time, counting a bare number as seconds.

A time is a number of seconds or any CSS time, so a caller who writes
@code{-6} and a caller who writes @code{\"-6s\"} both mean six seconds:
into the cycle when it is a delay, one drift long when it is a pace."
  (cond
    ((number? value)
     (format #f "~as" value))
    ((symbol? value)
     (symbol->string value))
    (else (format #f "~a" value))))

(define (glass-length value)
  "Return @var{value} as a CSS length, counting a bare number as rems.

A distance is a number of rems or any CSS length, so a caller who writes
@code{2} and a caller who writes @code{\"2rem\"} both mean two rems."
  (cond
    ((number? value)
     (format #f "~arem" value))
    ((symbol? value)
     (symbol->string value))
    (else (format #f "~a" value))))

(define (glass-frost-declaration frost)
  "Return the one CSS declaration a frost strength is written as.

A strength is a number of rems or any CSS length, so @code{3} and
@code{\"3rem\"} both mean three rems. It reaches the browser as
@code{--hg-frost-blur}, the property the frosted layer reads, behind which
the stylesheet's own 4rem sits as the default."
  (list (cons '--hg-frost-blur
              (glass-length frost))))

(define (glass-surface-attributes attributes declarations)
  "Return @var{attributes} with @var{declarations} added to their style.

The surface's attributes belong to the caller, so a panel that brought a
style of its own -- a colour, a size -- keeps it: the declarations are
appended to that style rather than replacing it. A panel with nothing to
declare is handed back its attributes untouched, and carries no @code{style}
attribute at all."
  (if (null? declarations) attributes
      (let ((style (mk-style declarations))
            (hit (assq 'style attributes)))
        (if hit
            (map (lambda (attribute)
                   (if (eq? attribute hit)
                       (list 'style
                             (string-append (cadr hit) "; " style)) attribute))
                 attributes)
            (append attributes
                    (list (list 'style style)))))))

(define* (glass-wash classes
                     #:key (delay #f)
                     (pace #f)
                     (distance #f))
  "Describe one colour wash for @code{glass-panel}.

A wash is a description, not markup: it says what the disc is made of and
when it sets off, and the panel supplies the rest. The @var{classes} given
here are read by Olive the way any other utility classes are, so the size
(@code{w-96}), the place inside the panel (@code{left-4 top-4}) and the
colour (@code{bg-naples-yellow-500/75}) are all just names. The panel adds
the mechanics -- the absolute positioning, the heavy blur, the rounding,
the fact that the disc is decoration and never takes a pointer event --
and decides whether it drifts at all, so one wash can stand still on one
panel and move on another.

@table @var
@item classes
List of symbols: the disc's size, position and colour.
@item delay
A number of seconds, or any CSS time as a string. A negative delay starts
the disc part way through its cycle, which is how several washes are kept
out of phase with one another; @code{#f} (the default) leaves it in step
with the rest.
@item pace
How long one drift takes: a number of seconds or any CSS time as a string,
emitted as the disc's @code{--hg-blob-duration}, which is what the
stylesheet reads for the pace and is where its own default sits. Omitted, a
panel drifts at that default. This is what lets one panel breathe slowly
and another wander on a short leash, without a second stylesheet or a new
class.
@item distance
How far the disc travels: a pair of lengths -- horizontally and vertically
-- or a single length, which moves it along the horizontal axis and leaves
the stylesheet's own upward drift in place. A bare number counts as rems,
so @code{'(2 -1)} travels 2rems right and 1rem up. Omitted, the
disc travels as far as the stylesheet's default.
@end table

@example
(glass-wash '(bg-china-rose-500/50 w-72 h-72 right-4 top-4)
            #:delay -14 #:pace 40 #:distance '(3 -2))
@end example"
  (list (cons 'classes classes)
        (cons 'delay delay)
        (cons 'pace pace)
        (cons 'distance distance)))

(define* (render-glass-wash wash
                            #:key (drift? #f))
  "Render one @code{glass-wash} descriptor as the decorative disc it describes."
  (let* ((classes (or (glass-wash-ref wash
                                      'classes)
                      '()))
         (delay (glass-wash-ref wash
                                'delay))
         (pace (glass-wash-ref wash
                               'pace))
         (distance (glass-wash-ref wash
                                   'distance))
         (x (if (pair? distance)
                (car distance) distance))
         (y (and (pair? distance)
                 (cadr distance)))
         (style (append (if delay
                            (list (cons 'animation-delay
                                        (glass-time delay)))
                            '())
                        (if pace
                            (list (cons '--hg-blob-duration
                                        (glass-time pace)))
                            '())
                        (if x
                            (list (cons '--hg-blob-x
                                        (glass-length x)))
                            '())
                        (if y
                            (list (cons '--hg-blob-y
                                        (glass-length y)))
                            '()))))
    `((div (@ (aria-hidden "true")
              (class ,(mk-class (append glass-wash-classes
                                        (if drift?
                                            '(hg-blob)
                                            '()) classes)))
              ,@(attr-when (pair? style)
                           'style
                           (mk-style style)))))))

(define* (glass-panel content
                      #:key (washes '())
                      (drift? #f)
                      accent
                      (tag 'div)
                      (attributes '())
                      (position '(relative))
                      (frost #f)
                      (tint glass-default-tint)
                      (rounding glass-default-rounding)
                      (border glass-default-border)
                      (shadow glass-default-shadow)
                      (clip? #f)
                      (padding '(p-6 sm:p-8))
                      (classes '())
                      (content-classes '()))
  "Create a frosted glass surface, with colour washes behind it if you want them.

The frost is the panel's own translucent tint plus @code{hg-frost}, the
framework's rounded frost layer (see @file{hygguile-extras.css}): whatever
sits behind the panel arrives blurred and coloured through it, so the
panel reads as a pane of glass rather than an opaque card. How strong the
frost is is the panel's to say with @var{frost}, or a page's in markup the
component did not build: it is written as @code{--hg-frost-blur}, and four
rems stand until something says otherwise.

The frost is not a @code{backdrop-filter} on the surface itself, and that
is the point of the layer. A browser paints a filtered backdrop in the
element's square box and ignores its radius, which leaves a square patch
of frost at every rounded corner; neither the radius nor a clip path on
that element stops it, and clipping the surface would trap whatever it is
meant to let out of its own corner. The layer therefore paints the frost,
clips itself to the surface's own radius, and leaves the surface free.

The surface never clips. The decorations (the washes and the @var{accent})
are wrapped in their own rounded clip layer, which is what keeps those
oversized discs inside the glass, and that layer is a plain element, which
browsers clip to its radius reliably.

The layer that holds the content does not clip unless the panel asks it to
with @var{clip?}, and that default is deliberate. That layer's edge falls
exactly on the content's own edge -- the surface's padding is on the
surface -- so a clip there shaves whatever sits flush with it by a device
pixel: the left arc of a line's first glyph, the stroke of a table's first
cell. Clipping is a knob a panel reaches for, not a tax every panel pays.

The washes are the wallpaper trick: a few oversized, heavily blurred discs
of colour thrown across the panel, each described by @code{glass-wash}.
They are decoration, so they are hidden from assistive technology and
never take a pointer event, and the content sits in a positioned layer of
its own above them. With @var{drift?} the discs move very slowly, out of
phase with one another, so the glass has something to frost without ever
stealing attention; left alone they are still, which is the calmer default
for a panel that is often just a bit of background. Either way the drift
stops for anyone who asks for less motion: @code{prefers-reduced-motion}
turns the animation off in the stylesheet.

The layer the discs ride in wears the panel's own rounding and clips, and
that is still not enough for a blurred disc: a browser draws a filter's
blur in the square box the blur reaches, so without a clip of its own the
wash leaves a faint square of ink beside each rounded corner. The layer's
class names that clip, and a clip has to name a radius, so it carries the
framework's default rounding as its own default. A panel that rounds its
glass differently says so in @code{--hg-glass-clip}, on the panel or on
any ancestor of the layer. See @code{hygguile-extras.css} for the whole
story, and for the measurements that leave an explicit clip as the only
cure.

A panel with no decorations has no layers, and then there is nothing to
sit above: the content is the panel's own children and no layer is added.
That is what lets this one component be a @code{<header>}, a @code{<ul>}
or a @code{<div>} without leaving an extra element inside, which a
@code{<ul>} may not legally hold. A panel that does have decorations gets
its decorations in a rounded @code{<div>} of their own and its content in
a second one.

@table @var
@item content
The panel's contents.
@item washes
A list of @code{glass-wash} descriptors, or the empty list (the default)
for a plain frosted panel.
@item drift?
A boolean; @code{#t} lets the washes drift.
@item accent
An optional decorative node drawn inside the clipped surface, above the
washes and below the content: a hairline of gradient along the top edge,
for instance.
@item tag
The element the surface is built from. Defaults to @code{div}; a bar wants
@code{header} and a menu wants @code{ul}.
@item attributes
Extra attributes for the surface, as pairs of name and value.
@item position
List of symbols saying how the surface is placed. Defaults to
@code{(relative)}, which is what gives the washes something to be absolute
against. A surface pinned some other way -- @code{(sticky top-0)} for a bar
-- passes its own, or the empty list to place itself with the layout
classes alone.
@item frost
How strong the frost is: a number of rems, or any CSS length as a string.
Defaults to @code{#f}, which declares nothing and leaves the strength to
the stylesheet's own 4rem -- the value Olive's @code{backdrop-blur-md}
would set. A pane that wants a gentler or heavier glass than the
framework's own passes its own, and carries no @code{style} attribute at
all when it does not.
@item tint
List of symbols representing the frosted tint. Defaults to
@code{(bg-stone-100/75 dark:bg-onyx-900/75)}.
@item rounding
List of symbols representing the corner rounding. Defaults to
@code{(rounded-3xl)}.
@item border
List of symbols representing the border, or the empty list for none.
Defaults to a two-pixel hairline in the stone ramp.
@item shadow
List of symbols representing the shadow, or the empty list for none.
Defaults to @code{(shadow-lg)}.
@item clip?
Whether the panel hides its content's overflow, in the layer holding the
content. Defaults to false: the washes are oversized but it is the layer
they are painted in that keeps them inside the glass, so the content layer
has no work to do unless a panel hands it some. Leaving it open is what
keeps a line's first glyph whole -- that layer's edge is the content's own
edge -- and it keeps a surface free to let a child escape, a bar holding a
dropdown being the case worth naming. The surface itself never carries
@code{overflow-hidden}, whichever way @var{clip?} is set.
@item padding
List of symbols representing the padding classes. Defaults to
@code{(p-6 sm:p-8)}.
@item classes
Extra classes for the surface itself. A colour utility here replaces the
corresponding default rather than piling onto it (see
@code{override-classes}), so a surface can recolour its own glass.
@item content-classes
Extra classes for the layer holding the content, when a layer is added, so
a panel can lay its contents out without reaching for the surface -- a
@code{(flex flex-col gap-6)} hero, for instance, spaces its rows with it.
@end table

@example
(glass-panel (list (h1 \"Hygguile\"))
             #:washes (list (glass-wash '(bg-naples-yellow-500/75
                                          w-96 h-96 left-4 top-4)
                                        #:delay -6))
             #:frost 3
             #:drift? #t)

(glass-panel (list (nav-link \"Home\" #:href \"/\"))
             #:tag 'header
             #:position '(sticky top-0)
             #:rounding '()
             #:border '()
             #:padding '(px-4 py-4))
@end example"
  (let* ((layers (or (pair? washes)
                     (and accent #t)))
         ;; a frost strength is a declaration rather than a class, since it
         ;; is read on the panel's own layer (see the docstring)
         (declarations (if frost
                           (glass-frost-declaration frost)
                           '()))
         ;; the frost, the silhouette and the shadow all stay on the
         ;; surface; the clipping is somebody else's job (see the docstring)
         (surface (append position
                          glass-frost-classes
                          tint
                          rounding
                          border
                          shadow))
         ;; the layer the washes ride in is rounded and clipping, and it
         ;; also names its own clip: a blurred disc is painted in the
         ;; square box its blur reaches, so the rounding alone would leave
         ;; a faint square of wash beside each corner (see the sheet)
         (clip-classes (append '(hg-glass-layer absolute inset-0) rounding
                               '(overflow-hidden)))
         (content-classes* (append '(relative)
                                   (if clip?
                                       (append rounding
                                               '(overflow-hidden))
                                       '()) content-classes)))
    `((,tag (@ ,@(glass-surface-attributes attributes declarations)
               (class ,(mk-class (override-classes (append surface padding)
                                                   classes))))
       ,@(if layers
             (list `(div (@ (class ,(mk-class clip-classes)))
                         ,@(map (lambda (wash)
                                  (render-glass-wash wash
                                                     #:drift? drift?)) washes)
                         ,@(if accent
                               (list accent)
                               '())))
             '())
       ,@(if (or layers clip?)
             (list `(div (@ (class ,(mk-class content-classes*)))
                         ,content))
             ;; a panel with no layer takes its contents directly, and a
             ;; single node is as good a content as a list of them
             (if (list? content) content
                 (list content)))))))
