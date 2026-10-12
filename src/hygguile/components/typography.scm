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

(define-module (hygguile components typography)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components disclosure)
  #:export (h1 h2
               h3
               h4
               sub-h1
               sub-h2
               sub-h3
               sub-h4
               p
               em
               a
               strong
               pre
               mono
               code
               kbd
               samp
               var
               mark
               time
               abbr
               glossary-term
               sup
               sub))

;; ===== The heading type scale =====
;;
;; Every heading is a size paired with a leading, and the pairing is the
;; scale: `text-4xl' at 2.25rem gets 1.3, `text-2xl' at 1.75rem gets 1.35,
;; `text-xl' at 1.5rem gets 1.4. Tightening as the size grows is the
;; familiar shape of a type scale, and the ratios are ratios rather than
;; fixed lengths so that a page moving a heading up or down a step keeps a
;; leading to match -- Olive's own `leading-*' utilities are absolute rems,
;; so they cannot follow a font-size a page chose for itself.
;;
;; The floor is not a matter of taste. A leaded line sits in a box of the
;; line's own height, and every glyph the line might hold -- descenders,
;; accents -- has to fit inside that box: ink outside it is not merely
;; cropped but unpainted, since gradient ink is a background clipped to the
;; letters (see `hg-gradient-text'). Measured on the two faces the
;; framework ships, Plus Jakarta Sans asks for 1.24 of that box at worst and
;; Lucida Sans for 1.16, so the tightest step here is 1.3, with room to
;; spare rather than a hairline. For comparison, body copy is set at 1.5.
(define heading-scale
  '((text-4xl . hg-leading-display) (text-3xl . hg-leading-display)
    (text-2xl . hg-leading-title)
    (text-xl . hg-leading-subtitle)))

(define (heading-leading size)
  "Return the leading class list the heading scale pairs with @var{size}.

@var{size} is a class list rather than a single name, so only its first
entry is looked up. A step the scale does not name -- a page reaching for
one of its own -- is led by the tightest ratio in the scale, which is still
looser than either shipped face needs, so a heading never loses ink by
leaving the scale."
  (list (or (assq-ref heading-scale
                      (car size))
            'hg-leading-display)))

(define* (h1 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-4xl))
             (leading (heading-leading size)))
  "Create an HTML @code{<h1>} heading.

@table @var
@item content
The inner text string or child elements of the heading.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size} (see @code{heading-leading}). A size
the scale does not name is led by its tightest ratio, so the ink of a
heading a page has resized for itself still fits its line box.
@end table

@example
(h1 \"Main Page Title\" #:color '(text-onyx-700 dark:text-stone-100))
@end example"
  `((h1 (@ (class ,(mk-class (append color size weight family leading))))
        ,content)))

(define* (h2 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-3xl))
             (leading (heading-leading size)))
  "Create an HTML @code{<h2>} heading.

@table @var
@item content
The inner text string or child elements of the heading.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(h2 \"Section Subtitle\" #:weight '(font-semibold))
@end example"
  `((h2 (@ (class ,(mk-class (append color size weight family leading))))
        ,content)))

(define* (h3 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-2xl))
             (leading (heading-leading size)))
  "Create an HTML @code{<h3>} heading.

@table @var
@item content
The inner text string or child elements of the heading.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(h3 \"Subsection Heading\")
@end example"
  `((h3 (@ (class ,(mk-class (append color size weight family leading))))
        ,content)))

(define* (h4 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-xl))
             (leading (heading-leading size)))
  "Create an HTML @code{<h4>} heading.

