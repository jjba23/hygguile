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

(define-module (hygguile hss hss)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss colors)
  #:use-module (hygguile hss sizes)
  #:use-module (hygguile hss reset)
  #:export (font-size-multiplier margin-multiplier
                                 padding-multiplier
                                 gap-multiplier
                                 rounded-multiplier
                                 width-multiplier
                                 weight-multiplier
                                 height-multiplier
                                 mono-font-family
                                 sans-font-family
                                 serif-font-family
                                 hss))

(define font-size-multiplier
  (make-parameter 0.24))
(define margin-multiplier
  (make-parameter 0.24))
(define padding-multiplier
  (make-parameter 0.24))
(define gap-multiplier
  (make-parameter 0.24))
(define rounded-multiplier
  (make-parameter 0.1))
(define width-multiplier
  (make-parameter 0.3))
(define height-multiplier
  (make-parameter 0.3))
(define weight-multiplier
  (make-parameter 1))

(define mono-font-family
  (make-parameter "'IBM Plex Mono', monospace"))
(define serif-font-family
  (make-parameter "'IBM Plex Serif', ui-serif, serif, 'Times New Roman'"))
(define sans-font-family
  (make-parameter (string-join '("'IBM Plex Sans', ui-sans-serif, system-ui, sans-serif,"
                                 "'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'")
                               " ")))

