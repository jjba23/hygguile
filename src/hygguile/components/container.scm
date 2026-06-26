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
                   linear-gradient))

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
         ,main
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
(hr #:margin '(my-4) #:color '(border-red-500))
@end example"
  `((hr (@ (class ,(mk-class (append color margin border)))))))

(define* (footer content
                 #:key (background '(bg-stone-300 dark:bg-onyx-700/75))
                 (shadow '(shadow-xl))
                 (footer-classes '(flex flex-col
                                        gap-4
                                        items-left
                                        px-6
                                        md:px-12
                                        justify-left
                                        py-10)))
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
             #:key (dl-classes '(flex flex-col)))
  "Create an HTML description list (@code{<dl>}) element.

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
             #:key (dt-classes '(py-2 pb-1))
             (weight '(font-light))
             (family '(font-sans))
             (style '(italic))
             (color '(text-onyx-300 dark:text-stone-500))
             (size '(text-lg)))
  "Create an HTML description term (@code{<dt>}) element.

@table @var
@item content
The term text string or fragment.
@item dt-classes
List of symbols for default structural padding CSS classes.
@item weight
List of symbols for font weight CSS classes.
@item family
List of symbols for font family CSS classes.
@item style
List of symbols for font style CSS classes.
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
             #:key (dd-classes '(px-2 text-onyx-300 dark:text-stone-300))
             (weight '(font-medium))
             (family '(font-sans))
             (color '(text-onyx-300 dark:text-stone-500))
             (size '(text-lg)))
  "Create an HTML description details (@code{<dd>}) element.

@table @var
@item content
The detailed explanation text string or fragment.
@item dd-classes
List of symbols for layout and fallback color CSS classes.
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
