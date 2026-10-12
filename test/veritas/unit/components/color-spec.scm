;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; hygguile is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Lesser General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; hygguile is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.

;; You should have received a copy of the GNU Lesser General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (veritas unit components color-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components color)
  #:use-module (hygguile sxml)
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

(define (render node)
  "Serialize an SXML fragment to an HTML string, as a page would be served."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has-attribute? html text)
  "True when the rendered HTML carries TEXT."
  (and (string-contains html text) #t))

(define color-suite
  (suite "Colour swatches"
         (test "hygguile colour swatch"
               (assert-equal #:name
                             "a swatch is a <button>, so a reader can step it from the keyboard"
                             #:got (caar (color-swatch #:color 'apple-green-500))
                             #:expect 'button)
               (assert-equal #:name
                             "the swatch carries the colour it shows"
                             #:got (class-has? (car (color-swatch #:color
                                                                  'apple-green-500))
                                               "bg-apple-green-500")
                             #:expect #t)
               (assert-equal #:name
                             "the swatch names the colour it shows"
                             #:got (has-attribute? (render (color-swatch #:color
                                                                         'apple-green-500))
                                                   ">apple-green-500</span>")
                             #:expect #t)
               (assert-equal #:name
                             "and names it to assistive technology too"
                             #:got (has-attribute? (render (color-swatch #:color
                                                                         'apple-green-500))
                                                   (string-append "aria-label=\"Show apple-green-500"
                                                                  " in the next shade of its colour\""))
                             #:expect #t)
               (assert-equal #:name "a swatch calls the script that steps it"
                             #:got (has-attribute? (render (color-swatch #:color
                                                                         'apple-green-500))
                                                   "cycleColorShow(this)")
                             #:expect #t)
               (assert-equal #:name
                             "the caption is frosted, since a swatch can be any lightness"
                             #:got (let ((caption (car (cddr (car (color-swatch
                                                                   #:color
                                                                   'apple-green-500))))))
                                     (class-has? caption "hg-frost"))
                             #:expect #t)
               (assert-equal #:name
                             "a label replaces the colour's own name on the tile"
                             #:got (has-attribute? (render (color-swatch #:color
                                                                         'apple-green-500
                                                                         #:label
                                                                         "Apple"))
                                                   ">Apple</span>")
                             #:expect #t))))

(define (spec)
  (veritas-run color-suite))
