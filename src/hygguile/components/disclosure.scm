;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components disclosure)
  #:use-module (hygguile abstraction)
  #:use-module (uuid generate)
  #:export (details summary accordion accordion-item modal tooltip))

(define* (summary content
                  #:key (classes '(cursor-pointer font-medium
                                   text-onyx-500
                                   dark:text-stone-300
                                   font-sans
                                   py-2
                                   transition-colors
                                   duration-150
                                   focus-visible:outline-2
                                   focus-visible:outline-offset-2
                                   outline-onyx-500)))
  "Create an HTML @code{<summary>} disclosure caption for @code{details}.

@table @var
@item content
The summary text or inline nodes.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(summary \"Advanced options\")
@end example"
  `((summary (@ (class ,(mk-class classes)))
             ,content)))

(define* (details content
                  #:key summary
                  (open #f)
                  (details-classes '(border-2 border-stone-500/25
                                              dark:border-onyx-100/25
                                              rounded-xl
                                              px-4
                                              py-2
                                              my-2
                                              bg-stone-300/75
                                              dark:bg-onyx-700/75))
                  (body-classes '(py-2 flex flex-col gap-2)))
  "Create a native HTML @code{<details>} disclosure element.

The element expands and collapses with no JavaScript at all, relying on
the browser's built-in disclosure behaviour.

@table @var
@item content
The collapsible body content.
@item summary
The summary caption rendered in the always-visible header. Accepts a
string or a @code{summary} node.
@item open
A boolean expanding the disclosure by default.
@item details-classes
List of symbols representing the wrapper CSS classes.
@item body-classes
List of symbols representing the collapsible body CSS classes.
@end table

@example
(details (list (p \"Hidden details\")) #:summary \"Show more\")
@end example"
  `((details (@ ,@(if open
                      '((open ""))
                      '())
                (class ,(mk-class details-classes)))
             ,@(if summary
                   `((summary (@ (class ,(mk-class '(cursor-pointer
                                                     font-medium
                                                     text-onyx-500
                                                     dark:text-stone-300
                                                     font-sans
                                                     py-2
                                                     transition-colors
                                                     duration-150
                                                     focus-visible:outline-2
                                                     focus-visible:outline-offset-2
                                                     outline-onyx-500))))
                              ,summary))
                   '())
             (div (@ (class ,(mk-class body-classes)))
                  ,content))))

(define* (accordion-item #:key summary content
                         (open #f))
  "Create a single accordion row backed by a native @code{details} element.

@table @var
@item summary
The always-visible row title.
@item content
The collapsible row body.
@item open
A boolean expanding the row by default.
@end table

@example
(accordion-item #:summary \"How do I install it?\" #:content (list (p \"Use Guix.\")))
@end example"
  (details content
           #:summary summary
           #:open open))

(define* (accordion #:key items
                    (accordion-classes '(flex flex-col gap-2 my-4)))
  "Stack several @code{accordion-item} rows into a JavaScript-free accordion.

Because each row is a native @code{details} element, the whole accordion
expands and collapses without any scripting.

@table @var
@item items
A list of @code{accordion-item} or @code{details} nodes.
@item accordion-classes
List of symbols representing the wrapper CSS classes.
@end table

@example
(accordion #:items (list (accordion-item #:summary \"A\" #:content (list (p \"Alpha\")))
                        (accordion-item #:summary \"B\" #:content (list (p \"Beta\")))))
@end example"
  `((div (@ (class ,(mk-class accordion-classes)))
         ,@items)))

(define* (modal #:key id
                title
                content
                (footer #f)
                (close-label "Close"))
  "Create a modal dialog that opens with no JavaScript.

The modal is revealed by the CSS @code{:target} pseudo-class: link to it
with an anchor such as @code{(a \"Open\" #:href \"#my-modal\")} and it appears;
follow a link to @code{\"#\"} to dismiss it. The dialog carries the proper
@code{role}, @code{aria-modal} and @code{aria-labelledby} attributes so
assistive technology announces it, and it keeps working with scripting
disabled.

@table @var
@item id
The unique element id targeted by the opening link.
@item title
The dialog title, also used as its accessible name.
@item content
The dialog body content.
@item footer
An optional list of action nodes shown at the bottom.
@item close-label
The accessible label for the close control. Defaults to @code{\"Close\"}.
@end table

@example
(modal #:id \"confirm\" #:title \"Are you sure?\" #:content (list (p \"This cannot be undone.\")))
@end example"
  `((div (@ (id ,id)
            (role dialog)
            (aria-modal "true")
            (aria-labelledby ,(format #f "~a-title" id))
            (class "hg-modal"))
         (a (@ (href "#")
               (aria-label ,close-label)
               (class "hg-modal-backdrop backdrop-blur-sm")) "")
         (div (@ (class "hg-modal-content"))
              (div (@ (class "hg-modal-header"))
                   (h3 (@ (id ,(format #f "~a-title" id))
                          (class ,(mk-class '(text-xl font-semibold
                                                      text-onyx-500
                                                      dark:text-stone-100
                                                      font-sans))))
                       ,title)
                   (a (@ (href "#")
                         (aria-label ,close-label)
                         (class "hg-modal-close")) "×"))
              (div (@ (class "hg-modal-body"))
                   ,content)
              ,@(if footer
                    `((div (@ (class "hg-modal-footer"))
                           ,footer))
                    '())))))

(define* (tooltip content
                  #:key text
                  (id #f)
                  (position 'top)
                  (classes '()))
  "Attach an accessible, JavaScript-free tooltip to inline content.

The tooltip is shown on both hover and keyboard focus through CSS, and its
text is exposed twice, each copy for the reader it is for. Sighted hover is
served by the @code{data-hg-tooltip} attribute the generated @code{::after}
bubble reads; assistive technology is served by a real text node the trigger
describes itself with, because generated content is not reliably part of the
exposed accessibility tree. The text node is visually hidden rather than
also drawn, so a hover still produces one bubble and one reading, not two.

@table @var
@item content
The trigger content the tooltip is attached to.
@item text
The tooltip text.
@item id
A stable HTML identifier for the hidden description, or @code{#f} for a generated one. Give one when the page has to name it.
@item position
Where the tooltip appears: @code{'top} (default), @code{'bottom}, @code{'left} or @code{'right}.
@item classes
List of additional utility CSS classes.
@end table

@example
(tooltip (code \"CARGO_HOME\") #:text \"Where Cargo stores downloaded crates\")
@end example"
  (let* ((position-class (string->symbol (format #f "hg-tooltip-~a" position)))
         (description-id (if id
                             (format #f "~a" id)
                             (generate-string-uuid))))
    `((span (@ (tabindex "0")
               (data-hg-tooltip ,text)
               (aria-describedby ,description-id)
               (class ,(mk-class (append classes
                                         (list position-class)
                                         '(hg-tooltip)))))
            (span (@ (id ,description-id)
                     (class ,(mk-class '(sr-only))))
                  ,text)
            ,content))))
