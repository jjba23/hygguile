;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components tokens)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:export (spacing-tokens
            radius-tokens
            elevation-tokens
            motion-tokens
            z-tokens
            color-tokens
            density-tokens
            token-value
            token-name
            token-declarations
            density-value
            design-tokens-css))

;; ===== Design tokens =====
;;
;; A utility-class framework names every value it ships, and that is most of
;; a design system already: `p-4', `rounded-xl', `shadow-md'. What it does not
;; do is let a *component* be written against a decision rather than against
;; a literal, so that the same component can be rendered at a different
;; density, or wired to a design a page keeps in Scheme, without a second
;; stylesheet.
;;
;; The tables below are that seam. They are the same values Olive's own
;; ladder uses, written once in Scheme so they can be read in three places:
;; as CSS custom properties (`design-tokens-css'), as inline declarations
;; (`token-declarations') and as plain values at render time (`token-value').
;; Nothing here invents a second palette: a token that a utility class can
;; already express is that class's value.
;;
;; The names are stable, so markup can override a single decision without
;; knowing which component asked for it:
;;
;;   (design-tokens-css)             ; the :root block, themes included
;;   (token-value 'space 4)          ; "1rem"
;;   (token-declarations '((space 4) (radius lg)))
;;   ;; => ((--hg-space-4 . "1rem") (--hg-radius-lg . ".75rem"))
;;
;; A component that says `var(--hg-space-4, 1rem)' keeps working on a page
;; that never loaded the block, because the fallback is the same value.

;; The spacing ladder: the keys are the numbers Olive's spacing utilities
;; carry, so `token-value' of 4 is what `p-4' sets.
(define spacing-tokens
  '((0 . "0")
    (px . "1px")
    (1 . "0.25rem")
    (2 . "0.5rem")
    (3 . "0.75rem")
    (4 . "1rem")
    (5 . "1.25rem")
    (6 . "1.5rem")
    (8 . "2rem")
    (10 . "2.5rem")
    (12 . "3rem")
    (16 . "4rem")
    (20 . "5rem")
    (24 . "6rem")))

;; The corner ladder, matching the rounding utilities the components wear.
(define radius-tokens
  '((none . "0")
    (2xs . "0.16rem")
    (xs . "0.32rem")
    (sm . "0.48rem")
    (md . "0.64rem")
    (lg . "0.8rem")
    (xl . "0.96rem")
    (2xl . "1.12rem")
    (3xl . "1.28rem")
    (full . "9999px")))

;; The elevation ladder: four depths rather than Olive's full shadow scale,
;; because a surface in this framework is a pane on a page, not a material
;; floating above it.
(define elevation-tokens
  '((none . "none")
    (sm . "0 1px 2px rgba(12, 10, 9, 0.12)")
    (md . "0 4px 12px rgba(12, 10, 9, 0.16)")
    (lg . "0 12px 32px rgba(12, 10, 9, 0.24)")
    (xl . "0 20px 48px rgba(12, 10, 9, 0.32)")))

