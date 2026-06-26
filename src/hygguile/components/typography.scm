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
               code))

(define* (h1 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-4xl)))
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
@end table

@example
(h1 \"Main Page Title\" #:color '(text-stone-900))
@end example"
  `((h1 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h2 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-3xl)))
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
@end table

@example
(h2 \"Section Subtitle\" #:weight '(font-semibold))
@end example"
  `((h2 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h3 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-2xl)))
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
@end table

@example
(h3 \"Subsection Heading\")
@end example"
  `((h3 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h4 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-xl)))
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
@end table

@example
(h4 \"Minor Subsection Title\")
@end example"
  `((h4 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (sub-h1 content
                 #:key (weight '(font-light))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (style '(italic))
                 (size '(text-3xl)))
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
@end table

@example
(sub-h1 \"A deeper dive into the architecture\")
@end example"
  `((h1 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h2 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-2xl)))
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
@end table

@example
(sub-h2 \"Contextual commentary block\")
@end example"
  `((h2 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h3 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl)))
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
@end table

@example
(sub-h3 \"Detailed breakdown notes\")
@end example"
  `((h3 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h4 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl)))
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
@end table

@example
(sub-h4 \"Supplemental metadata label\")
@end example"
  `((h4 (@ (class ,(mk-class (append color size weight style family))))
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
            (color '(text-jeans-blue-500 dark:text-jeans-blue-500))
            (family '(font-sans))
            (hover '(hover:text-jeans-blue-900 hover:dark:text-jeans-blue-100))
            (extra-classes '(no-underline hover:underline))
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
               (padding-x '(px-4))
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
              #:key (weight '(font-medium))
              (color '(text-onyx-500 dark:text-stone-300))
              (size '(text-md))
              (background '(bg-stone-300/75 dark:bg-onyx-700/75))
              (rounding '(rounded-lg))
              (shadow '(shadow-md))
              (width '(w-full))
              (leading '(leading-6))
              (text-wrap '(text-nowrap))
              (padding-y '(py-6))
              (padding-x '(px-8))
              (pre-classes '(font-mono overflow-auto whitespace-pre)))
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
@end table

@example
(pre \"(define (hello)\\n  (display \\\"Hi\\\"))\")
@end example"
  `((pre (@ (class ,(mk-class (append color
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
