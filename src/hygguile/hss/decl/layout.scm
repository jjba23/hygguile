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
  #:export (aspect-ratio columns z-index absolute-positions displays visibility))

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
