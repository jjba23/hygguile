;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components feedback-extras-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components feedback)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define feedback-extras-suite
  (suite "Feedback extras"
         (test "toasts"
               (assert-equal #:name "a toast is a live region"
                             #:got (has? (render (toast #:title "Saved"))
                                         "role=\"status\"")
                             #:expect #t)
               (assert-equal #:name "a danger toast is announced assertively"
                             #:got (has? (render (toast #:title "Failed"
                                                        #:variant 'danger))
                                         "role=\"alert\"")
                             #:expect #t)
               (assert-equal #:name "the tray owns one polite region"
                             #:got (has? (render (toast-tray))
                                         "data-hg-toast-tray")
                             #:expect #t)
               (assert-equal #:name "the tray carries a template"
                             #:got (has? (render (toast-tray))
                                         "<template")
                             #:expect #t))
         (test "circular progress"
               (assert-equal #:name "the ring is a progressbar"
                             #:got (has? (render (circular-progress #:value 40 #:label "L"))
                                         "role=\"progressbar\"")
                             #:expect #t)
               (assert-equal #:name "the ring states its value"
                             #:got (has? (render (circular-progress #:value 40))
                                         "aria-valuenow=\"40\"")
                             #:expect #t)
               (assert-equal #:name "an indeterminate ring has no value"
                             #:got (has? (render (circular-progress))
                                         "aria-valuenow")
                             #:expect #f))
         (test "empty and error states"
               (assert-equal #:name "empty state renders a heading"
                             #:got (has? (render (empty-state #:title "Nothing"))
                                         "<h3")
                             #:expect #t)
               (assert-equal #:name "error state offers a retry"
                             #:got (has? (render (error-state))
                                         "Try again")
                             #:expect #t)
               (assert-equal #:name "error state folds technical details"
                             #:got (has? (render (error-state #:details "trace"))
                                         "Technical details")
                             #:expect #t))
         (test "per-component skeletons"
               (assert-equal #:name "a card skeleton is one card"
                             #:got (caar (skeleton-card))
                             #:expect 'div)
               (assert-equal #:name "a table skeleton draws its columns"
                             #:got (has? (render (skeleton-table #:rows 2 #:columns 3))
                                         "hg-skeleton-table")
                             #:expect #t)
               (assert-equal #:name "a form skeleton draws one field per request"
                             #:got (length (cddr (car (skeleton-form #:fields 2))))
                             #:expect 2))))

(define (spec)
  (veritas-run feedback-extras-suite))