(define paddings
  (make-parameter (append (css* #:selector 'p
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'px
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-left padding-right)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'py
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-top padding-bottom)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'pt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-top)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'pb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-bottom)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'pl
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-left)
                                #:multiplier (padding-multiplier))
                          (css* #:selector 'pr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-right)
                                #:multiplier (padding-multiplier)))))

(define margins
  (make-parameter (append (css* #:selector 'm
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'mx
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-left margin-right)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'ml
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-left)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'mr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-right)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'my
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-top margin-bottom)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'mt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-top)
                                #:multiplier (margin-multiplier))
                          (css* #:selector 'mb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-bottom)
                                #:multiplier (margin-multiplier)))))

(define weights
  (make-parameter (append (css* #:selector 'font
                                #:sizes default-weights
                                #:declarations '(font-weight)
                                #:rounded-to-integer? #t
                                #:multiplier (weight-multiplier)
                                #:unit ""))))

(define widths
  (make-parameter (append (list (css #:selector 'min-w-screen
                                     #:declarations '((min-width "1vw"))))
                          (css* #:selector 'w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(width)
                                #:multiplier (width-multiplier))
                          (css* #:selector 'min-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(min-width)
                                #:multiplier (width-multiplier))
                          (css* #:selector 'max-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(max-width)
                                #:multiplier (width-multiplier)))))

(define heights
  (make-parameter (append (list (css #:selector 'min-h-screen
                                     #:declarations '((min-height "1vh"))))
                          (css* #:selector 'h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(height)
                                #:multiplier (height-multiplier))
                          (css* #:selector 'min-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(min-height)
                                #:multiplier (height-multiplier))
                          (css* #:selector 'max-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(max-height)
                                #:multiplier (height-multiplier)))))

(define font-families
  (make-parameter (list (css #:selector 'font-sans
                             #:declarations `((font-family ,(sans-font-family))))
                        (css #:selector 'font-mono
                             #:declarations `((font-family ,(mono-font-family))))
                        (css #:selector 'font-serif
                             #:declarations `((font-family ,(serif-font-family)))))))

(define flex-justifies
  (make-parameter (map (lambda (x)
                         (css #:selector (string->symbol (format #f
                                                                 "justify-~a"
                                                                 (car x)))
                              #:declarations `((justify-content ,(cadr x)))))
                       '((start flex-start)
                         (end flex-end)
                         (end-safe "safe flex-end")
                         (center center)
                         (center-safe "safe center")
                         (between space-between)
                         (around space-around)
                         (evenly space-evenly)
                         (stretch stretch)
                         (baseline baseline)
                         (normal normal)))))

(define scroll-snap-type
  (make-parameter "proximity"))

(define scroll-snap-types
  (make-parameter (map (lambda (x)
                         (css #:selector (string->symbol (format #f "snap-~a"
                                                                 (car x)))
                              #:declarations `((scroll-snap-type ,(cadr x)))))
                       `((none none)
                         (x ,(format #f "x ~a"
                                     (scroll-snap-type)))
                         (y ,(format #f "y ~a"
                                     (scroll-snap-type)))
                         (both ,(format #f "both ~a"
                                        (scroll-snap-type)))))))

(define flex-utilities
  (make-parameter (append (css* #:selector 'gap
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(gap)
                                #:multiplier (gap-multiplier))
                          (list (css #:selector 'flex
                                     #:declarations '((display flex)))
                                (css #:selector 'flex-col
                                     #:declarations '((flex-direction column)))
                                (css #:selector 'flex-row
                                     #:declarations '((flex-direction row)))
                                (css #:selector 'flex-wrap
                                     #:declarations '((flex-wrap wrap)))
                                (css #:selector 'flex-nowrap
                                     #:declarations '((flex-wrap nowrap)))
                                (css #:selector 'items-center
                                     #:declarations '((align-items center)))))))

(define z-index
  (make-parameter (css* #:selector 'z
                        #:sizes default-numeric-sizes
                        #:direct-size? #t
                        #:rounded-to-integer? #t
                        #:declarations '(z-index)
                        #:multiplier 1
                        #:unit "")))

(define colors
  (make-parameter (append (map (lambda (p)
                                 (css-color* #:selector 'bg
                                             #:declarations '(background)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:selector 'bg-white
                                     #:declarations '((background white)))
                                (css #:selector 'bg-transparent
                                     #:declarations '((background transparent)))
                                (css #:selector 'bg-black
                                     #:declarations '((background black))))

                          (list (css #:selector "dark\\:bg-white"
                                     #:declarations `((,where-dark ((background
                                                                     white)))))
                                (css #:selector "dark\\:bg-transparent"
                                     #:declarations `((,where-dark ((background
                                                                     transparent)))))
                                (css #:selector "dark\\:bg-black"
                                     #:declarations `((,where-dark ((background
                                                                     black))))))
                          (map (lambda (p)
                                 (css-color* #:selector 'text
                                             #:declarations '(color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:selector 'text-white
                                     #:declarations '((color white)))
                                (css #:selector 'text-transparent
                                     #:declarations '((color transparent)))
                                (css #:selector 'text-black
                                     #:declarations '((color black))))
                          (list (css #:selector "dark\\:text-white"
                                     #:declarations `((,where-dark ((color
                                                                     white)))))
                                (css #:selector "dark\\:text-transparent"
                                     #:declarations `((,where-dark ((color
                                                                     transparent)))))
                                (css #:selector "dark\\:text-black"
                                     #:declarations `((,where-dark ((color
                                                                     black))))))
                          (map (lambda (p)
                                 (css-color* #:selector 'border
                                             #:declarations '(border-color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:selector 'border-white
                                     #:declarations '((border-color white)))
                                (css #:selector 'border-transparent
                                     #:declarations '((border-color
                                                       transparent)))
                                (css #:selector 'border-black
                                     #:declarations '((border-color black))))
                          (list (css #:selector "dark\\:border-white"
                                     #:declarations `((,where-dark ((border-color
                                                                     white)))))
                                (css #:selector "dark\\:border-transparent"
                                     #:declarations `((,where-dark ((border-color
                                                                     transparent)))))
                                (css #:selector "dark\\:border-black"
                                     #:declarations `((,where-dark ((border-color
                                                                     black)))))))))

(define text-utilities
  (make-parameter (list (css #:selector 'italic
                             #:declarations `((font-style italic)))
                        (css #:selector 'text-center
                             #:declarations '((text-align center))))))

(define display-utilities
  (make-parameter (list (css #:selector 'hidden
                             #:declarations `((display none)))
                        (css #:selector 'overflow-x-scroll
                             #:declarations '((overflow-x scroll)))
                        (css #:selector 'cursor-pointer
                             #:declarations `((cursor pointer))))))

(define roundings
  (make-parameter (css* #:selector 'rounded
                        #:sizes default-tshirt-sizes
                        #:declarations '(border-radius)
                        #:multiplier (rounded-multiplier))))

(define border-style
  (make-parameter 'solid))

(define borders
  (make-parameter (css* #:selector 'border
                        #:sizes default-numeric-sizes
                        #:declarations '(border-width)
                        #:other-declarations `((border-style ,(border-style)))
                        #:direct-size? #t
                        #:multiplier 1
                        #:unit "px")))

(define positions
  (make-parameter (map (lambda (x)
                         (css #:selector (string->symbol (format #f
                                                          "position-~a"
                                                          (car x)))
                              #:declarations `((position ,(cadr x)))))
                       '((absolute absolute)
                         (relative relative)))))

(define fade-in-page-transition
  (make-parameter (list (css #:selector "@view-transition"
                             #:selector-type ""
                             #:declarations '((navigation auto)))
                        (css #:selector (string-join '("::view-transition-old(root)"
                                                       "::view-transition-new(root)")
                                                     ", ")
                             #:selector-type ""
                             #:declarations '((animation "fade 0.1s ease both")))
                        (css #:selector "@keyframes fade"
                             #:selector-type ""
                             #:declarations '((from ((opacity 0.2)))
                                              (to ((opacity 1))))))))

(define active-scale
  (make-parameter (list (css #:selector "active\\:scale-95"
                             #:declarations '(("&:active" ((scale "95% 95%"))))))))

;; ============ Stylesheet Generation Entry-point =========================

(define* (hss)
  (append reset-css
          (css* #:selector 'text
                #:sizes default-tshirt-sizes
                #:declarations '(font-size)
                #:multiplier (font-size-multiplier))
          (positions)
          (flex-justifies)
          (z-index)
          (roundings)
          (paddings)
          (scroll-snap-types)
          (margins)
          (weights)
          (flex-utilities)
          (borders)
          (widths)
          (heights)
          (font-families)
          (display-utilities)
          (fade-in-page-transition)
          (active-scale)
          (colors)))

