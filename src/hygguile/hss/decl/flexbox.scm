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
  #:export (flex-basis flex-justify-content
                       flex-justify-items
                       flex-justify-self
                       flex-align-items
                       flex-align-self
                       flex-align-content
                       flexbox-classes
                       flex-directions
                       gap
                       flex
                       flex-shrink
                       flex-grow
                       flex-place-content
                       flex-place-items
                       flex-place-self
                       gap-multiplier
                       order
                       flex-wrap))

(define gap-multiplier
  (param 0.3))

(define flex-basis
  (param (rulv ".basis-~a"
               #:property 'flex-basis
               #:variants (append tshirt-sizes numeric-sizes))))

(define flex-justify-content
  (param (rulv ".justify-~a"
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
  (param (rulv ".items-~a"
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
  (param (rulv ".self-~a"
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
  (param (rulv ".content-~a"
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
  (param (rulv ".flex-~a"
               #:property 'flex-direction
               #:variants '((row row)
                            (col column)
                            (row-reverse row-reverse)
                            (col-reverse column-reverse)))))

(define gap
  (param (rulv ".gap-~a"
               #:property 'gap
               #:variants (map (lambda (s)
                                 (siz s
                                      #:conversion to-rem
                                      #:multiplier (gap-multiplier)))
                               (append numeric-sizes tshirt-sizes)))))

(define flex-wrap
  (param (rulv ".flex-~a"
               #:property 'flex-wrap
               #:variants '((nowrap nowrap)
                            (wrap wrap)
                            (wrap-reverse wrap-reverse)))))

(define flex
  (param (list (rulv ".flex-~a"
                     #:property 'flex
                     #:variants (map (lambda (s)
                                       (siz s
                                            #:conversion to-rem))
                                     (append numeric-sizes tshirt-sizes)))
               (rulv ".flex-~a"
                     #:property 'flex
                     #:variants fractions)
               (rulv ".flex-~a"
                     #:property 'flex
                     #:variants '((initial "0 auto")
                                  (none none)
                                  (auto auto))))))

(define flex-shrink
  (param (list (rul ".shrink"
                    (dec 'flex-shrink 1))
               (rul ".shrink-0"
                    (dec 'flex-shrink 0)))))

(define flex-grow
  (param (list (rul ".grow"
                    (dec 'flex-grow 1))
               (rul ".grow-0"
                    (dec 'flex-grow 0)))))

(define order
  (param (rulv ".order-~a"
               #:property 'order
               #:variants (append numeric-sizes
                                  '((first -9999)
                                    (last 9999)
                                    (none 0))))))

(define flex-place-content
  (param (rulv ".place-content-~a"
               #:property 'place-content
               #:variants '((center center)
                            (center-safe "safe center")
                            (start start)
                            (end end)
                            (end-safe "safe end")
                            (between space-between)
                            (around space-around)
                            (evenly space-evenly)
                            (baseline baseline)
                            (stretch stretch)))))

(define flex-place-items
  (param (rulv ".place-items-~a"
               #:property 'place-items
               #:variants '((start start)
                            (end end)
                            (end-safe "safe end")
                            (center center)
                            (center-safe "safe center")
                            (baseline baseline)
                            (stretch stretch)))))

(define flex-place-self
  (param (rulv ".place-self-~a"
               #:property 'place-self
               #:variants '((auto auto)
                            (start start)
                            (end end)
                            (end-safe "safe end")
                            (center center)
                            (center-safe "safe center")
                            (stretch stretch)))))

(define flex-justify-items
  (param (rulv ".justify-items-~a"
               #:property 'justify-items
               #:variants '((start start)
                            (end end)
                            (end-safe "safe end")
                            (center center)
                            (center-safe "safe center")
                            (stretch stretch)
                            (normal normal)))))

(define flex-justify-self
  (param (rulv ".justify-self-~a"
               #:property 'justify-self
               #:variants '((auto auto)
                            (start start)
                            (center center)
                            (center-safe "safe center")
                            (end end)
                            (end-safe "safe end")
                            (stretch stretch)))))

(define flexbox-classes
  (param (list (flex-basis)
               (flex-place-content)
               (flex-place-items)
               (flex-place-self)
               (flex-justify-content)
               (flex-justify-items)
               (flex-justify-self)
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
