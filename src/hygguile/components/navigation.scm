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

(define-module (hygguile components navigation)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components glass)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:export (navbar nav-link
                   breadcrumbs
                   pagination
                   tabs
                   tab
                   section-nav
                   sidebar
                   sidebar-link
                   nav-rail
                   wizard))

;; One shade deeper than the glass panel's own tint: the bar spans the whole
;; viewport, so it has to hold its own against whatever it scrolls over
;; rather than read as a pane resting on a page.
(define navbar-tint
  '(bg-stone-300/75 dark:bg-onyx-700/75))

(define* (navbar content
                 #:key (brand #f)
                 (sticky #t)
                 (navbar-classes '(w-full px-4
                                          md:px-8
                                          py-4
                                          flex
                                          flex-row
                                          items-center
                                          justify-between
                                          gap-4
                                          shadow-md
                                          z-32)))
  "Create a top navigation bar shell.

The bar is a frosted glass surface like every other one in the framework: it
is built by @code{glass-panel}, which owns the frost (the translucent tint
and the backdrop blur), so the tint in @var{navbar-classes} is not the
bar's to invent. What the bar owns is its silhouette -- it spans the
viewport, so it has no rounding, no border and no padding of the panel's
own, and its layout lives in @var{navbar-classes}.

@table @var
@item content
The navigation content, typically a list of @code{nav-link} elements.
@item brand
An optional brand/logo node shown at the start of the bar.
@item sticky
A boolean pinning the bar to the top of the viewport. Defaults to true.
@item navbar-classes
List of symbols representing the bar's layout and place. A colour utility
among them replaces the panel's tint, so a bar can recolour its own glass.
@end table

@example
(navbar (list (nav-link \"Home\" #:href \"/\" #:active #t)) #:brand \"Hygguile\")
@end example"
  (glass-panel (append (if brand
                           (list `(div (@ (class ,(mk-class '(text-xl
                                                              font-bold
                                                              text-onyx-500
                                                              dark:text-stone-300))))
                                       ,brand))
                           '())
                       (list `(nav (@ (class ,(mk-class '(flex flex-row
                                                               flex-wrap
                                                               items-center
                                                               gap-4))))
                                   ,content)))
               #:tag 'header
               #:tint navbar-tint
               #:position (if sticky
                              '(sticky top-0)
                              '())
               #:rounding '()
               #:border '()
               #:shadow '()
               #:padding '()
               #:classes navbar-classes))

(define* (nav-link content
                   #:key href
                   (active #f)
                   (classes '(no-underline px-2
                                           py-1
                                           rounded-lg
                                           font-sans
                                           text-md
                                           font-medium
                                           transition-colors
                                           duration-150
                                           focus-visible:outline-2
                                           focus-visible:outline-offset-2
                                           outline-onyx-500))
                   (active-classes '(bg-stone-500/25 text-onyx-500
                                                     dark:bg-onyx-500/25
                                                     dark:text-stone-100))
                   (inactive-classes '(text-onyx-300 dark:text-stone-300
                                       hover:text-onyx-500
                                       dark:hover:text-stone-100)))
  "Create a navigation link with an optional active state.

When @var{active} is true, the link also carries @code{aria-current=\"page\"}
so assistive technology announces the current section. Links never
require JavaScript.

@table @var
@item content
The link label.
@item href
The destination URL.
@item active
A boolean marking this link as the current page.
@item classes
List of base link CSS classes.
@item active-classes
List of symbols applied when the link is active.
@item inactive-classes
List of symbols applied when the link is inactive.
@end table

@example
(nav-link \"Pricing\" #:href \"/pricing\")
@end example"
  `((a (@ (href ,href)
          ,@(attr-when active
                       'aria-current "page")
          (class ,(mk-class (append classes
                                    (if active active-classes inactive-classes)))))
       ,content)))

(define* (section-nav sections
                      #:key (label "Page sections")
                      (sticky? #t)
                      (scroll-spy? #t)
                      (classes '(my-2 rounded-2xl
                                      border-2
                                      border-stone-500/25
                                      dark:border-onyx-100/25
                                      bg-stone-100/75
                                      dark:bg-onyx-900/75
                                      hg-frost
                                      shadow-lg
                                      px-3
                                      py-3))
                      (list-classes '(flex flex-row flex-wrap gap-2 list-none
                                           p-0))
                      (link-classes '(no-underline rounded-512
                                                   px-3
                                                   py-1
                                                   text-sm
                                                   font-medium
                                                   bg-stone-100/50
                                                   dark:bg-onyx-900/50
                                                   border-2
                                                   border-stone-500/25
                                                   dark:border-onyx-100/25
                                                   hover:bg-stone-100/90
                                                   dark:hover:bg-onyx-900/75
                                                   transition-colors
                                                   duration-150))
                      (active-classes '(bg-stone-300/90 dark:bg-onyx-700/90
                                                        text-onyx-500
                                                        dark:text-stone-100))
                      (inactive-classes '(text-onyx-500 dark:text-stone-300)))
  "Create a rail of links to the sections of one page.

A page whose sections are stacked one under another is hard to move around
in, and a table of contents that scrolls away is no help once a reader is
past it. This rail is that list of links, frosted so it holds its own over
whatever it passes, and sticky from the small breakpoint up: any section
stays one tap away, and each link is an ordinary anchor, so it works with
JavaScript disabled and can be bookmarked or shared.

@table @var
@item sections
A list of @code{(id . label)} pairs, in the order the rail should show them. Each @var{id} is the identifier of the section it points at.
@item label
The accessible name of the rail, read out by assistive technology.
@item sticky?
Whether the rail follows the page from the small breakpoint up.
@item scroll-spy?
Whether the rail marks the section a reader is currently in. The marking is
done by the framework's scroll-spy script (a progressive enhancement), and
the attribute it needs is written only when the page asks for it. Defaults to
true.
@item classes
List of base CSS classes for the @code{<nav>}.
@item list-classes
List of CSS classes for the wrapping @code{<ul>}.
@item link-classes
List of CSS classes for every link.
@item active-classes
List of CSS classes applied to the link of the current section.
@item inactive-classes
List of CSS classes applied to the other links.
@end table

@example
(section-nav '((buttons . \"Buttons\") (forms . \"Forms\")))
@end example"
  `((nav (@ (aria-label ,label)
            ,@(attr-when scroll-spy?
                         'data-hg-scroll-spy "")
            (class ,(mk-class (append classes
                                      (if sticky?
                                          '(sm:sticky top-2 z-20)
                                          '())))))
         (ul (@ (class ,(mk-class list-classes)))
             ,@(map (lambda (section)
                      `(li ,(nav-link (cdr section)
                                      #:href (format #f "#~a"
                                                     (car section))
                                      #:classes link-classes
                                      #:active-classes active-classes
                                      #:inactive-classes inactive-classes)))
                    sections)))))

(define* (breadcrumbs #:key items
                      (separator "/")
                      (nav-class '(py-2))
                      (list-class '(flex flex-row
                                         flex-wrap
                                         items-center
                                         gap-2
                                         list-none
                                         font-sans
                                         text-sm
                                         font-light
                                         text-onyx-300
                                         dark:text-stone-500)))
  "Create an accessible breadcrumb trail from a list of nodes.

The trail is rendered as a @code{<nav>} with an ordered list, and the
final item is marked with @code{aria-current=\"page\"}. Breadcrumbs are
static markup and work without JavaScript.

@table @var
@item items
An ordered list of link or text nodes, from root to current page.
@item separator
The string shown between items. Defaults to @code{\"/\"}.
@item nav-class
List of symbols representing the nav wrapper CSS classes.
@item list-class
List of symbols representing the list CSS classes.
@end table

@example
(breadcrumbs #:items (list (a \"Home\" #:href \"/\") (a \"Docs\" #:href \"/docs\") (span \"API\")))
@end example"
  (let ((last-index (1- (length items))))
    `((nav (@ (aria-label "Breadcrumb")
              (class ,(mk-class nav-class)))
           (ol (@ (class ,(mk-class list-class)))
               ,@(map (lambda (index item)
                        `(li (@ ,@(attr-when (= index last-index)
                                             'aria-current "page")
                                (class ,(mk-class '(flex flex-row items-center
                                                         gap-2))))
                             ,@(if (> index 0)
                                   `((span (@ (aria-hidden "true")
                                              (class ,(mk-class '(text-onyx-300
                                                                  dark:text-stone-500))))
                                           ,separator))
                                   '())
                             ,item))
                      (iota (length items)) items))))))

(define* (pagination #:key (current 1)
                     total
                     (base-url "#")
                     (prev-label "← Previous")
                     (next-label "Next →")
                     (nav-class '(flex flex-row
                                       flex-wrap
                                       items-center
                                       gap-2
                                       my-4
                                       font-sans))
                     (link-class '(no-underline px-3
                                   py-1
                                   rounded-lg
                                   border-2
                                   border-stone-500/25
                                   text-onyx-300
                                   dark:text-stone-300
                                   font-medium
                                   text-sm
                                   transition-colors
                                   duration-150
                                   focus-visible:outline-2
                                   focus-visible:outline-offset-2
                                   outline-onyx-500))
                     ;; the current page is a filled pill, so it inverts with
                     ;; the theme: dark ink on a light pill when the page is
                     ;; dark, and the other way round when it is light. It
                     ;; replaces the base link's colour utilities instead of
                     ;; piling on top of them (see `override-classes'), which
                     ;; is what keeps the pill readable: two `text-' colours on
                     ;; the same variant would otherwise be resolved by
                     ;; stylesheet order.
                     (active-class '(bg-onyx-500 text-stone-100
                                                 dark:bg-stone-100
                                                 dark:text-onyx-900
                                                 border-onyx-300
                                                 dark:border-stone-500)))
  "Create page navigation for a paginated result set.

@table @var
@item current
The current page number, starting at @code{1}.
@item total
The total number of pages.
@item base-url
The URL prefix each page number is appended to. Defaults to @code{\"#\"}.
@item prev-label
The label for the previous-page link.
@item next-label
The label for the next-page link.
@item nav-class
List of symbols representing the nav wrapper CSS classes.
@item link-class
List of symbols representing a page link's base CSS classes.
@item active-class
List of symbols highlighting the current page link.
@end table

@example
(pagination #:current 2 #:total 5 #:base-url \"/blog?page=\")
@end example"
  `((nav (@ (aria-label "Pagination")
            (class ,(mk-class nav-class)))
         ,@(if (> current 1)
               `((a (@ (href ,(format #f "~a~a" base-url
                                      (1- current)))
                       (rel prev)
                       (class ,(mk-class link-class)))
                    ,prev-label))
               '())
         ,@(map (lambda (page)
                  `(a (@ (href ,(format #f "~a~a" base-url page))
                         ,@(attr-when (= page current)
                                      'aria-current "page")
                         (class ,(mk-class (if (= page current)
                                               (override-classes link-class
                                                                 active-class)
                                               link-class))))
                      ,(number->string page)))
                (iota total 1))
         ,@(if (< current total)
               `((a (@ (href ,(format #f "~a~a" base-url
                                      (1+ current)))
                       (rel next)
                       (class ,(mk-class link-class)))
                    ,next-label))
               '()))))

(define* (tab #:key id label content)
  "Describe a single tab for use with @code{tabs}.

@table @var
@item id
A short, group-unique identifier used to bind the tab, its label and its panel.
@item label
The visible label shown on the tab button.
@item content
The panel content fragments.
@end table

@example
(tab #:id \"billing\" #:label \"Billing\" #:content (list (p \"Invoices\")))
@end example"
  (list id label content))

(define* (tabs #:key tab-items
               (id #f)
               (selected #f)
               (tabs-class '(my-4 flex flex-col)))
  "Create a JavaScript-free tabbed interface.

Each tab is a hidden radio input paired with a visible label; selecting
a label reveals the matching panel purely through CSS
(@code{:checked} and @code{:has}). This means the component remains fully
functional with JavaScript disabled and is keyboard accessible, since the
underlying controls are native form elements.

@table @var
@item tab-items
A list of @code{tab} descriptors.
@item id
An optional group identifier; a unique one is generated when omitted.
@item selected
The id of the tab selected initially. Defaults to the first tab.
@item tabs-class
List of symbols representing the wrapper CSS classes.
@end table

@example
(tabs #:tab-items (list (tab #:id \"a\" #:label \"A\" #:content (list (p \"A\")))
                       (tab #:id \"b\" #:label \"B\" #:content (list (p \"B\")))))
@end example"
  (let* ((group (if id id
                    (symbol->string (gensym "hg-tabs"))))
         (selected-id (if selected selected
                          (car (car tab-items))))
         (field-id (lambda (t)
                     (format #f "~a-~a" group
                             (car t))))
         (label-id (lambda (t)
                     (format #f "~a-label"
                             (field-id t)))))
    `((div (@ (class ,(mk-class (append tabs-class
                                        '(hg-tabs)))))
           ,@(map (lambda (t)
                    `(input (@ (type "radio")
                               (name ,group)
                               (id ,(field-id t))
                               ,@(if (equal? (car t) selected-id)
                                     '((checked ""))
                                     '())
                               (class "hg-tab-input")))) tab-items)
           (div (@ (class "hg-tab-labels")
                   (role "tablist"))
                ,@(map (lambda (t)
                         `(label (@ (id ,(label-id t))
                                    (for ,(field-id t))
                                    (role "tab")
                                    (aria-selected ,(if (equal? (car t)
                                                                selected-id)
                                                        "true" "false"))
                                    (aria-controls ,(format #f "~a-panel"
                                                            (field-id t)))
                                    (class "hg-tab-label"))
                                 ,(cadr t))) tab-items))
           (div (@ (class "hg-tab-panels"))
                ,@(map (lambda (t)
                         `(div (@ (id ,(format #f "~a-panel"
                                               (field-id t)))
                                  (role "tabpanel")
                                  (aria-labelledby ,(label-id t))
                                  (class "hg-tab-panel"))
                               ,(caddr t))) tab-items))))))



;; ===== Sidebars and rails =====

(define* (sidebar-link label
                       #:key href
                       (icon #f)
                       (active #f)
                       (badge #f)
                       (classes '()))
  "Create one link of a sidebar, with an optional icon and badge.

The link marks the page it is on with @code{aria-current=\"page\"}, so a
screen reader announces the current item the same way the stylesheet paints
it.

@table @var
@item label
The link text.
@item href
The destination.
@item icon
An optional Phosphor icon name shown before the label.
@item active
Whether this is the current page.
@item badge
An optional short count or label shown at the end of the row.
@item classes
Extra classes for the link.
@end table

@example
(sidebar-link \"Settings\" #:href \"/settings\" #:icon 'gear)
@end example"
  (let* ((icon-node (if icon
                        (list `(i (@ (class ,(mk-class
                                              (list 'ph
                                                    (string->symbol
                                                     (format #f "ph-~a" icon))
                                                    'text-lg 'shrink-0))))))
                        '()))
         (badge-node (if badge
                         (list `(span (@ (class ,(mk-class
                                                  '(hg-sidebar-badge text-xs
                                                                     font-medium
                                                                     px-2 py-0.5
                                                                     rounded-512
                                                                     bg-stone-500/25
                                                                     dark:bg-onyx-500/25))))
                                      ,badge))
                         '()))
         (children (append icon-node
                           (list `(span (@ (class "flex-1")) ,label))
                           badge-node))
         (link-classes (append '(hg-sidebar-link flex flex-row items-center
                                                  gap-2 px-3 py-2 rounded-lg
                                                  no-underline text-onyx-300
                                                  dark:text-stone-300
                                                  hover:bg-stone-500/25
                                                  dark:hover:bg-onyx-500/25
                                                  transition-colors duration-150
                                                  focus-visible:outline-2
                                                  focus-visible:outline-offset-2
                                                  outline-onyx-500)
                               (if active
                                   '(bg-stone-500/25 text-onyx-500
                                     dark:bg-onyx-500/25 dark:text-stone-100)
                                   '())
                               classes)))
    (list `(li (@ (class "hg-sidebar-item"))
               (a (@ (href ,href)
                     ,@(attr-when active 'aria-current "page")
                     (class ,(mk-class link-classes)))
                  ,@children)))))

(define (sidebar-section-node section current)
  "Render one @code{(heading . items)} section of a sidebar."
  (let* ((heading (car section))
         (items (cdr section))
         (item-nodes (map (lambda (item)
                            (if (and (pair? item)
                                     (string? (cdr item)))
                                (sidebar-link (car item)
                                              #:href (cdr item)
                                              #:active (and current
                                                            (string=? current
                                                                      (cdr item))))
                                item))
                          items)))
    `(div (@ (class "hg-sidebar-section mb-4"))
          ,@(if heading
                (list `(p (@ (class ,(mk-class '(hg-sidebar-heading px-3 py-1
                                                                 text-xs
                                                                 font-semibold
                                                                 uppercase
                                                                 tracking-wide
                                                                 text-onyx-300
                                                                 dark:text-stone-500))))
                         ,heading))
                '())
          (ul (@ (class "list-none p-0 m-0 flex flex-col gap-1"))
              ,@item-nodes))))

(define* (sidebar #:key (brand #f)
                  sections
                  (footer #f)
                  (label "Sidebar")
                  (current #f)
                  (sticky? #t)
                  (classes '()))
  "Create a vertical navigation sidebar, collapsing to a plain list on phones.

A sidebar is a page's own table of contents for an application: a brand at
the top, one or more groups of links, and an optional footer (usually a
settings link or an account block). It is a real @code{<nav>} with a label,
each link is an ordinary anchor, and the current page is marked with
@code{aria-current}. From the large breakpoint up it can stick beside the
content; below it, it is simply a list above the page.

@table @var
@item brand
An optional node shown at the top.
@item sections
A list of @code{(heading . items)} pairs. Each item is either a
@code{(label . href)} pair or a node built with @code{sidebar-link}.
@item footer
An optional node shown at the bottom.
@item label
The accessible name of the navigation region.
@item current
The href of the current page, used to mark the active link.
@item sticky?
Whether the sidebar sticks from the large breakpoint up.
@item classes
Extra classes for the sidebar.
@end table

@example
(sidebar #:brand \"LucidPlan\"
         #:current \"/projects\"
         #:sections '((\"Work\" (\"Projects\" . \"/projects\")
                               (\"Reports\" . \"/reports\"))
                      (\"Account\" (\"Settings\" . \"/settings\"))))
@end example"
  (let* ((section-nodes (map (lambda (section)
                               (sidebar-section-node section current))
                             sections))
         (sticky-classes (if sticky?
                             '(lg:sticky lg:top-4 lg:self-start)
                             '())))
    (list `(nav (@ (aria-label ,label)
                   (class ,(mk-class (append '(hg-sidebar w-full
                                                          flex flex-col
                                                          gap-2 p-3
                                                          rounded-2xl
                                                          border-2
                                                          border-stone-500/25
                                                          dark:border-onyx-100/25
                                                          bg-stone-100/75
                                                          dark:bg-onyx-900/50)
                                             sticky-classes classes))))
                ,@(if brand
                      (list `(div (@ (class ,(mk-class '(px-3 py-2 text-lg
                                                                  font-bold
                                                                  text-onyx-500
                                                                  dark:text-stone-300))))
                                  ,brand))
                      '())
                ,@section-nodes
                ,@(if footer
                      (list `(div (@ (class "hg-sidebar-footer mt-auto
                                              border-t-2
                                              border-stone-500/25
                                              dark:border-onyx-100/25
                                              pt-3"))
                                  ,footer))
                      '())))))

(define* (nav-rail #:key items
                   (label "Primary")
                   (current #f)
                   (classes '()))
  "Create a narrow icon rail for a primary navigation.

Each item is a triple, @code{(icon label href)}: the icon is what is drawn,
and the label is what assistive technology reads and what a mouse reader
sees in the browser's own tooltip. A rail is the right shape for a desktop
application with a persistent set of destinations and no room for words;
the labels are still there in the markup, which is what keeps it usable.

@table @var
@item items
A list of @code{(icon label href)} triples.
@item label
The accessible name of the navigation region.
@item current
The href of the current page.
@item classes
Extra classes for the rail.
@end table

@example
(nav-rail #:items '((house \"Home\" \"/\") (gear \"Settings\" \"/settings\")))
@end example"
  (let ((links (map (lambda (item)
                      (let ((icon (list-ref item 0))
                            (item-label (list-ref item 1))
                            (href (list-ref item 2)))
                        `(li (a (@ (href ,href)
                                   (title ,item-label)
                                   ,@(attr-when (and current
                                                     (string=? current href))
                                                'aria-current "page")
                                   (class ,(mk-class (append '(hg-nav-rail-link
                                                               inline-flex
                                                               items-center
                                                               justify-center
                                                               w-12 h-12
                                                               rounded-xl
                                                               no-underline
                                                               text-onyx-300
                                                               dark:text-stone-300
                                                               hover:bg-stone-500/25
                                                               dark:hover:bg-onyx-500/25
                                                               transition-colors
                                                               duration-150
                                                               focus-visible:outline-2
                                                               focus-visible:outline-offset-2
                                                               outline-onyx-500)
                                                             (if (and current
                                                                      (string=?
                                                                       current
                                                                       href))
                                                                 '(bg-stone-500/25
                                                                   text-onyx-500
                                                                   dark:bg-onyx-500/25
                                                                   dark:text-stone-100)
                                                                 '())))))
                               (i (@ (class ,(mk-class (list 'ph
                                                             (string->symbol
                                                              (format #f
                                                                      "ph-~a"
                                                                      icon))
                                                             'text-2xl)))))
                               (span (@ (class "sr-only")) ,item-label)))))
                    items)))
    (list `(nav (@ (aria-label ,label)
                   (class ,(mk-class (append '(hg-nav-rail inline-flex
                                                            flex-col
                                                            gap-1 p-2
                                                            rounded-2xl
                                                            border-2
                                                            border-stone-500/25
                                                            dark:border-onyx-100/25
                                                            bg-stone-100/75
                                                            dark:bg-onyx-900/50)
                                             classes))))
                (ul (@ (class "list-none p-0 m-0 flex flex-col gap-1"))
                    ,@links)))))

;; ===== Wizards =====

(define (wizard-step-label step)
  "Return the label of a wizard step, which may be a pair or a string."
  (if (pair? step)
      (car step)
      step))

(define (wizard-step-href step)
  "Return the href of a wizard step, or @code{#f}."
  (and (pair? step)
       (cdr step)))

(define (wizard-step-node step index current-index numbered?)
  "Render one step of a @code{wizard}."
  (let* ((step-label (wizard-step-label step))
         (href (wizard-step-href step))
         (complete? (< index current-index))
         (active? (= index current-index))
         (state-class (cond
                        (complete? 'hg-wizard-complete)
                        (active? 'hg-wizard-current)
                        (else 'hg-wizard-upcoming)))
         (marker (if numbered?
                     (list `(span (@ (class ,(mk-class
                                              '(hg-wizard-marker inline-flex
                                                                 items-center
                                                                 justify-center
                                                                 w-8 h-8
                                                                 rounded-512
                                                                 border-2
                                                                 font-semibold
                                                                 font-sans
                                                                 shrink-0))))
                                  ,(if complete?
                                       "✓"
                                       (format #f "~a" index))))
                     '()))
         (text (list `(span (@ (class ,(mk-class '(hg-wizard-label
                                                   font-medium font-sans))))
                            ,step-label)))
         (content (append marker text))
         (link-classes "hg-wizard-link inline-flex items-center gap-2
                        text-onyx-300 dark:text-stone-300"))
    `(li (@ (class ,(mk-class (list 'hg-wizard-step state-class))))
         ,(if href
              `(a (@ (href ,href)
                     ,@(attr-when active? 'aria-current "step")
                     (class ,link-classes))
                  ,@content)
              `(span (@ ,@(attr-when active? 'aria-current "step")
                        (class ,link-classes))
                     ,@content)))))

(define* (wizard #:key steps
                 current
                 (label "Progress")
                 (orientation 'horizontal)
                 (numbered? #t)
                 (classes '()))
  "Create the ordered steps of a multi-step form or a checkout.

The list is a real @code{<ol>}, because the order is the point, and the step
the reader is on carries @code{aria-current=\"step\"}. Steps before it are
marked complete, steps after it are marked upcoming, and every step that has
an href is a link so a reader can go back. Nothing here needs a script: the
server knows which step it rendered, and that is the state the page shows.

@table @var
@item steps
A list of steps, each a label string or a @code{(label . href)} pair.
@item current
The 1-based index of the current step, or its label.
@item label
The accessible name of the navigation region.
@item orientation
@code{'horizontal} (default) or @code{'vertical}.
@item numbered?
Whether each step shows its number (or a check when complete).
@item classes
Extra classes for the wrapper.
@end table

@example
(wizard #:steps '((\"Cart\" . \"/cart\") (\"Address\") (\"Payment\"))
        #:current 2)
@end example"
  (let* ((current-index (cond
                          ((number? current) current)
                          ((string? current)
                           (let loop ((rest steps) (index 1))
                             (cond
                               ((null? rest) 1)
                               ((equal? (wizard-step-label (car rest)) current)
                                index)
                               (else (loop (cdr rest) (+ index 1))))))
                          (else 1)))
         (step-nodes (map (lambda (step index)
                            (wizard-step-node step index current-index
                                              numbered?))
                          steps (iota (length steps) 1)))
         (orientation-classes (if (eq? 'vertical orientation)
                                  '(flex-col items-start)
                                  '(flex-row flex-wrap items-center))))
    (list `(nav (@ (aria-label ,label)
                   (class ,(mk-class (append '(hg-wizard) classes))))
                (ol (@ (class ,(mk-class (append '(list-none p-0 m-0 flex
                                                                   gap-3)
                                                 orientation-classes))))
                    ,@step-nodes)))))
