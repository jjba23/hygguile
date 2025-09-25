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

(define-module (hygguile hss decl typography)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (typography-classes font-family
                               mono-font-family
                               text-wrap
                               text-underline-offset
                               text-transform
                               font-smoothing
                               white-space
                               sans-font-family
                               serif-font-family
                               font-variant-numeric
                               word-break
                               text-decoration-style
                               list-style-type
                               text-overflow
                               overflow-wrap
                               hyphens
                               font-stretch
                               weight-multiplier
                               text-decoration-line
                               letter-spacing
                               line-clamp
                               font-size-multiplier
                               font-style
                               font-weight
                               font-size
                               leading
                               line-height-multiplier
                               list-style-position
                               text-align))

(define mono-font-family
  (param "'IBM Plex Mono', monospace"))
(define serif-font-family
  (param "'IBM Plex Serif', ui-serif, serif, 'Times New Roman'"))
(define sans-font-family
  (param (string-join '("'IBM Plex Sans', ui-sans-serif, system-ui, sans-serif,"
                        "'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'")
                      " ")))

(define font-size-multiplier
  (param 0.25))

(define line-height-multiplier
  (param 0.25))

(define weight-multiplier
  (param 1))

(define font-weight
  (param (rulv ".font-~a"
               #:property 'font-weight
               #:variants weights)))

(define font-size
  (param (rulv ".text-~a"
               #:property 'font-size
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem
                                      #:multiplier (font-size-multiplier)))
                               (append tshirt-sizes numeric-sizes)))))

(define font-family
  (param (list (rul ".font-sans"
                    (dec 'font-family
                         (sans-font-family)))
               (rul ".font-mono"
                    (dec 'font-family
                         (mono-font-family)))
               (rul ".font-serif"
                    (dec 'font-family
                         (serif-font-family))))))

(define text-align
  (param (rulv ".text-~a"
               #:property 'text-align
               #:variants '((center center)
                            (left left)
                            (right right)
                            (justify justify)
                            (start start)
                            (end end)))))

(define letter-spacing
  (param (rulv ".tracking-~a"
               #:property 'letter-spacing
               #:variants trackings)))

(define font-style
  (param (list (rul ".italic"
                    (dec 'font-style
                         'italic))
               (rul ".not-italic"
                    (dec 'font-style
                         'normal)))))

(define font-smoothing
  (param (list (rul ".antialiased"
                    (dec "-webkit-font-smoothing" "antialiased")
                    (dec "-moz-osx-font-smoothing" "grayscale"))
               (rul ".subpixel-antialiased"
                    (dec "-webkit-font-smoothing" "auto")
                    (dec "-moz-osx-font-smoothing" "auto")))))

(define font-stretch
  (param (rulv ".font-stretch-~a"
               #:property 'font-stretch
               #:variants stretches)))

(define font-variant-numeric
  (param (rulv ".~a"
               #:property 'font-variant-numeric
               #:variants numeric-variants)))

(define line-clamp
  (param (rulv ".line-clamp-~a"
               #:property "-webkit-line-clamp"
               #:other-properties '((overflow hidden)
                                    (display "-webkit-box")
                                    ("-webkit-box-orient" vertical))
               #:variants numeric-sizes)))

(define leading
  (param (list (rul ".leading-none"
                    (dec 'line-height 1))
               (rulv ".leading-~a"
                     #:property 'line-height
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion to-rem
                                            #:multiplier (line-height-multiplier)))
                                     (append tshirt-sizes numeric-sizes))))))

(define list-style-type
  (param (list (rulv ".list-~a"
                     #:property 'list-style-type
                     #:variants '((disc disc)
                                  (decimal decimal)
                                  (none none))))))

(define list-style-position
  (param (list (rulv ".list-~a"
                     #:property 'list-style-position
                     #:variants '((inside inside)
                                  (outside outside))))))

(define text-decoration-line
  (param (rulv ".~a"
               #:property 'text-decoration-line
               #:variants '((underline underline)
                            (overline overline)
                            (line-through line-through)
                            (no-underline none)))))

(define text-decoration-style
  (param (rulv ".decoration-~a"
               #:property 'text-decoration-style
               #:variants '((solid solid)
                            (double double)
                            (dotted dotted)
                            (dashed dashed)
                            (wavy wavy)))))

(define text-underline-offset
  (param (list (rul ".underline-offset-auto"
                    (dec 'text-underline-offset
                         'auto))
               (rulv ".underline-offset-~a"
                     #:property 'text-underline-offset
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion to-rem
                                            #:multiplier (line-height-multiplier)))
                                     (append tshirt-sizes numeric-sizes))))))

(define text-transform
  (param (rulv ".~a"
               #:property 'text-transform
               #:variants '((uppercase uppercase)
                            (lowercase lowercase)
                            (capitalize capitalize)
                            (normal-case none)))))

(define text-overflow
  (param (list (rul ".truncate"
                    (dec 'overflow
                         'hidden)
                    (dec 'text-overflow
                         'ellipsis)
                    (dec 'white-space
                         'nowrap))
               (rul ".text-ellipsis"
                    (dec 'text-overflow
                         'ellipsis))
               (rul ".text-clip"
                    (dec 'text-overflow
                         'clip)))))

(define text-wrap
  (param (rulv ".text-~a"
               #:property 'text-wrap
               #:variants '((wrap wrap)
                            (nowrap nowrap)
                            (balance balance)
                            (pretty pretty)))))

(define white-space
  (param (rulv ".whitespace-~a"
               #:property 'white-space
               #:variants '((normal normal)
                            (nowrap nowrap)
                            (pre pre)
                            (pre-line pre-line)
                            (pre-wrap pre-wrap)
                            (break-spaces break-spaces)))))

(define word-break
  (param (rulv ".break-~a"
               #:property 'word-break
               #:variants '((normal normal)
                            (all break-all)
                            (keep keep-all)))))

(define overflow-wrap
  (param (rulv ".wrap-~a"
               #:property 'overflow-wrap
               #:variants '((break-word break-word)
                            (anywhere anywhere)
                            (normal normal)))))

(define hyphens
  (param (rulv ".hyphens-~a"
               #:property 'hyphens
               #:variants '((none none)
                            (manual manual)
                            (auto auto)))))

(define typography-classes
  (param (list (font-family)
               (font-weight)
               (font-size)
               (font-style)
               (text-align)
               (font-stretch)
               (font-smoothing)
               (line-clamp)
               (leading)
               (list-style-type)
               (list-style-position)
               (font-variant-numeric)
               (list-style-type)
               (text-decoration-line)
               (text-decoration-style)
               (text-underline-offset)
               (text-transform)
               (text-overflow)
               (text-wrap)
               (white-space)
               (word-break)
               (overflow-wrap)
               (hyphens)
               (letter-spacing))))
