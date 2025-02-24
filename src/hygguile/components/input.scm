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

(define-module (hygguile components input)
  #:use-module (hygguile abstraction))

(begin
  (define* (mk-input #:key label
                     name
                     (value "")
                     (required #f)
                     (input-css '(p-3 max-w-prose rounded-xl border-stone-200
                                      border-1))
                     (label-css '(text-sm font-bold text-stone-600))
                     (input-flex-css '(flex flex-col gap-1)))
    `((div (@(class ,(symbols->css ,input-flex-css))))
      (label (@(class ,(symbols->css label-class))
              (for ,name))
             ,label)
      (input (@(class ,(symbols->css input-class))
              (name ,name)
              (value ,value)
              ,(if required
                   '(required "")
                   '(not-required ""))) "")))
  (export mk-input))

