;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components fly-out)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components glass)
  #:export (fly-out fly-out-submenu fly-out-item))

;; The dropdown hangs over the page it dropped out of, which is exactly the
;; case for glass: the panel blurs and tints whatever it covers. It wears the
;; panel's own tint, since a menu is a pane over the page rather than part of
;; it, and takes the panel's frost while keeping its own shape.
(define fly-out-tint
  '(bg-stone-100/75 dark:bg-onyx-700/75))

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
                                          flex
                                          text-onyx-300
                                          dark:text-stone-300
                                          transition-colors
                                          duration-150))
                          (ul-class '(flyout-submenu z-10
                                                     rounded-xl
                                                     shadow-md
                                                     my-2
                                                     px-4
                                                     py-1))
                          (button-content `((h4 "Menu")))
                          (items '()))
  "Construct a fly-out sub-menu dropdown block.

The dropdown is a frosted glass surface built by @code{glass-panel}: the
frost (the translucent tint and the backdrop blur) is the panel's, so a
dropdown hanging over the page shows the page through it. The menu keeps
its own shape -- it is absolutely placed under its trigger, and the
rounding, shadow and padding stay in @var{ul-class}. It is still the same
@code{<ul>} with the @code{flyout-submenu} class and the @code{hidden}
attribute that @code{fly-out.js} opens and closes, so nothing about the
behaviour changes.

@table @var
@item li-class
List of symbols representing CSS classes for the wrapper @code{<li>} component.
@item button-class
List of symbols representing CSS classes for the trigger @code{<button>} element.
@item ul-class
List of symbols representing the dropdown's own shape and layout. A colour
utility among them replaces the panel's tint.
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
        ,@(glass-panel items
                       #:tag 'ul
                       #:attributes '((hidden ""))
                       #:tint fly-out-tint
                       #:position '(absolute)
                       #:rounding '()
                       #:border '()
                       #:shadow '()
                       #:padding '()
                       #:classes ul-class))))

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
