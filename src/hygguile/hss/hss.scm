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
  (make-parameter 0.25))
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
  (make-parameter "76ch"))
(define shadow-multiplier
  (make-parameter 0.3))
(define absolute-positions-multiplier
  (make-parameter 0.4))
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
  (make-parameter (map (lambda (d)
                         (map (lambda (p)
                                (rulv (string-append "."
                                                     (format #f "~a"
                                                             (car d)) "-" "~a")
                                      #:property p
                                      #:variants (map (lambda (s)
                                                        (siz s
                                                             #:conversion
                                                             to-rem
                                                             #:multiplier (padding-multiplier)))
                                                      (append
                                                       default-numeric-sizes
                                                       default-tshirt-sizes))))
                              (cdr d)))
                       '((p padding-top padding-bottom padding-left
                            padding-right)
                         (px padding-left padding-right)
                         (py padding-top padding-bottom)
                         (pt padding-top)
                         (pb padding-bottom)
                         (pl padding-left)
                         (pr padding-right)))))

(define margins
  (make-parameter (map (lambda (d)
                         (map (lambda (p)
                                (rulv (string-append "."
                                                     (format #f "~a"
                                                             (car d)) "-" "~a")
                                      #:property p
                                      #:variants (map (lambda (s)
                                                        (siz s
                                                             #:conversion
                                                             to-rem
                                                             #:multiplier (margin-multiplier)))
                                                      (append
                                                       default-numeric-sizes
                                                       default-tshirt-sizes))))
                              (cdr d)))
                       '((m margin-top margin-bottom margin-left margin-right)
                         (mx margin-left margin-right)
                         (my margin-top margin-bottom)
                         (mt margin-top)
                         (mb margin-bottom)
                         (ml margin-left)
                         (mr margin-right)))))

