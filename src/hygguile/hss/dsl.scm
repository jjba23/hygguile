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
  #:use-module (srfi srfi-9)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 format)
  #:export (~ css-color*
              format-css
              list-combinations
              where-dark
              ;;
              rulc
              rule
              make-rule
              rule?
              rule-selector
              rule-declarations
              declaration
              make-declaration
              declaration?
              declaration-property
              declaration-value
              rul

              dec
              flatten-list
              rulv
              siz
              to-rem
              to-px
              compose
              ;;
              ))

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define (flatten-list xs)
  (cond
    ((null? xs)
     '())
    ((pair? xs)
     (append (flatten-list (car xs))
             (flatten-list (cdr xs))))
    (else (list xs))))

(define (compose f g)
  (lambda (x)
    (f (g x))))

;; ========================================================================

(define-record-type rule
  (make-rule selector declarations) rule?
  (selector rule-selector)
  (declarations rule-declarations))

(define* (rul selector . args)
  (make-rule selector
             (flatten-list args)))

(define-record-type declaration
  (make-declaration property value) declaration?
  (property declaration-property)
  (value declaration-value))

(define dec
  make-declaration)

(define* (rulv selector
               #:key property variants
               (other-properties '()))
  (map (lambda (v)
         (rul (format #f selector
                      (car v))

              (append (map (lambda (p)
                             (dec (car p)
                                  (cadr p))) other-properties)
                      (list (dec property
                                 (cadr v))))

              )) variants))

(define* (rulc msg)
  (list (format #f "/*\n  ~a\n*/" msg)))

(define* (siz s
              #:key (conversion identity)
              (multiplier 1))
  (list (car s)
        (conversion (* (cadr s) multiplier))))

(define (to-rem x)
  (format #f "~,2frem" x))

(define (to-px x)
  (format #f "~,2fpx" x))

;; ========================================================================

(define (list-combinations list1 list2)
  "Computes all combinations (Cartesian product) of elements from two lists."
  (append-map (lambda (x)
                (map (lambda (y)
                       (list x y)) list2)) list1))

(define* (mk-color #:key alpha-weight
                   palette
                   namespace
                   declarations
                   selector-type
                   selector
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
                                   ","))
         (color-alpha (if (equal? namespace
                                  'rgba)
                          (~ ",~a"
                             (cadar alpha-weight)) ""))
         (prop (string-join (map (lambda (p)
                                   (~ "~a:~a(~a~a)" p namespace tri-channel
                                      color-alpha)) declarations) " ")))
    (list (~ "~a~a-~a-~a~a{~a}"
             selector-type
             selector
             name
             weight-name
             alpha-name
             prop)
          (~ "~adark\\:~a-~a-~a~a{~a{~a}}"
             selector-type
             selector
             name
             weight-name
             alpha-name
             where-dark
             (~ "~a !important" prop)))))

(define* (css-color* #:key (selector-type ".")
                     selector
                     declarations
                     name
                     palette
                     (alphas '())
                     weights
                     (namespace 'rgba))
  (let* ((alphas-and-weights (if (nil? alphas)
                                 (list-combinations '((("" 1))) weights)
                                 (list-combinations alphas weights))))
    
    (append-map (lambda (alpha-weight)
                  (mk-color #:alpha-weight alpha-weight
                            #:palette palette
                            #:namespace namespace
                            #:declarations declarations
                            #:selector-type selector-type
                            #:selector selector
                            #:name name)) alphas-and-weights)))

(define* (format-css xs)
  (cond
    ((list? xs)
     (map format-css xs))
    ((rule? xs)
     (format #f "~a {~a}"
             (rule-selector xs)
             (cond
               ((rule? (rule-declarations xs))
                (format-css (rule-declarations xs)))
               ((list? (rule-declarations xs))
                (string-join (map (lambda (xx)
                                    (cond
                                      ((rule? xx)
                                       (format-css xx))
                                      ((declaration? xx)
                                       (format-declaration xx))
                                      (else (format #f "~a" xx)))

                                    )
                                  (rule-declarations xs)) " "))
               (else (begin
                       (format-declaration (rule-declarations xs)))))))
    ((declaration? xs)
     (format-declaration xs))
    (else (format #f "~a" xs))))

(define (format-declaration xs)
  (format #f "~a:~a;"
          (declaration-property xs)
          (declaration-value xs)))

(define where-dark
  "&:where([data-theme=dark], [data-theme=dark] *)")
