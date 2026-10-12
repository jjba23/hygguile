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

(define-module (hygguile components notification)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components glass)
  #:export (notification-tray notification-card))

;; A polite live region: injected notifications are announced by
;; assistive technology without interrupting whatever the user is
;; doing, and the default empty value keeps the region silent until
;; something is actually added.
(define notification-tray
  `((div (@ (id notification-tray)
            (role status)
            (aria-live polite)
            (aria-atomic "true")
            (class ,(mk-class '(fixed z-32 top-8 right-8)))) "")))

(define notification-card-tint
  '(bg-stone-300/90 dark:bg-onyx-700/75))

(define notification-card-classes
  '(max-w-full max-w-prose
               text-onyx-300
               dark:text-stone-300
               font-sans
               flex
               flex-col
               gap-4))

(define* (notification-card #:key (header-classes (mk-class '(text-xl
                                                              text-onyx-500
                                                              dark:text-stone-300)))
                            (close-icon-on-click
                             "document.getElementById('notification-tray').innerHTML = ''")
                            (close-icon-classes (mk-class '(ph ph-x
                                                            text-onyx-500
                                                            cursor-pointer
                                                            dark:text-stone-300
                                                            text-xl)))
                            (title-container-classes (mk-class '(flex flex-row
                                                                 justify-between
                                                                 flex-wrap
                                                                 gap-10
                                                                 items-center)))
                            (card-classes '()))
  "Build the frosted card a notification arrives in.

A notification interrupts a page from above it, which is the case glass is
for: the card is a @code{glass-panel}, so it blurs and tints whatever it
covers, and it wears a slightly more opaque tint than the framework's own
so it holds its own over any page.

The title and the body are empty in the markup: the script fills them from
the query string with @code{textContent}, so a title cannot smuggle markup
into the page. The two placeholders it looks for are
@code{notification-title} and @code{notification-body}.

The card arrives and then holds still. It is deliberately quiet -- no
bounce, no pulse, nothing that keeps moving once it has landed -- because
a notification is information, and motion at the edge of the eye competes
with the page the reader was already looking at. The only thing that
changes is whether it is there.

Its silhouette is quiet too: the same hairline border as every other pane
of glass rather than a heavy outline, and padding sized so the card is a
note passed to the reader rather than a second page competing with theirs.

@table @var
@item header-classes
The title's own classes, on its @code{<h4>}.
@item close-icon-on-click
The script run when the dismiss icon is clicked.
@item close-icon-classes
The classes of the dismiss icon, which needs its Phosphor icon names.
@item title-container-classes
The classes of the row holding the title and the dismiss icon.
@item card-classes
Extra classes for the card itself, appended to the panel's own.
@end table

@example
(notification-card #:header-classes \"text-lg font-bold\")
@end example"
  (glass-panel (list `(div (@ (class ,title-container-classes))
                           (h4 (@ (id "notification-title")
                                  (class ,header-classes)) "")
                           (i (@ (onclick ,close-icon-on-click)
                                 (class ,close-icon-classes))))
                     `(p (@ (id "notification-body")) ""))
               #:tint notification-card-tint
               #:rounding '(rounded-xl)
               #:border '(border-2 border-stone-500/25 dark:border-onyx-100/25)
               #:shadow '()
               #:padding '(py-5 px-5)
               #:classes (append notification-card-classes card-classes)))
