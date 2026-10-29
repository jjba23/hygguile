;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components segmented-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components segmented)
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

(define ranges
  '((day . "Day") (week . "Week")
    (month . "Month")))

(define (range-control)
  (segmented-control #:label "Range"
                     #:name "range"
                     #:options ranges
                     #:selected "week"))

(define segmented-suite
  (suite "Segmented controls"
         (test "the control is a named radio group"
               (assert-equal #:name "the component renders a field wrapper"
                             #:got (caar (range-control))
                             #:expect 'div)
               (assert-equal #:name "the group is named by a legend"
                             #:got (has? (render (range-control)) "<legend")
                             #:expect #t)
               (assert-equal #:name "one radio per choice"
                             #:got (count-of (render (range-control))
                                             "type=\"radio\"")
                             #:expect 3)
               (assert-equal #:name "the choices carry the group's name"
                             #:got (count-of (render (range-control))
                                             "name=\"range\"")
                             #:expect 3)
               (assert-equal #:name "the values are the choice values"
                             #:got (has? (render (range-control))
                                         "value=\"month\"")
                             #:expect #t)
               (assert-equal #:name "exactly one choice is chosen"
                             #:got (count-of (render (range-control))
                                             "checked=\"\"")
                             #:expect 1)
               (assert-equal #:name "the chosen choice is the selected value"
                             #:got (has? (render (range-control))
                                         "id=\"range-option-week\"")
                             #:expect #t)
               (assert-equal #:name
                "the first choice is chosen when the page names none"
                #:got (has? (render (segmented-control #:label "Range"
                                                       #:name "range"
                                                       #:options ranges))
                            "checked=\"\"")
                #:expect #t))
         (test "the bar"
               (assert-equal #:name "the choices sit in the bar"
                             #:got (has? (render (range-control))
                                         "hg-segmented ")
                             #:expect #t)
               (assert-equal #:name "the bar takes its width from its choices"
                             #:got (has? (render (range-control)) "w-fit")
                             #:expect #t)
               (assert-equal #:name "a full-width bar stretches"
                             #:got (has? (render (segmented-control #:label
                                                                    "Range"
                                                                    #:name
                                                                    "range"
                                                                    #:options
                                                                    ranges
                                                                    #:full-width?
                                                                    #t))
                                         "w-full")
                             #:expect #t))
         (test "errors and hints"
               (assert-equal #:name "an error is announced"
                             #:got (has? (render (segmented-control #:label
                                                  "Range"
                                                  #:name "range"
                                                  #:options ranges
                                                  #:error "Pick a range"))
                                         "role=\"alert\"")
                             #:expect #t)
               (assert-equal #:name "the helper copy is linked to the group"
                             #:got (has? (render (segmented-control #:label
                                                  "Range"
                                                  #:name "range"
                                                  #:options ranges
                                                  #:help-text "Any is fine"))
                                         "aria-describedby=\"range-help\"")
                             #:expect #t)
               (assert-equal #:name "a required control says so on the group"
                             #:got (has? (render (segmented-control #:label
                                                                    "Range"
                                                                    #:name
                                                                    "range"
                                                                    #:options
                                                                    ranges
                                                                    #:required
                                                                    #t))
                                         "aria-required=\"true\"")
                             #:expect #t))
         (test "the states of the control"
               (assert-equal #:name "a refused control says so on its shell"
                             #:got (has? (render (segmented-control
                                                 #:label "Range"
                                                 #:name "range"
                                                 #:options ranges
                                                 #:error "Pick a range"))
                                         "hg-field-invalid")
                             #:expect #t)
               (assert-equal #:name "an answered control says so on its shell"
                             #:got (has? (render (segmented-control
                                                 #:label "Range"
                                                 #:name "range"
                                                 #:options ranges
                                                 #:valid #t))
                                         "hg-field-valid")
                             #:expect #t))))

(define item-suite
  (suite "Segmented items"
         (test "an item is a label around its own radio"
               (assert-equal #:name
                             "the item is a label pointing at its radio"
                             #:got (has? (render (list (segmented-item #:value
                                                        "week"
                                                        #:label "Week"
                                                        #:name "range"
                                                        #:checked #t)))
                                         "for=\"hg-segmented-option-week\"")
                             #:expect #t)
               (assert-equal #:name "a checked item renders checked"
                             #:got (has? (render (list (segmented-item #:value
                                                        "week"
                                                        #:label "Week"
                                                        #:name "range"
                                                        #:checked #t)))
                                         "checked=\"\"")
                             #:expect #t))))

(define (spec)
  (veritas-run segmented-suite)
  (veritas-run item-suite))
