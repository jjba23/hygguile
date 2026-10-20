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

(define-module (hygguile components overlay)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (drawer sheet
                   popover hover-card
                   dropdown-item dropdown-menu
                   command-item command-palette))

;; ===== Overlays =====
;;
;; An overlay is a surface that leaves the flow: a dialog, a drawer, a menu,
;; a command palette. The framework's answer to "which of us is on top" is the
;; layer scale in `(hygguile components tokens)', and the answer to "where do
;; I sit" is the browser's own machinery wherever it exists:
;;
;;   * a drawer and a command palette are revealed by `:target', so the link
;;     that opens them is an ordinary anchor and the overlay still opens with
;;     scripting off;
;;   * a popover is the native HTML Popover API, which puts it in the top
;;     layer and lets the browser dismiss it, with CSS anchor positioning
;;     placing it against its trigger where that is supported;
;;   * a dropdown is a native `<details>', so the menu opens and closes with
;;     no script at all.
;;
;; The scripts that make these nicer -- focus trapping, Escape, arrow keys,
;; filtering -- are enhancements. None of them is required for the overlay to
;; be reachable, readable and dismissible.

(define (normalize-nodes content)
  "Return @var{content} as a list of nodes, wrapping a single node."
  (cond
    ((null? content)
     '())
    ((and (list? content)
          (pair? content)
          (not (symbol? (car content))))
     content)
    (else (list content))))

(define (drawer-side-class side)
  "Return the placement class for a drawer @var{side}."
  (cond
    ((eq? 'left side) 'hg-drawer-left)
    ((eq? 'bottom side) 'hg-drawer-bottom)
    (else 'hg-drawer-right)))

(define* (drawer #:key id
                 title
                 content
                 (footer #f)
                 (side 'right)
                 (close-label "Close")
                 (label #f)
                 (classes '()))
  "Create a drawer that slides in from an edge, opened by a link.

The drawer is a real dialog, revealed by the CSS @code{:target}
pseudo-class: link to it with @code{(a \"Filters\" #:href \"#filters\")} and it
appears, follow a link to @code{\"#\"} and it is gone. That means the whole
overlay works with scripting off, and the URL says which overlay is open,
which is the same contract the framework's modal already uses.

The drawer is placed at the end of the page, so the link that opens it is
never itself covered by it. A drawer that carries a form is the common case
-- filters, a cart, a settings panel -- and the footer is where its actions
go.

@table @var
@item id
The identifier the opening link targets.
@item title
The dialog's title, also its accessible name.
@item content
The drawer body.
@item footer
An optional list of actions.
@item side
@code{'right} (default), @code{'left} or @code{'bottom}.
@item close-label
The accessible name of the close control.
@item label
An optional accessible name overriding the title.
@item classes
Extra classes for the panel.
@end table

@example
(drawer #:id \"filters\" #:title \"Filters\"
        #:content (list (checkbox #:label \"In stock\" #:name \"stock\")))
@end example"
  (let* ((title-id (format #f "~a-title" id))
         (header `(div (@ (class "hg-drawer-header"))
                       (h3 (@ (id ,title-id)
                              (class ,(mk-class '(text-xl font-semibold
                                                          text-onyx-500
                                                          dark:text-stone-100
                                                          font-sans))))
                           ,title)
                       (a (@ (href "#")
                             (aria-label ,close-label)
                             (class "hg-drawer-close no-underline
                                     text-2xl text-onyx-300
                                     dark:text-stone-500"))
                          "×")))
         (footer-node (if footer
                          (list `(div (@ (class "hg-drawer-footer"))
                                      ,footer))
                          '()))
         (panel-classes (append (list 'hg-drawer (drawer-side-class side))
                                classes)))
    (list `(div (@ (id ,id)
                   (role "dialog")
                   (aria-modal "true")
                   (aria-labelledby ,title-id)
                   (data-hg-focus-trap "")
                   (class ,(mk-class panel-classes)))
                (a (@ (href "#")
                      (aria-label ,close-label)
                      (class "hg-drawer-backdrop"))
                   "")
                (div (@ (class "hg-drawer-panel"))
                     ,header
                     (div (@ (class "hg-drawer-body"))
                          ,content)
                     ,@footer-node)))))

