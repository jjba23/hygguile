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
  #:export (hyg-option hyg-glyph-option))

(define* (hyg-option #:key value
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

(define* (hyg-glyph-option #:key value glyph
                           (content #f)
                           (selected-value #f))
  (let ((option-flex-css '(flex gap-1)))
    (hyg-option #:value value
                #:selected-value selected-value
                #:content `(div (@ (class ,(->css option-flex-css)))
                                (span ,glyph)
                                (span ,(if (not (equal? #f content)) content
                                           value))))))

