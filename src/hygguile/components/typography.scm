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

(define-module (hygguile components typography)
  #:use-module (hygguile abstraction)
  #:export (hyg-h1 hyg-h2
                   hyg-h3
                   hyg-h4
                   hyg-sub-h1
                   hyg-sub-h2
                   hyg-sub-h3
                   hyg-sub-h4
                   hyg-p
                   hyg-em
                   hyg-strong))

(define* (hyg-h1 content
                 #:key (weight 'font-bold)
                 (size 'text-4xl))
  `((h1 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-h2 content
                 #:key (weight 'font-bold)
                 (size 'text-3xl))
  `((h2 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-h3 content
                 #:key (weight 'font-bold)
                 (size 'text-2xl))
  `((h3 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-h4 content
                 #:key (weight 'font-bold)
                 (size 'text-xl))
  `((h4 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-sub-h1 content
                     #:key (weight 'font-light)
                     (size 'text-4xl))
  `((h1 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-sub-h2 content
                     #:key (weight 'font-light)
                     (size 'text-3xl))
  `((h2 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-sub-h3 content
                     #:key (weight 'font-light)
                     (size 'text-2xl))
  `((h3 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-sub-h4 content
                     #:key (weight 'font-light)
                     (size 'text-xl))
  `((h4 (@ (class ,(->css `(,size ,weight))))
        ,content)))

(define* (hyg-p content
                #:key (weight 'font-medium)
                (size 'text-lg))
  `((p (@ (class ,(->css `(,size ,weight))))
       ,content)))

(define* (hyg-em content
                 #:key (weight 'font-light)
                 (size 'text-lg))
  `((p (@ (class ,(->css `(,size ,weight))))
       ,content)))

(define* (hyg-strong content
                     #:key (weight 'font-bold)
                     (size 'text-lg))
  `((strong (@ (class ,(->css `(,size ,weight))))
            ,content)))
