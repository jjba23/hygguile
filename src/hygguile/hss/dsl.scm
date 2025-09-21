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
  #:export (~ css css* css-color* display-css list-combinations))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define (generate-sized-declarations properties calculated-value unit)
  "Creates a list of CSS properties from a calculated value."
  (map (lambda (p)
         ;; Formats a string like "width: 10.00px;"
         (~ "~a: ~,2f~a;" p calculated-value unit)) properties))

(define (generate-static-declarations other-properties)
  "Creates a list of CSS properties from fixed key-value pairs."
  (map (lambda (op)
         ;; Formats a string like "display: block;"
         (~ "~a: ~a;"
            (car op)
            (cadr op))) other-properties))

(define (build-selector selector class size direct-size?)
  "Constructs the CSS selector, adding a size suffix if needed."
  (if direct-size?
      (~ "~a~a-~a" selector class size)
      (~ "~a~a-~a" selector class (car size))))

(define (build-rule-for-size size
                             selector
                             class
                             properties
                             other-properties
                             multiplier
                             unit
                             direct-size?)
  "Builds a complete CSS rule for a single size element."
  (let* ((sel (build-selector selector class size direct-size?))
         ;; Determine the base value from 's'
         (base-value (if direct-size? size
                         (cadr size)))
         ;; Generate the two types of CSS declarations
         (sized-decs (generate-sized-declarations properties
                                                  (* multiplier base-value)
                                                  unit))
         (static-decs (generate-static-declarations other-properties))
         ;; Combine declarations into one string: "prop1: val; prop2: val;"
         (declarations-string (string-join (append sized-decs static-decs) " ")))
    
    ;; Format the final CSS rule, e.g., ".item-sm { width: 10.00px; }"
    (~ "~a { ~a }" sel declarations-string)))

(define* (css* #:key (selector ".")
               class
               properties
               (other-properties '())
               (direct-size? #f)
               multiplier
               (unit "rem")
               sizes)
  (map (lambda (size)
         (build-rule-for-size size
                              selector
                              class
                              properties
                              other-properties
                              multiplier
                              unit
                              direct-size?)) sizes))

(define (list-combinations list1 list2)
  "Computes all combinations (Cartesian product) of elements from two lists."
  (append-map (lambda (x)
                (map (lambda (y)
                       (list x y)) list2)) list1))

(define* (css-color* #:key (selector ".")
                     class
                     properties
                     name
                     palette
                     (alphas '())
                     weights
                     (namespace 'rgba))
  (let* ((alphas-and-weights ;(list-combinations alphas weights)
                             (if (nil? alphas)
                                 (list-combinations '((("" 1))) weights)
                                 (list-combinations alphas weights))))
    (display "\n==================")
    (write alphas-and-weights)

    (map (lambda (aw)
           (map (lambda (a)
                  (~ "~a~a-~a-~a~a { ~a }"
                     selector
                     class
                     name
                     (caadr aw) ;weight
                     (if (equal? ""
                                 (car a)) ""
                         (~ "\\/~a"
                            (car a))) ;alpha
                     (string-join (map (lambda (p)
                                         (~ "~a: ~a(~a~a)" p namespace
                                            (string-join (map (lambda (x)
                                                                (~ "~a" x))
                                                              (car (assoc-ref
                                                                    palette
                                                                    (caadr aw))))
                                                         ", ")
                                            (if (equal? namespace
                                                        'rgba)
                                                (~ ", ~a"
                                                   (cadr a)) ""))) properties)
                                  " ")

                     ))
                (car aw))) alphas-and-weights)))

(define* (css #:key class properties
              (selector "."))
  (~ "~a~a { ~a }" selector class
     (string-join (map (lambda (p)
                         (~ "~a: ~a;"
                            (car p)
                            (cadr p))) properties) " ")))

(define* (display-css xs)
  (cond
    ((string? xs)
     (display xs)
     (display "\n"))
    ((list? xs)
     (for-each display-css xs))
    (else (display xs))))
