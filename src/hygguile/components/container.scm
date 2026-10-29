;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components container)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components icon)
  #:export (footer with-footer
                   hr
                   col
                   row
                   dl
                   dd
                   dt
                   noscript
                   linear-gradient))

(define* (noscript content
                   #:key (classes '()))
  "Wrap @var{content} in an HTML @code{<noscript>} fallback element.

The contents are rendered and executed by browsers only when JavaScript
is disabled, which makes this component the natural home for no-script
notices or alternative navigation. Pair it with the recommended
JavaScript-free stylesheet so JavaScript-dependent controls can hide
themselves gracefully.

@table @var
@item content
The fallback content shown when scripting is unavailable.
@item classes
List of symbols representing utility CSS classes applied to the element.
@end table

@example
(noscript fallback-fragment)
@end example"
  `((noscript (@ ,@(attr-when (not (null? classes))
                              'class
                              (mk-class classes)))
              ,content)))

(define* (with-footer #:key main footer)
  "Wrap a main content fragment and a footer fragment within a full-screen vertical flex container.

@table @var
@item main
S-expression representing the main content layout.
@item footer
S-expression representing the footer layout.
@end table

@example
(with-footer #:main '((p \"Hello World\")) #:footer '((footer \"Standard Footer\")))
@end example"
  `((div (@ (class ,(mk-class '(flex flex-col justify-between min-h-screen))))
         ;; a real <main> landmark so assistive technology can jump
         ;; straight to the page content
         (main (@ (class ,(mk-class '(flex-1))))
               ,main)
         ,footer)))

(define* (hr #:key (margin '(my-8 mx-4))
             (border '(border-2))
             (color '(border-stone-500/50 dark:border-onyx-100/50)))
  "Create an HTML horizontal rule (@code{<hr>}) element.

@table @var
@item margin
List of symbols representing margin CSS classes.
@item border
List of symbols representing border width CSS classes.
@item color
List of symbols representing border color CSS classes.
@end table

@example
(hr #:margin '(my-4) #:color '(border-redwood-500))
@end example"
  `((hr (@ (class ,(mk-class (append color margin border)))))))

(define* (footer content
                 #:key (background '(bg-stone-300 dark:bg-onyx-700/75))
                 (shadow '(shadow-xl))
                 (footer-classes '(flex flex-col
                                        gap-3
                                        items-start
                                        px-6
                                        sm:px-8
                                        md:px-12
                                        justify-start
                                        py-8)))
  "Create an HTML footer element.

@table @var
@item content
The inner content or layout fragments of the footer.
@item background
List of symbols for background CSS classes.
@item shadow
List of symbols for shadow effect CSS classes.
@item footer-classes
List of utility formatting and layout CSS classes.
@end table

@example
(footer \"© 2026 Hygguile Framework\")
@end example"
  `((footer (@ (class ,(mk-class (append background shadow footer-classes))))
            ,content)))

(define* (row content
              #:key (gap '(gap-6))
              (shadow '(shadow-md))
              (wrap '(flex-wrap))
              (padding-y '(py-6))
              (padding-x '(px-4))
              (rounding '(rounded-lg))
              (background '(bg-stone-300/75 dark:bg-onyx-700))
              (items '(items-center))
              (row-classes '(flex flex-row)))
  "Create a horizontal row container using flexbox layout.

@table @var
@item content
The inner content elements or fragments to align horizontally.
@item gap
List of symbols for spacing gaps between elements.
@item shadow
List of symbols for shadow effect CSS classes.
@item wrap
List of symbols defining wrap properties.
@item padding-y
List of symbols for vertical padding CSS classes.
@item padding-x
List of symbols for horizontal padding CSS classes.
@item rounding
List of symbols for container border-radius CSS classes.
@item background
List of symbols for container background CSS classes.
@item items
List of symbols for cross-axis alignment CSS classes.
@item row-classes
List of base horizontal flex layout CSS classes.
@end table

@example
(row '((div \"Left Element\") (div \"Right Element\")) #:gap '(gap-4))
@end example"
  `((div (@ (class ,(mk-class (append row-classes
                                      background
                                      items
                                      wrap
                                      shadow
                                      gap
                                      padding-x
                                      padding-y
                                      rounding))))
         ,content)))

(define* (col content
              #:key (gap '(gap-6))
              (shadow '(shadow-md))
              (wrap '(flex-nowrap))
              (padding-y '(py-6))
              (padding-x '(px-4))
              (rounding '(rounded-lg))
              (background '(bg-stone-300/75 dark:bg-onyx-700))
              (items '(items-center))
              (col-classes '(flex flex-col)))
  "Create a vertical column container using flexbox layout.

@table @var
@item content
The inner content elements or fragments to stack vertically.
@item gap
List of symbols for spacing gaps between elements.
@item shadow
List of symbols for shadow effect CSS classes.
@item wrap
List of symbols defining wrap properties.
@item padding-y
List of symbols for vertical padding CSS classes.
@item padding-x
List of symbols for horizontal padding CSS classes.
@item rounding
List of symbols for container border-radius CSS classes.
@item background
List of symbols for container background CSS classes.
@item items
List of symbols for cross-axis alignment CSS classes.
@item col-classes
List of base vertical flex layout CSS classes.
@end table

@example
(col '((div \"Top Item\") (div \"Bottom Item\")) #:background '(bg-transparent))
@end example"
  `((div (@ (class ,(mk-class (append col-classes
                                      background
                                      items
                                      wrap
                                      shadow
                                      gap
                                      padding-x
                                      padding-y
                                      rounding))))
         ,content)))

(define* (dl content
             #:key (dl-classes '(flex flex-col gap-1 my-4 max-w-prose)))
  "Create an HTML description list (@code{<dl>}) element.

Terms and descriptions are stacked in a single column with a little
vertical rhythm and a comfortable reading width. Pair it with @code{dt}
for the term and @code{dd} for its description.

@table @var
@item content
The inner term (@code{<dt>}) and description (@code{<dd>}) elements.
@item dl-classes
List of symbols for layout and style CSS classes.
@end table

@example
(dl '((dt \"Framework\") (dd \"Hygguile\")))
@end example"
  `((dl (@ (class ,(mk-class dl-classes)))
        ,content)))

(define* (dt content
             #:key (dt-classes '(mt-2 pt-1))
             (weight '(font-semibold))
             (family '(font-sans))
             (style '())
             (color '(text-onyx-500 dark:text-stone-100))
             (size '(text-md)))
  "Create an HTML description term (@code{<dt>}) element.

A term renders as a compact, semi-bold label so it reads as a key above
its description. The small top margin separates one term/description
pair from the next.

@table @var
@item content
The term text string or fragment.
@item dt-classes
List of symbols for default structural spacing CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item family
List of symbols for font family CSS classes.
@item style
List of symbols for font style CSS classes (empty by default).
@item color
List of symbols for text color CSS classes.
@item size
List of symbols for text sizing CSS classes.
@end table

@example
(dt \"Guile Scheme\" #:weight '(font-bold))
@end example"
  `((dt (@ (class ,(mk-class (append dt-classes
                                     weight
                                     style
                                     color
                                     size
                                     family))))
        ,content)))

(define* (dd content
             #:key (dd-classes '(pl-4 ml-2
                                      mb-1
                                      border-l-2
                                      border-stone-700
                                      dark:border-onyx-100
                                      leading-6))
             (weight '(font-light))
             (family '(font-sans))
             (color '(text-onyx-300 dark:text-stone-300))
             (size '(text-md)))
  "Create an HTML description details (@code{<dd>}) element.

A description is indented behind a subtle left rule, which visually ties
it to the term above and keeps longer prose easy to scan.

@table @var
@item content
The detailed explanation text string or fragment.
@item dd-classes
List of symbols for layout and indentation CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item family
List of symbols for font family CSS classes.
@item color
List of symbols for text color CSS classes.
@item size
List of symbols for text sizing CSS classes.
@end table

@example
(dd \"An implementation of the Scheme programming language.\")
@end example"
  `((dd (@ (class ,(mk-class (append dd-classes weight color size family))))
        ,content)))

(define* (linear-gradient content
                          #:key (container-class "")
                          (direction 'right) steps)
  "Create a container styled with a CSS linear gradient background.

@table @var
@item content
The inner layout components or text elements inside the container.
@item container-class
A string containing additional CSS utility classes for the wrapper.
@item direction
A symbol or string designating the gradient vector direction (e.g., @code{'right}, @code{'bottom}).
@item steps
A list of color string steps making up the gradient stops.
@end table

@example
(linear-gradient \"Gradient Text\" #:direction 'right #:steps '(\"#ff0000\" \"#0000ff\"))
@end example"
  `((div (@ (class ,container-class)
            (style ,(mk-style `((background-color unquote
                                                  (car steps))
                                (background-image unquote
                                                  (format #f
                                                   "linear-gradient(to ~a, ~a)"
                                                   direction
                                                   (string-join steps ", ")))))))
         ,content)))