;; Durations and the one easing curve the framework moves with. The
;; reduced-motion block in `design-tokens-css' sets every duration to zero,
;; so a component that reads these tokens stops moving for a reader who asked
;; it to without carrying a media query of its own.
(define motion-tokens
  '((instant . "0ms")
    (fast . "120ms")
    (base . "200ms")
    (slow . "320ms")
    (slower . "480ms")
    (ease . "cubic-bezier(0.2, 0, 0, 1)")))

;; The layer scale. Every overlay in the framework names one of these instead
;; of inventing a number, so two overlays cannot silently swap places when a
;; page adds a third.
(define z-tokens
  '((base . "0")
    (raised . "8")
    (sticky . "20")
    (dropdown . "32")
    (overlay . "48")
    (modal . "64")
    (popover . "72")
    (toast . "80")
    (tooltip . "96")))

;; Semantic colours, as a light and a dark value per name. These are the
;; colours the companion stylesheet already paints with; the tokens exist so
;; a new component can ask for "the page's ink" rather than for a shade of a
;; particular ramp. A component that paints text still carries Olive's
;; `text-*'/`dark:text-*' pair, because those are the classes the contrast
;; gate measures; the tokens are for surfaces, rules and states.
(define color-tokens
  '((ink . ("#1c1917" . "#ededee"))
    (muted-ink . ("#57534e" . "#d6d3d1"))
    (surface . ("#f5f5f4" . "#262626"))
    (raised . ("#e7e5e4" . "#3f3f3f"))
    (sunken . ("#d6d3d1" . "#1c1917"))
    (line . ("rgba(120, 113, 108, 0.5)" . "rgba(214, 211, 209, 0.5)"))
    (accent . ("#57534e" . "#d6d3d1"))
    (accent-ink . ("#f5f5f4" . "#1c1917"))
    (danger . ("#a1301b" . "#ffb4a2"))
    (success . ("#3f6212" . "#d9f99d"))
    (warning . ("#713f12" . "#fef08a"))
    (info . ("#1e3a8a" . "#dbeafe"))))

