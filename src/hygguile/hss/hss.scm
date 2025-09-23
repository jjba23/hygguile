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
  (make-parameter 0.28))
(define padding-multiplier
  (make-parameter 0.28))
(define gap-multiplier
  (make-parameter 0.3))
(define rounded-multiplier
  (make-parameter 0.16))
(define width-multiplier
  (make-parameter 0.24))
(define height-multiplier
  (make-parameter 0.24))
(define weight-multiplier
  (make-parameter 1))
(define prose-size
  (make-parameter "82ch"))
(define shadow-multiplier
  (make-parameter 0.3))

(define sm-breakpoint
  (make-parameter "640px"))

(define md-breakpoint
  (make-parameter "768px"))

(define lg-breakpoint
  (make-parameter "1024px"))

(define xl-breakpoint
  (make-parameter "1280px"))

(define breakpoints
  (make-parameter `((sm ,(sm-breakpoint))
                    (md ,(md-breakpoint))
                    (lg ,(lg-breakpoint))
                    (xl ,(xl-breakpoint)))))

(define mono-font-family
  (make-parameter "'IBM Plex Mono', monospace"))
(define serif-font-family
  (make-parameter "'IBM Plex Serif', ui-serif, serif, 'Times New Roman'"))
(define sans-font-family
  (make-parameter (string-join '("'IBM Plex Sans', ui-sans-serif, system-ui, sans-serif,"
                                 "'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'")
                               " ")))

;; ========================================================================

(define paddings
  (make-parameter (append (css* #:selector 'p
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'px
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-left padding-right)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'py
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-top padding-bottom)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'pt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-top)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'pb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-bottom)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'pl
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-left)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'pr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(padding-right)
                                #:multiplier (padding-multiplier)
                                #:breakpoints (breakpoints)))))

(define margins
  (make-parameter (append (css* #:selector 'm
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'mx
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-left margin-right)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'ml
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-left)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'mr
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-right)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'my
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-top margin-bottom)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'mt
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-top)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'mb
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(margin-bottom)
                                #:multiplier (margin-multiplier)
                                #:breakpoints (breakpoints)))))

(define weights
  (make-parameter (append (css* #:selector 'font
                                #:sizes default-weights
                                #:declarations '(font-weight)
                                #:rounded-to-integer? #t
                                #:multiplier (weight-multiplier)
                                #:unit ""
                                #:breakpoints (breakpoints)))))

(define widths
  (make-parameter (append (list (rul ".min-w-screen"
                                     (dec 'min-width "1vw"))
                                (rul ".max-w-screen"
                                     (dec 'max-width "1vw"))
                                (rul ".min-w-prose"
                                     (dec 'min-width
                                          (prose-size)))
                                (rul ".max-w-prose"
                                     (dec 'max-width
                                          (prose-size))))
                          (css* #:selector 'w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(width)
                                #:multiplier (width-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'min-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(min-width)
                                #:multiplier (width-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'max-w
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(max-width)
                                #:multiplier (width-multiplier)
                                #:breakpoints (breakpoints)))))

(define absolute-positions
  (make-parameter (append (css* #:selector 'top
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(top)
                                #:multiplier 1
                                #:unit "px"
                                #:breakpoints (breakpoints))
                          (css* #:selector 'bottom
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(bottom)
                                #:multiplier 1
                                #:unit "px"
                                #:breakpoints (breakpoints))
                          (css* #:selector 'left
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(left)
                                #:multiplier 1
                                #:unit "px"
                                #:breakpoints (breakpoints))
                          (css* #:selector 'right
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(right)
                                #:multiplier 1
                                #:unit "px"
                                #:breakpoints (breakpoints)))))

(define heights
  (make-parameter (append (list (rul ".min-h-screen"
                                     (dec 'min-height "1vh"))
                                (rul ".max-h-screen"
                                     (dec 'max-height "1vh")))
                          (css* #:selector 'h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(height)
                                #:multiplier (height-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'min-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(min-height)
                                #:multiplier (height-multiplier)
                                #:breakpoints (breakpoints))
                          (css* #:selector 'max-h
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(max-height)
                                #:multiplier (height-multiplier)
                                #:breakpoints (breakpoints)))))

(define font-families
  (make-parameter (list (rul ".font-sans"
                             (dec 'font-family
                                  (sans-font-family)))
                        (rul ".font-mono"
                             (dec 'font-family
                                  (mono-font-family)))
                        (rul ".font-serif"
                             (dec 'font-family
                                  (serif-font-family))))))

(define flex-justifies
  (make-parameter (rule-variants #:selector ".justify-~a"
                                #:property 'justify-content
                                #:variants '((start flex-start)
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

(define flex-aligns
  (make-parameter (rule-variants #:selector ".items-~a"
                                #:property 'align-items
                                #:variants '((start flex-start)
                                             (end flex-end)
                                             (end-safe "safe flex-end")
                                             (center center)
                                             (center-safe "safe center")
                                             (baseline baseline)
                                             (baseline-last "last baseline")
                                             (stretch stretch)))))

(define shadows
  (make-parameter (rule-variants #:selector ".shadow-~a"
                                #:property 'box-shadow
                                #:variants '((2xs "0 1px rgb(0 0 0 / 0.05)")
                                             (xs
                                              "0 1px 2px 0 rgb(0 0 0 / 0.05)")
                                             (sm
                                              "0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)")
                                             (md
                                              "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)")
                                             (lg
                                              "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)")
                                             (xl
                                              "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)")
                                             (2xl
                                              "0 25px 50px -12px rgb(0 0 0 / 0.25)")
                                             (none "0 0 #0000")))))

(define scroll-snap-type
  (make-parameter "proximity"))

(define scroll-snap-types
  (make-parameter (rule-variants #:selector ".snap-~a"
                                #:property 'scroll-snap-type
                                #:variants `((none none)
                                             (x ,(format #f "x ~a"
                                                         (scroll-snap-type)))
                                             (y ,(format #f "y ~a"
                                                         (scroll-snap-type)))
                                             (both ,(format #f "both ~a"
                                                            (scroll-snap-type)))))))

