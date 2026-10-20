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

(define-module (veritas unit components overlay-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components overlay)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define overlay-suite
  (suite "Overlays"
         (test "drawers"
               (assert-equal #:name "drawer is a dialog"
                             #:got (has? (render (drawer #:id "d" #:title "T"
                                                        #:content '()))
                                         "role=\"dialog\"")
                             #:expect #t)
               (assert-equal #:name "drawer says which side it is on"
                             #:got (has? (render (drawer #:id "d" #:title "T"
                                                        #:side 'left
                                                        #:content '()))
                                         "hg-drawer-left")
                             #:expect #t)
               (assert-equal #:name "sheet is a bottom drawer"
                             #:got (has? (render (sheet #:id "s" #:title "S"
                                                      #:content '()))
                                         "hg-drawer-bottom")
                             #:expect #t)
               (assert-equal #:name "drawer opts into the focus trap"
                             #:got (has? (render (drawer #:id "d" #:title "T"
                                                        #:content '()))
                                         "data-hg-focus-trap")
                             #:expect #t))
         (test "popover and hover card"
               (assert-equal #:name "popover uses the native popover API"
                             #:got (has? (render (popover #:id "p" #:trigger "Open"
                                                         #:content '()))
                                         "popovertarget=\"p\"")
                             #:expect #t)
               (assert-equal #:name "popover names its anchor for positioning"
                             #:got (has? (render (popover #:id "p" #:trigger "Open"
                                                         #:content '()))
                                         "anchor-name")
                             #:expect #t)
               (assert-equal #:name "hover card is a dialog preview"
                             #:got (has? (render (hover-card #:trigger "Ada"
                                                            #:content '()))
                                         "hg-hover-card")
                             #:expect #t))
         (test "menus"
               (assert-equal #:name "dropdown menu is a native disclosure"
                             #:got (caar (dropdown-menu #:label "A"
                                                        #:items '()))
                             #:expect 'details)
               (assert-equal #:name "dropdown item can be a link"
                             #:got (has? (render (dropdown-item "Rename" #:href "/r"))
                                         "role=\"menuitem\"")
                             #:expect #t)
               (assert-equal #:name "dropdown item can be a danger action"
                             #:got (has? (render (dropdown-item "Delete" #:danger? #t))
                                         "text-redwood-700")
                             #:expect #t))
         (test "command palette"
               (assert-equal #:name "command palette is a dialog"
                             #:got (has? (render (command-palette #:id "c" #:commands '()))
                                         "role=\"dialog\"")
                             #:expect #t)
               (assert-equal #:name "command palette filters its list"
                             #:got (has? (render (command-palette #:id "c" #:commands '()))
                                         "data-hg-command-input")
                             #:expect #t)
               (assert-equal #:name "command item is a link"
                             #:got (has? (render (command-item "Home" #:href "/"))
                                         "role=\"option\"")
                             #:expect #t))))

(define (spec)
  (veritas-run overlay-suite))
