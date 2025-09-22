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
                 (selected-value #f))
  (let ((option-content (if (not (equal? #f content)) content value)))
    (cond
      ((equal? value selected-value)
       `(option (@ (value ,value)
                   (selected ""))
                ,option-content))
      (else `(option (@ (value ,value))
                     ,option-content)))))

(define* (glyph-option #:key value
                       glyph
                       (content #f)
                       (selected-value #f)
                       (option-flex-css '(flex gap-1)))
  (option #:value value
          #:selected-value selected-value
          #:content `(div (@ (class ,(mk-class option-flex-css)))
                          (span ,glyph)
                          (span ,(if (not (equal? #f content)) content value)))))

(define* (select #:key options
                 on-change
                 name
                 id
                 (select-classes '(p-4 border-2
                                       border-stone-300
                                       dark:border-stone-700
                                       bg-stone-300/75
                                       dark:bg-stone-900
                                       text-stone-900
                                       dark:text-stone-300
                                       text-md
                                       rounded-xl
                                       shadow-md)))
  `((div (@ (class ,(mk-class '(flex flex-col gap-2 w-min))))
         (select (@ (onchange ,on-change)
                    (name ,name)
                    (id ,id)
                    (class ,(mk-class select-classes)))
                 ,options))))
