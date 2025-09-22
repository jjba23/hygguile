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

(define-module (hygguile hss dsl)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:export (~ css css* css-color* display-css list-combinations))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define* (generate-sized-declarations #:key properties calculated-value unit
                                      (rounded-to-integer? #f))
  "Creates a list of CSS properties from a calculated value."
  (map (lambda (p)
         ;; Formats a string like "width: 10.00px;"
         (format #f
                 (if rounded-to-integer? "~a:~d~a;" "~a:~,2f~a;") p
                 (if rounded-to-integer?
                     (round calculated-value) calculated-value) unit))
       properties))

(define* (generate-static-declarations #:key properties)
  "Creates a list of CSS properties from fixed key-value pairs."
  (map (lambda (op)
         ;; Formats a string like "display: block;"
         (format #f "~a:~a;"
                 (car op)
                 (if (list? (cadr op))
                     (format #f "{~a}"
                             (string-join (generate-static-declarations
                                                                        #:properties
                                                                        (cadr
                                                                         op))
                                          " "))
                     (cadr op)))) properties))

(define* (build-selector #:key selector class size direct-size?)
  "Constructs the CSS selector, adding a size suffix if needed."
  (if direct-size?
      (~ "~a~a-~a" selector class size)
      (~ "~a~a-~a" selector class
         (car size))))

(define* (build-rule-for-size #:key size
                              selector
                              class
                              properties
                              (rounded-to-integer? #f)
                              (other-properties '())
                              multiplier
                              unit
                              (direct-size? #f))
  "Builds a complete CSS rule for a single size element."
  (let* ((sel (build-selector #:selector selector
                              #:class class
                              #:size size
                              #:direct-size? direct-size?))
         (base-value (if direct-size? size
                         (cadr size)))
         (sized-decs (generate-sized-declarations #:properties properties
                                                  #:calculated-value (*
                                                                      multiplier
                                                                      base-value)
                                                  #:rounded-to-integer?
                                                  rounded-to-integer?
                                                  #:unit unit))
         (static-decs (generate-static-declarations #:properties
                                                    other-properties))
         (declarations-string (string-join (append sized-decs static-decs) " ")))
    
    ;; Format the final CSS rule, e.g., ".item-sm { width: 10.00px; }"
    (~ "~a {~a}" sel declarations-string)))

(define* (css #:key class properties
              (selector "."))
  (~ "~a~a {~a}" selector class
     (string-join (generate-static-declarations #:properties properties) " ")))

(define* (css* #:key (selector ".")
               class
               properties
               (other-properties '())
               (direct-size? #f)
               (rounded-to-integer? #f)
               multiplier
               (unit "rem")
               sizes)
  (map (lambda (size)
         (build-rule-for-size #:size size
                              #:selector selector
                              #:class class
                              #:properties properties
                              #:rounded-to-integer? rounded-to-integer?
                              #:other-properties other-properties
                              #:multiplier multiplier
                              #:unit unit
                              #:direct-size? direct-size?)) sizes))

(define (list-combinations list1 list2)
  "Computes all combinations (Cartesian product) of elements from two lists."
  (append-map (lambda (x)
                (map (lambda (y)
                       (list x y)) list2)) list1))

(define* (mk-color #:key alpha-weight
                   palette
                   namespace
                   properties
                   selector
                   class
                   name)
  (let* ((weight-name (caadr alpha-weight))
         (alpha-name (if (equal? ""
                                 (caar alpha-weight)) ""
                         (~ "\\/~a"
                            (caar alpha-weight))))
         (tri-channel (string-join (map (lambda (x)
                                          (~ "~a" x))
                                        (car (assoc-ref palette

                                                        (caadr alpha-weight))))
                                   ", "))
         (color-alpha (if (equal? namespace
                                  'rgba)
                          (~ ",~a"
                             (cadar alpha-weight)) ""))
         (props (string-join (map (lambda (p)
                                    (~ "~a: ~a(~a~a)" p namespace tri-channel
                                       color-alpha)) properties) " ")))
    (~ "~a~a-~a-~a~a { ~a }"
       selector
       class
       name
       weight-name
       alpha-name
       props)))

(define* (css-color* #:key (selector ".")
                     class
                     properties
                     name
                     palette
                     (alphas '())
                     weights
                     (namespace 'rgba))
  (let* ((alphas-and-weights (if (nil? alphas)
                                 (list-combinations '((("" 1))) weights)
                                 (list-combinations alphas weights))))
    
    (map (lambda (alpha-weight)
           (mk-color #:alpha-weight alpha-weight
                     #:palette palette
                     #:namespace namespace
                     #:properties properties
                     #:selector selector
                     #:class class
                     #:name name)) alphas-and-weights)))

(define* (display-css xs)
  (cond
    ((list? xs)
     (for-each display-css xs))
    (else (begin
            (display xs)
            (display "\n")))))