(define scroll-snap-aligns
  (make-parameter (rule-variants #:selector ".snap-~a"
                                #:property 'scroll-snap-align
                                #:variants '((start start)
                                             (end end)
                                             (center center)
                                             (none none)))))

(define flex-directions
  (make-parameter (rule-variants #:selector ".flex-~a"
                                #:property 'flex-direction
                                #:variants '((row row)
                                             (col column)
                                             (row-reverse row-reverse)
                                             (col-reverse column-reverse)))))

(define flex-utilities
  (make-parameter (append (css* #:selector 'gap
                                #:sizes default-numeric-sizes
                                #:direct-size? #t
                                #:declarations '(gap)
                                #:multiplier (gap-multiplier)
                                #:breakpoints (breakpoints))
                          (list (rul ".flex"
                                     (dec 'display
                                          'flex))
                                (rul ".flex-wrap"
                                     (dec 'flex-wrap
                                          'wrap))
                                (rul ".flex-nowrap"
                                     (dec 'flex-wrap
                                          'nowrap))))))

(define z-index
  (make-parameter (css* #:selector 'z
                        #:sizes default-numeric-sizes
                        #:direct-size? #t
                        #:rounded-to-integer? #t
                        #:declarations '(z-index)
                        #:multiplier 1
                        #:breakpoints (breakpoints)
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
                          (rule-variants #:selector ".bg-~a"
                                        #:property 'background
                                        #:variants '((white white)
                                                     (black black)
                                                     (transparent transparent)))
                          (rule-variants #:selector ".text-~a"
                                        #:property 'color
                                        #:variants '((white white)
                                                     (black black)
                                                     (transparent transparent)))
                          (rule-variants #:selector ".border-~a"
                                        #:property 'border-color
                                        #:variants '((white white)
                                                     (black black)
                                                     (transparent transparent)))

                          ;; (list (css #:selector "dark\\:bg-white"
                          ;; #:declarations `((,where-dark ((background
                          ;; white)))))
                          ;; (css #:selector "dark\\:bg-transparent"
                          ;; #:declarations `((,where-dark ((background
                          ;; transparent)))))
                          ;; (css #:selector "dark\\:bg-black"
                          ;; #:declarations `((,where-dark ((background
                          ;; black))))))
                          (map (lambda (p)
                                 (css-color* #:selector 'text
                                             #:declarations '(color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))

                          ;; (list (css #:selector "dark\\:text-white"
                          ;; #:declarations `((,where-dark ((color
                          ;; white)))))
                          ;; (css #:selector "dark\\:text-transparent"
                          ;; #:declarations `((,where-dark ((color
                          ;; transparent)))))
                          ;; (css #:selector "dark\\:text-black"
                          ;; #:declarations `((,where-dark ((color
                          ;; black))))))
                          
                          (map (lambda (p)
                                 (css-color* #:selector 'border
                                             #:declarations '(border-color)
                                             #:name (car p)
                                             #:palette (cdr p)
                                             #:alphas default-alphas
                                             #:weights default-color-weights))
                               (default-palettes))

                          ;; (list (css #:selector "dark\\:border-white"
                          ;; #:declarations `((,where-dark ((border-color
                          ;; white)))))
                          ;; (css #:selector "dark\\:border-transparent"
                          ;; #:declarations `((,where-dark ((border-color
                          ;; transparent)))))
                          ;; (css #:selector "dark\\:border-black"
                          ;; #:declarations `((,where-dark ((border-color
                          ;; black))))))
                          )))

