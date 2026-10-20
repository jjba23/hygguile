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

(define-module (veritas unit components data-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components data)
  #:use-module (hygguile components media)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define data-suite
  (suite "Data display"
         (test "chips"
               (assert-equal #:name "chip renders a <span>"
                             #:got (caar (chip "Draft"))
                             #:expect 'span)
               (assert-equal #:name "a chip can be a link"
                             #:got (caar (chip "Draft" #:href "/drafts"))
                             #:expect 'a)
               (assert-equal #:name "a chip can be removable"
                             #:got (has? (render (chip "Draft" #:remove-href "/r"))
                                         "hg-chip-remove")
                             #:expect #t))
         (test "avatar groups"
               (assert-equal #:name "avatar-group renders a <div>"
                             #:got (caar (avatar-group (list (avatar #:initials "AB"))))
                             #:expect 'div)
               (assert-equal #:name "avatar-group counts the overflow"
                             #:got (has? (render (avatar-group (list (avatar #:initials "A")
                                                                    (avatar #:initials "B")
                                                                    (avatar #:initials "C"))
                                                              #:max 2))
                                         "+1")
                             #:expect #t))
         (test "timelines"
               (assert-equal #:name "timeline renders an ordered list"
                             #:got (caar (timeline '()))
                             #:expect 'ol)
               (assert-equal #:name "timeline item renders a list item"
                             #:got (caar (timeline-item #:time "Now" #:title "Done"))
                             #:expect 'li)
               (assert-equal #:name "a current entry is announced"
                             #:got (has? (render (timeline-item #:time "Now"
                                                                #:title "Done"
                                                                #:current? #t))
                                         "aria-current=\"step\"")
                             #:expect #t))
         (test "trees"
               (assert-equal #:name "tree-view is a navigation region"
                             #:got (caar (tree-view #:items '()))
                             #:expect 'nav)
               (assert-equal #:name "a branch is a disclosure"
                             #:got (has? (render (tree-view
                                                #:items (list (tree-item "Docs"
                                                                        #:children
                                                                        (list (tree-item "Install"
                                                                                         #:href "/i"))))))
                                         "<details")
                             #:expect #t)
               (assert-equal #:name "a leaf is a link"
                             #:got (has? (render (tree-item "Install" #:href "/i"))
                                         "href=\"/i\"")
                             #:expect #t))))

(define (spec)
  (veritas-run data-suite))
