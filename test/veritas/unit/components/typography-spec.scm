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
  #:use-module (hygguile components typography)
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
         (string-contains classes token)
         #t)))

(define typography-suite
  (suite "Inline typography"
         (test "hygguile inline typography"
               (assert-equal #:name "kbd renders a <kbd> element"
                             #:got (caar (kbd "Ctrl"))
                             #:expect 'kbd)
               (assert-equal #:name "kbd is set in a monospace face"
                             #:got (class-has? (car (kbd "Ctrl"))
                                               "font-mono")
                             #:expect #t)
               (assert-equal #:name "samp renders a <samp> element"
                             #:got (caar (samp "Build succeeded."))
                             #:expect 'samp)
               (assert-equal #:name "var renders a <var> element"
                             #:got (caar (var "username"))
                             #:expect 'var)
               (assert-equal #:name "var is italicised"
                             #:got (class-has? (car (var "username"))
                                               "italic")
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
                             #:got (class-has? (car (sup "2"))
                                               "align-super")
                             #:expect #t)
               (assert-equal #:name "sub renders a <sub> element"
                             #:got (caar (sub "2"))
                             #:expect 'sub)
               (assert-equal #:name "sub lowers the text"
                             #:got (class-has? (car (sub "2"))
                                               "align-sub")
                             #:expect #t))))

(define (spec)
  (veritas-run typography-suite))
