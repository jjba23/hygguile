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

(define-module (hygguile udtryk udtryk)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile udtryk dsl)
  #:use-module (hygguile udtryk sizes)
  #:use-module (hygguile udtryk reset)
  #:export (font-size-multiplier margin-multiplier
                                 padding-multiplier
                                 gap-multiplier
                                 rounded-multiplier
                                 width-multiplier
                                 weight-multiplier
                                 mono-font-family
                                 sans-font-family
                                 serif-font-family
                                 udtryk))

(define font-size-multiplier
  (make-parameter "0.24rem"))
(define margin-multiplier
  (make-parameter "0.24rem"))
(define padding-multiplier
  (make-parameter "0.24rem"))
(define gap-multiplier
  (make-parameter "0.24rem"))
(define rounded-multiplier
  (make-parameter "0.1rem"))
(define width-multiplier
  (make-parameter "0.4rem"))
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
(define* (udtryk)
  (append reset-css
          (css* #:class 'text
                #:sizes default-tshirt-sizes
                #:properties '(font-size)
                #:multiplier (font-size-multiplier))
          (css* #:class 'rounded
                #:sizes default-tshirt-sizes
                #:properties '(border-radius)
                #:multiplier (rounded-multiplier))
          ;; ====== Paddings ======
          (css* #:class 'p
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
          ;; ====== Margins ======
          (css* #:class 'm
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin)
                #:multiplier (margin-multiplier))
          (css* #:class 'mx
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-left margin-right)
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
                #:multiplier (margin-multiplier))

          ;; ====== Font Weights ======
          (css* #:class 'font
                #:sizes default-weight-sizes
                #:properties '(font-weight)
                #:multiplier (weight-multiplier))

          ;; ====== Flex utilities ======
          (css* #:class 'gap
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
                (css #:class 'items-center
                     #:properties '((align-items center)))
                (css #:class 'justify-center
                     #:properties '((justify-content center))))
          ;; ====== Width ======
          (css* #:class 'max-w
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(max-width)
                #:multiplier (width-multiplier))
          ;; ====== Font utilities ======
          (list (css #:class 'font-sans
                     #:properties `((font-family ,(sans-font-family))))
                (css #:class 'font-mono
                     #:properties `((font-family ,(mono-font-family))))
                (css #:class 'font-serif
                     #:properties `((font-family ,(serif-font-family)))))
          ;; ====== Display utilities ======
          (list (css #:class 'hidden
                     #:properties `((display none)))
                (css #:class 'overflow-x-scroll
                     #:properties '((overflow-x scroll)))
                (css #:class 'italic
                     #:properties `((font-style italic)))
                (css #:class 'text-center
                     #:properties '((text-align center)))
                (css #:class 'cursor-pointer
                     #:properties `((cursor pointer))))))
