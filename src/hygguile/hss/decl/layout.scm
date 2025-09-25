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

(define-module (hygguile hss decl layout)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (aspect-ratio columns
                         z-index
                         absolute-positions
                         displays
                         visibility
                         box-decoration-break
                         float
                         clear
                         isolation
                         object-fit
                         object-position
                         overflow
                         overflow-x
                         overflow-y
                         overscroll-behavior
                         overscroll-behavior-x
                         overscroll-behavior-y
                         position
                         layout-classes))

(define absolute-positions-multiplier
  (make-parameter 0.4))

(define aspect-ratio
  (make-parameter (rulv ".aspect-~a"
                        #:property 'aspect-ratio
                        #:variants '((square "1 / 1")
                                     (auto auto)
                                     ("16\\/9" "16 / 9")
                                     ("16\\/10" "16 / 10")
                                     ("4\\/3" "4 / 3")))))

(define columns
  (make-parameter (rulv ".columns-~a"
                        #:property 'columns
                        #:variants (append tshirt-sizes numeric-sizes))))

(define z-index
  (make-parameter (rulv ".z-~a"
                        #:property 'z-index
                        #:variants numeric-sizes)))

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
                                                       numeric-sizes)
                                                  (map siz fractions))))
                       '(top bottom left right)))

  )

(define displays
  (make-parameter (rulv ".~a"
                        #:property 'display
                        #:variants '((inline inline)
                                     (block block)
                                     (inline-block inline-block)
                                     (flow-root flow-root)
                                     (flex flex)
                                     (inline-flex inline-flex)
                                     (grid grid)
                                     (inline-grid inline-grid)
                                     (contents contents)
                                     (table table)
                                     (inline-table inline-table)
                                     (table-caption table-caption)
                                     (table-cell table-cell)
                                     (table-column table-column)
                                     (table-column-group table-column-group)
                                     (table-footer-group table-footer-group)
                                     (table-header-group table-header-group)
                                     (table-row-group table-row-group)
                                     (table-row table-row)
                                     (list-item list-item)
                                     (hidden "none !important")))))

(define visibility
  (make-parameter (rulv ".~a"
                        #:property 'visibility
                        #:variants '((visible visible)
                                     (invisible invisible)
                                     (collapse collapse)))))

(define overflow
  (make-parameter (rulv ".overflow-~a"
                        #:property 'overflow
                        #:variants '((auto auto)
                                     (hidden hidden)
                                     (clip clip)
                                     (visible visible)
                                     (scroll scroll)))))

(define overflow-x
  (make-parameter (rulv ".overflow-x-~a"
                        #:property 'overflow-x
                        #:variants '((auto auto)
                                     (hidden hidden)
                                     (clip clip)
                                     (visible visible)
                                     (scroll scroll)))))

(define overflow-y
  (make-parameter (rulv ".overflow-y-~a"
                        #:property 'overflow-y
                        #:variants '((auto auto)
                                     (hidden hidden)
                                     (clip clip)
                                     (visible visible)
                                     (scroll scroll)))))

(define overscroll-behavior
  (make-parameter (rulv ".overscroll-~a"
                        #:property 'overscroll-behavior
                        #:variants '((auto auto)
                                     (contain contain)
                                     (none none)))))

(define overscroll-behavior-x
  (make-parameter (rulv ".overscroll-x-~a"
                        #:property 'overscroll-behavior-x
                        #:variants '((auto auto)
                                     (contain contain)
                                     (none none)))))

(define overscroll-behavior-y
  (make-parameter (rulv ".overscroll-y-~a"
                        #:property 'overscroll-behavior-y
                        #:variants '((auto auto)
                                     (contain contain)
                                     (none none)))))

(define box-decoration-break
  (make-parameter (rulv ".box-decoration-~a"
                        #:property 'box-decoration-break
                        #:variants '((clone clone)
                                     (slice slice)))))

(define box-sizing
  (make-parameter (rulv ".box-~a"
                        #:property 'box-sizing
                        #:variants '((border border-box)
                                     (content content-box)))))

(define float
  (make-parameter (rulv ".float-~a"
                        #:property 'float
                        #:variants '((right right)
                                     (left left)
                                     (start inline-start)
                                     (end inline-end)
                                     (none none)))))

(define clear
  (make-parameter (rulv ".clear-~a"
                        #:property 'clear
                        #:variants '((left left)
                                     (right right)
                                     (both both)
                                     (start inline-start)
                                     (end inline-end)
                                     (none none)))))

(define isolation
  (make-parameter (rulv ".~a"
                        #:property 'isolation
                        #:variants '((isolate isolate)
                                     (isolation-auto auto)))))

(define object-fit
  (make-parameter (rulv ".object-~a"
                        #:property 'object-fit
                        #:variants '((contain contain)
                                     (cover cover)
                                     (fill fill)
                                     (none none)
                                     (scale-down scale-down)))))

(define object-position
  (make-parameter (rulv ".object-~a"
                        #:property 'object-position
                        #:variants '((top-left "top left")
                                     (top top)
                                     (top-right "top right")
                                     (left left)
                                     (center center)
                                     (right right)
                                     (bottom-left "bottom left")
                                     (bottom bottom)
                                     (bottom-right "bottom right")))))

(define position
  (make-parameter (rulv ".~a"
                        #:property 'position
                        #:variants '((absolute absolute)
                                     (fixed fixed)
                                     (relative relative)
                                     (sticky sticky)
                                     (static static)))))

(define layout-classes
  (make-parameter (list (aspect-ratio)
                        (columns)
                        (object-fit)
                        (object-position)
                        (absolute-positions)
                        (displays)
                        (float)
                        (clear)
                        (overflow)
                        (overflow-x)
                        (overflow-y)
                        (overscroll-behavior)
                        (overscroll-behavior-x)
                        (overscroll-behavior-y)
                        (box-decoration-break)
                        (box-sizing)
                        (isolation)
                        (position)
                        (z-index))))
