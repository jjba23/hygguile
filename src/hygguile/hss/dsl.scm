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
  #:export (~ format-css
              list-combinations
              where-dark
              lighten-oklch
              identity-oklch
              darken-oklch
              make-palette
              ;;
              rulc
              rule
              mq
              addmq
              addhover
              make-rule
              rule?
              set-rule-selector!
              rule-selector
              rule-declarations
              declaration
              make-declaration
              declaration?
              declaration-property
              declaration-value
              rul
              rulcol
              dec
              flatten-list
              rulv
              siz
              to-rem
              to-px
              to-rem-blur
              to-percent
              to-percent-f
              param
              ;;
              ))

(define param
  make-parameter)

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

(define (darken-oklch xs n)
  (append (list (let* ((comp (- (car xs) n)))
                  (if (< comp 0) 0
                      (string->number (format #f "~,5f" comp)))))
          (cdr xs)))

(define (lighten-oklch xs n)
  (append (list (let* ((comp (+ n
                                (car xs))))
                  (if (>= comp 1) 1
                      (string->number (format #f "~,5f" comp)))))
          (cdr xs)))

(define (identity-oklch oklch some)
  oklch)

(define* (make-palette oklch
                       #:key (transformers (list (list 100 lighten-oklch 0.1)
                                                 (list 300 lighten-oklch 0.05)
                                                 (list 500 identity-oklch 0)
                                                 (list 700 darken-oklch 0.05)
                                                 (list 900 darken-oklch 0.1))))
  (map (lambda (t)
         (list (car t)
               (apply (cadr t)
                      (list oklch
                            (caddr t))))) transformers))

(define-record-type rule
  (make-rule selector declarations) rule?
  (selector rule-selector set-rule-selector!)
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

(define (addmq sel args)
  
  (cond
    ((rule? args)
     (let* ((a args)
            (selector (rule-selector a))
            (str (if (equal? "."
                             (string-take selector 1))
                     (format #f ".~a\\:~a" sel
                             (string-drop selector 1)) selector)))
       (rul str
            (rule-declarations a))))
    ((list? args)
     (map (lambda (a)
            (addmq sel a)) args))
    (else args)))

(define (addhover sel args)
  (cond
    ((rule? args)
     (let* ((a args)
            (selector (rule-selector a))
            (str (if (equal? "."
                             (string-take selector 1))
                     (format #f ".~a\\:~a" sel
                             (string-drop selector 1)) selector))
            (rd (rul "&:hover"
                     (rule-declarations a))))
       (rul str rd)))
    ((list? args)
     (map (lambda (a)
            (addhover sel a)) args))
    (else args)))

(define* (rulcol selector
                 #:key property
                 variants
                 (other-properties '())
                 (palettes '()))
  (map (lambda (palette)
         (map (lambda (alpha-weight)
                (rul (format #f selector
                             (car palette)
                             (caadr alpha-weight)
                             (if (and (not (equal? ""
                                                   (caar alpha-weight)))
                                      (not (equal? #f
                                                   (caar alpha-weight))))
                                 (format #f "\\/~a"
                                         (caar alpha-weight)) ""))

                     (append (map (lambda (p)
                                    (dec (car p)
                                         (cadr p))) other-properties)
                             (list (dec property
                                        (apply format
                                               (append (list #f
                                                        "oklch(~a ~a ~a / ~a)")
                                                       (car (assoc-ref palette
                                                             (caadr
                                                              alpha-weight)))
                                                       (list (cadar
                                                              alpha-weight)))))))

                     )) variants)) palettes))

(define* (siz s
              #:key (conversion identity)
              (multiplier 1))
  (list (car s)
        (conversion (cond
                      ((number? (cadr s))
                       (* (cadr s) multiplier))
                      ((string? (cadr s))
                       (cadr s))
                      (else (cadr s))))))

(define (to-rem x)
  (format #f "~,2frem" x))

(define (to-px x)
  (format #f "~,2fpx" x))

(define (to-percent x)
  (format #f "~,2f%" x))

(define (to-rem-blur x)
  (format #f "blur(~,2frem)" x))

(define (to-percent-f f)
  (lambda (x)
    (format #f "~a(~,2f%)" f x)))

(define (list-combinations list1 list2)
  "Computes all combinations (Cartesian product) of elements from two lists."
  (append-map (lambda (x)
                (map (lambda (y)
                       (list x y)) list2)) list1))

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

(define* (mq query . args)
  (append (list (format #f "@media (~a) {" query)) args
          '("}")))
