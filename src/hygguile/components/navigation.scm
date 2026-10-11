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
  #:use-module (srfi srfi-1)
  #:export (navbar nav-link breadcrumbs pagination tabs tab))

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
                    (symbol->string (gensym "hg-tabs"))))         (selected-id (if selected selected (car (car tab-items))))
         (field-id (lambda (t) (format #f "~a-~a" group (car t))))
         (label-id (lambda (t) (format #f "~a-label" (field-id t)))))
    `((div (@ (class ,(mk-class (append tabs-class '(hg-tabs)))))
           ,@(map (lambda (t)
                    `(input (@ (type "radio")
                               (name ,group)
                               (id ,(field-id t))
                               ,@(if (equal? (car t) selected-id)
                                     '((checked ""))
                                     '())
                               (class "hg-tab-input"))))
                  tab-items)
           (div (@ (class "hg-tab-labels")
                   (role "tablist"))
                ,@(map (lambda (t)
                         `(label (@ (id ,(label-id t))
                                    (for ,(field-id t))
                                    (role "tab")
                                    (aria-selected ,(if (equal? (car t)
                                                                selected-id)
                                                        "true"
                                                        "false"))
                                    (aria-controls ,(format #f "~a-panel"
                                                            (field-id t)))
                                    (class "hg-tab-label"))
                                 ,(cadr t)))
                       tab-items))
           (div (@ (class "hg-tab-panels"))
                ,@(map (lambda (t)
                         `(div (@ (id ,(format #f "~a-panel" (field-id t)))
                                  (role "tabpanel")
                                  (aria-labelledby ,(label-id t))
                                  (class "hg-tab-panel"))
                               ,(caddr t)))
                       tab-items))))))
