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
  (make-parameter (append (css* #:class 'p
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'px
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-left padding-right)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'py
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-top padding-bottom)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'pt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-top)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'pb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-bottom)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'pl
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-left)
                                #:multiplier (padding-multiplier))
                          (css* #:class 'pr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(padding-right)
                                #:multiplier (padding-multiplier)))))

(define margins
  (make-parameter (append (css* #:class 'm
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'mx
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-left margin-right)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'ml
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-left)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'mr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-right)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'my
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-top margin-bottom)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'mt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-top)
                                #:multiplier (margin-multiplier))
                          (css* #:class 'mb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(margin-bottom)
                                #:multiplier (margin-multiplier)))))

(define weights
  (make-parameter (append (css* #:class 'font
                                #:sizes default-weights
                                #:properties '(font-weight)
                                #:rounded-to-integer? #t
                                #:multiplier (weight-multiplier)
                                #:unit ""))))

(define widths
  (make-parameter (append (list (css #:class 'min-w-screen
                                     #:properties '((min-width "1vw"))))
                          (css* #:class 'w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(width)
                                #:multiplier (width-multiplier))
                          (css* #:class 'min-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(min-width)
                                #:multiplier (width-multiplier))
                          (css* #:class 'max-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(max-width)
                                #:multiplier (width-multiplier)))))

(define heights
  (make-parameter (append (list (css #:class 'min-h-screen
                                     #:properties '((min-height "1vh"))))
                          (css* #:class 'h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(height)
                                #:multiplier (height-multiplier))
                          (css* #:class 'min-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(min-height)
                                #:multiplier (height-multiplier))
                          (css* #:class 'max-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(max-height)
                                #:multiplier (height-multiplier)))))

(define font-families
  (make-parameter (list (css #:class 'font-sans
                             #:properties `((font-family ,(sans-font-family))))
                        (css #:class 'font-mono
                             #:properties `((font-family ,(mono-font-family))))
                        (css #:class 'font-serif
                             #:properties `((font-family ,(serif-font-family)))))))

(define flex-justifies
  (make-parameter (map (lambda (x)
                         (css #:class (string->symbol (format #f "justify-~a"
                                                              (car x)))
                              #:properties `((justify-content ,(cadr x)))))
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
                         (css #:class (string->symbol (format #f "snap-~a"
                                                              (car x)))
                              #:properties `((scroll-snap-type ,(cadr x)))))
                       `((none none)
                         (x ,(format #f "x ~a"
                                     (scroll-snap-type)))
                         (y ,(format #f "y ~a"
                                     (scroll-snap-type)))
                         (both ,(format #f "both ~a"
                                        (scroll-snap-type)))))))

;; snap-none

;; scroll-snap-type: none;
;; snap-x

;; scroll-snap-type: x var(--tw-scroll-snap-strictness);
;; snap-y

;; scroll-snap-type: y var(--tw-scroll-snap-strictness);
;; snap-both

;; scroll-snap-type: both var(--tw-scroll-snap-strictness);
;; snap-mandatory

;; --tw-scroll-snap-strictness: mandatory;
;; snap-proximity

;; --tw-scroll-snap-strictness: proximity;

(define flex-utilities
  (make-parameter (append (css* #:class 'gap
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:properties '(gap)
                                #:multiplier (gap-multiplier))
                          (list (css #:class 'flex
                                     #:properties '((display flex)))
                                (css #:class 'flex-col
                                     #:properties '((flex-direction column)))
                                (css #:class 'flex-row
                                     #:properties '((flex-direction row)))
                                (css #:class 'flex-wrap
                                     #:properties '((flex-wrap wrap)))
                                (css #:class 'flex-nowrap
                                     #:properties '((flex-wrap nowrap)))
                                (css #:class 'items-center
                                     #:properties '((align-items center)))))))

(define z-index
  (make-parameter (css* #:class 'z
                        #:sizes default-numeric-sizes
                        #:direct-size? #t
                        #:rounded-to-integer? #t
                        #:properties '(z-index)
                        #:multiplier 1
                        #:unit "")))

;; We work with rgba by default for colors
;;
;;
;; You can do this for using colors without transparency
;; #:namespace 'rgb
;; #:alphas '((("" 1)))

(define colors
  (make-parameter (append (map (lambda (p)
                                 (css-color* #:class 'bg
                                             #:properties '(background)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:class 'bg-white
                                     #:properties '((background white)))
                                (css #:class 'bg-transparent
                                     #:properties '((background transparent)))
                                (css #:class 'bg-black
                                     #:properties '((background black))))
                          (map (lambda (p)
                                 (css-color* #:class 'text
                                             #:properties '(color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:class 'text-white
                                     #:properties '((color white)))
                                (css #:class 'text-transparent
                                     #:properties '((color transparent)))
                                (css #:class 'text-black
                                     #:properties '((color black))))
                          (map (lambda (p)
                                 (css-color* #:class 'border
                                             #:properties '(border-color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))
                          (list (css #:class 'border-white
                                     #:properties '((border-color white)))
                                (css #:class 'border-transparent
                                     #:properties '((border-color transparent)))
                                (css #:class 'border-black
                                     #:properties '((border-color black)))))))

(define text-utilities
  (make-parameter (list (css #:class 'italic
                             #:properties `((font-style italic)))
                        (css #:class 'text-center
                             #:properties '((text-align center))))))

(define display-utilities
  (make-parameter (list (css #:class 'hidden
                             #:properties `((display none)))
                        (css #:class 'overflow-x-scroll
                             #:properties '((overflow-x scroll)))
                        (css #:class 'cursor-pointer
                             #:properties `((cursor pointer))))))

(define roundings
  (make-parameter (css* #:class 'rounded
                        #:sizes default-tshirt-sizes
                        #:properties '(border-radius)
                        #:multiplier (rounded-multiplier))))

(define border-style
  (make-parameter 'solid))

(define borders
  (make-parameter (css* #:class 'border
                        #:sizes default-numeric-sizes
                        #:properties '(border-width)
                        #:other-properties `((border-style ,(border-style)))
                        #:direct-size? #t
                        #:multiplier 1
                        #:unit "px")))

(define positions
  (make-parameter (map (lambda (x)
                         (css #:class (string->symbol (format #f "position-~a"
                                                              (car x)))
                              #:properties `((position ,(cadr x)))))
                       '((absolute absolute)
                         (relative relative)))))

;; ============ Stylesheet Generation Entry-point =========================

(define* (hss)
  (append reset-css
          (css* #:class 'text
                #:sizes default-tshirt-sizes
                #:properties '(font-size)
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
          (colors)))

;; .active\:scale-95 {
;;     &:active {
;;         --tw-scale-x: 95%;
;;         --tw-scale-y: 95%;
;;         --tw-scale-z: 95%;
;;         scale: var(--tw-scale-x) var(--tw-scale-y);
;;     }
;; }
