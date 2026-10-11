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

;; You should have received a copy of the GNU Lesser General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (veritas unit components fly-out-spec)
  #:use-module (veritas veritas)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components fly-out)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  "Serialize an SXML fragment to the HTML a server would send."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define* (submenu #:optional (ul-class #f))
  "A submenu with two items, wearing UL-CLASS of its own when given one."
  (fly-out-submenu #:button-content (list "Menu")
                   #:items (list (fly-out-item "One") (fly-out-item "Two"))
                   #:ul-class (or ul-class
                                  '(flyout-submenu z-10
                                                   rounded-xl
                                                   shadow-md
                                                   my-2
                                                   px-4
                                                   py-1))))

(define (dropdown-of submenu-node)
  "The <ul> of a rendered submenu."
  (let ((li (car submenu-node)))
    (car (cdr (cddr li)))))

(define dropdown-html
  (render (submenu)))

(define custom-html
  (render (submenu '(my-dropdown))))

(define (classes-of html)
  "The dropdown's class list in HTML, or #f."
  (let ((m (string-match "<ul[^>]*class=\"([^\"]*)\"" html)))
    (and m (match:substring m 1))))

(define (has-class? classes name)
  "True when a space-separated class string contains exactly NAME."
  (and classes
       (member name (string-split classes #\space))
       #t))

(define (contains? text needle)
  "True when NEEDLE appears in TEXT."
  (and (string-contains text needle) #t))

(define (count-of text needle)
  "How many times NEEDLE appears in TEXT."
  (let loop
    ((at 0)
     (n 0))
    (let ((hit (string-contains text needle at)))
      (if hit
          (loop (+ hit
                   (string-length needle))
                (1+ n)) n))))

(define (frosted? html)
  "The three classes that make the dropdown in HTML a frosted surface."
  (let ((classes (classes-of html)))
    (list (has-class? classes "backdrop-blur-md")
          (has-class? classes "bg-stone-100/75")
          (has-class? classes "dark:bg-onyx-700/75"))))

(define fly-out-suite
  (suite "Fly-out menus"
         (test "hygguile fly-out menus"
               (assert-equal #:name "the dropdown is still a <ul>"
                             #:got (car (dropdown-of (submenu)))
                             #:expect 'ul)
               (assert-equal #:name
                             "it is still hidden until the script opens it"
                             #:got (contains? dropdown-html
                                    "<ul hidden=\"\"")
                             #:expect #t)
               (assert-equal #:name
                             "and still carries the class the script looks for"
                             #:got (has-class? (classes-of dropdown-html)
                                               "flyout-submenu")
                             #:expect #t)
               (assert-equal #:name "the dropdown is glass"
                             #:got (frosted? dropdown-html)
                             #:expect (list #t #t #t))
               (assert-equal #:name
                             "it is placed under its trigger, not in the flow"
                             #:got (has-class? (classes-of dropdown-html)
                                               "absolute")
                             #:expect #t)
               (assert-equal #:name "and keeps the shape it always had"
                             #:got (let ((classes (classes-of dropdown-html)))
                                     (list (has-class? classes "rounded-xl")
                                           (has-class? classes "shadow-md")
                                           (has-class? classes "px-4")
                                           (has-class? classes "py-1")
                                           (has-class? classes "z-10")
                                           (has-class? classes "my-2")))
                             #:expect (list #t #t #t #t #t #t))
               (assert-equal #:name
                             "it does not wear the panel's own dress"
                             #:got (let ((classes (classes-of dropdown-html)))
                                     (list (has-class? classes "rounded-3xl")
                                           (has-class? classes "border-2")
                                           (has-class? classes "shadow-lg")
                                           (has-class? classes "p-6")))
                             #:expect (list #f #f #f #f))
               (assert-equal #:name
                             "a menu item is a direct child of the list"
                             #:got (count-of dropdown-html "<div")
                             #:expect 0)
               (assert-equal #:name
                             "a caller's classes do not cost the frost"
                             #:got (append (frosted? custom-html)
                                           (list (has-class?
                                                  (classes-of custom-html)
                                                  "my-dropdown")))
                             #:expect (list #t #t #t #t))
               (assert-equal #:name
                             "the trigger still announces what it controls"
                             #:got (let ((html (render (submenu))))
                                     (list (contains? html "aria-haspopup")
                                           (contains? html "aria-expanded")
                                           (contains? html
                                                      "aria-controls=\"submenu\"")))
                             #:expect (list #t #t #t)))))

(define (spec)
  (veritas-run fly-out-suite))
