;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components code-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components code)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (count-children elements tag)
  "How many elements named TAG the siblings in ELEMENTS render.

ELEMENTS may be an improper list, since a node's attribute list ends in the
value of its last pair rather than in the empty list."
  (let loop
    ((rest elements)
     (count 0))
    (cond
      ((pair? rest)
       (loop (cdr rest)
             (+ count
                (count-tag (car rest) tag))))
      (else count))))

(define (count-tag node tag)
  "How many elements named TAG NODE renders, however deeply they are nested.

NODE is either a node -- a list headed by the element's name -- or a
fragment, a list of nodes, which is how a component returns its markup."
  (cond
    ((not (pair? node)) 0)
    ((symbol? (car node))
     (+ (if (eq? tag (car node)) 1 0)
        (count-children (cdr node) tag)))
    (else (count-children node tag))))

(define (render node)
  "Serialize an SXML fragment to an HTML string, as a page would be served."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (attr-value node name)
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (has-attribute? html text)
  "True when the rendered HTML carries TEXT."
  (and (string-contains html text) #t))

(define code-suite
  (suite "Code samples"
         (test "hygguile pretty-code and code-sample"
               (assert-equal #:name
                             "pretty-code spells a quoted form the short way"
                             #:got (has-attribute? (pretty-code '(button "Save"
                                                                          #:size
                                                                          '(text-sm)))
                                                   "'(text-sm)")
                             #:expect #t)
               (assert-equal #:name
                             "pretty-code leaves a form that fits on one line"
                             #:got (pretty-code '(button "Save"))
                             #:expect "(button \"Save\")")
               (assert-equal #:name
                             "pretty-code wraps a form that would run past the column width"
                             #:got (> (length (string-split (pretty-code
                                                             '(button "Save"
                                                                      #:on-click
                                                                      "hygguileSave()"
                                                                      #:extra-classes
                                                                      '(rounded-lg
                                                                        shadow-sm
                                                                        py-2)))
                                                           #\newline))
                                      1)
                             #:expect #t)
               (assert-equal #:name
                             "code-sample sets the source in the mono face it is code in"
                             #:got (has-attribute? (render (code-sample '(button
                                                                          "Save")))
                                                   "font-mono")
                             #:expect #t)
               (assert-equal #:name "code-sample renders a <div> card"
                             #:got (caar (code-sample '(button "Save")))
                             #:expect 'div)
               (assert-equal #:name
                             "code-sample renders the specimen and both its controls"
                             #:got (count-tag (code-sample '(button "Save"))
                                              'button)
                             #:expect 3)
               (assert-equal #:name
                             "code-sample renders the source in one <pre>"
                             #:got (count-tag (code-sample '(button "Save"))
                                              'pre)
                             #:expect 1)
               (assert-equal #:name
                             "code-sample shows the form pretty-printed"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")))
                                                   "(button \"Save\")")
                             #:expect #t)
               (assert-equal #:name "a code-sample panel starts hidden"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")))
                                                   " hidden=")
                             #:expect #t)
               (assert-equal #:name
                             "the fold control names the panel it opens"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")
                                                                         #:id
                                                                         "sample"))
                                                   "aria-controls=\"sample-panel\"")
                             #:expect #t)
               (assert-equal #:name
                             "the copy button names the <pre> the copy script reads"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")
                                                                         #:id
                                                                         "sample"))
                                                   "hygguileCopyPreInnerText('sample')")
                             #:expect #t)
               (assert-equal #:name
                             "the panel carries the class the noscript stylesheet reveals"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")))
                                                   "hg-code-sample-panel")
                             #:expect #t)
               (assert-equal #:name
                             "an already-rendered value replaces the evaluated form"
                             #:got (has-attribute? (render (code-sample '(button
                                                                           "Save")
                                                                         #:value
                                                                         '((em
                                                                            "Alt"))))
                                                   "<em>Alt</em>")
                             #:expect #t))))

(define (spec)
  (veritas-run code-suite))
