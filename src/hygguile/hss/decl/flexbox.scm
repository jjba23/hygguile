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

(define-module (hygguile hss decl flexbox)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:use-module (hygguile hss sizes)
  #:export (flex-basis flex-justifies
                       flex-align-items
                       flex-align-self
                       flex-align-content
                       flexbox-classes
                       flex-directions
                       gap
                       flex flex-shrink flex-grow
                       gap-multiplier
                       order
                       flex-wrap))

(define gap-multiplier
  (make-parameter 0.3))

(define flex-basis
  (make-parameter (rulv ".basis-~a"
                        #:property 'flex-basis
                        #:variants (append tshirt-sizes numeric-sizes))))

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

(define flex-align-items
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

(define flex-align-self
  (make-parameter (rulv ".self-~a"
                        #:property 'align-self
                        #:variants '((auto auto)
                                     (start flex-start)
                                     (end flex-end)
                                     (end-safe "safe flex-end")
                                     (center center)
                                     (center-safe "safe center")
                                     (baseline baseline)
                                     (baseline-last "last baseline")
                                     (stretch stretch)))))

(define flex-align-content
  (make-parameter (rulv ".content-~a"
                        #:property 'align-content
                        #:variants '((start flex-start)
                                     (end flex-end)
                                     (center center)
                                     (normal normal)
                                     (between space-between)
                                     (around space-around)
                                     (evenly space-evenly)
                                     (baseline baseline)
                                     (stretch stretch)))))

(define flex-directions
  (make-parameter (rulv ".flex-~a"
                        #:property 'flex-direction
                        #:variants '((row row)
                                     (col column)
                                     (row-reverse row-reverse)
                                     (col-reverse column-reverse)))))

(define gap
  (make-parameter (rulv ".gap-~a"
                        #:property 'gap
                        #:variants (map (lambda (s)
                                          (siz s
                                               #:conversion to-rem
                                               #:multiplier (gap-multiplier)))
                                        (append numeric-sizes tshirt-sizes)))))

(define flex-wrap
  (make-parameter (rulv ".flex-~a"
                        #:property 'flex-wrap
                        #:variants '((nowrap nowrap)
                                     (wrap wrap)
                                     (wrap-reverse wrap-reverse)))))

(define flex
  (make-parameter (list (rulv ".flex-~a"
                              #:property 'flex
                              #:variants (map (lambda (s)
                                                (siz s
                                                     #:conversion to-rem))
                                              (append numeric-sizes
                                                      tshirt-sizes )))
                        (rulv ".flex-~a"
                              #:property 'flex
                              #:variants fractions)
                        (rulv ".flex-~a"
                              #:property 'flex
                              #:variants '((initial "0 auto")
                                           (none none)
                                           (auto auto))))))


(define flex-shrink
  (make-parameter (list (rul ".shrink"
                             (dec 'flex-shrink 1))
                        (rul ".shrink-0"
                             (dec 'flex-shrink 0)))))

(define flex-grow
  (make-parameter (list (rul ".grow"
                             (dec 'flex-grow 1))
                        (rul ".grow-0"
                             (dec 'flex-grow 0)))))

(define order
  (make-parameter (rulv ".order-~a"
                        #:property 'order
                        #:variants (append numeric-sizes '((first -9999)
                                                           (last 9999)
                                                           (none 0))))))

(define flexbox-classes
  (make-parameter (list (flex-basis)
                        (flex-justifies)
                        (flex-align-items)
                        (flex-align-self)
                        (flex-directions)
                        (flex-align-content)
                        (flex)
                        (order)
                        (flex-shrink)
                        (flex-grow)
                        (gap)
                        (flex-wrap))))
