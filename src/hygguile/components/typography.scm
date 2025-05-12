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
  #:export (h1 h2
               h3
               h4
               sub-h1
               sub-h2
               sub-h3
               sub-h4
               p
               em
               a
               strong
               pre
               mono
               code))

(define* (h1 content
             #:key (weight 'font-bold)
             (color 'text-stone-700)
             (size 'text-4xl))
  `((h1 (@ (class ,(mk-classes `(,size ,weight
                                 ,color))))
        ,content)))

(define* (h2 content
             #:key (weight 'font-bold)
             (color 'text-stone-700)
             (size 'text-3xl))
  `((h2 (@ (class ,(mk-classes `(,size ,weight
                                 ,color))))
        ,content)))

(define* (h3 content
             #:key (weight 'font-bold)
             (color 'text-stone-700)
             (size 'text-2xl))
  `((h3 (@ (class ,(mk-classes `(,size ,weight
                                 ,color))))
        ,content)))

(define* (h4 content
             #:key (weight 'font-bold)
             (color 'text-stone-700)
             (size 'text-xl))
  `((h4 (@ (class ,(mk-classes `(,size ,weight
                                 ,color))))
        ,content)))

(define* (sub-h1 content
                 #:key (weight 'font-light)
                 (color 'text-stone-600)
                 (style 'italic)
                 (size 'text-3xl))
  `((h1 (@ (class ,(mk-classes `(,size ,weight
                                 ,style
                                 ,color))))
        ,content)))

(define* (sub-h2 content
                 #:key (weight 'font-light)
                 (style 'italic)
                 (color 'text-stone-600)
                 (size 'text-2xl))
  `((h2 (@ (class ,(mk-classes `(,size ,weight
                                 ,style
                                 ,color))))
        ,content)))

(define* (sub-h3 content
                 #:key (weight 'font-light)
                 (style 'italic)
                 (color 'text-stone-600)
                 (size 'text-xl))
  `((h3 (@ (class ,(mk-classes `(,size ,weight
                                 ,style
                                 ,color))))
        ,content)))

(define* (sub-h4 content
                 #:key (weight 'font-light)
                 (style 'italic)
                 (color 'text-stone-600)
                 (size 'text-xl))
  `((h4 (@ (class ,(mk-classes `(,size ,weight
                                 ,style
                                 ,color))))
        ,content)))

(define* (p content
            #:key (weight 'font-medium)
            (color 'text-stone-800)
            (size 'text-lg))
  `((p (@ (class ,(mk-classes `(,size ,weight
                                ,color))))
       ,content)))

(define* (em content
             #:key (weight 'font-light)
             (color 'text-stone-600)
             (size 'text-md))
  `((em (@ (class ,(mk-classes `(,size ,weight
                                 ,color))))
        ,content)))

(define* (strong content
                 #:key (weight 'font-bold)
                 (color 'text-stone-800)
                 (size 'text-lg))
  `((strong (@ (class ,(mk-classes `(,size ,weight
                                     ,color))))
            ,content)))

(define* (a content
            #:key (weight 'font-bold)
            (size 'text-lg)
            (color 'text-blue-500)
            (hover 'hover:text-blue-700)
            (href #f))
  `((a (@ (href ,(if (not href) content href))
          (class ,(mk-classes `(,size ,weight
                                ,color
                                ,hover))))
       ,content)))

(define* (mono content
               #:key (weight 'font-medium)
               (color 'text-stone-800)
               (size 'text-lg))
  `((p (@ (class ,(mk-classes `(font-mono ,size
                                          ,weight
                                          ,color))))
       ,content)))

(define* (code content
               #:key (weight 'font-medium)
               (color 'text-stone-800)
               (size 'text-md)
               (background 'bg-stone-200/75)
               (rounding 'rounded-lg)
               (shadow 'shadow-md)
               (padding-y 'py-1)
               (padding-x 'px-2))
  `((code (@ (class ,(mk-classes `(font-mono ,shadow
                                             ,size
                                             ,weight
                                             ,padding-y
                                             ,padding-x
                                             ,color
                                             ,background
                                             ,rounding))))
          ,content)))

(define* (pre content
              #:key (weight 'font-medium)
              (color 'text-stone-800)
              (size 'text-md)
              (background 'bg-stone-200/75)
              (rounding 'rounded-lg)
              (shadow 'shadow-md)
              (width 'w-full)
              (text-wrap 'text-nowrap)
              (padding-y 'py-6)
              (padding-x 'px-8))
  `((pre (@ (class ,(mk-classes `(font-mono ,shadow
                                            ,size
                                            ,weight
                                            ,text-wrap
                                            ,width
                                            ,padding-y
                                            ,padding-x
                                            ,color
                                            ,background
                                            ,rounding
                                            overflow-auto
                                            whitespace-pre))))
         ,content)))
