;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit sxml-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render tree)
  "Serialize an SXML node to the HTML text a server would send.

Escaping is off, which is the default and the mode every hygguile page is
built in: a component already knows what its own markup is."
  (call-with-output-string (lambda (port)
                             (sxml->xml tree port))))

(define (render-escaped tree)
  "Serialize an SXML node with text escaping turned on.

This is the mode for a document whose text came from somewhere else, where
a stray angle bracket or ampersand in the data has to survive the round
trip as a character reference."
  (call-with-output-string (lambda (port)
                             (sxml->xml tree port #t))))

;; The HTML5 void elements, which are the only tags that may be written as
;; a lone tag.  The list is written out here rather than read from the
;; module so that this spec states the specification instead of agreeing
;; with whatever the implementation happens to say.
(define html5-void-tags
  '(area base
         br
         col
         embed
         hr
         img
         input
         link
         meta
         param
         source
         track
         wbr))

(define (lone-tag tag)
  "The HTML a void element is expected to serialize to."
  (string-append "<"
                 (symbol->string tag) " />"))

(define sxml-suite
  (suite "SXML serialization"
         (test "empty elements"
               (assert-equal #:name
                "a non-void element with no children is written as an open/close pair"
                #:got (render '(div))
                #:expect "<div></div>")
               (assert-equal #:name
                "attributes do not turn an empty element into a self-closing tag"
                #:got (render '(div (@ (id "x"))))
                #:expect "<div id=\"x\"></div>")
               (assert-equal #:name
                "an empty attribute list adds nothing to the tag"
                #:got (render '(div (@)))
                #:expect "<div></div>")
               (assert-equal #:name
                "an empty string child still gets an explicit close tag"
                #:got (render '(span ""))
                #:expect "<span></span>")
               (assert-equal #:name "an empty nodelist renders nothing at all"
                             #:got (render '())
                             #:expect ""))

         (test "void elements"
               (assert-equal #:name
                "every HTML5 void element is written as a lone tag"
                #:got (map (lambda (tag)
                             (render (list tag))) html5-void-tags)
                #:expect (map lone-tag html5-void-tags))
               (assert-equal #:name "a void element keeps its attributes"
                             #:got (render '(img (@ (src "a.png")
                                                    (alt "A"))))
                             #:expect "<img src=\"a.png\" alt=\"A\" />")
               (assert-equal #:name
                             "a void element is recognized whatever its case"
                             #:got (render '(BR))
                             #:expect "<BR />")
               (assert-equal #:name
                "a void element with children falls back to an open/close pair"
                #:got (render '(br "text"))
                #:expect "<br>text</br>"))

         (test "attributes"
               (assert-equal #:name
                             "attributes are written in the order given"
                             #:got (render '(a (@ (href "/x")
                                                  (rel "noopener")) "go"))
                             #:expect "<a href=\"/x\" rel=\"noopener\">go</a>")
               (assert-equal #:name "a dotted-pair attribute keeps its value"
                             #:got (render '(div (@ (class . "a b"))))
                             #:expect "<div class=\"a b\"></div>")
               (assert-equal #:name
                "a non-string attribute value is written the way display prints it"
                #:got (render '(div (@ (tabindex 0))))
                #:expect "<div tabindex=\"0\"></div>")
               (assert-equal #:name
                "a list attribute value is concatenated without a separator"
                #:got (render '(div (@ (class ("a" "b")))))
                #:expect "<div class=\"ab\"></div>")
               (assert-equal #:name
                "an attribute with no value renders as an empty string"
                #:got (render '(div (@ (id))))
                #:expect "<div id=\"\"></div>")
               (assert-equal #:name
                "attribute values are escaped even when text escaping is off"
                #:got (render '(a (@ (title "a & b"))))
                #:expect "<a title=\"a &amp; b\"></a>")
               (assert-equal #:name
                "a boolean attribute value is not minimized away"
                #:got (render '(input (@ (disabled #t))))
                #:expect "<input disabled=\"#t\" />")
               (assert-error (lambda ()
                               (render '(div (@ id))))
                #:name
                "an attribute that is not a name/value pair raises an error"))

         (test "escaping"
               (assert-equal #:name
                             "text is written literally when escaping is off"
                             #:got (render '(p "a & b < c"))
                             #:expect "<p>a & b < c</p>")
               (assert-equal #:name
                "text inside an element is escaped when escaping is on"
                #:got (render-escaped '(p "a & b < c > d \" e"))
                #:expect "<p>a &amp; b &lt; c &gt; d &quot; e</p>")
               (assert-equal #:name
                "a top-level string is escaped when escaping is on"
                #:got (render-escaped "a & b")
                #:expect "a &amp; b")
               (assert-equal #:name
                "escaping reaches text inside nested elements and nodelists"
                #:got (render-escaped '((div (p "a & b"))))
                #:expect "<div><p>a &amp; b</p></div>")
               (assert-equal #:name "escaping survives a *TOP* wrapper"
                             #:got (render-escaped '(*TOP* (p "a & b")))
                             #:expect "<p>a &amp; b</p>")
               ;; Not a shape the framework relies on -- content reaches a
               ;; page as a string -- but an asymmetry worth knowing about
               ;; before a bare number is one day dropped from a page.
               (assert-equal #:name
                "a bare number is written only when escaping is on"
                #:got (list (render 42)
                            (render-escaped 42))
                #:expect (list "" "42")))

         (test "nodelists"
               (assert-equal #:name
                "a nodelist renders its members in order, with no wrapper"
                #:got (render '((div)
                                (span "x")))
                #:expect "<div></div><span>x</span>")
               (assert-equal #:name
                             "elements nested in elements keep their nesting"
                             #:got (render '((div (span (em "deep")))))
                             #:expect "<div><span><em>deep</em></span></div>")
               (assert-equal #:name "empty, false and #t members are skipped"
                             #:got (render '((p "a")
                                             () #f #t "b"))
                             #:expect "<p>a</p>b")
               (assert-equal #:name
                "*TOP* splices its nodelist without a wrapper of its own"
                #:got (render '(*TOP* (p "a")
                                      (p "b")))
                #:expect "<p>a</p><p>b</p>"))))

(define (spec)
  (veritas-run sxml-suite))
