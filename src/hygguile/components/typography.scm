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
                   hyg-a
                   hyg-strong
                   hyg-pre
                   hyg-mono
                   hyg-code))

(define* (hyg-h1 content
                 #:key (weight 'font-bold)
                 (color 'text-stone-700)
                 (size 'text-4xl))
  `((h1 (@ (class ,(->css `(,size ,weight
                            ,color))))
        ,content)))

(define* (hyg-h2 content
                 #:key (weight 'font-bold)
                 (color 'text-stone-700)
                 (size 'text-3xl))
  `((h2 (@ (class ,(->css `(,size ,weight
                            ,color))))
        ,content)))

(define* (hyg-h3 content
                 #:key (weight 'font-bold)
                 (color 'text-stone-700)
                 (size 'text-2xl))
  `((h3 (@ (class ,(->css `(,size ,weight
                            ,color))))
        ,content)))

(define* (hyg-h4 content
                 #:key (weight 'font-bold)
                 (color 'text-stone-700)
                 (size 'text-xl))
  `((h4 (@ (class ,(->css `(,size ,weight
                            ,color))))
        ,content)))

(define* (hyg-sub-h1 content
                     #:key (weight 'font-light)
                     (color 'text-stone-600)
                     (style 'italic)
                     (size 'text-3xl))
  `((h1 (@ (class ,(->css `(,size ,weight
                            ,style
                            ,color))))
        ,content)))

(define* (hyg-sub-h2 content
                     #:key (weight 'font-light)
                     (style 'italic)
                     (color 'text-stone-600)
                     (size 'text-2xl))
  `((h2 (@ (class ,(->css `(,size ,weight
                            ,style
                            ,color))))
        ,content)))

(define* (hyg-sub-h3 content
                     #:key (weight 'font-light)
                     (style 'italic)
                     (color 'text-stone-600)
                     (size 'text-xl))
  `((h3 (@ (class ,(->css `(,size ,weight
                            ,style
                            ,color))))
        ,content)))

(define* (hyg-sub-h4 content
                     #:key (weight 'font-light)
                     (style 'italic)
                     (color 'text-stone-600)
                     (size 'text-xl))
  `((h4 (@ (class ,(->css `(,size ,weight
                            ,style
                            ,color))))
        ,content)))

(define* (hyg-p content
                #:key (weight 'font-medium)
                (color 'text-stone-800)
                (size 'text-lg))
  `((p (@ (class ,(->css `(,size ,weight
                           ,color))))
       ,content)))

(define* (hyg-em content
                 #:key (weight 'font-light)
                 (color 'text-stone-600)
                 (size 'text-md))
  `((em (@ (class ,(->css `(,size ,weight
                            ,color))))
        ,content)))

(define* (hyg-strong content
                     #:key (weight 'font-bold)
                     (color 'text-stone-800)
                     (size 'text-lg))
  `((strong (@ (class ,(->css `(,size ,weight
                                ,color))))
            ,content)))

(define* (hyg-a content
                #:key (weight 'font-bold)
                (size 'text-lg)
                (color 'text-blue-500)
                (hover 'hover:text-blue-700)
                (href #f))
  `((a (@ (href ,(if (not href) content href))
          (class ,(->css `(,size ,weight
                                 ,color
                                 ,hover))))
       ,content)))

(define* (hyg-mono content
                   #:key (weight 'font-medium)
                   (color 'text-stone-800)
                   (size 'text-lg))
  `((p (@ (class ,(->css `(font-mono ,size ,weight
                                     ,color))))
       ,content)))


(define* (hyg-code content
                   #:key (weight 'font-medium)
                   (color 'text-stone-800)
                   (size 'text-md)
                   (background 'bg-stone-200/75)
                   (rounding 'rounded-lg)
                   (shadow 'shadow-md)
                   (padding-y 'py-1)
                   (padding-x 'px-2))
  `((code (@ (class ,(->css `(font-mono ,shadow ,size ,weight ,padding-y ,padding-x
                                        ,color ,background ,rounding))))
          ,content)))

(define* (hyg-pre content
                  #:key (weight 'font-medium)
                  (color 'text-stone-800)
                  (size 'text-md)
                  (background 'bg-stone-200/75)
                  (rounding 'rounded-lg)
                  (shadow 'shadow-md)
                  (padding-y 'py-1)
                  (padding-x 'px-3))
  `((pre (@ (class ,(->css `(font-mono ,shadow ,size ,weight ,padding-y ,padding-x
                                       ,color ,background ,rounding whitespace-pre))))
         ,content)))
