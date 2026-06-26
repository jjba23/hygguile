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

(define-module (hygguile components input)
  #:use-module (hygguile abstraction)
  #:export (input textarea))

(define* (input #:key label
                name
                (value "")
                (placeholder "")
                (type 'text)
                (required #f)
                (input-css '(p-4 max-w-prose
                                 rounded-xl
                                 border-stone-700
                                 dark:border-onyx-100
                                 dark:text-stone-300
                                 bg-stone-300/75
                                 dark:bg-onyx-700/75
                                 border-2
                                 shadow-md
                                 font-sans))
                (label-css '(text-lg font-light text-onyx-100
                                     dark:text-stone-300 font-sans py-2))
                (input-flex-css '(my-2 flex flex-col gap-1)))
  "Construct an HTML @code{<input>} component with a matching label.

@table @var
@item label
The descriptive text string displaying the identity of the field.
@item name
The name mapping configuration string bound onto form serialization attributes.
@item value
The standard default textual configuration payload string.
@item placeholder
The ambient string text descriptive hint applied when the field boundary is unpopulated.
@item type
A configuration symbol managing browser input rendering choices (e.g., @code{'text}, @code{'password}).
@item required
A boolean property indicating if form verification forces evaluation validation.
@item input-css
List of symbols representing layout utility CSS classes for the input field.
@item label-css
List of symbols representing presentation utility CSS classes for the label field.
@item input-flex-css
List of symbols regulating structure container box margins and gaps.
@end table

@example
(input #:label \"Email Address\" #:name \"email\" #:type 'email #:required #t)
@end example"
  `((div (@ (class ,(mk-class input-flex-css)))
         (label (@ (class ,(mk-class label-css))
                   (for ,name))
                ,label)
         (input (@ (class ,(mk-class input-css))
                   (name ,name)
                   (placeholder ,placeholder)
                   (value ,value)
                   (type ,(symbol->string type))
                   ,(if required
                        '(required "")
                        '(not-required ""))) ""))))

(define* (textarea #:key label
                   name
                   (value "")
                   (required #f)
                   (textarea-css '(p-4 rounded-xl
                                       border-stone-700
                                       dark:border-onyx-100
                                       dark:text-stone-300
                                       dark:bg-onyx-700/75
                                       bg-stone-300/75
                                       border-2
                                       min-h-72
                                       min-w-90
                                       shadow-md
                                       min-w-prose))
                   (label-css '(text-lg font-light text-onyx-100
                                        dark:text-stone-300 font-sans py-2))
                   (textarea-flex-css '(my-2 flex flex-col gap-1 w-full
                                             font-sans)))
  "Construct an HTML @code{<textarea>} multiline field block.

@table @var
@item label
The explicit header string informing users of required field contexts.
@item name
The unique string structural identifier mapping the entity across standard DOM tables.
@item value
The initial text block paragraph payload string nested inside the block.
@item required
A field completion mandatory requirement boolean validation gate switch.
@item textarea-css
List of symbols targeting specific dimensions and borders configuration styles.
@item label-css
List of symbols handling sizing constraints applied onto the matching label tags.
@item textarea-flex-css
List of symbols managing outer wrapper responsive card flex constraints.
@end table

@example
(textarea #:label \"User Bio\" #:name \"biography\" #:value \"Born in Scheme...\")
@end example"
  `((div (@ (class ,(mk-class textarea-flex-css)))
         (label (@ (class ,(mk-class label-css))
                   (for ,name))
                ,label)
         (textarea (@ (class ,(mk-class textarea-css))
                      (id ,name)
                      (name ,name)
                      ,(if required
                           '(required "")
                           '(not-required "")))
                   ,value))))
