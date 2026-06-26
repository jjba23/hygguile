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

(define-module (hygguile components fly-out)
  #:use-module (hygguile abstraction)
  #:export (fly-out fly-out-submenu fly-out-item))

(define* (fly-out #:key (aria-label "Fly-out selection menu")
                  (nav-class '(py-4))
                  (top-ul-class '(flex flex-row flex-wrap justify-center
                                       items-start gap-4))
                  (items '()))
  "Construct an outer fly-out navigation menu shell.

@table @var
@item aria-label
The accessibility text label string assigned to the @code{<nav>} component.
@item nav-class
List of symbols representing CSS classes for the structural @code{<nav>} wrapper.
@item top-ul-class
List of symbols representing CSS classes for the top-level container @code{<ul>}.
@item items
A list of sub-components or list items to nest within the top-level menu container.
@end table

@example
(fly-out #:aria-label \"Main Navigation\"
         #:items (list (fly-out-item \"Home\")))
@end example"
  `((nav (@ (class ,(mk-class nav-class))
            (aria-label ,aria-label))
         (ul (@ (class ,(mk-class top-ul-class)))
             ,items))))

(define* (fly-out-submenu #:key (li-class '(flyout-menu-container
                                            cursor-pointer px-4 py-4))
                          (button-class '(flyout-submenu-button cursor-pointer
                                          flex text-onyx-300
                                          dark:text-stone-300))
                          (ul-class '(flyout-submenu z-10
                                                     absolute
                                                     bg-stone-100/75
                                                     dark:bg-onyx-700/75
                                                     rounded-xl
                                                     shadow-md
                                                     my-2
                                                     px-4
                                                     py-1))
                          (button-content `((h4 "Menu")))
                          (items '()))
  "Construct a fly-out sub-menu dropdown block.

@table @var
@item li-class
List of symbols representing CSS classes for the wrapper @code{<li>} component.
@item button-class
List of symbols representing CSS classes for the trigger @code{<button>} element.
@item ul-class
List of symbols representing CSS classes for the inner hidden dropdown @code{<ul>} list.
@item button-content
S-expression content or fragments rendered inside the dropdown trigger button.
@item items
A list of nested child items (typically @code{fly-out-item} items) belonging to this sub-menu.
@end table

@example
(fly-out-submenu #:button-content '((span \"Settings\"))
                 #:items (list (fly-out-item \"Account Profile\")))
@end example"
  `((li (@ (class ,(mk-class li-class)))
        (button (@ (class ,(mk-class button-class))
                   (aria-haspopup true)
                   (aria-expanded false)
                   (aria-controls submenu))
                ,button-content)
        (ul (@ (hidden "")
               (class ,(mk-class ul-class)))
            ,items))))

(define* (fly-out-item content
                       #:key (li-class '(px-4 py-4)))
  "Construct a single leaf item within a fly-out menu.

@table @var
@item content
The text description, link, or component fragment inside the item container.
@item li-class
List of symbols representing CSS classes for the wrapping @code{<li>} item.
@end table

@example
(fly-out-item \"Documentation\" #:li-class '(px-2 py-2))
@end example"
  `((li (@ (class ,(mk-class li-class)))
        ,content)))
