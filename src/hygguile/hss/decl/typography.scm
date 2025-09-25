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
                               font-smoothing
                               sans-font-family
                               serif-font-family
                               font-variant-numeric
                               font-stretch
                               weight-multiplier
                               letter-spacing
                               line-clamp
                               font-size-multiplier
                               font-style
                               font-weight
                               font-size
                               leading
                               line-height-multiplier
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
  (param (list (rul ".leading-none" (dec 'line-height 1))
               (rulv ".leading-~a"
                     #:property 'line-height
                     #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem
                                      #:multiplier (line-height-multiplier)))
                               (append tshirt-sizes numeric-sizes))))))

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
               (font-variant-numeric)
               (letter-spacing))))
