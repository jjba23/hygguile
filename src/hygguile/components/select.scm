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

(define-module (hygguile components select)
  #:use-module (hygguile abstraction)
  #:export (option glyph-option select))

(define* (option #:key value
                 (content #f)
                 (family '(font-sans))
                 (selected-value #f))
  "Construct an HTML @code{<option>} element.

If @var{selected-value} matches @var{value}, the option will render with a selected attribute status.

@table @var
@item value
The structural form state value string assigned to the option.
@item content
The visual display text string or inner components. Defaults to @var{value} if false.
@item family
List of symbols representing font family CSS classes applied if selected.
@item selected-value
The active value configuration used to evaluate selection symmetry.
@end table

@example
(option #:value \"light\" #:content \"Cozy Light Theme\" #:selected-value \"dark\")
@end example"
  (let ((option-content (if (not (equal? #f content)) content value)))
    (cond
      ((equal? value selected-value)
       `(option (@ (value ,value)
                   (class ,(mk-class (append family)))
                   (selected ""))
                ,option-content))
      (else `(option (@ (value ,value))
                     ,option-content)))))

(define* (glyph-option #:key value
                       glyph
                       (content #f)
                       (family '(font-sans))
                       (selected-value #f)
                       (option-flex-css '(flex gap-1)))
  "Construct an HTML option styled with an inline icon or glyph indicator.

@table @var
@item value
The structural form state value string assigned to the option.
@item glyph
An S-expression fragment or character representing the icon prefix element.
@item content
The text label descriptive string. Defaults to @var{value} if false.
@item family
List of symbols representing layout font family CSS classes.
@item selected-value
The active control target state tracker matching criteria.
@item option-flex-css
List of symbols determining internal flexbox element alignment constraints.
@end table

@example
(glyph-option #:value \"nl\" #:glyph \"🇳🇱\" #:content \"Nederlands\")
@end example"
  (option #:value value
          #:selected-value selected-value
          #:content `(div (@ (class ,(mk-class (append family option-flex-css))))
                          (span ,glyph)
                          (span ,(if (not (equal? #f content)) content value)))))

(define* (select #:key options
                 on-change
                 name
                 id
                 (family '(font-sans))
                 (select-classes '(w-full max-w-full
                                        px-3 py-2
                                        border-2
                                        border-stone-700
                                        dark:border-onyx-100
                                        bg-stone-300/75
                                        text-onyx-500
                                        dark:bg-onyx-700
                                        dark:text-stone-300
                                        text-md
                                        rounded-xl
                                        shadow-md
                                        cursor-pointer
                                        transition-colors
                                        duration-150
                                        focus-visible:outline-2
                                        focus-visible:outline-offset-2
                                        outline-onyx-500)))
  "Construct a dropdown list interactive selection menu wrapper.

The menu fills its container on phones and shrinks to its own
min-content width from the small breakpoint up, so a long option label
can never push a narrow page sideways.

@table @var
@item options
A list of option or glyph-option S-expressions making up the menu rows.
@item on-change
A string JavaScript execution statement evaluated during interaction changes.
@item name
The element name context configuration string bound onto target HTML form tracking.
@item id
The unique DOM string selector matching layout identifier tables.
@item family
List of symbols representing base structural font choices.
@item select-classes
List of symbols specifying visual layout styles for the component wrapper card.
@end table

@example
(select #:id \"theme-picker\"
        #:on-change \"console.log('Changed!')\"
        #:options (list (option #:value \"dim\")))
@end example"
  `((div (@ (class ,(mk-class '(flex flex-col gap-2 w-full sm:w-min))))
         (select (@ (onchange ,on-change)
                    (name ,name)
                    (id ,id)
                    (class ,(mk-class (append select-classes family))))
                 ,options))))
