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
  (define default-input-class '(p-3 max-w-prose rounded-xl
                                    border-stone-400/75 border-2))
  
  (define default-label-class '(text-sm font-bold text-stone-600))
  
  (define* (mk-input #:key label name
                     (value "")
                     (required #f)
                     (input-class default-input-class)
                     (label-class default-label-class))
    `((div (@,(symbols->css '(flex flex-col gap-1))))
      (label (@,(symbols->css label-class)(for ,name)) ,label)
      (input (@,(symbols->css input-class)
              (name ,name)
              (value ,value)
              ,(if required '(required "") '(attr "")))
             ""))))
  (export mk-input))

