;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright (C) 2025 Josep Bigorra (jjba23) <jjbigorra@gmail.com>

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

(define-module (hygguile components button)
  #:use-module (hygguile abstraction))

(begin
  (define* (action-button #:key content
                          (type 'button)
                          (background 'bg-stone-700/75)
                          (foreground 'text-white))
    `(button (@ (type ,(symbol->string type))
                (class ,(mk-class-str `(p-2 rounded-xl
                                            w-min
                                            font-bold
                                            text-md
                                            ,background
                                            ,foreground))))
             ,content))
  (export action-button))

(begin
  (define* (success-submit-button #:key content)
    (action-button #:content content
                   #:type 'submit
                   #:background 'bg-green-700/75))
  (export success-submit-button))

(begin
  (define* (danger-submit-button #:key content)
    (action-button #:content content
                   #:type 'submit
                   #:background 'bg-red-700/75))
  (export danger-submit-button))
