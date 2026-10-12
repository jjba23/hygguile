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

(define-module (hygguile components tray)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components button)
  #:export (sort-control disclosure-controls))

;; ====== The controls that act on a tray ======
;;
;; A tray is a container of cards a reader takes in as a whole -- a grid of
;; expandable cards, say -- and these are the two things a reader asks of it:
;; which order, and every one of it open or closed. Both are controls over
;; *other* elements, so each one names its target and hands the work to
;; `resources/js/tray.js', which is one small script for every tray on the
;; page: the ordering reads the `data-*' attributes an `expandable-card'
;; carries, and the buttons carry nothing but the call they make.

(define sort-button-classes
  '(hg-sort-button py-1
                   px-3
                   cursor-pointer
                   select-none
                   transition-colors
                   duration-200
                   ease-in-out
                   focus-visible:outline-2
                   focus-visible:outline-offset-2
                   outline-onyx-500))

(define* (sort-control #:key target
                       modes
                       (label "Order")
                       (aria-label "Order")
                       (classes '(flex flex-row flex-wrap items-center gap-2))
                       (label-classes '(text-sm font-medium text-onyx-300
                                                dark:text-stone-300)))
  "Create a group of buttons that puts a tray in one of several orders.

The tray is the container whose identifier is @var{target}; its items are
ordered by the @code{data-*} attribute each of them carries under the name
of the mode asked for. The ordering is done in the browser by
@code{tray.js}, which every build already ships, and it is the sort of a
handful of rendered cards rather than of a data set: a page that has a real
question to ask a server asks it with @code{sortable-table} and a URL
instead.

A mode no item carries is the tray's own order -- the items return to the
order the page wrote them in -- so the button that restores it needs no
attribute anywhere:

@example
(sort-control #:target \"cards\"
              #:modes '((page . \"Page order\")
                        (title . \"A to Z\")))
@end example

@table @var
@item target
The identifier of the container to reorder.
@item modes
A list of @code{(mode . label)} pairs, in the order the buttons should appear. Each @var{mode} names the @code{data-*} attribute to order by, and the first pair is the order the tray opens in.
@item label
The word shown before the buttons.
@item aria-label
The accessible name of the group of buttons.
@item classes
List of CSS classes for the group.
@item label-classes
List of CSS classes for the @var{label}.
@end table"
  `((div (@ (data-hg-sort-target ,target)
            (role "group")
            (aria-label ,aria-label)
            (class ,(mk-class classes)))
         ,@(render-if-nempty (lambda (text)
                               (list `(span (@ (class ,(mk-class label-classes)))
                                            ,text))) label)
         ,@(map (lambda (mode)
                  (button (cdr mode)
                          #:size '(text-sm)
                          #:rounding '(rounded-lg)
                          #:shadow '(shadow-sm)
                          #:extra-classes sort-button-classes
                          #:on-click (format #f "hygguileSortTray(this, '~a')"
                                             (car mode)))) modes))))

(define* (disclosure-controls #:key (selector "details.hg-expandable-card")
                              (expand-label "Expand all")
                              (collapse-label "Collapse all")
                              (classes '(flex flex-row flex-wrap items-center
                                              gap-2)))
  "Create the pair of buttons that open or close every disclosure of a tray.

@var{selector} is any CSS selector, so the pair works for a grid of
@code{expandable-card}s, for a stack of @code{accordion}s, or for the plain
@code{details} elements of a page. Each disclosure is still an ordinary
disclosure that opens and closes on its own; these two buttons only save a
reader the clicking.

@table @var
@item selector
A CSS selector matching the elements to open or close.
@item expand-label
The label of the button that opens them all.
@item collapse-label
The label of the button that closes them all.
@item classes
List of CSS classes for the pair.
@end table

@example
(disclosure-controls #:selector \"details.hg-expandable-card\")
@end example"
  `((div (@ (class ,(mk-class classes)))
         ,(button expand-label
                  #:size '(text-sm)
                  #:on-click (format #f "hygguileToggleTray(true, '~a')"
                                     selector))
         ,(button collapse-label
                  #:size '(text-sm)
                  #:on-click (format #f "hygguileToggleTray(false, '~a')"
                                     selector)))))
