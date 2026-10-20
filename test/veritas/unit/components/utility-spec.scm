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

(define-module (veritas unit components utility-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components utility)
  #:use-module (hygguile components tokens)
  #:use-module (hygguile components typography)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define utility-suite
  (suite "Utility"
         (test "accessibility helpers"
               (assert-equal #:name "visually-hidden is sr-only"
                             #:got (has? (render (visually-hidden "Loading"))
                                         "sr-only")
                             #:expect #t)
               (assert-equal #:name "skip-link points where it was told"
                             #:got (has? (render (skip-link #:target "#main"))
                                         "href=\"#main\"")
                             #:expect #t))
         (test "text and clipboard"
               (assert-equal #:name "truncate clamps more than one line"
                             #:got (has? (render (truncate-text "text" #:lines 2))
                                         "line-clamp-2")
                             #:expect #t)
               (assert-equal #:name "copy-button carries its value as data"
                             #:got (has? (render (copy-button #:text "hello"))
                                         "data-hg-copy=\"hello\"")
                             #:expect #t))
         (test "responsive helpers"
               (assert-equal #:name "show is hidden until its breakpoint"
                             #:got (has? (render (show (list (p "a")) #:from 'lg))
                                         "hidden")
                             #:expect #t)
               (assert-equal #:name "hide names the breakpoint it hides from"
                             #:got (has? (render (hide (list (p "a")) #:from 'md))
                                         "hg-hidden-from-md")
                             #:expect #t))
         (test "motion respects the token scale"
               (assert-equal #:name "fade-in names its effect"
                             #:got (has? (render (fade-in (list (p "a"))))
                                         "hg-motion-fade")
                             #:expect #t)
               (assert-equal #:name "collapse is a native disclosure"
                             #:got (caar (collapse #:summary "S" #:content (list (p "a"))))
                             #:expect 'details))
         (test "layers and locale"
               (assert-equal #:name "layer names its level"
                             #:got (has? (render (layer (list (p "a")) #:level 'modal))
                                         "hg-layer-modal")
                             #:expect #t)
               (assert-equal #:name "locale passes its language and direction"
                             #:got (has? (render (locale (list (p "a"))
                                                          #:lang "ar" #:dir 'rtl))
                                         "dir=\"rtl\"")
                             #:expect #t))
         (test "design tokens"
               (assert-equal #:name "spacing token reads the ladder"
                             #:got (token-value 'space 4)
                             #:expect "1rem")
               (assert-equal #:name "a colour token has a dark value"
                             #:got (token-value 'color 'ink #:theme 'dark)
                             #:expect "#ededee")
               (assert-equal #:name "token declarations are CSS properties"
                             #:got (car (token-declarations '((space 4))))
                             #:expect (cons "--hg-space-4" "1rem")))))

(define (spec)
  (veritas-run utility-suite))
