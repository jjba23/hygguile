;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components rating-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components rating)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define (count-of html needle)
  "Count how many times NEEDLE appears in HTML."
  (let loop
    ((start 0)
     (found 0))
    (let ((hit (string-contains html needle start)))
      (if hit
          (loop (+ hit
                   (string-length needle))
                (+ found 1)) found))))

(define rating-suite
  (suite "Ratings"
         (test "a rating is a radio group"
               (assert-equal #:name "the component renders a field wrapper"
                             #:got (caar (rating #:label "Score"
                                                 #:name "score"))
                             #:expect 'div)
               (assert-equal #:name "the group is named by a legend"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"))
                                         "<legend")
                             #:expect #t)
               (assert-equal #:name "the stars are radios, one per star"
                             #:got (count-of (render (rating #:label "Score"
                                                             #:name "score"))
                                             "type=\"radio\"")
                             #:expect 5)
               (assert-equal #:name "a rating of three stars has three"
                             #:got (count-of (render (rating #:label "Score"
                                                             #:name "score"
                                                             #:max 3))
                                             "type=\"radio\"")
                             #:expect 3)
               (assert-equal #:name "exactly one star is checked"
                             #:got (count-of (render (rating #:label "Score"
                                                             #:name "score"
                                                             #:value 2))
                                             "checked=\"\"")
                             #:expect 1)
               (assert-equal #:name
                             "the checked star is the value the page gave"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:value 2))
                                         "id=\"score-star-2\"")
                             #:expect #t)
               (assert-equal #:name
                             "every star names itself for a screen reader"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"))
                                         "3 of 5")
                             #:expect #t)
               (assert-equal #:name
                             "a rating above its own maximum is clamped"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:value 9))
                                         "id=\"score-star-5\"")
                             #:expect #t))
         (test "a rating that has to be given"
               (assert-equal #:name "a required rating says so on the group"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:required #t))
                                         "aria-required=\"true\"")
                             #:expect #t)
               (assert-equal #:name "a required rating marks the legend"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:required #t))
                                         "sr-only\"> (required)")
                             #:expect #t))
         (test "a rating that was answered"
               (assert-equal #:name "a wrong rating says so on its shell"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:error "Pick a star"))
                                         "hg-field-invalid")
                             #:expect #t)
               (assert-equal #:name "an answered rating says so on its shell"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:value 4
                                                         #:valid "Thanks!"))
                                         "hg-field-valid")
                             #:expect #t)
               (assert-equal #:name "an answered rating can say so in words"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:value 4
                                                         #:valid "Thanks!"))
                                         "hg-success-message")
                             #:expect #t))
         (test "errors and hints"
               (assert-equal #:name "an error is announced"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:error "Pick a star"))
                                         "role=\"alert\"")
                             #:expect #t)
               (assert-equal #:name "the helper copy is linked to the group"
                             #:got (has? (render (rating #:label "Score"
                                                         #:name "score"
                                                         #:help-text
                                                         "Be honest"))
                                         "aria-describedby=\"score-help\"")
                             #:expect #t))
         (test "a score nobody can change"
               (assert-equal #:name "a read-only rating has no radios"
                             #:got (count-of (render (rating #:label "Average"
                                                             #:name "avg"
                                                             #:value 4
                                                             #:readonly #t))
                                             "type=\"radio\"")
                             #:expect 0)
               (assert-equal #:name
                             "a read-only rating states its score in words"
                             #:got (has? (render (rating #:label "Average"
                                                         #:name "avg"
                                                         #:value 4
                                                         #:readonly #t))
                                         "aria-label=\"4 out of 5\"")
                             #:expect #t)
               (assert-equal #:name
                             "a read-only rating fills exactly its score"
                             #:got (count-of (render (rating #:label "Average"
                                                             #:name "avg"
                                                             #:value 4
                                                             #:readonly #t))
                                             "hg-star-on")
                             #:expect 4)
               (assert-equal #:name
                             "the stars a score does not reach stay empty"
                             #:got (count-of (render (rating #:label "Average"
                                                             #:name "avg"
                                                             #:value 4
                                                             #:readonly #t))
                                             "hg-star-off")
                             #:expect 1)
               (assert-equal #:name
                             "the stars are text, so a reader can count them"
                             #:got (has? (render (rating #:label "Average"
                                                         #:name "avg"
                                                         #:value 1
                                                         #:readonly #t)) "★")
                             #:expect #t))))

(define (spec)
  (veritas-run rating-suite))
