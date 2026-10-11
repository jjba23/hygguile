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

(define-module (hygguile components media)
  #:use-module (hygguile abstraction)
  #:export (img source
                picture
                figure
                figcaption
                avatar
                image-gallery))

(define* (img #:key src
              (alt "")
              (title #f)
              (srcset #f)
              (sizes #f)
              (width #f)
              (height #f)
              (loading 'lazy)
              (decoding 'async)
              (fetch-priority #f)
              (referrer-policy #f)
              (crossorigin #f)
              (aspect-ratio #f)
              (fit 'cover)
              (rounding '(rounded-xl))
              (shadow '(shadow-md))
              (img-classes '(max-w-full h-auto))
              (extra-classes '()))
  "Create an accessible HTML @code{<img>} element.

Unlike a bare image tag, @var{alt} is always rendered, even when empty,
so decorative images are announced correctly by assistive technology.
The image is lazy-loaded and asynchronously decoded by default.

@table @var
@item src
The image source URL string.
@item alt
The alternative text. Use an empty string for purely decorative images.
@item title
An optional advisory title string.
@item srcset
An optional responsive candidate set string, e.g. @code{\"a.png 1x, a@@2x.png 2x\"}.
@item sizes
An optional source-size list describing layout widths to the browser.
@item width
An optional intrinsic width in pixels, helping avoid layout shift.
@item height
An optional intrinsic height in pixels, helping avoid layout shift.
@item loading
A symbol controlling native lazy loading, either @code{'lazy} or @code{'eager}.
@item decoding
A symbol requesting @code{'async} or @code{'sync} image decoding.
@item fetch-priority
An optional string such as @code{\"high\"} for above-the-fold hero images.
@item referrer-policy
An optional referrer policy string.
@item crossorigin
An optional CORS setting string such as @code{\"anonymous\"}.
@item aspect-ratio
An optional aspect ratio class value, e.g. @code{'square} or @code{\"16/9\"}.
@item fit
A symbol mapping to an @code{object-*} fit class: @code{'cover}, @code{'contain}, @code{'fill} or @code{'none}.
@item rounding
List of symbols representing border radius CSS classes.
@item shadow
List of symbols representing shadow CSS classes.
@item img-classes
List of symbols representing base image CSS classes.
@item extra-classes
List of additional utility CSS classes.
@end table

@example
(img #:src \"avatar.png\" #:alt \"Portrait\" #:width 320 #:height 320)
@end example"
  (let ((image-css (append extra-classes
                           img-classes
                           shadow
                           rounding
                           (list (string->symbol (format #f "object-~a" fit)))
                           (if aspect-ratio
                               (list (string->symbol (format #f "aspect-~a"
                                                             aspect-ratio)))
                               '()))))
    `((img (@ (src ,src)
              (alt ,alt)
              ,@(attr-when title
                           'title title)
              ,@(attr-when srcset
                           'srcset srcset)
              ,@(attr-when sizes
                           'sizes sizes)
              ,@(attr-when width
                           'width width)
              ,@(attr-when height
                           'height height)
              ,@(attr-when loading
                           'loading
                           (symbol->string loading))
              ,@(attr-when decoding
                           'decoding
                           (symbol->string decoding))
              ,@(attr-when fetch-priority
                           'fetchpriority fetch-priority)
              ,@(attr-when referrer-policy
                           'referrerpolicy referrer-policy)
              ,@(attr-when crossorigin
                           'crossorigin crossorigin)
              (class ,(mk-class image-css)))))))

(define* (source #:key srcset
                 (media #f)
                 (type #f)
                 (sizes #f)
                 (width #f)
                 (height #f))
  "Create an HTML @code{<source>} element for use inside @code{picture}.

@table @var
@item srcset
The candidate image set string.
@item media
An optional media query string providing art direction, e.g. @code{\"(min-width: 800px)\"}.
@item type
An optional MIME type string such as @code{\"image/avif\"}.
@item sizes
An optional source-size list string.
@item width
An optional intrinsic width in pixels.
@item height
An optional intrinsic height in pixels.
@end table

@example
(source #:type \"image/webp\" #:srcset \"hero.webp\")
@end example"
  `((source (@ ,@(attr-when srcset
                            'srcset srcset)
               ,@(attr-when media
                            'media media)
               ,@(attr-when type
                            'type type)
               ,@(attr-when sizes
                            'sizes sizes)
               ,@(attr-when width
                            'width width)
               ,@(attr-when height
                            'height height)))))

(define* (picture #:key sources image
                  (picture-classes '(block max-w-full)))
  "Create an HTML @code{<picture>} element for responsive images and art direction.

The @var{image} argument must be the output of @code{img}, which acts as
the fallback for browsers that do not support @code{picture}, modern
image formats such as AVIF or WebP, or any of the supplied media queries.
Because @code{picture} is native HTML, it keeps working with JavaScript
disabled.

@table @var
@item sources
A list of @code{source} elements to try in order.
@item image
The fallback @code{img} node produced by @code{(img ...)}.
@item picture-classes
List of symbols representing layout CSS classes for the wrapper.
@end table

@example
(picture #:sources (list (source #:type \"image/webp\" #:srcset \"photo.webp\"))
         #:image (img #:src \"photo.jpg\" #:alt \"A photo\"))
@end example"
  `((picture (@ (class ,(mk-class picture-classes)))
             ,@sources
             ,image)))

(define* (figcaption content
                     #:key (classes '(text-onyx-300 dark:text-stone-500
                                                    text-md font-light italic)))
  "Create an HTML @code{<figcaption>} caption element.

@table @var
@item content
The caption text string or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(figcaption \"Figure 1: the hygguile logo\")
@end example"
  `((figcaption (@ (class ,(mk-class classes)))
                ,content)))

(define* (figure content
                 #:key (caption #f)
                 (caption-classes '(text-onyx-300 dark:text-stone-500 text-md
                                                  font-light italic))
                 (align 'start)
                 (figure-classes '(flex flex-col gap-2 my-4 max-w-full)))
  "Create an HTML @code{<figure>} element with an optional caption.

@table @var
@item content
The figure body, typically an @code{img} or @code{picture} node.
@item caption
An optional caption rendered as a @code{figcaption} below the body.
@item caption-classes
List of symbols representing caption typography CSS classes.
@item align
A symbol controlling alignment, one of @code{'start}, @code{'center} or @code{'end}.
@item figure-classes
List of symbols representing the wrapper layout CSS classes.
@end table

@example
(figure (img #:src \"logo.png\" #:alt \"The logo\") #:caption \"Figure 1\")
@end example"
  (let ((alignment (cond
                     ((eq? 'center align)
                      '(items-center text-center))
                     ((eq? 'end align)
                      '(items-end text-right))
                     (else '(items-start)))))
    `((figure (@ (class ,(mk-class (append figure-classes alignment))))
              ,content
              ,@(if caption
                    `((figcaption (@ (class ,(mk-class caption-classes)))
                                  ,caption))
                    '())))))

(define* (avatar #:key src
                 (alt "")
                 (initials "")
                 (size 'md)
                 shape
                 (ring #f)
                 (classes '()))
  "Create a circular (or rounded) avatar image with an initials fallback.

When @var{src} is false, the @var{initials} are shown instead, which is
useful for user accounts without a profile picture. Everything is plain
HTML and CSS, so avatars render with JavaScript disabled.

@table @var
@item src
The optional image source URL.
@item alt
The alternative text describing the depicted person.
@item initials
Fallback initials shown when no image source is supplied.
@item size
A size keyword: @code{'xs}, @code{'sm}, @code{'md}, @code{'lg} or @code{'xl}.
@item shape
A shape keyword: @code{'circle} (default), @code{'rounded} or @code{'square}.
@item ring
An optional boolean adding a subtle border ring around the avatar.
@item classes
List of additional utility CSS classes.
@end table

@example
(avatar #:src \"me.png\" #:alt \"Josep\" #:size 'lg #:ring #t)
@end example"
  (let* ((size-classes (cond
                         ((eq? 'xs size)
                          '(w-8 h-8 text-sm))
                         ((eq? 'sm size)
                          '(w-10 h-10 text-md))
                         ((eq? 'lg size)
                          '(w-16 h-16 text-2xl))
                         ((eq? 'xl size)
                          '(w-24 h-24 text-3xl))
                         (else '(w-12 h-12 text-xl))))
         (shape-classes (cond
                          ((eq? 'rounded shape)
                           '(rounded-xl))
                          ((eq? 'square shape)
                           '(rounded-2xs))
                          (else '(rounded-512))))
         (container-css (append classes size-classes shape-classes
                                '(inline-flex items-center
                                              justify-center
                                              overflow-hidden
                                              shrink-0
                                              bg-stone-500/75
                                              dark:bg-onyx-500/75
                                              text-onyx-500
                                              dark:text-stone-100
                                              font-medium
                                              font-sans)
                                (if ring
                                    '(border-2 border-stone-300
                                               dark:border-onyx-100)
                                    '()))))
    `((span (@ (class ,(mk-class container-css)))
            ,@(if src
                  `((img (@ (src ,src)
                            (alt ,alt)
                            (loading "lazy")
                            (decoding "async")
                            (class "w-full h-full object-cover"))))
                  (list initials))))))

(define* (image-gallery images
                        #:key (columns 3)
                        (gap '(gap-4)))
  "Create a responsive, evenly spaced gallery grid for a list of image nodes.

@table @var
@item images
A list of image or figure nodes to lay out.
@item columns
The number of columns to request on wide viewports.
@item gap
List of symbols representing gap CSS classes.
@end table

@example
(image-gallery (list (img #:src \"a.png\" #:alt \"A\")
                    (img #:src \"b.png\" #:alt \"B\")))
@end example"
  (let* ((cols (if (< columns 1) 1 columns))
         ;; one column on phones, two on small screens, then the
         ;; requested number of columns from the medium breakpoint up
         (column-classes (append '(grid-cols-1)
                                 (if (> cols 1)
                                     '(sm:grid-cols-2)
                                     '())
                                 (list (string->symbol (format #f
                                                        "md:grid-cols-~a" cols))))))
    `((div (@ (class ,(mk-class (append '(grid place-items-center) gap
                                        column-classes))))
           ,@images))))
