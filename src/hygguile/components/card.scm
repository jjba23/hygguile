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

(define-module (hygguile components card)
  #:use-module (hygguile abstraction)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:use-module (hygguile components typography)
  #:export (card card-header
                 card-body
                 card-footer
                 card-title
                 card-description
                 badge
                 stat-card
                 expandable-card))

(define* (card content
               #:key (card-classes '(bg-stone-300/75 dark:bg-onyx-700/75
                                                     rounded-xl
                                                     shadow-md
                                                     border-2
                                                     border-stone-500/50
                                                     dark:border-onyx-100/50
                                                     overflow-hidden
                                                     my-4
                                                     flex
                                                     flex-col)))
  "Create a surface container grouping related content.

Compose a card from @code{card-header}, @code{card-body} and
@code{card-footer} fragments, or place any content inside directly.

@table @var
@item content
The inner content or section fragments of the card.
@item card-classes
List of symbols representing container CSS classes.
@end table

@example
(card (list (card-header (h3 \"Title\")) (card-body (p \"Body\"))))
@end example"
  `((div (@ (class ,(mk-class card-classes)))
         ,content)))

(define* (card-header content
                      #:key (header-classes '(px-6 py-4
                                                   flex
                                                   flex-row
                                                   items-center
                                                   justify-between
                                                   gap-2
                                                   border-2
                                                   border-stone-500/10
                                                   dark:border-onyx-100/10
                                                   bg-stone-300/75
                                                   dark:bg-onyx-700/75)))
  "Create the header section of a card.

@table @var
@item content
The header content fragments.
@item header-classes
List of symbols representing header CSS classes.
@end table

@example
(card-header (h3 \"Recent activity\"))
@end example"
  `((header (@ (class ,(mk-class header-classes)))
            ,content)))

(define* (card-body content
                    #:key (body-classes '(px-6 py-5 flex flex-col gap-2)))
  "Create the main body section of a card.

@table @var
@item content
The body content fragments.
@item body-classes
List of symbols representing body CSS classes.
@end table

@example
(card-body (p \"Everything you need to know.\"))
@end example"
  `((div (@ (class ,(mk-class body-classes)))
         ,content)))

(define* (card-footer content
                      #:key (footer-classes '(px-6 py-4
                                                   flex
                                                   flex-row
                                                   items-center
                                                   justify-end
                                                   gap-3
                                                   bg-stone-300/75
                                                   dark:bg-onyx-700/75)))
  "Create the footer section of a card, typically holding actions.

@table @var
@item content
The footer content fragments.
@item footer-classes
List of symbols representing footer CSS classes.
@end table

@example
(card-footer (list (submit-button \"Save\")))
@end example"
  `((footer (@ (class ,(mk-class footer-classes)))
            ,content)))

(define* (card-title content
                     #:key (classes '(text-xl font-semibold text-onyx-500
                                              dark:text-stone-300 font-sans)))
  "Create a card heading.

@table @var
@item content
The heading text or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(card-title \"Account summary\")
@end example"
  `((h3 (@ (class ,(mk-class classes)))
        ,content)))

(define* (card-description content
                           #:key (classes '(text-md font-light text-onyx-300
                                                    dark:text-stone-500
                                                    font-sans leading-6)))
  "Create muted descriptive copy inside a card.

@table @var
@item content
The description text or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(card-description \"Updated 3 minutes ago.\")
@end example"
  `((p (@ (class ,(mk-class classes)))
       ,content)))

(define* (badge content
                #:key (variant 'neutral)
                (size 'md))
  "Create a small status pill or label.

The @var{variant} argument picks a semantic color treatment while staying
readable in both light and dark themes: the fill is the dark end of the
ramp with near-white type on the light theme, and the light end with dark
type on the dark theme, so the label clears the 4.5:1 ratio of WCAG AA.

@table @var
@item content
The label text or inline nodes.
@item variant
A semantic keyword: @code{'neutral}, @code{'info}, @code{'success}, @code{'warning} or @code{'danger}.
@item size
A size keyword: @code{'sm}, @code{'md} or @code{'lg}.
@end table

@example
(badge \"New\" #:variant 'success)
@end example"
  (let* ((variant-classes (cond
                            ((eq? 'info variant)
                             '(bg-jeans-blue-500 text-stone-100
                                                 dark:bg-jeans-blue-700))
                            ((eq? 'success variant)
                             '(bg-asparagus-900 text-stone-100
                                                dark:bg-asparagus-100
                                                dark:text-onyx-900))
                            ((eq? 'warning variant)
                             '(bg-naples-yellow-500 text-onyx-500
                                                    dark:bg-naples-yellow-700))
                            ((eq? 'danger variant)
                             '(bg-redwood-900 text-stone-100
                                              ;; light-coral rather than
                                              ;; redwood: 6.9:1 behind the
                                              ;; near-black ink instead of 4.7
                                              dark:bg-light-coral-100
                                              dark:text-onyx-900))
                            (else '(bg-stone-500/75 text-onyx-500
                                                    dark:bg-onyx-500/75
                                                    dark:text-stone-300))))
         (size-classes (cond
                         ((eq? 'sm size)
                          '(text-xs px-2 py-1))
                         ((eq? 'lg size)
                          '(text-md px-4 py-1))
                         (else '(text-sm px-3 py-1))))
         (badge-css (append variant-classes size-classes
                            '(inline-flex items-center
                                          gap-1
                                          rounded-512
                                          font-medium
                                          font-sans
                                          uppercase
                                          tracking-wide))))
    `((span (@ (class ,(mk-class badge-css)))
            ,content))))

(define* (expandable-card content
                          #:key (id #f)
                          title
                          icon
                          (tag #f)
                          (open #f)
                          (wide? #f)
                          (data '())
                          (card-classes '(hg-expandable-card rounded-2xl
                                          border-2
                                          border-stone-500/25
                                          dark:border-onyx-100/25
                                          bg-stone-100/75
                                          dark:bg-onyx-900/50
                                          hg-frost
                                          shadow-sm))
                          (summary-classes '(hg-expandable-summary list-none
                                             cursor-pointer
                                             select-none
                                             flex
                                             flex-row
                                             flex-wrap
                                             items-center
                                             gap-2
                                             px-4
                                             py-3
                                             transition-colors
                                             duration-150
                                             focus-visible:outline-2
                                             focus-visible:outline-offset-2
                                             outline-onyx-500))
                          (body-classes '(px-4 pb-4 flex flex-col gap-6)))
  "Create a card that opens in place, its header doubling as the disclosure control.

The card is a native @code{<details>}, so it opens and closes with no
JavaScript at all, and @var{id} is placed on the @code{<summary>} rather
than on the @code{<details>}: a link to that id then points *inside* the
card, which is what makes a browser open it as it scrolls there, and the
summary is the header a reader should land on.

@table @var
@item content
The nodes revealed while the card is open.
@item id
An optional HTML identifier, placed on the summary, for a link to land on.
@item title
The card's title, rendered as a real heading inside the summary.
@item icon
An optional Phosphor icon name shown before the title, e.g. @code{'cards}.
@item tag
An optional short label shown as a badge beside the title, such as the
category a card belongs to.
@item open
Whether the card starts open.
@item wide?
Whether the card spans the whole row of a grid it is placed in.
@item data
An association list of @code{data-*} attributes rendered on the
@code{<details>}, named without the @code{data-} prefix. These are what a
@code{sort-control} orders a tray of cards by, and a card carries as many as
the orderings you intend to offer: @code{'((order . \"0\") (title . \"Cards\"))}.
@item card-classes
List of additional container CSS classes.
@item summary-classes
List of CSS classes for the header, which is the disclosure control.
@item body-classes
List of CSS classes for the layer holding @var{content}.
@end table

@example
(expandable-card (p \"Cards group related content together.\")
                 #:id \"cards\"
                 #:title \"Cards\"
                 #:icon 'cards
                 #:tag \"Layout\"
                 #:open #t
                 #:data '((order . \"0\") (title . \"Cards\")))
@end example"
  (let ((attributes (map (lambda (pair)
                           (list (string->symbol (format #f "data-~a"
                                                         (car pair)))
                                 (cdr pair))) data)))
    `((details (@ ,@(attr-when open
                               'open "")
                  ,@attributes
                  (class ,(mk-class (append card-classes
                                            (if wide?
                                                '(lg:col-span-2)
                                                '())))))
               (summary (@ ,@(attr-when id
                                        'id id)
                           (class ,(mk-class summary-classes)))
                        ,@(render-if-nempty (lambda (name)
                                              (list (hyg:icon #:type name
                                                              #:icon-css '(text-xl
                                                                           text-onyx-300
                                                                           dark:text-stone-500))))
                                            icon)
                        ,(sub-h2 title)
                        ,@(render-if-nempty (lambda (text)
                                              ;; the shelf a section belongs to
                                              ;; is read before the section
                                              ;; itself, so the chip is set at
                                              ;; body size rather than as the
                                              ;; smallest thing on the card
                                              (list (badge text
                                                           #:size 'lg))) tag)
                        (span (@ (class ,(mk-class '(hg-expandable-chevron
                                                     ml-auto
                                                     font-light
                                                     text-xl
                                                     text-onyx-300
                                                     dark:text-stone-300
                                                     transition-transform
                                                     duration-200)))) "⌄"))
               (div (@ (class ,(mk-class body-classes)))
                    ,content)))))

(define* (stat-card #:key value
                    label
                    (trend #f)
                    (trend-variant 'success)
                    (classes '()))
  "Create a compact key-figure block for dashboards and summary panels.

@table @var
@item value
The prominent value to display, such as a number or short string.
@item label
A short descriptive label rendered below the value.
@item trend
An optional trend string, e.g. @code{\"+12%\"}.
@item trend-variant
A semantic keyword controlling the trend color: @code{'success}, @code{'danger} or @code{'neutral}.
@item classes
List of additional utility CSS classes.
@end table

@example
(stat-card #:value \"1,204\" #:label \"Active users\" #:trend \"+12%\")
@end example"
  (let ((trend-classes (cond
                         ((eq? 'danger trend-variant)
                          '(text-redwood-700 dark:text-light-coral-100))
                         ((eq? 'neutral trend-variant)
                          '(text-onyx-300 dark:text-stone-500))
                         (else '(text-asparagus-900 dark:text-asparagus-100)))))
    `((div (@ (class ,(mk-class (append classes
                                        '(flex flex-col gap-1 my-2)))))
           (span (@ (class ,(mk-class '(text-3xl font-bold text-onyx-500
                                                 dark:text-stone-300 font-sans
                                                 tabular-nums))))
                 ,value)
           (span (@ (class ,(mk-class '(text-sm font-light text-onyx-300
                                                dark:text-stone-500 font-sans))))
                 ,label)
           ,@(if trend
                 `((span (@ (class ,(mk-class (append trend-classes
                                                      '(text-sm font-medium
                                                                font-sans)))))
                         ,trend))
                 '())))))