@table @var
@item content
The inner text string or child elements of the heading.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(h4 \"Minor Subsection Title\")
@end example"
  `((h4 (@ (class ,(mk-class (append color size weight family leading))))
        ,content)))

(define* (sub-h1 content
                 #:key (weight '(font-light))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (style '(italic))
                 (size '(text-3xl))
                 (leading (heading-leading size)))
  "Create a lighter, styled secondary @code{<h1>} heading wrapper.

@table @var
@item content
The inner text string or child elements of the subheading.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item style
List of symbols representing font style layout configuration options (e.g., italic).
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(sub-h1 \"A deeper dive into the architecture\")
@end example"
  `((h1 (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (sub-h2 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-2xl))
                 (leading (heading-leading size)))
  "Create a lighter, styled secondary @code{<h2>} heading wrapper.

@table @var
@item content
The inner text string or child elements of the subheading.
@item weight
List of symbols representing font weight CSS classes.
@item style
List of symbols representing font style layout configuration options.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(sub-h2 \"Contextual commentary block\")
@end example"
  `((h2 (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (sub-h3 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl))
                 (leading (heading-leading size)))
  "Create a lighter, styled secondary @code{<h3>} heading wrapper.

@table @var
@item content
The inner text string or child elements of the subheading.
@item weight
List of symbols representing font weight CSS classes.
@item style
List of symbols representing font style layout configuration options.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(sub-h3 \"Detailed breakdown notes\")
@end example"
  `((h3 (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (sub-h4 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl))
                 (leading (heading-leading size)))
  "Create a lighter, styled secondary @code{<h4>} heading wrapper.

@table @var
@item content
The inner text string or child elements of the subheading.
@item weight
List of symbols representing font weight CSS classes.
@item style
List of symbols representing font style layout configuration options.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item leading
List of symbols representing the line-height, defaulting to the ratio the
heading scale pairs with @var{size}.
@end table

@example
(sub-h4 \"Supplemental metadata label\")
@end example"
  `((h4 (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (p content
            #:key (weight '(font-medium))
            (color '(text-onyx-500 dark:text-stone-300))
            (family '(font-sans))
            (leading '(leading-6))
            (size '(text-lg)))
  "Create an HTML paragraph (@code{<p>}) component.

@table @var
@item content
The text block or inner nodes rendered inside the paragraph boundaries.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item leading
List of symbols representing line-height spacing CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@end table

@example
(p \"This framework focuses on modular, cozy web architectures.\")
@end example"
  `((p (@ (class ,(mk-class (append color size weight family leading))))
       ,content)))

(define* (em content
             #:key (weight '(font-light))
             (color '(text-onyx-300 dark:text-stone-500))
             (family '(font-sans))
             (leading '(leading-6))
             (style '(italic))
             (size '(text-md)))
  "Create an HTML emphasis (@code{<em>}) layout block.

@table @var
@item content
The inner text content or target inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item leading
List of symbols representing line-height spacing CSS classes.
@item style
List of symbols representing text element style transformations.
@item size
List of symbols representing text sizing CSS classes.
@end table

@example
(em \"Please notice this crucial contextual exception.\")
@end example"
  `((em (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (strong content
                 #:key (weight '(font-bold))
                 (color '(text-onyx-500 dark:text-stone-300))
                 (family '(font-sans))
                 (leading '(leading-6))
                 (size '(text-lg)))
  "Create an HTML strong importance (@code{<strong>}) text fragment.

@table @var
@item content
The inner phrase string or inline elements requiring strong visual weight.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item leading
List of symbols representing line-height spacing CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@end table

@example
(strong \"Warning: Destructive action ahead!\")
@end example"
  `((strong (@ (class ,(mk-class (append color size weight family leading))))
            ,content)))

(define* (a content
            #:key (weight '(font-bold))
            (size '(text-md))
            ;; jeans-blue is a dark ramp with no light end, so the dark theme
            ;; borrows the light end of a neighbouring blue instead: glaucous
            ;; only reaches oklch 0.665, which is 4.56:1 on the darkest panel,
            ;; while moonstone-300 clears 5.5:1 there and 6.2:1 on the page.
            (color '(text-jeans-blue-500 dark:text-moonstone-300))
            (family '(font-sans))
            (hover '(hover:text-jeans-blue-900 dark:hover:text-moonstone-100))
            (extra-classes '(no-underline hover:underline
                                          transition-colors
                                          duration-150
                                          focus-visible:outline-2
                                          focus-visible:outline-offset-2
                                          outline-jeans-blue-500))
            (href #f))
  "Create an HTML anchor link (@code{<a>}) component.

If the @var{href} key argument evaluates to false, the hyperlink target location defaults directly to the structural evaluation of @var{content}.

@table @var
@item content
The text label or component displayed inside the interactive anchor boundary.
@item weight
List of symbols representing font weight CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item color
List of symbols representing base link text color CSS classes.
@item family
List of symbols representing font family CSS classes.
@item hover
List of symbols representing interactive state hover coloring CSS rules.
@item extra-classes
List of base text formatting utility attributes.
@item href
Optional explicit destination target path URL string.
@end table

@example
(a \"https://gnu.org\" #:extra-classes '(underline))
@end example"
  `((a (@ (href ,(if (not href) content href))
          (class ,(mk-class (append color
                                    hover
                                    size
                                    weight
                                    family
                                    extra-classes))))
       ,content)))

(define* (mono content
               #:key (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-lg))
               (mono-classes '(font-mono)))
  "Create a structural paragraph element wrapped in a monospace text layout.

@table @var
@item content
The inner code text string or inline elements.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item mono-classes
List of configuration framework tokens defining a fixed-width layout style.
@end table

@example
(mono \"$ guix pull\")
@end example"
  `((p (@ (class ,(mk-class (append color mono-classes size weight))))
       ,content)))

(define* (code content
               #:key (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-md))
               (background '(bg-stone-300/75 dark:bg-onyx-700/75))
               (rounding '(rounded-lg))
               (shadow '(shadow-md))
               (padding-y '(py-1))
               (padding-x '(px-2))
               (code-classes '(font-mono)))
  "Create an inline HTML @code{<code>} fragment.

@table @var
@item content
The code instruction text string.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item background
List of symbols representing inline code surface container background colors.
@item rounding
List of symbols representing container boundary radius options.
@item shadow
List of symbols representing structural layout presentation depth drops.
@item padding-y
List of symbols controlling top/bottom baseline cell padding spaces.
@item padding-x
List of symbols controlling left/right horizontal boundary alignment padding.
@item code-classes
List of font typography rules enforcing monospaced code metrics.
@end table

@example
(code \"(car list-expression)\")
@end example"
  `((code (@ (class ,(mk-class (append color
                                       background
                                       code-classes
                                       shadow
                                       size
                                       weight
                                       padding-y
                                       padding-x
                                       rounding))))
          ,content)))

(define* (pre content
              #:key (id #f)
              (weight '(font-medium))
              (color '(text-onyx-500 dark:text-stone-300))
              (size '(text-md))
              (background '(bg-stone-300/75 dark:bg-onyx-700/75))
              (rounding '(rounded-lg))
              (shadow '(shadow-md))
              (width '(w-full max-w-full min-w-0))
              (leading '(leading-6))
              (text-wrap '())
              (padding-y '(py-2 sm:py-3))
              (padding-x '(px-3 sm:px-4))
              (pre-classes '(font-mono overflow-x-auto whitespace-pre-wrap)))
  "Create an HTML preformatted multi-line source code container block (@code{<pre>}).

@table @var
@item content
The raw multi-line string contents to preserve.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item background
List of symbols representing code presentation layout surface background cards.
@item rounding
List of symbols representing card container boundary radius configurations.
@item shadow
List of symbols representing card container visual shadow definitions.
@item width
List of symbols tracking macro dimension constraint rules.
@item leading
List of symbols processing vertical paragraph text baseline spacing layouts.
@item text-wrap
List of symbols configuring code boundary line wrapping constraints.
@item padding-y
List of symbols processing top/bottom container padding margins.
@item padding-x
List of symbols processing side outer margin boundaries padding options.
@item pre-classes
List of structural code scrolling mechanisms and whitespace behaviors.
@item id
An optional HTML identifier, or @code{#f} for a @code{<pre>} nothing has to name.
@end table

@example
(pre \"(define (hello)\\n  (display \\\"Hi\\\"))\")
@end example"
  `((pre (@ ,@(attr-when id
                         'id id)
           (class ,(mk-class (append color
                                      leading
                                      background
                                      pre-classes
                                      shadow
                                      size
                                      weight
                                      text-wrap
                                      width
                                      padding-y
                                      padding-x
                                      rounding))))
         ,content)))

(define* (kbd content
              #:key (weight '(font-medium))
              (size '(text-sm))
              (color '(text-onyx-500 dark:text-stone-300))
              (background '(bg-stone-300/75 dark:bg-onyx-700/75))
              (border-color '(border-stone-500/50 dark:border-onyx-100/50))
              (rounding '(rounded-md))
              (shadow '(shadow-sm))
              (padding-y '(py-1))
              (padding-x '(px-2))
              (kbd-classes '(font-mono whitespace-nowrap border-2)))
  "Create an inline HTML @code{<kbd>} fragment for user keyboard input.

Use @code{kbd} for keys the user presses (@code{Ctrl}, @code{Enter},
@code{Esc}). Marking them up lets assistive technology announce them as
input rather than as ordinary prose.

@table @var
@item content
The key name or inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item color
List of symbols representing text color CSS classes.
@item background
List of symbols representing the key surface background colors.
@item border-color
List of symbols representing the key border colors.
@item rounding
List of symbols representing container boundary radius options.
@item shadow
List of symbols representing the key depth shadow.
@item padding-y
List of symbols controlling top/bottom padding.
@item padding-x
List of symbols controlling left/right padding.
@item kbd-classes
List of structural typography rules for keyboard keys.
@end table

@example
(kbd \"Ctrl\")
@end example"
  `((kbd (@ (class ,(mk-class (append color
                                      background
                                      kbd-classes
                                      shadow
                                      size
                                      weight
                                      padding-y
                                      padding-x
                                      rounding))))
         ,content)))

(define* (samp content
               #:key (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-md))
               (samp-classes '(font-mono)))
  "Create an inline HTML @code{<samp>} fragment for program output.

@code{samp} marks text produced by a computer: a command's reply, a
compiler diagnostic, a log line.

@table @var
@item content
The sampled output text string or inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item samp-classes
List of typography rules enforcing monospaced output metrics.
@end table

@example
(samp \"Build succeeded.\")
@end example"
  `((samp (@ (class ,(mk-class (append color samp-classes size weight))))
          ,content)))

(define* (var content
              #:key (weight '(font-medium))
              (style '(italic))
              (color '(text-onyx-500 dark:text-stone-300))
              (size '(text-md))
              (family '(font-serif))
              (var-classes '()))
  "Create an inline HTML @code{<var>} fragment for a variable or placeholder.

A serif italic @code{var} stands out from the surrounding sans-serif
text, which is exactly what you want for a name the reader is expected
to substitute.

@table @var
@item content
The variable name or placeholder text string.
@item weight
List of symbols representing font weight CSS classes.
@item style
List of symbols representing text style transformations.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item family
List of symbols representing font family CSS classes.
@item var-classes
List of additional typography utility classes.
@end table

@example
(var \"username\")
@end example"
  `((var (@ (class ,(mk-class (append color
                                      var-classes
                                      size
                                      weight
                                      style
                                      family))))
         ,content)))

(define* (mark content
               #:key (weight '(font-medium))
               (color '(text-onyx-700 dark:text-onyx-900))
               (size '(text-md))
               (background '(bg-naples-yellow-500/75))
               (rounding '(rounded-2xs))
               (padding-x '(px-1))
               (mark-classes '()))
  "Create an inline HTML @code{<mark>} fragment highlighting relevant text.

The highlight is a soft yellow wash rather than the browser's default
neon, so it reads as an annotation instead of a warning.

@table @var
@item content
The highlighted text string or inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item background
List of symbols representing the highlight background colors.
@item rounding
List of symbols representing container boundary radius options.
@item padding-x
List of symbols controlling left/right padding.
@item mark-classes
List of additional typography utility classes.
@end table

@example
(mark \"today\")
@end example"
  `((mark (@ (class ,(mk-class (append color
                                       background
                                       mark-classes
                                       size
                                       weight
                                       padding-x
                                       rounding))))
          ,content)))

(define* (time content
               #:key (datetime #f)
               (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-md))
               (time-classes '(tabular-nums)))
  "Create an inline HTML @code{<time>} fragment for a machine-readable date.

The @var{datetime} attribute carries the value in ISO format
(@code{2026-10-11}, @code{2026-10-11T09:30}) so that browsers, calendars
and crawlers can parse it, while the visible text stays human and
locale-appropriate. When @var{content} is a string and no
@var{datetime} is given, the content itself is used.

@table @var
@item content
The human-readable date or time string.
@item datetime
An optional ISO-8601 machine-readable value.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item time-classes
List of typography rules, such as tabular figures for aligned dates.
@end table

@example
(time \"11 October 2026\" #:datetime \"2026-10-11\")
@end example"
  (let ((machine-value (cond
                         (datetime datetime)
                         ((string? content)
                          content)
                         (else #f))))
    `((time (@ ,@(attr-when machine-value
                            'datetime machine-value)
               (class ,(mk-class (append color time-classes size weight))))
            ,content))))

(define* (abbr content
               #:key (title #f)
               (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-md))
               (decoration '(underline decoration-dotted))
               (abbr-classes '(cursor-help)))
  "Create an inline HTML @code{<abbr>} fragment expanding an abbreviation.

The expansion travels in the @code{title} attribute, which browsers show
on hover and assistive technology can read out.

@table @var
@item content
The abbreviation text, e.g. @code{\"HTTP\"}.
@item title
The expansion, e.g. @code{\"HyperText Transfer Protocol\"}.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item decoration
List of symbols representing text decoration classes.
@item abbr-classes
List of additional typography utility classes.
@end table

@example
(abbr \"HTTP\" #:title \"HyperText Transfer Protocol\")
@end example"
  `((abbr (@ ,@(attr-when title
                          'title title)
             (class ,(mk-class (append color abbr-classes decoration size
                                       weight))))
          ,content)))

(define* (sup content
              #:key (weight '(font-medium))
              (color '(text-onyx-500 dark:text-stone-300))
              ;; Olive's scale puts text-xs at 0.5rem, too small to read as
              ;; a footnote marker or an exponent, so the raised and lowered
              ;; inline elements keep text-sm and rely on vertical-align.
              (size '(text-sm))
              (vertical '(align-super))
              (sup-classes '(leading-none)))
  "Create an inline HTML @code{<sup>} superscript fragment.

Use it for footnote markers, ordinal suffixes and exponents.

@table @var
@item content
The superscript text or inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item vertical
List of symbols setting the vertical alignment offset.
@item sup-classes
List of additional typography utility classes.
@end table

@example
(p (list \"Copyright\" (sup \"©\")))
@end example"
  `((sup (@ (class ,(mk-class (append color sup-classes size weight vertical))))
         ,content)))

(define* (sub content
              #:key (weight '(font-medium))
              (color '(text-onyx-500 dark:text-stone-300))
              (size '(text-sm))
              (vertical '(align-sub))
              (sub-classes '(leading-none)))
  "Create an inline HTML @code{<sub>} subscript fragment.

The natural home for chemical formulae and mathematical indices.

@table @var
@item content
The subscript text or inline nodes.
@item weight
List of symbols representing font weight CSS classes.
@item color
List of symbols representing text color CSS classes.
@item size
List of symbols representing text sizing CSS classes.
@item vertical
List of symbols setting the vertical alignment offset.
@item sub-classes
List of additional typography utility classes.
@end table

@example
(p (list \"H\" (sub \"2\") \"O\"))
@end example"
  `((sub (@ (class ,(mk-class (append color sub-classes size weight vertical))))
         ,content)))

(define* (glossary-term term
                        #:key (href #f)
                        (note #f)
                        (position 'top)
                        (classes '()))
  "Create an inline term that may link to its documentation and may spell itself out.

A page's prose names a technology once and this puts the two other things
that name implies on that same word: where the term is documented, and, for
an abbreviation, what it stands for. The note is a @code{tooltip}, so it
appears on hover and on keyboard focus alike, and it wraps the link rather
than sitting beside it -- one word carries both, the reader who has never
met the abbreviation learns what it stands for without leaving the page, and
the reader who wants the manual follows that same word.

@table @var
@item term
The word as the prose writes it.
@item href
Where the term is documented, or @code{#f} for a term that is only text.
@item note
What the term stands for, or @code{#f} for a term with nothing to spell out.
@item position
Where the note appears: @code{'top} (default), @code{'bottom}, @code{'left} or @code{'right}.
@item classes
List of additional utility CSS classes for the note.
@end table

@example
(glossary-term \"SXML\"
               #:href \"https://en.wikipedia.org/wiki/SXML\"
               #:note \"Scheme XML: XML written as S-expressions\")
@end example"
  (let ((word (if href
                  (a term
                     #:href href) term)))
    (if note
        (tooltip word
                 #:text note
                 #:position position
                 #:classes classes) word)))