(define weights
  (make-parameter (rulv ".font-~a"
                        #:property 'font-weight
                        #:variants default-weights)))

(define widths
  (make-parameter (append (list (rul ".min-w-screen"
                                     (dec 'min-width "1vh"))
                                (rul ".max-w-screen"
                                     (dec 'max-width "1vh"))
                                (rul ".min-w-prose"
                                     (dec 'min-width
                                          (prose-size)))
                                (rul ".max-w-prose"
                                     (dec 'max-width
                                          (prose-size))))
                          (map (lambda (d)
                                 (rulv (string-append "."
                                                      (format #f "~a"
                                                              (car d)) "-"
                                                      "~a")
                                       #:property (cadr d)
                                       #:variants (map (lambda (s)
                                                         (siz s
                                                              #:conversion
                                                              to-rem
                                                              #:multiplier (width-multiplier)))
                                                       (append
                                                        default-numeric-sizes
                                                        default-tshirt-sizes))))
                               '((w width)
                                 (min-w min-width)
                                 (max-w max-width))))))

(define absolute-positions
  (make-parameter (map (lambda (d)
                         (rulv (string-append "."
                                              (format #f "~a" d) "-" "~a")
                               #:property d
                               #:variants (append (map (lambda (s)
                                                         (siz s
                                                              #:conversion
                                                              to-rem
                                                              #:multiplier (absolute-positions-multiplier)))
                                                       default-numeric-sizes)
                                                  (map siz default-fractions))))
                       '(top bottom left right)))

  )

(define heights
  (make-parameter (append (list (rul ".min-h-screen"
                                     (dec 'min-height "1vh"))
                                (rul ".max-h-screen"
                                     (dec 'max-height "1vh")))
                          (map (lambda (d)
                                 (rulv (string-append "."
                                                      (format #f "~a"
                                                              (car d)) "-"
                                                      "~a")
                                       #:property (cadr d)
                                       #:variants (map (lambda (s)
                                                         (siz s
                                                              #:conversion
                                                              to-rem
                                                              #:multiplier (height-multiplier)))
                                                       (append
                                                        default-numeric-sizes
                                                        default-tshirt-sizes))))
                               '((h height)
                                 (min-h min-height)
                                 (max-h max-height))))))

(define text-sizes
  (make-parameter (rulv ".text-~a"
                        #:property 'font-size
                        #:variants (map (lambda (s)
                                          (siz s
                                               #:conversion to-rem
                                               #:multiplier (font-size-multiplier)))
                                        (append default-tshirt-sizes
                                                default-numeric-sizes)))))

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
  (make-parameter (rulv ".justify-~a"
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
  (make-parameter (rulv ".items-~a"
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
  (make-parameter (rulv ".shadow-~a"
                        #:property 'box-shadow
                        #:variants '(("2xs" "0 1px rgb(0 0 0 / 0.05)")
                                     (xs "0 1px 2px 0 rgb(0 0 0 / 0.05)")
                                     (sm
                                      "0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)")
                                     (md
                                      "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)")
                                     (lg
                                      "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)")
                                     (xl
                                      "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)")
                                     ("2xl"
                                      "0 25px 50px -12px rgb(0 0 0 / 0.25)")
                                     (none "0 0 #0000")))))

(define scroll-snap-type
  (make-parameter "proximity"))

(define scroll-snap-types
  (make-parameter (rulv ".snap-~a"
                        #:property 'scroll-snap-type
                        #:variants `((none none)
                                     (x ,(format #f "x ~a"
                                                 (scroll-snap-type)))
                                     (y ,(format #f "y ~a"
                                                 (scroll-snap-type)))
                                     (both ,(format #f "both ~a"
                                                    (scroll-snap-type)))))))

(define scroll-snap-aligns
  (make-parameter (rulv ".snap-~a"
                        #:property 'scroll-snap-align
                        #:variants '((start start)
                                     (end end)
                                     (center center)
                                     (none none)))))

(define flex-directions
  (make-parameter (rulv ".flex-~a"
                        #:property 'flex-direction
                        #:variants '((row row)
                                     (col column)
                                     (row-reverse row-reverse)
                                     (col-reverse column-reverse)))))

(define flex-utilities
  (make-parameter (append (rulv ".gap-~a"
                                #:property 'gap
                                #:variants (map (lambda (s)
                                                  (siz s
                                                       #:conversion to-rem
                                                       #:multiplier (gap-multiplier)))
                                                (append default-numeric-sizes
                                                        default-tshirt-sizes)))

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
  (make-parameter (rulv ".z-~a"
                        #:property 'z-index
                        #:variants default-numeric-sizes)))

(define colors
  (make-parameter (append (rulv ".bg-~a"
                                #:property 'background
                                #:variants '((white white)
                                             (black black)
                                             (transparent transparent)))
                          (rulv ".text-~a"
                                #:property 'color
                                #:variants '((white white)
                                             (black black)
                                             (transparent transparent)))
                          (rulv ".border-~a"
                                #:property 'border-color
                                #:variants '((white white)
                                             (black black)
                                             (transparent transparent)))

                          (rulcol ".bg-~a-~a~a"
                                  #:property 'background
                                  #:variants (list-combinations default-alphas
                                              default-color-weights)
                                  #:palettes (default-palettes))
                          (rulcol ".text-~a-~a~a"
                                  #:property 'color
                                  #:variants (list-combinations default-alphas
                                              default-color-weights)
                                  #:palettes (default-palettes))
                          (rulcol ".border-~a-~a~a"
                                  #:property 'border-color
                                  #:variants (list-combinations default-alphas
                                              default-color-weights)
                                  #:palettes (default-palettes))

                          )))

(define dark-mode-colors
  (make-parameter (list '("&:where([data-theme=dark], [data-theme=dark] *) {")
                        (addmq 'dark
                               (colors))
                        '("}"))))

(define text-utilities
  (make-parameter (list (rul ".italic"
                             (dec 'font-style
                                  'italic)))))

(define text-aligns
  (make-parameter (rulv ".text-~a"
                        #:property 'text-align
                        #:variants '((center center)
                                     (left left)
                                     (right right)
                                     (justify justify)
                                     (start start)
                                     (end end)))))

(define display-utilities
  (make-parameter (list (rul ".hidden"
                             (dec 'display "none !important"))
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
  (make-parameter (list (rulv ".rounded-~a"
                              #:property 'border-radius
                              #:variants (map (lambda (s)
                                                (siz s
                                                     #:conversion to-rem
                                                     #:multiplier (rounded-multiplier)))
                                              (append default-numeric-sizes
                                                      default-tshirt-sizes))))))

(define border-style
  (make-parameter 'solid))

(define borders
  (make-parameter (rulv ".border-~a"
                        #:property 'border-width
                        #:other-properties `((border-style ,(border-style)))
                        #:variants (map (lambda (s)
                                          (siz s
                                               #:conversion to-px))
                                        default-numeric-sizes))))

(define positions
  (make-parameter (rulv ".~a"
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

(define license-header
  (make-parameter
   "hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>."))

;; ============ Stylesheet Generation Entry-point =========================

(define responsive-classes
  (make-parameter (append (z-index)
                          (heights)
                          (widths))))

(define sm-responsive
  (make-parameter (map (lambda (r)
                         (addmq 'sm r))
                       (responsive-classes))))

(define md-responsive
  (make-parameter (map (lambda (r)
                         (addmq 'md r))
                       (responsive-classes))))

(define lg-responsive
  (make-parameter (map (lambda (r)
                         (addmq 'lg r))
                       (responsive-classes))))

(define xl-responsive
  (make-parameter (map (lambda (r)
                         (addmq 'xl r))
                       (responsive-classes))))

(define 2xl-responsive
  (make-parameter (map (lambda (r)
                         (addmq "2xl" r))
                       (responsive-classes))))

(define responsive
  (make-parameter (append (mq "width >= 40rem"
                              (sm-responsive))
                          (mq "width >= 48rem"
                              (md-responsive))
                          (mq "width >= 64rem"
                              (lg-responsive))
                          (mq "width >= 80rem"
                              (xl-responsive))
                          (mq "width >= 96rem"
                              (2xl-responsive))
                          )))

(define* (hss)
  (append (rulc (license-header))
          '("")
          (rulc "Load CSS browser reset - should be first")
          (reset-css)
          '("")
          (rulc "Load HSS Hygge Style Sheets")
          (absolute-positions)
          (active-scale)
          (borders)
          (display-utilities)
          (display-utilities)
          (fade-in-page-transition)
          (flex-aligns)
          (flex-directions)
          (flex-justifies)
          (flex-utilities)
          (font-families)
          (heights)
          (margins)
          (paddings)
          (positions)
          (roundings)
          (scroll-snap-aligns)
          (scroll-snap-types)
          (shadows)
          (shrinks)
          (text-aligns)
          (text-sizes)
          (text-utilities)
          (weights)
          (widths)
          (z-index)
          '("")
          (rulc "Load HSS colors")
          (colors)
          '("")
          (rulc "Load HSS Dark mode colors")
          (dark-mode-colors)
          '("")
          (rulc "Load responsive classes")
          (responsive)))

