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

(define-module (hygguile components data)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components media)
  #:use-module ((hygguile components icon)
                #:prefix hyg:)
  #:export (chip
                   avatar-group
                   timeline timeline-item
                   tree-view tree-item))

;; ===== Data display =====
;;
;; The small pieces a page puts around its data: a tag on a row, a stack of
;; faces, a history in order, a hierarchy the reader can open. None of them
;; owns a data set; each is a shape for one, and every one of them is plain
;; markup with no script behind it. The loading, empty and error shapes that
;; belong beside them live in `(hygguile components feedback)', so a page can
;; say "this is a timeline", "this timeline is still loading" and "this
;; timeline could not load" with the same vocabulary.

;; ===== Chips =====

(define* (chip content
               #:key (variant 'neutral)
               (size 'md)
               (href #f)
               (icon #f)
               (remove-href #f)
               (remove-label "Remove")
               (classes '()))
  "Create a small tag or chip, optionally removable.

A chip is a badge that belongs to the content rather than to a status: a
topic on a post, a filter that is on, a recipient in a compose window. It can
be a link (a filter that navigates to its own removal) and it can carry a
remove control, which is also a link, so removing a filter is a plain
navigation and works with scripting off.

@table @var
@item content
The chip's label.
@item variant
@code{'neutral} (default), @code{'info}, @code{'success}, @code{'warning}
or @code{'danger}.
@item size
@code{'sm}, @code{'md} or @code{'lg}.
@item href
An optional destination, turning the chip into a link.
@item icon
An optional Phosphor icon name.
@item remove-href
An optional URL that removes the chip.
@item remove-label
The accessible name of the remove control.
@item classes
Extra classes for the chip.
@end table

@example
(chip \"Scheme\" #:variant 'info)
(chip \"Draft\" #:remove-href \"/posts/1?remove=draft\")
@end example"
  (let* ((variant-classes (cond
                            ((eq? 'info variant)
                             '(bg-jeans-blue-500/25 text-jeans-blue-900
                               dark:text-moonstone-100))
                            ((eq? 'success variant)
                             '(bg-asparagus-500/25 text-black-olive-900
                               dark:text-mantis-100))
                            ((eq? 'warning variant)
                             '(bg-naples-yellow-500/25 text-coffee-900
                               dark:text-naples-yellow-100))
                            ((eq? 'danger variant)
                             '(bg-redwood-500/25 text-claret-900
                               dark:text-light-coral-100))
                            (else '(bg-stone-500/25 text-onyx-500
                                   dark:bg-onyx-500/25
                                   dark:text-stone-300))))
         (size-classes (cond
                         ((eq? 'sm size) '(text-xs px-2 py-0.5))
                         ((eq? 'lg size) '(text-md px-3 py-1))
                         (else '(text-sm px-2 py-1))))
         (chip-classes (append '(hg-chip inline-flex items-center gap-1
                                          rounded-512 border-2
                                          border-stone-500/25
                                          dark:border-onyx-100/25
                                          font-medium font-sans no-underline)
                               variant-classes size-classes classes))
         (icon-node (if icon
                        (list (hyg:icon #:type icon
                                        #:icon-css '(text-sm shrink-0)))
                        '()))
         (remove-node (if remove-href
                          (list `(a (@ (href ,remove-href)
                                       (aria-label ,remove-label)
                                       (class "hg-chip-remove no-underline
                                               text-current opacity-70
                                               hover:opacity-100"))
                                    "×"))
                          '()))
         (children (append icon-node
                           (list `(span ,content))
                           remove-node)))
    (if href
        (list `(a (@ (href ,href)
                     (class ,(mk-class chip-classes)))
                  ,@children))
        (list `(span (@ (class ,(mk-class chip-classes)))
                     ,@children)))))

;; ===== Avatar groups =====

(define (avatar-overflow-node avatars max total)
  "Return the overflow badge of an avatar group, or an empty list."
  (if (> (avatar-overflow-count avatars max total) 0)
      (list `(span (@ (class ,(mk-class
                               '(hg-avatar-overflow inline-flex items-center
                                                     justify-center w-12 h-12
                                                     rounded-512 border-2
                                                     border-stone-500/50
                                                     dark:border-onyx-100/50
                                                     bg-stone-500/25
                                                     dark:bg-onyx-500/25
                                                     text-sm font-medium
                                                     text-onyx-500
                                                     dark:text-stone-300
                                                     font-sans shrink-0))))
                   ,(format #f "+~a"
                            (avatar-overflow-count avatars max total))))
      '()))

(define (avatar-overflow-count avatars max total)
  "How many avatars an avatar group hides."
  (- (or total (length avatars))
     (length (take avatars (min max (length avatars))))))

(define* (avatar-group avatars
                       #:key (max 4)
                       (size 'md)
                       (total #f)
                       (label #f)
                       (classes '()))
  "Stack several avatars into one group, with an overflow count.

The group shows @var{max} faces and then how many more there are. The
overflow is text, not an avatar, so it is read out as a count rather than as
a person; the group carries an optional accessible label so a screen reader
knows what the row of faces represents.

@table @var
@item avatars
A list of @code{avatar} nodes.
@item max
How many avatars to show before the overflow badge. Defaults to @code{4}.
@item size
The size of the overflow badge's text. Defaults to @code{'md}.
@item total
The real number of people, when @var{avatars} is a truncated list. Defaults
to the length of @var{avatars}.
@item label
An optional accessible name for the group.
@item classes
Extra classes for the group.
@end table

@example
(avatar-group (list (avatar #:src \"a.png\" #:alt \"Ada\")
                    (avatar #:src \"b.png\" #:alt \"Grace\")))
@end example"
  (list `(div (@ (class ,(mk-class (append '(hg-avatar-group inline-flex
                                                            flex-row
                                                            items-center
                                                            gap-1)
                                          classes)))
                 ,@(attr-when label 'aria-label label))
              ,@(take avatars (min max (length avatars)))
              ,@(avatar-overflow-node avatars max total))))

;; ===== Timelines =====

(define* (timeline-item #:key time
                        (datetime #f)
                        title
                        (body #f)
                        (icon #f)
                        (variant 'neutral)
                        (current? #f))
  "Create one entry of a @code{timeline}.

The marker is decorative, the time is marked up as a real @code{<time>} with
its machine-readable value, and the entry's heading says what happened. The
current entry carries @code{aria-current=\"step\"}, which is how a reader
learns where in the history the page is.

@table @var
@item time
The human-readable time shown beside the marker.
@item datetime
The ISO value for the @code{<time>} element.
@item title
The entry's heading.
@item body
Optional detail below the heading.
@item icon
An optional Phosphor icon name shown in the marker.
@item variant
@code{'neutral} (default), @code{'info}, @code{'success}, @code{'warning}
or @code{'danger}.
@item current?
Whether this is the entry in progress.
@end table

@example
(timeline-item #:time \"11 Oct\" #:title \"Deployed\")
@end example"
  (let* ((marker-classes (cond
                           ((eq? 'success variant)
                            '(bg-asparagus-900 text-stone-100
                              dark:bg-asparagus-100 dark:text-onyx-900))
                           ((eq? 'warning variant)
                            '(bg-naples-yellow-500 text-onyx-500
                              dark:bg-naples-yellow-700))
                           ((eq? 'danger variant)
                            '(bg-redwood-700 text-stone-100))
                           ((eq? 'info variant)
                            '(bg-jeans-blue-500 text-stone-100
                              dark:bg-jeans-blue-700))
                           (else '(bg-stone-500/50 text-onyx-500
                                   dark:bg-onyx-500/50
                                   dark:text-stone-300))))
         (marker `(span (@ (aria-hidden "true")
                           (class ,(mk-class (append '(hg-timeline-marker
                                                       inline-flex
                                                       items-center
                                                       justify-center
                                                       w-8 h-8
                                                       rounded-512
                                                       shrink-0
                                                       border-2
                                                       border-stone-500/50
                                                       dark:border-onyx-100/50)
                                                     marker-classes))))
                        ,@(if icon
                              (list (hyg:icon #:type icon
                                              #:icon-css '(text-md)))
                              '())))
         (time-node (if time
                        (list `(time (@ ,@(attr-when datetime
                                                     'datetime datetime)
                                       (class ,(mk-class
                                                '(text-xs font-medium
                                                          text-onyx-300
                                                          dark:text-stone-500
                                                          font-sans
                                                          tabular-nums))))
                                    ,time))
                        '()))
         (body-node (if body
                        (list `(p (@ (class ,(mk-class
                                               '(text-sm font-light
                                                         text-onyx-300
                                                         dark:text-stone-500
                                                         italic
                                                         leading-6))))
                                  ,body))
                        '())))
    `((li (@ (class ,(mk-class '(hg-timeline-item flex flex-row
                                                   items-start gap-3)))
              ,@(attr-when current? 'aria-current "step"))
           ,marker
           (div (@ (class ,(mk-class '(flex flex-col gap-1 min-w-0))))
                (div (@ (class ,(mk-class '(flex flex-row flex-wrap
                                                   items-center gap-2))))
                     ,@time-node
                     (h4 (@ (class ,(mk-class '(text-md font-semibold
                                                        text-onyx-500
                                                        dark:text-stone-300
                                                        font-sans))))
                         ,title))
                ,@body-node)))))

(define* (timeline items
                   #:key (label "Timeline")
                   (classes '()))
  "Create an ordered history from @code{timeline-item} nodes.

The list is an @code{<ol>}, because a timeline is order rather than a set,
and the order is what the reader came for.

@table @var
@item items
A list of @code{timeline-item} nodes.
@item label
The accessible name of the list.
@item classes
Extra classes for the wrapper.
@end table

@example
(timeline (list (timeline-item #:time \"11 Oct\" #:title \"Deployed\")))
@end example"
  `((ol (@ (aria-label ,label)
           (class ,(mk-class (append '(hg-timeline flex flex-col gap-4
                                                    list-none p-0 m-0 my-4)
                                     classes))))
        ,@items)))

;; ===== Tree views =====

(define (tree-summary-node label icon-list)
  "Return the summary row of a tree branch."
  `(summary (@ (class ,(mk-class
                        '(hg-tree-summary cursor-pointer select-none
                                          flex flex-row items-center gap-2
                                          px-2 py-1 rounded-lg
                                          text-onyx-500 dark:text-stone-300
                                          font-medium font-sans text-md
                                          list-none
                                          hover:bg-stone-500/25
                                          dark:hover:bg-onyx-500/25
                                          focus-visible:outline-2
                                          focus-visible:outline-offset-2
                                          outline-onyx-500))))
            ,@icon-list
            (span ,label)))

(define (tree-branch-node label children icon-list open classes)
  "Return one branch of a tree view."
  `(li (@ (class ,(mk-class (append '(hg-tree-branch) classes))))
       (details (@ ,@(if open '((open "")) '()))
                ,(tree-summary-node label icon-list)
                (ul (@ (class ,(mk-class
                                '(hg-tree-children list-none pl-6 m-0
                                                   flex flex-col gap-1))))
                    ,@children))))

(define (tree-leaf-node label href icon-list classes)
  "Return one leaf of a tree view."
  `(li (@ (class ,(mk-class (append '(hg-tree-leaf) classes))))
       (a (@ ,@(attr-when href 'href href)
             (class ,(mk-class
                      '(hg-tree-link flex flex-row items-center gap-2
                                     px-2 py-1 rounded-lg no-underline
                                     text-onyx-500 dark:text-stone-300
                                     font-medium font-sans text-md
                                     hover:bg-stone-500/25
                                     dark:hover:bg-onyx-500/25
                                     focus-visible:outline-2
                                     focus-visible:outline-offset-2
                                     outline-onyx-500))))
          ,@icon-list
          (span ,label))))

(define* (tree-item label
                    #:key (href #f)
                    (children '())
                    (open #f)
                    (icon #f)
                    (classes '()))
  "Create one node of a @code{tree-view}.

A node with children is a native @code{<details>}, so the tree opens and
closes with no script; a leaf is a link. That combination is the smallest
thing that is both a hierarchy and a set of destinations, and it stays
usable when the browser cannot run a tree widget's keyboard model.

@table @var
@item label
The node's text.
@item href
The destination for a leaf node.
@item children
Child @code{tree-item} nodes, for a branch.
@item open
Whether a branch starts open.
@item icon
An optional Phosphor icon name.
@item classes
Extra classes for the node.
@end table

@example
(tree-item \"Docs\" #:children (list (tree-item \"Install\" #:href \"/install\")))
@end example"
  (let ((icon-list (if icon
                       (list (hyg:icon #:type icon
                                       #:icon-css '(text-md shrink-0)))
                       '())))
    (if (null? children)
        (list (tree-leaf-node label href icon-list classes))
        (list (tree-branch-node label children icon-list open classes)))))

(define* (tree-view #:key items
                    (label "Tree")
                    (classes '()))
  "Create a navigable hierarchy from @code{tree-item} nodes.

@table @var
@item items
A list of @code{tree-item} nodes.
@item label
The accessible name of the tree's navigation region.
@item classes
Extra classes for the wrapper.
@end table

@example
(tree-view #:items (list (tree-item \"Docs\"
                                    #:children (list (tree-item \"Install\"
                                                                #:href \"/install\")))))
@end example"
  `((nav (@ (aria-label ,label)
            (class ,(mk-class (append '(hg-tree) classes))))
         (ul (@ (class "list-none p-0 m-0 flex flex-col gap-1"))
             ,@items))))