(define text-utilities
  (make-parameter (list (rul ".italic"
                             (dec 'font-style
                                  'italic)))))

(define text-aligns
  (make-parameter (rule-variants #:selector ".text-~a"
                                 #:property 'text-align
                                 #:variants '((center center)
                                              (left left)
                                              (right right)
                                              (justify justify)
                                              (start start)
                                              (end end)))))

(define display-utilities
  (make-parameter (list (rul ".hidden"
                             (dec 'display
                                  'none))
                        (rul ".overflow-x-scroll"
                             (dec 'overflow-x
                                  'scroll))
                        (rul ".overflow-y-scroll"
                             (dec 'overflow-y
                                  'scroll))
                        (rul ".cursor-pointer"
                             (dec 'cursor
                                  'pointer)))))

(define roundings
  (make-parameter (css* #:selector 'rounded
                        #:sizes default-tshirt-sizes
                        #:declarations '(border-radius)
                        #:multiplier (rounded-multiplier)
                        #:breakpoints (breakpoints))))

(define border-style
  (make-parameter 'solid))

(define borders
  (make-parameter (css* #:selector 'border
                        #:sizes default-numeric-sizes
                        #:declarations '(border-width)
                        #:other-declarations `((border-style ,(border-style)))
                        #:direct-size? #t
                        #:multiplier 1
                        #:breakpoints (breakpoints)
                        #:unit "px")))

(define positions
  (make-parameter (rule-variants #:selector "~a"
                                #:property 'position
                                #:variants '((absolute absolute)
                                             (fixed fixed)
                                             (relative relative)))))

(define fade-in-page-transition
  (make-parameter (list (rul "@view-transition"
                             (dec 'navigation
                                  'auto))
                        (rul (string-join '("::view-transition-old(root)"
                                            "::view-transition-new(root)")
                                          ", ")
                             (dec 'animation "fade 0.1s ease both"))
                        (rul "@keyframes fade"
                             (rul 'from
                                  (dec 'opacity 0.2))
                             (rul 'to
                                  (dec 'opacity 1))))))

(define active-scale
  (make-parameter (list (rul ".active\\:scale-95"
                             (rul "&:active"
                                  (dec 'scale "95% 95%"))))))

(define shrinks
  (make-parameter (list (rul ".shrink"
                             (dec 'flex-shrink 1))
                        (rul ".shrink-0"
                             (dec 'flex-shrink 0)))))

;; ============ Stylesheet Generation Entry-point =========================

(define* (hss)
  (append (reset-css)
          (font-families)
          (text-aligns)
          (text-utilities)
          (flex-justifies)
          (flex-aligns)
          (shrinks)
          (active-scale)
          (positions)
          (flex-directions)
          (fade-in-page-transition)
          (list (rul ".flex"
                     (dec 'display
                          'flex))))

  ;; (css* #:selector 'text
  ;; #:sizes default-tshirt-sizes
  ;; #:declarations '(font-size)
  ;; #:breakpoints (breakpoints)
  ;; #:multiplier (font-size-multiplier))
  ;; (positions)
  ;; (absolute-positions)
  ;; (scroll-snap-aligns)
  ;; (scroll-snap-types)
  ;; (z-index)
  ;; (roundings)
  ;; (paddings)
  ;; (shadows)
  ;; (margins)
  ;; (weights)
  ;; (text-utilities)
  ;; (flex-utilities)
  ;; (borders)
  ;; (widths)
  ;; (heights)
  ;; (font-families)
  ;; (display-utilities)
  ;; (fade-in-page-transition)
  ;; (active-scale)
  ;; (colors))
  )

