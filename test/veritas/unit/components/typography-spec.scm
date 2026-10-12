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

(define-module (veritas unit components typography-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components typography)
  #:use-module (hygguile embed css)
  #:export (spec))

(define (attr-value node name)
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (class-has? node token)
  "Return #t when the rendered @var{token} appears in the node's class list."
  (let ((classes (attr-value node
                             'class)))
    (and (string? classes)
         (string-contains classes token) #t)))

;; ===== the heading type scale =====

(define heading-scale-classes
  '("hg-leading-display" "hg-leading-title" "hg-leading-subtitle"))

;; Every heading the framework ships, with the step it occupies: the
;; component's name, the node it renders, and the size and leading classes
;; the scale pairs for that step.
(define heading-levels
  (list (list "h1"
              (h1 "Heading") "text-4xl" "hg-leading-display")
        (list "h2"
              (h2 "Heading") "text-3xl" "hg-leading-display")
        (list "h3"
              (h3 "Heading") "text-2xl" "hg-leading-title")
        (list "h4"
              (h4 "Heading") "text-xl" "hg-leading-subtitle")
        (list "sub-h1"
              (sub-h1 "Heading") "text-3xl" "hg-leading-display")
        (list "sub-h2"
              (sub-h2 "Heading") "text-2xl" "hg-leading-title")
        (list "sub-h3"
              (sub-h3 "Heading") "text-xl" "hg-leading-subtitle")
        (list "sub-h4"
              (sub-h4 "Heading") "text-xl" "hg-leading-subtitle")))

(define (heading-facts entry)
  "What a rendered heading says about its step of the scale."
  (let ((el (car (cadr entry))))
    (list (car entry)
          (car el)
          (class-has? el
                      (caddr entry))
          (class-has? el
                      (cadddr entry))
          ;; a heading set solid is the one thing the scale is there to
          ;; prevent: its descenders would fall out of its own box
          (class-has? el "leading-none"))))

(define (stylesheet-text)
  "The companion stylesheet, as it ships inside the library."
  (car (filter string?
               (cdr (car (hygguile-extras-css))))))

(define (leading-ratio css class)
  "The line-height the stylesheet gives @var{class} as a plain class, or #f."
  (let ((at (string-contains css
                             (string-append "." class " {"))))
    (and at
         (let ((m (string-match "line-height:\\s*([0-9.]+)" css at)))
           (and m
                (string->number (match:substring m 1)))))))

(define heading-suite
  (suite "Heading type scale"
         (test "hygguile heading type scale"
               (assert-equal #:name
                             "every level is a size paired with its leading"
                             #:got (map heading-facts heading-levels)
                             #:expect '(("h1" h1 #t #t #f)
                                        ("h2" h2 #t #t #f)
                                        ("h3" h3 #t #t #f)
                                        ("h4" h4 #t #t #f)
                                        ("sub-h1" h1 #t #t #f)
                                        ("sub-h2" h2 #t #t #f)
                                        ("sub-h3" h3 #t #t #f)
                                        ("sub-h4" h4 #t #t #f)))
               (assert-equal #:name
                             "a heading resized by hand is led by the scale"
                             #:got (let ((el (car (h1 "Heading"
                                                      #:size '(text-6xl)))))
                                     (list (class-has? el "text-6xl")
                                           (class-has? el "hg-leading-display")))
                             #:expect (list #t #t))
               (assert-equal #:name
                             "a leading given outright replaces the scale's"
                             #:got (let ((el (car (h1 "Heading"
                                                      #:leading '(leading-6)))))
                                     (list (class-has? el "leading-6")
                                           (any (lambda (class)
                                                  (class-has? el class))
                                                heading-scale-classes)))
                             #:expect (list #t #f))
               (assert-equal #:name
                "every ratio in the scale leaves room for the ink"
                #:got (map (lambda (class)
                             (let ((ratio (leading-ratio (stylesheet-text)
                                                         class)))
                               (and ratio
                                    (> ratio 1.25)))) heading-scale-classes)
                #:expect (list #t #t #t))
               (assert-equal #:name
                             "and the scale loosens as the size shrinks"
                             #:got (< (leading-ratio (stylesheet-text)
                                                     "hg-leading-display")
                                      (leading-ratio (stylesheet-text)
                                                     "hg-leading-title")
                                      (leading-ratio (stylesheet-text)
                                                     "hg-leading-subtitle"))
                             #:expect #t))))

(define typography-suite
  (suite "Inline typography"
         (test "hygguile inline typography"
               (assert-equal #:name
                             "inline code is set in a mono face with close padding"
                             #:got (let ((el (car (code "guix shell"))))
                                     (list (class-has? el "font-mono")
                                           (class-has? el "px-2")))
                             #:expect (list #t #t))
               (assert-equal #:name
                             "a code block is set in a mono face with close padding"
                             #:got (let ((el (car (pre "(display 1)"))))
                                     (list (class-has? el "font-mono")
                                           (class-has? el "px-3")
                                           (class-has? el "py-2")))
                             #:expect (list #t #t #t))
               (assert-equal #:name "kbd renders a <kbd> element"
                             #:got (caar (kbd "Ctrl"))
                             #:expect 'kbd)
               (assert-equal #:name "kbd is set in a monospace face"
                             #:got (class-has? (car (kbd "Ctrl")) "font-mono")
                             #:expect #t)
               (assert-equal #:name "samp renders a <samp> element"
                             #:got (caar (samp "Build succeeded."))
                             #:expect 'samp)
               (assert-equal #:name "var renders a <var> element"
                             #:got (caar (var "username"))
                             #:expect 'var)
               (assert-equal #:name "var is italicised"
                             #:got (class-has? (car (var "username")) "italic")
                             #:expect #t)
               (assert-equal #:name "mark renders a <mark> element"
                             #:got (caar (mark "today"))
                             #:expect 'mark)
               (assert-equal #:name "mark highlights the text"
                             #:got (class-has? (car (mark "today"))
                                               "bg-naples-yellow-500/75")
                             #:expect #t)
               (assert-equal #:name "time renders a <time> element"
                             #:got (caar (time "11 October 2026"))
                             #:expect 'time)
               (assert-equal #:name "time carries a machine-readable datetime"
                             #:got (attr-value (car (time "11 October 2026"
                                                          #:datetime
                                                          "2026-10-11"))
                                               'datetime)
                             #:expect "2026-10-11")
               (assert-equal #:name
                "time reuses an ISO string as its datetime value"
                #:got (attr-value (car (time "2026-10-11"))
                                  'datetime)
                #:expect "2026-10-11")
               (assert-equal #:name "time omits datetime when it has none"
                             #:got (attr-value (car (time (sup "1")))
                                               'datetime)
                             #:expect #f)
               (assert-equal #:name "abbr renders an <abbr> element"
                             #:got (caar (abbr "HTTP"))
                             #:expect 'abbr)
               (assert-equal #:name "abbr carries the expansion as a title"
                             #:got (attr-value (car (abbr "HTTP"
                                                     #:title
                                                     "HyperText Transfer Protocol"))
                                               'title)
                             #:expect "HyperText Transfer Protocol")
               (assert-equal #:name "abbr omits the title when none is given"
                             #:got (attr-value (car (abbr "HTTP"))
                                               'title)
                             #:expect #f)
               (assert-equal #:name "sup renders a <sup> element"
                             #:got (caar (sup "2"))
                             #:expect 'sup)
               (assert-equal #:name "sup raises the text"
                             #:got (class-has? (car (sup "2")) "align-super")
                             #:expect #t)
               (assert-equal #:name "sub renders a <sub> element"
                             #:got (caar (sub "2"))
                             #:expect 'sub)
               (assert-equal #:name "sub lowers the text"
                             #:got (class-has? (car (sub "2")) "align-sub")
                             #:expect #t))))

(define (tag-inside? node tag)
  "True when a TAG element is rendered somewhere inside NODE."
  (cond
    ((not (pair? node)) #f)
    ((eq? tag (car node)) #t)
    (else (any (lambda (child)
                 (tag-inside? child tag)) node))))

(define glossary-suite
  (suite "Glossary terms"
         (test "hygguile glossary terms"
               (assert-equal #:name
                             "a term with nothing to say is the bare word"
                             #:got (glossary-term "hygge")
                             #:expect "hygge")
               (assert-equal #:name "a documented term is an <a>"
                             #:got (caar (glossary-term "SXML"
                                                       #:href
                                                       "https://en.wikipedia.org/wiki/SXML"))
                             #:expect 'a)
               (assert-equal #:name "and it links where it says it does"
                             #:got (attr-value (car (glossary-term
                                                     "SXML"
                                                     #:href
                                                     "https://en.wikipedia.org/wiki/SXML"))
                                               'href)
                             #:expect "https://en.wikipedia.org/wiki/SXML")
               (assert-equal #:name
                             "a term with a note is wrapped in a tooltip"
                             #:got (attr-value (car (glossary-term
                                                     "SXML"
                                                     #:note
                                                     "Scheme XML"))
                                               'data-hg-tooltip)
                             #:expect "Scheme XML")
               (assert-equal #:name
                             "the tooltip wraps the link, so one word carries both"
                             #:got (let ((word (glossary-term
                                                "SXML"
                                                #:href
                                                "https://en.wikipedia.org/wiki/SXML"
                                                #:note
                                                "Scheme XML")))
                                     (list (caar word)
                                           (tag-inside? (car word)
                                                        'a)))
                             #:expect (list 'span
                                            #t))
               (assert-equal #:name "a note places itself where it is asked"
                             #:got (class-has? (car (glossary-term
                                                     "SXML"
                                                     #:note
                                                     "Scheme XML"
                                                     #:position
                                                     'bottom))
                                               "hg-tooltip-bottom")
                             #:expect #t))))

(define (spec)
  (veritas-run typography-suite)
  (veritas-run heading-suite)
  (veritas-run glossary-suite))