(define* (sheet #:key id
                title
                content
                (footer #f)
                (close-label "Close")
                (label #f)
                (classes '()))
  "Create a bottom sheet: a drawer anchored to the bottom edge.

This is @code{drawer} with @code{#:side 'bottom}, named for the surface it
makes. On a phone it is the shape a picker or an action list usually takes,
and it is still a plain anchor target, so it opens without a script.

@table @var
@item id
The identifier the opening link targets.
@item title
The sheet's title and accessible name.
@item content
The sheet body.
@item footer
An optional list of actions.
@item close-label
The accessible name of the close control.
@item label
An optional accessible name overriding the title.
@item classes
Extra classes for the panel.
@end table

@example
(sheet #:id \"actions\" #:title \"Actions\" #:content (list (p \"...\")))
@end example"
  (drawer #:id id
          #:title title
          #:content content
          #:footer footer
          #:side 'bottom
          #:close-label close-label
          #:label label
          #:classes classes))

;; ===== Popovers and hover cards =====

(define* (popover #:key id
                  trigger
                  content
                  (title #f)
                  (position 'bottom-start)
                  (label #f)
                  (classes '()))
  "Attach a native popover to a trigger.

The popover is the HTML Popover API: the control carries
@code{popovertarget}, the panel carries the @code{popover} attribute, and the
browser puts the panel in the top layer, dismisses it on Escape or an outside
click, and does not let it be clipped by an ancestor. That is a lot of
behaviour no script of ours has to implement.

Placement is CSS anchor positioning where the browser supports it: the
trigger names an anchor, the panel points at it, and the stylesheet places the
panel below or above it. Where anchor positioning is not available, the
panel falls back to the browser's own centred popover placement, which is
usable even if less precise -- and the position class is still there for a
page that wants to nudge it.

@table @var
@item id
The identifier the trigger's @code{popovertarget} names.
@item trigger
The button's label, or a node to put inside the button.
@item content
The popover body.
@item title
An optional heading inside the popover.
@item position
@code{'bottom-start} (default), @code{'bottom}, @code{'top-start} or
@code{'top}.
@item label
The accessible name of the panel, when there is no title.
@item classes
Extra classes for the panel.
@end table

@example
(popover #:id \"share\" #:trigger \"Share\"
         #:title \"Share this page\"
         #:content (list (copy-button #:text \"https://example.org\")))
@end example"
  (let* ((anchor-name (format #f "--hg-popover-~a" id))
         (trigger-node (if (and (list? trigger)
                                (pair? trigger)
                                (not (symbol? (car trigger))))
                           trigger
                           `(span ,trigger)))
         (heading (if title
                      (list `(h3 (@ (class ,(mk-class '(text-md font-semibold
                                                                text-onyx-500
                                                                dark:text-stone-300
                                                                font-sans))))
                                 ,title))
                      '()))
         (body (normalize-nodes content))
         (accessible-name (or label title "Popover"))
         (trigger-style (mk-style `((anchor-name . ,anchor-name))))
         (panel-style (mk-style `((position-anchor . ,anchor-name))))
         (position-class (string->symbol (format #f "hg-popover-~a"
                                                 position))))
    (list `(div (@ (class "hg-popover-anchor relative inline-block"))
                (button (@ (type "button")
                           (popovertarget ,id)
                           (aria-haspopup "dialog")
                           (style ,trigger-style)
                           (class ,(mk-class '(hg-popover-trigger inline-flex
                                                                  items-center
                                                                  gap-2
                                                                  px-3 py-2
                                                                  rounded-lg
                                                                  border-2
                                                                  border-stone-500/50
                                                                  dark:border-onyx-100/50
                                                                  bg-stone-300/75
                                                                  dark:bg-onyx-700/75
                                                                  text-onyx-500
                                                                  dark:text-stone-300
                                                                  text-sm font-medium
                                                                  font-sans
                                                                  cursor-pointer
                                                                  transition-colors
                                                                  duration-150
                                                                  focus-visible:outline-2
                                                                  focus-visible:outline-offset-2
                                                                  outline-onyx-500))))
                        ,trigger-node)
                (div (@ (id ,id)
                        (popover "")
                        (role "dialog")
                        (aria-label ,accessible-name)
                        (style ,panel-style)
                        (class ,(mk-class (append (list 'hg-popover
                                                        position-class)
                                                  classes))))
                     ,@heading
                     ,@body)))))

(define* (hover-card #:key trigger
                     (title #f)
                     content
                     (position 'bottom-start)
                     (label #f)
                     (classes '()))
  "Show a small card of richer content when a trigger is hovered or focused.

A tooltip is a sentence; a hover card is a little more -- a name, a role, a
couple of links. It appears on hover and on keyboard focus, because
@code{:focus-within} is part of the same rule, and its content is real markup
inside the page, not generated content, so assistive technology can reach it.

The card is not a modal and does not trap focus: a reader can ignore it,
tab past it, or follow what is inside it. That is the right shape for a
preview; a surface that must be dealt with is a dialog.

@table @var
@item trigger
The label or node the card is attached to.
@item title
An optional heading inside the card.
@item content
The card body.
@item position
@code{'bottom-start} (default), @code{'bottom}, @code{'top-start} or
@code{'top}.
@item label
The accessible name of the card.
@item classes
Extra classes for the card.
@end table

@example
(hover-card #:trigger \"@@ada\" #:title \"Ada Lovelace\"
            #:content (list (p \"Wrote the first algorithm.\")))
@end example"
  (let* ((trigger-node (if (and (list? trigger)
                                (pair? trigger)
                                (not (symbol? (car trigger))))
                           trigger
                           `(span ,trigger)))
         (heading (if title
                      (list `(strong (@ (class ,(mk-class '(block text-md
                                                                   font-semibold
                                                                   text-onyx-500
                                                                   dark:text-stone-300
                                                                   font-sans))))
                                     ,title))
                      '()))
         (body (normalize-nodes content))
         (accessible-name (or label title "Preview"))
         (position-class (string->symbol (format #f "hg-hover-card-~a"
                                                 position))))
    (list `(span (@ (class "hg-hover-card-wrapper relative inline-flex")
                    (tabindex "0"))
                 ,trigger-node
                 (span (@ (role "dialog")
                          (aria-label ,accessible-name)
                          (class ,(mk-class (append (list 'hg-hover-card
                                                          position-class)
                                                    classes))))
                       ,@heading
                       ,@body)))))

;; ===== Dropdown menus =====

(define* (dropdown-item label
                        #:key (href #f)
                        (on-click #f)
                        (danger? #f)
                        (disabled? #f)
                        (classes '()))
  "Create one item of a dropdown menu.

The item is a link when it has an @code{href}, and a button otherwise, so a
menu is a list of ordinary controls rather than a list of scripted rows.
Items carry @code{role=\"menuitem\"}; the menu itself is the native
disclosure around them.

@table @var
@item label
The item's text.
@item href
The destination, for a navigation item.
@item on-click
A JavaScript handler, for an item that acts in place.
@item danger?
Whether the item is destructive.
@item disabled?
Whether the item is disabled.
@item classes
Extra classes for the item.
@end table

@example
(dropdown-item \"Duplicate\" #:on-click \"duplicate()\")
@end example"
  (let ((item-classes (append '(hg-dropdown-item flex flex-row
                                                  items-center gap-2
                                                  w-full px-3 py-2
                                                  text-sm font-medium
                                                  font-sans no-underline
                                                  text-left text-onyx-500
                                                  dark:text-stone-300
                                                  hover:bg-stone-500/25
                                                  dark:hover:bg-onyx-500/25
                                                  transition-colors
                                                  duration-150
                                                  focus-visible:outline-2
                                                  focus-visible:outline-offset-2
                                                  outline-onyx-500)
                               (if danger?
                                   '(text-redwood-700
                                     dark:text-light-coral-100)
                                   '())
                               (if disabled?
                                   '(opacity-50 cursor-not-allowed
                                     pointer-events-none)
                                   '())
                               classes)))
    (if href
        (list `(li (@ (role "none"))
                   (a (@ (role "menuitem")
                         (href ,href)
                         (class ,(mk-class item-classes))
                         ,@(if disabled? '((aria-disabled "true")) '()))
                      ,label)))
        (list `(li (@ (role "none"))
                   (button (@ (role "menuitem")
                              (type "button")
                              (class ,(mk-class item-classes))
                              ,@(if disabled? '((disabled "")) '())
                              ,@(if on-click
                                    (list (cons 'onclick on-click))
                                    '()))
                           ,label))))))

(define* (dropdown-menu #:key label
                        items
                        (position 'bottom-start)
                        (open? #f)
                        (classes '()))
  "Create a dropdown menu that opens without JavaScript.

The menu is a native @code{<details>}: its summary is the trigger, its body is
a list of menu items, and the browser does the opening and closing. The
script that ships with the framework adds the keyboard behaviour a
@code{role=\"menu\"} promises -- arrow keys, Home and End, Escape -- and
leaves the menu usable when it is not there.

@table @var
@item label
The trigger's visible text.
@item items
A list of @code{dropdown-item} nodes.
@item position
@code{'bottom-start} (default), @code{'bottom-end}, @code{'top-start} or
@code{'top-end}.
@item open?
Whether the menu starts open. Defaults to false; a menu on a page normally
opens when its summary is clicked, but a demo or a menu that should draw
attention can start expanded.
@item classes
Extra classes for the menu wrapper.
@end table

@example
(dropdown-menu #:label \"Actions\"
               #:items (list (dropdown-item \"Rename\" #:href \"/rename\")
                             (dropdown-item \"Delete\" #:danger? #t)))
@end example"
  `((details (@ (class ,(mk-class (append '(hg-dropdown relative
                                                      inline-block)
                                        classes)))
                ,@(if open? '((open "")) '())
                (data-hg-dropdown ""))
             (summary (@ (class ,(mk-class '(hg-dropdown-trigger
                                             inline-flex items-center gap-2
                                             px-3 py-2 rounded-lg border-2
                                             border-stone-500/50
                                             dark:border-onyx-100/50
                                             bg-stone-300/75
                                             dark:bg-onyx-700/75
                                             text-onyx-500
                                             dark:text-stone-300
                                             text-sm font-medium font-sans
                                             cursor-pointer select-none
                                             list-none transition-colors
                                             duration-150
                                             focus-visible:outline-2
                                             focus-visible:outline-offset-2
                                             outline-onyx-500)))
                           (aria-haspopup "menu"))
                      (span ,label)
                      (span (@ (aria-hidden "true")
                               (class "hg-dropdown-chevron text-sm"))
                            "⌄"))
             (ul (@ (role "menu")
                    (class ,(mk-class (append
                                       (list 'hg-dropdown-menu
                                             (string->symbol
                                              (format #f "hg-dropdown-~a"
                                                      position)))
                                       '(absolute z-32 mt-1 min-w-48 p-1 m-0
                                                  list-none rounded-xl border-2
                                                  border-stone-500/25
                                                  dark:border-onyx-100/25
                                                  bg-stone-100
                                                  dark:bg-onyx-900
                                                  shadow-lg)))))
                 ,@items))))

;; ===== Command palette =====

(define* (command-item label
                       #:key href
                       (hint #f)
                       (keywords #f))
  "Create one command in a command palette.

A command is a link: choosing one is a navigation, and the palette is only
a quicker way to find it. @var{keywords} are extra words the filter should
match (a synonym, an abbreviation) and are kept out of the visible label.

@table @var
@item label
The command's visible text.
@item href
Where the command goes.
@item hint
An optional keyboard shortcut or category shown at the end of the row.
@item keywords
Optional extra text for the filter to match.
@end table

@example
(command-item \"Open settings\" #:href \"/settings\" #:hint \"G S\")
@end example"
  `((li (@ (role "option")
           (data-hg-command-item "")
           ,@(attr-when keywords
                        'data-hg-command-keywords keywords))
        (a (@ (href ,href)
              (class ,(mk-class '(hg-command-item flex flex-row
                                                  items-center gap-3
                                                  px-3 py-2 rounded-lg
                                                  no-underline
                                                  text-onyx-500
                                                  dark:text-stone-300
                                                  hover:bg-stone-500/25
                                                  dark:hover:bg-onyx-500/25
                                                  focus-visible:outline-2
                                                  focus-visible:outline-offset-2
                                                  outline-onyx-500))))
           (span (@ (class "flex-1")) ,label)
           ,@(if hint
                 (list `(kbd (@ (class ,(mk-class
                                         '(ml-auto text-xs font-mono
                                                   text-onyx-300
                                                   dark:text-stone-500))))
                              ,hint))
                 '())))))

(define* (command-palette #:key id
                          (label "Command palette")
                          (placeholder "Type a command…")
                          commands
                          (empty-text "No matching commands")
                          (close-label "Close")
                          (classes '()))
  "Create a command palette, opened by a link and filtered as you type.

The palette is a dialog revealed by @code{:target}, like the drawer: an
anchor to @code{#commands} opens it and an anchor to @code{\"#\"} closes it,
so it works with scripting off and the URL states what is open. The input
filters the list in the browser, and the script that ships with the
framework adds arrow-key navigation and the common keyboard shortcut.

The list is a list of real links, which is what makes the palette useful in a
server-rendered page: every row is something that can be followed, not a
button whose meaning lives in a client-side handler.

@table @var
@item id
The identifier the opening link targets.
@item label
The accessible name of the dialog and its list.
@item placeholder
The input's placeholder. Defaults to @code{\"Type a command…\"}.
@item commands
A list of @code{command-item} nodes.
@item empty-text
What the palette says when the filter matches nothing.
@item close-label
The accessible name of the backdrop's close control.
@item classes
Extra classes for the panel.
@end table

@example
(command-palette #:id \"commands\"
                 #:commands (list (command-item \"Home\" #:href \"/\")))
@end example"
  (let ((input-id (format #f "~a-input" id))
        (list-id (format #f "~a-list" id))
        (title-id (format #f "~a-title" id)))
    (list `(div (@ (id ,id)
                   (role "dialog")
                   (aria-modal "true")
                   (aria-labelledby ,title-id)
                   (data-hg-command-palette "")
                   (class "hg-command-palette"))
                (a (@ (href "#")
                      (aria-label ,close-label)
                      (class "hg-command-backdrop"))
                   "")
                (div (@ (class ,(mk-class (append '(hg-command-panel)
                                                  classes))))
                     (h2 (@ (id ,title-id)
                            (class "sr-only"))
                         ,label)
                     (label (@ (for ,input-id)
                               (class "sr-only"))
                            ,placeholder)
                     (input (@ (id ,input-id)
                               (type "search")
                               (placeholder ,placeholder)
                               (autocomplete "off")
                               (data-hg-command-input "")
                               (aria-controls ,list-id)
                               (aria-autocomplete "list")
                               (class ,(mk-class '(hg-command-input w-full
                                                                    px-4 py-3
                                                                    rounded-xl
                                                                    border-2
                                                                    border-stone-700
                                                                    dark:border-onyx-100
                                                                    bg-stone-300/75
                                                                    dark:bg-onyx-700/75
                                                                    text-onyx-500
                                                                    dark:text-stone-300
                                                                    font-sans
                                                                    text-md
                                                                    focus-visible:outline-2
                                                                    focus-visible:outline-offset-2
                                                                    outline-onyx-500)))))
                     (ul (@ (id ,list-id)
                            (role "listbox")
                            (aria-label ,label)
                            (data-hg-command-list "")
                            (class ,(mk-class '(hg-command-list list-none
                                                                p-0 m-0 my-2
                                                                max-h-96
                                                                overflow-y-auto))))
                         ,@commands)
                     (p (@ (data-hg-command-empty "")
                           (class ,(mk-class '(hg-command-empty hidden
                                                                 text-sm
                                                                 font-light
                                                                 text-onyx-300
                                                                 dark:text-stone-500
                                                                 py-3 text-center))))
                        ,empty-text)
                     (p (@ (class ,(mk-class '(hg-command-footer text-xs
                                                                 font-light
                                                                 text-onyx-300
                                                                 dark:text-stone-500
                                                                 pt-2
                                                                 border-t-2
                                                                 border-stone-500/25
                                                                 dark:border-onyx-100/25))))
                        "↑↓ to navigate · Enter to open · Esc to close"))))
))