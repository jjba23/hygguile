;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components layout-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components layout)
  #:use-module (hygguile components typography)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define layout-suite
  (suite "Layout"
         (test "layout primitives"
               (assert-equal #:name "stack renders a <div>"
                             #:got (caar (stack (list (p "a"))))
                             #:expect 'div)
               (assert-equal #:name "grid renders a <div>"
                             #:got (caar (grid (list (p "a"))))
                             #:expect 'div)
               (assert-equal #:name "split renders a <div>"
                             #:got (caar (split #:start (list (p "a"))
                                                #:end (list (p "b"))))
                             #:expect 'div)
               (assert-equal #:name "aspect-ratio writes its ratio"
                             #:got (and (string-contains (render (aspect-ratio
                                                                 (list (p "a"))
                                                                 #:ratio 'video))
                                                         "aspect-ratio: 16 / 9")
                                        #t)
                             #:expect #t))))

(define (spec)
  (veritas-run layout-suite))
