;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components utility)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components tokens)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (visually-hidden
            skip-link
            truncate-text
            line-clamp
            copy-button
            show
            hide
            fade-in
            slide-in
            collapse
            layer
            layer-root
            locale
            bdi
            bdo
            density-toggle))

;; ===== Utility and composition =====
;;
;; The things a page reaches for once, in the middle of writing something
;; else: hide this from sight but not from a screen reader, let a reader jump
;; past the navigation, cut a line of text off with an ellipsis, copy a value
;; to the clipboard, show a control only on wide screens. Each is small on
;; its own; together they are the difference between a component library and
;; a toolkit someone can actually build a page with.

;; ===== Accessibility =====

(define* (visually-hidden content
                           #:key (tag 'span)
                           (focusable? #f)
                           (classes '()))
  "Hide @var{content} visually while leaving it available to assistive
technology.

This is the framework's `sr-only' class with a name, so a page does not have
to remember which utility it is. Use it for the label of an icon-only
control, a section heading that would repeat what is already visible, or an
instruction that only makes sense to a screen reader.

Pass @code{#:focusable? #t} for the rarer case of content that should be
hidden until it takes focus -- a skip link, or a control that appears when
tabbed to. That one needs to be an element that can hold focus, so the
default tag is a @code{<span>} and callers pass @code{#'a} or
@code{#'button} as appropriate.

@table @var
@item content
The text or nodes to hide.
@item tag
The element to build. Defaults to @code{span}.
@item focusable?
Whether the content becomes visible when focused. Defaults to false.
@item classes
Extra classes for the wrapper.
@end table

@example
(visually-hidden \"Loading search results\")
(visually-hidden \"Skip to content\" #:tag 'a #:focusable? #t)
@end example"
  `((,tag (@ (class ,(mk-class (append '(sr-only)
                                       (if focusable?
                                           '(hg-visually-hidden-focusable)
                                           '())
                                       classes))))
          ,content)))

(define* (skip-link #:key (target "#main")
                    (label "Skip to content")
                    (classes '()))
  "Render the first focusable control on a page: a link that jumps past
the navigation straight to the content.

A skip link is the cheapest accessibility win there is and the most often
forgotten. It sits off-screen until a keyboard reader tabs to it, then
appears at the top of the page; following it moves focus to @var{target},
which should be the @code{id} of the page's @code{<main>}.

@table @var
@item target
The fragment the link points at, including the leading @code{#}. Defaults
to @code{\"#main\"}.
@item label
The link text. Defaults to @code{\"Skip to content\"}.
@item classes
Extra classes for the link.
@end table

@example
(skip-link #:target \"#main\")
@end example"
  `((a (@ (href ,target)
          (class ,(mk-class (append '(hg-skip-link) classes))))
       ,label)))

;; ===== Text =====

(define* (truncate-text content
                        #:key (lines 1)
                        (title #f)
                        (tag 'p)
                        (classes '()))
  "Cut text off after a number of lines, with an ellipsis.

One line uses Olive's @code{truncate} utility; several lines use its
@code{line-clamp-*} utilities, which is a real, painted clamp rather than a
character count, so it follows the rendered width of the type. The full
text stays in the DOM, so assistive technology and find-in-page still reach
it; a @var{title} is available for the mouse reader, but it is off by
default because it would make a second copy of the text for anyone who can
already see it.

@table @var
@item content
The text or inline nodes.
@item lines
How many lines to keep. Defaults to @code{1}.
@item title
An optional @code{title} attribute carrying the untruncated text.
@item tag
The element to build. Defaults to @code{p}.
@item classes
Extra classes for the text.
@end table

@example
(truncate-text \"A very long description indeed\" #:lines 2)
@end example"
  (let ((clamp-classes (if (<= lines 1)
                           '(truncate)
                           (list (string->symbol
                                  (format #f "line-clamp-~a"
                                          (min lines 5)))))))
    `((,tag (@ ,@(attr-when title
                            'title title)
               (class ,(mk-class (append clamp-classes classes))))
            ,content))))

(define* (line-clamp content
                       #:key (lines 2)
                       (title #f)
                       (tag 'p)
                       (classes '()))
  "Clamp text to a number of lines, with an ellipsis.

This is @code{truncate-text} under the name the CSS property has, for a page
that would rather read @code{line-clamp} at the call site. The full text
stays in the DOM, so assistive technology and find-in-page still reach it.

@table @var
@item content
The text or inline nodes.
@item lines
How many lines to keep. Defaults to @code{2}.
@item title
An optional @code{title} attribute carrying the untruncated text.
@item tag
The element to build. Defaults to @code{p}.
@item classes
Extra classes for the text.
@end table

@example
(line-clamp \"A long summary\" #:lines 3)
@end example"
  (truncate-text content #:lines lines #:title title #:tag tag #:classes classes))

;; ===== Clipboard =====

(define* (copy-button #:key text
                      (label "Copy")
                      (copied-label "Copied")
                      (show-text? #f)
                      (classes '()))
  "Render a button that copies @var{text} to the clipboard.

The button is a progressive enhancement and says so: it carries
@code{js-only}, so the no-script stylesheet hides it, and a
@code{<noscript>} beside it shows the value as selectable text instead. A
control that silently does nothing is worse than no control at all.

The value lives in a @code{data-hg-copy} attribute, not in an inline
handler, so the same script serves every copy button on the page and a page
with a Content Security Policy does not have to allow inline JavaScript.

@table @var
@item text
The value to copy.
@item label
The accessible label, shown as text only when @var{show-text?} is true.
@item copied-label
The accessible label after a successful copy. Defaults to
@code{\"Copied\"}.
@item show-text?
Whether the label is visible beside the icon. Defaults to false.
@item classes
Extra classes for the button.
@end table

@example
(copy-button #:text \"(use-modules (hygguile hygguile))\")
@end example"
  `((span (@ (class ,(mk-class '(inline-flex items-center gap-2))))
          (button (@ (type "button")
                     (class ,(mk-class (append '(hg-copy-button js-only
                                                   inline-flex
                                                   items-center
                                                   justify-center
                                                   gap-2
                                                   px-2
                                                   py-1
                                                   rounded-lg
                                                   border-2
                                                   border-stone-500/50
                                                   dark:border-onyx-100/50
                                                   bg-stone-300/75
                                                   dark:bg-onyx-700/75
                                                   text-onyx-500
                                                   dark:text-stone-300
                                                   text-sm
                                                   font-medium
                                                   font-sans
                                                   cursor-pointer
                                                   transition-colors
                                                   duration-150
                                                   focus-visible:outline-2
                                                   focus-visible:outline-offset-2
                                                   outline-onyx-500)
                                                 classes)))
                     (data-hg-copy ,text)
                     (data-hg-copy-label ,label)
                     (data-hg-copied-label ,copied-label)
                     (aria-label ,label))
                  ,(hyg:icon #:type 'copy
                             #:icon-css '(text-md))
                  ,@(if show-text?
                        `((span ,label))
                        '()))
          (noscript (code (@ (class ,(mk-class '(font-mono text-sm
                                                        select-all
                                                        text-onyx-500
                                                        dark:text-stone-300))))
                          ,text)))))

;; ===== Responsive helpers =====

(define breakpoint-map
  '((sm . "sm")
    (md . "md")
    (lg . "lg")
    (xl . "xl")
    (2xl . "2xl")))

(define (breakpoint-suffix from)
  "Return the utility-class prefix for @var{from}, or signal a helpful error."
  (let ((hit (assq-ref breakpoint-map from)))
    (or hit
        (error "unknown breakpoint (expected sm, md, lg, xl or 2xl)"
               from))))

(define* (show content
               #:key (from 'md)
               (display 'block)
               (tag 'div)
               (classes '())
               (attributes '()))
  "Show @var{content} only from a breakpoint up.

The markup is @code{hidden} plus the breakpoint's display utility, so the
hiding is done by the same stylesheet as everything else and the content is
not fetched twice. Below the breakpoint the element is not rendered at all
(@code{display: none}), which is the correct behaviour for a control that
only makes sense on a wide screen.

@table @var
@item content
The children, as a list of nodes.
@item from
The breakpoint: @code{'sm}, @code{'md} (default), @code{'lg},
@code{'xl} or @code{'2xl}.
@item display
The display value above the breakpoint, e.g. @code{'block},
@code{'flex}, @code{'grid} or @code{'inline-block}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(show (list (table ...)) #:from 'lg)
@end example"
  `((,tag (@ ,@attributes
             (class ,(mk-class (append (list 'hidden
                                             (string->symbol
                                              (format #f "~a:~a"
                                                      (breakpoint-suffix from)
                                                      display)))
                                       classes))))
          ,@content)))

(define* (hide content
               #:key (from 'md)
               (tag 'div)
               (classes '())
               (attributes '()))
  "Hide @var{content} from a breakpoint up.

Olive's responsive utilities are min-width, so there is no plain utility
that means \"gone above this width\"; the companion stylesheet names the
five classes this needs (@code{hg-hidden-from-sm} and friends), and this
component is the name a page uses instead of remembering them.

@table @var
@item content
The children, as a list of nodes.
@item from
The breakpoint: @code{'sm}, @code{'md} (default), @code{'lg},
@code{'xl} or @code{'2xl}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(hide (list (toolbar ...)) #:from 'md)
@end example"
  `((,tag (@ ,@attributes
             (class ,(mk-class (append (list (string->symbol
                                              (format #f "hg-hidden-from-~a"
                                                      (breakpoint-suffix from))))
                                       classes))))
          ,@content)))

;; ===== Motion primitives =====

(define* (motion-classes effect)
  "Return the classes for a named motion @var{effect}."
  (cond
    ((eq? 'fade effect)
     '(hg-motion-fade))
    ((eq? 'slide-up effect)
     '(hg-motion-slide-up))
    ((eq? 'slide-down effect)
     '(hg-motion-slide-down))
    ((eq? 'slide-start effect)
     '(hg-motion-slide-start))
    ((eq? 'slide-end effect)
     '(hg-motion-slide-end))
    ((eq? 'scale effect)
     '(hg-motion-scale))
    (else (error "unknown motion effect" effect))))

(define* (fade-in content
                  #:key (duration 'base)
                  (delay #f)
                  (tag 'div)
                  (classes '())
                  (attributes '()))
  "Fade @var{content} in, and do nothing at all when motion is reduced.

The duration is read from the design tokens, so the reduced-motion block
that sets every token to zero turns the animation off without a second
media query here. That is the whole point of the primitive: motion is a
token, not a commitment sprinkled through the markup.

@table @var
@item content
The children, as a list of nodes.
@item duration
A motion token: @code{'fast}, @code{'base} (default), @code{'slow} or
@code{'slower}.
@item delay
An optional delay token or CSS time.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(fade-in (list (alert ...)))
@end example"
  `((,tag (@ ,@attributes
             ,@(attr-when delay
                          'style
                          (mk-style (append
                                     (token-declarations (list (list 'motion
                                                                     duration)))
                                     (if (number? delay)
                                         (list (cons 'animation-delay
                                                     (format #f "~ams" delay)))
                                         (list (cons 'animation-delay
                                                     delay))))))
             (class ,(mk-class (append '(hg-motion-fade) classes))))
          ,@content)))

(define* (slide-in content
                   #:key (from 'up)
                   (duration 'base)
                   (tag 'div')
                   (classes '())
                   (attributes '()))
  "Slide @var{content} in from an edge, or not at all when motion is reduced.

@table @var
@item content
The children, as a list of nodes.
@item from
@code{'up} (default), @code{'down}, @code{'start} or @code{'end}.
@item duration
A motion token. Defaults to @code{'base}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the wrapper.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(slide-in (list (card ...)) #:from 'down)
@end example"
  `((,tag (@ ,@attributes
             (class ,(mk-class (append (motion-classes (string->symbol
                                                        (format #f "slide-~a"
                                                                from)))
                                       classes)))
             (style ,(mk-style (token-declarations (list (list 'motion
                                                               duration))))))
          ,@content)))

(define* (collapse #:key summary content
                   (open #f)
                   (classes '()))
  "A disclosure whose body animates open and closed.

This is a native @code{<details>} with its content in a grid track that
moves between zero and one fraction of its height, so the browser animates
the real height without a measuring script. The reduced-motion block in the
companion stylesheet sets the transition off, and the disclosure still
opens instantly -- the behaviour was never the animation.

@table @var
@item summary
The always-visible caption.
@item content
The collapsible body, as a list of nodes.
@item open
Whether it starts open.
@item classes
Extra classes for the @code{<details>}.
@end table

@example
(collapse #:summary \"Advanced\" #:content (list (input #:label \"Pattern\" #:name \"p\")))
@end example"
  `((details (@ ,@(if open
                      '((open ""))
                      '())
                (class ,(mk-class (append '(hg-collapse) classes))))
             (summary (@ (class ,(mk-class '(hg-collapse-summary cursor-pointer
                                                                 font-medium
                                                                 text-onyx-500
                                                                 dark:text-stone-300
                                                                 font-sans
                                                                 py-2
                                                                 transition-colors
                                                                 duration-150
                                                                 focus-visible:outline-2
                                                                 focus-visible:outline-offset-2
                                                                 outline-onyx-500))))
                      ,summary)
             (div (@ (class "hg-collapse-body"))
                  (div (@ (class ,(mk-class '(hg-collapse-content flex flex-col
                                                                  gap-2 py-2))))
                       ,@content)))))

;; ===== Layers =====

(define* (layer content
                #:key (level 'modal)
                (id #f)
                (tag 'div)
                (classes '())
                (attributes '()))
  "Place @var{content} in one of the framework's named layers.

Every overlay has to answer the same question -- which of us is on top -- and
the answer stops being obvious the moment a page has a modal, a dropdown and
a toast at once. Naming a level reads the framework's own scale
(@code{sticky}, @code{dropdown}, @code{overlay}, @code{modal},
@code{popover}, @code{toast}, @code{tooltip}) through a custom property, so
a page can raise or lower a whole layer without hunting for a component's
z-index.

@table @var
@item content
The children, as a list of nodes.
@item level
A layer name. Defaults to @code{'modal}.
@item id
An optional HTML identifier, for a portal target a script fills.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the element.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(layer (list (drawer ...)) #:level 'modal)
@end example"
  (let* ((z (token-value 'z level))
         (level-name (symbol->string level)))
    `((,tag (@ ,@attributes
               ,@(attr-when id
                            'id id)
               (data-hg-layer ,level-name)
               (class ,(mk-class (append '(hg-layer)
                                         (list (string->symbol
                                                (format #f "hg-layer-~a"
                                                        level-name)))
                                         classes)))
               (style ,(mk-style `((z-index . ,(format #f
                                                       "var(--hg-z-~a, ~a)"
                                                       level-name z)))))))
            ,@content)))

(define* (layer-root #:key (id "hg-layers")
                     (content '())
                     (classes '()))
  "The single mount point a page gives its overlays.

Rendered once, near the end of the body, this is where scripts append a
toast or a command palette. In a server-rendered page it is mostly a
declaration of intent: overlays rendered by the server can sit here too, so
they all share one stacking context and one place to look for them.

@table @var
@item id
The identifier scripts use to find the root.
@item content
Any overlays rendered by the server, as a list of nodes.
@item classes
Extra classes for the root.
@end table

@example
(layer-root)
@end example"
  `((div (@ (id ,id)
            (class ,(mk-class (append '(hg-layer-root) classes))))
         ,@content)))

;; ===== Direction and language =====

(define* (locale content
                 #:key (lang #f)
                 (dir #f)
                 (tag 'div)
                 (classes '())
                 (attributes '()))
  "Mark a region's language and writing direction.

Both attributes are inherited, so wrapping the part of a page that is in
another language -- or in a right-to-left script -- is enough for browsers,
screen readers, hyphenation and the CSS logical properties the components
are written with. The framework's own layout primitives use logical
spacing, so a split or a drawer mirrors itself when it is told to.

@table @var
@item content
The children, as a list of nodes.
@item lang
A BCP 47 language tag, such as @code{\"ar\"} or @code{\"pt-BR\"}.
@item dir
@code{'ltr}, @code{'rtl} or @code{'auto}.
@item tag
The element to build. Defaults to @code{div}.
@item classes
Extra classes for the element.
@item attributes
Extra attributes, as pairs of name and value.
@end table

@example
(locale (list (p \"مرحبا\")) #:lang \"ar\" #:dir 'rtl)
@end example"
  `((,tag (@ ,@attributes
             ,@(attr-when lang
                          'lang lang)
             ,@(attr-when dir
                          'dir
                          (if (symbol? dir)
                              (symbol->string dir)
                              dir))
             (class ,(mk-class classes)))
          ,@content)))

(define* (bdi content
              #:key (classes '()))
  "Isolate an inline run whose direction the browser should decide.

A username, a file name, a number next to a currency symbol: anything a
page does not control the script of. @code{<bdi>} keeps it from rearranging
the sentence around it.

@table @var
@item content
The inline content.
@item classes
Extra classes.
@end table

@example
(p (list \"Signed in as \" (bdi \"@@ada\")))
@end example"
  `((bdi (@ (class ,(mk-class classes)))
         ,content)))

(define* (bdo content
              #:key (dir 'rtl)
              (classes '()))
  "Override the bidirectional algorithm for @var{content}.

This is deliberately explicit: it is for displaying a string in the
direction opposite to its own, not for laying out a page. Pages that need
a whole region mirrored want @code{locale} instead.

@table @var
@item content
The inline content.
@item dir
@code{'ltr} or @code{'rtl}. Defaults to @code{'rtl}.
@item classes
Extra classes.
@end table

@example
(bdo \"abc\" #:dir 'rtl)
@end example"
  `((bdo (@ (dir ,(symbol->string dir))
            (class ,(mk-class classes)))
         ,content)))

;; ===== Density =====

(define* (density-toggle #:key (current 'comfortable)
                         (label "Compact density")
                         (classes '()))
  "Render the control that switches a page between comfortable and compact
density.

The control is a progressive enhancement: it carries @code{js-only}, and
the no-script stylesheet hides it, because a density preference that cannot
be remembered is a button that lies. The script stores the choice and sets
@code{data-density} on the root element before the page is drawn, so a
reader never sees one density and then the other.

A page opts in by reading the same attribute in its own stylesheet; the
framework's data grid, field shell and sidebar already do.

@table @var
@item current
The density the server rendered the page in. Defaults to
@code{'comfortable}.
@item label
The accessible label of the control.
@item classes
Extra classes for the button.
@end table

@example
(density-toggle #:current 'comfortable)
@end example"
  (let ((compact? (eq? 'compact current)))
    `((button (@ (type "button")
                 (class ,(mk-class (append '(hg-density-toggle js-only
                                               px-3 py-1 rounded-lg border-2
                                               border-stone-500/50
                                               dark:border-onyx-100/50
                                               bg-stone-300/75
                                               dark:bg-onyx-700/75
                                               text-onyx-500
                                               dark:text-stone-300
                                               text-sm font-medium font-sans
                                               cursor-pointer
                                               transition-colors
                                               duration-150
                                               focus-visible:outline-2
                                               focus-visible:outline-offset-2
                                               outline-onyx-500)
                                             classes)))
                 (data-hg-density-toggle "")
                 (aria-pressed ,(if compact? "true" "false"))
                 (aria-label ,label)
                 (onclick "hygguileToggleDensity()"))
              ,label))))