;; The density modes a data-heavy page can ask for, as a scale applied to
;; spacing and control heights. `comfortable' is the framework's own look;
;; `compact' tightens the spacing of the components that read
;; `--hg-density' without changing the type scale, so a compact table is
;; still readable and not merely smaller.
(define density-tokens
  '((comfortable . "1")
    (compact . "0.8")))

(define group-prefixes
  '((space . "--hg-space")
    (radius . "--hg-radius")
    (elevation . "--hg-elevation")
    (motion . "--hg-motion")
    (z . "--hg-z")
    (color . "--hg-color")
    (density . "--hg-density")))

(define* (token-value group name #:key (theme 'light))
  "Return the value of the token called @var{name} in @var{group}, as a string.

Groups are @code{'space}, @code{'radius}, @code{'elevation},
@code{'motion}, @code{'z}, @code{'color} and @code{'density}. A colour has
a value per theme, so @var{theme} picks one; every other group ignores it.

Unknown groups and names signal an error rather than returning a silent
@code{#f}, because a token that is misspelt in a component is a bug that
should surface on the first render, not a value that quietly disappears.

@table @var
@item group
One of the symbol names above.
@item name
The token's key, e.g. @code{4} for spacing or @code{'lg} for a radius.
@item theme
@code{'light} (the default) or @code{'dark}, read by colour tokens only.
@end table

@example
(token-value 'space 4)
;; => \"1rem\"

(token-value 'color 'ink #:theme 'dark)
;; => \"#ededee\"
@end example"
  (define (table group)
    (cond
      ((eq? 'space group)
       spacing-tokens)
      ((eq? 'radius group)
       radius-tokens)
      ((eq? 'elevation group)
       elevation-tokens)
      ((eq? 'motion group)
       motion-tokens)
      ((eq? 'z group)
       z-tokens)
      ((eq? 'color group)
       color-tokens)
      ((eq? 'density group)
       density-tokens)
      (else (error "unknown token group" group))))
  (let* ((entry (assv name (table group)))
         (raw (and entry (cdr entry))))
    (cond
      ((not entry)
       (error "unknown token" group name))
      ((eq? 'color group)
       (if (eq? 'dark theme)
           (cdr raw)
           (car raw)))
      (else raw))))

(define* (token-name group name #:key (theme #f))
  "Return the CSS custom property a token is exposed as, or @code{#f} for an
unknown group.

A colour's name carries its theme as a suffix (@code{--hg-color-ink-dark}),
because both values have to exist in the same stylesheet.

@example
(token-name 'space 4)
;; => \"--hg-space-4\"
@end example"
  (let ((prefix (assq-ref group-prefixes group)))
    (and prefix
         (if (and (eq? 'color group)
                  theme)
             (format #f "~a-~a-~a" prefix name theme)
             (format #f "~a-~a" prefix name)))))

(define* (token-declarations pairs #:key (theme 'light))
  "Turn a list of @code{(group name)} pairs into CSS declaration pairs.

The result can be handed to @code{mk-style}, which is how a component
passes a token to the browser as an inline custom property:

@example
(mk-style (token-declarations '((space 6) (radius 2xl))))
;; => \"--hg-space-6: 1.5rem; --hg-radius-2xl: 1.12rem\"
@end example

@table @var
@item pairs
A list of two-element lists, @code{(group name)}.
@item theme
The theme read by a colour token. Defaults to @code{'light}.
@end table"
  (map (lambda (pair)
         (cons (token-name (car pair)
                           (cadr pair))
               (token-value (car pair)
                            (cadr pair)
                            #:theme theme)))
       pairs))

(define (density-value density)
  "Return the scale of a density mode as a string, defaulting to
@code{comfortable} for a mode the table does not name.

@table @var
@item density
@code{'comfortable} or @code{'compact}.
@end table"
  (or (assq-ref density-tokens density)
      (assq-ref density-tokens 'comfortable)))

(define (css-declarations pairs)
  "Render a list of declaration pairs as the body of a CSS rule."
  (string-join (map (lambda (pair)
                      (format #f "  ~a: ~a;"
                              (car pair)
                              (cdr pair))) pairs) "\n"))

(define (theme-color-declarations theme)
  "Render every semantic colour as the declarations of one theme."
  (map (lambda (entry)
         (cons (token-name 'color (car entry)
                           #:theme theme)
               (token-value 'color (car entry)
                           #:theme theme)))
       color-tokens))

(define (scale-declarations)
  "Render the spacing, radius, elevation, motion and layer tokens."
  (append (map (lambda (entry)
                 (cons (token-name 'space (car entry))
                       (cdr entry))) (reverse spacing-tokens))
          (map (lambda (entry)
                 (cons (token-name 'radius (car entry))
                       (cdr entry))) radius-tokens)
          (map (lambda (entry)
                 (cons (token-name 'elevation (car entry))
                       (cdr entry))) elevation-tokens)
          (map (lambda (entry)
                 (cons (token-name 'motion (car entry))
                       (cdr entry))) motion-tokens)
          (map (lambda (entry)
                 (cons (token-name 'z (car entry))
                       (cdr entry))) z-tokens)
          (list (cons (token-name 'density 'scale)
                      (density-value 'comfortable)))))

(define* (design-tokens-css #:key (class "hg-tokens"))
  "Return the SXML @code{<style>} block that publishes every design token.

The block has three parts: the light theme on @code{:root}, the dark theme
on @code{[data-theme=\"dark\"]}, and a reduced-motion block that sets every
duration to zero. A page that loads it can override any single decision
from its own stylesheet -- or from markup, with an inline custom property --
and the components that read @code{var(--hg-space-4, 1rem)} follow.

The class on the style element is only there to make the block easy to
find in a document; the tokens themselves are declared on the root
element, not scoped to it.

@table @var
@item class
A class name for the @code{<style>} element itself.
@end table

@example
(design-tokens-css)
@end example"
  `((style (@ (type "text/css")
              (class ,(or class "hg-tokens")))
           ,(string-append
             ":root {\n"
             (css-declarations (append (scale-declarations)
                                       (theme-color-declarations 'light)))
             "\n}\n\n"
             "[data-theme=\"dark\"] {\n"
             (css-declarations (theme-color-declarations 'dark))
             "\n}\n\n"
             "@media (prefers-reduced-motion: reduce) {\n"
             "  :root {\n"
             "    --hg-motion-instant: 0ms;\n"
             "    --hg-motion-fast: 0ms;\n"
             "    --hg-motion-base: 0ms;\n"
             "    --hg-motion-slow: 0ms;\n"
             "    --hg-motion-slower: 0ms;\n"
             "  }\n"
             "}\n"))))
