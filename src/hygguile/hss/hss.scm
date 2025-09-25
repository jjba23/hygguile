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
  #:use-module (hygguile hss sizes)
  #:use-module (hygguile hss decl colors)
  #:use-module (hygguile hss decl layout)
  #:use-module (hygguile hss decl flexbox)
  #:use-module (hygguile hss decl spacing)
  #:use-module (hygguile hss decl sizing)
  #:use-module (hygguile hss decl filters)
  #:use-module (hygguile hss decl typography)
  #:use-module (hygguile hss decl reset)
  #:export (rounded-multiplier  hss))



(define rounded-multiplier
  (param 0.16))


(define shadow-multiplier
  (param 0.3))

(define sm-breakpoint
  (param "640px"))

(define md-breakpoint
  (param "768px"))

(define lg-breakpoint
  (param "1024px"))

(define xl-breakpoint
  (param "1280px"))

(define breakpoints
  (param `((sm ,(sm-breakpoint))
           (md ,(md-breakpoint))
           (lg ,(lg-breakpoint))
           (xl ,(xl-breakpoint)))))

;; ========================================================================



(define shadows
  (param (rulv ".shadow-~a"
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
                            ("2xl" "0 25px 50px -12px rgb(0 0 0 / 0.25)")
                            (none "0 0 #0000")))))

(define scroll-snap-type
  (param "proximity"))

(define scroll-snap-types
  (param (rulv ".snap-~a"
               #:property 'scroll-snap-type
               #:variants `((none none)
                            (x ,(format #f "x ~a"
                                        (scroll-snap-type)))
                            (y ,(format #f "y ~a"
                                        (scroll-snap-type)))
                            (both ,(format #f "both ~a"
                                           (scroll-snap-type)))))))

(define scroll-snap-aligns
  (param (rulv ".snap-~a"
               #:property 'scroll-snap-align
               #:variants '((start start)
                            (end end)
                            (center center)
                            (none none)))))

(define colors
  (param (append (rulv ".bg-~a"
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
                         #:variants (list-combinations alphas color-weights)
                         #:palettes (palettes))
                 (rulcol ".text-~a-~a~a"
                         #:property 'color
                         #:variants (list-combinations alphas color-weights)
                         #:palettes (palettes))
                 (rulcol ".border-~a-~a~a"
                         #:property 'border-color
                         #:variants (list-combinations alphas color-weights)
                         #:palettes (palettes))

                 )))

(define dark-mode
  (param (list '("")
               (rulc "Load HSS Dark mode colors")
               (list where-dark " {")
               (addmq 'dark
                      (colors))
               (addmq 'dark
                      (filter-classes))
               '("")
               (rulc "Load HSS Dark mode hover colors")
               (addhover "hover\\:dark"
                         (colors))
               '("}"))))

(define hover-colors
  (param (addhover 'hover
                   (colors))))




(define display-utilities
  (param (list (rul ".overflow-x-scroll"
                    (dec 'overflow-x
                         'scroll))
               (rul ".overflow-y-scroll"
                    (dec 'overflow-y
                         'scroll))
               (rul ".cursor-pointer"
                    (dec 'cursor
                         'pointer)))))

(define roundings
  (param (list (rulv ".rounded-~a"
                     #:property 'border-radius
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion to-rem
                                            #:multiplier (rounded-multiplier)))
                                     (append numeric-sizes tshirt-sizes))))))

(define border-style
  (param 'solid))

(define borders
  (param (rulv ".border-~a"
               #:property 'border-width
               #:other-properties `((border-style ,(border-style)))
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-px)) numeric-sizes))))

(define fade-in-page-transition
  (param (list (rul "@view-transition"
                    (dec 'navigation
                         'auto))
               (rul (string-join '("::view-transition-old(root)"
                                   "::view-transition-new(root)") ", ")
                    (dec 'animation "fade 0.1s ease both"))
               (rul "@keyframes fade"
                    (rul 'from
                         (dec 'opacity 0.2))
                    (rul 'to
                         (dec 'opacity 1))))))

(define active-scale
  (param (list (rul ".active\\:scale-95"
                    (rul "&:active"
                         (dec 'scale "95% 95%"))))))

(define license-header
  (param
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
  (param (append (layout-classes)
                 (filter-classes)
                 (flexbox-classes)
                 (spacing-classes)
                 (sizing-classes)
                 (typography-classes)
                 (roundings)
                 (scroll-snap-aligns)
                 (scroll-snap-types))))

(define sm-responsive
  (param (map (lambda (r)
                (addmq 'sm r))
              (responsive-classes))))

(define md-responsive
  (param (map (lambda (r)
                (addmq 'md r))
              (responsive-classes))))

(define lg-responsive
  (param (map (lambda (r)
                (addmq 'lg r))
              (responsive-classes))))

(define xl-responsive
  (param (map (lambda (r)
                (addmq 'xl r))
              (responsive-classes))))

(define 2xl-responsive
  (param (map (lambda (r)
                (addmq "2xl" r))
              (responsive-classes))))

(define responsive
  (param (append (mq "width >= 40rem"
                     (sm-responsive))
                 (mq "width >= 48rem"
                     (md-responsive))
                 (mq "width >= 64rem"
                     (lg-responsive))
                 (mq "width >= 80rem"
                     (xl-responsive))
                 (mq "width >= 96rem"
                     (2xl-responsive)))))

(define* (hss)
  (append (rulc (license-header))
          '("")
          (rulc "Load CSS browser reset - should be first")
          (reset-css)
          '("")
          (rulc "Load HSS Hygge Style Sheets")
          (layout-classes)
          (filter-classes)
          (flexbox-classes)
          (spacing-classes)
          (sizing-classes)
          (typography-classes)
          ;;
          (active-scale)
          (borders)
          (display-utilities)
          (fade-in-page-transition)
          (visibility)
          (roundings)
          (scroll-snap-aligns)
          (scroll-snap-types)
          (shadows)
          '("")
          (rulc "Load HSS colors")
          (colors)
          '("")
          (rulc "Load HSS hover colors")
          (hover-colors)
          (dark-mode)
          '("")
          (rulc "Load responsive classes")
          (responsive)))

