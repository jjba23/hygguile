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
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-4xl)))
  `((h1 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h2 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-3xl)))
  `((h2 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h3 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-2xl)))
  `((h3 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (h4 content
             #:key (weight '(font-bold))
             (color '(text-onyx-300 dark:text-stone-300))
             (family '(font-sans))
             (size '(text-xl)))
  `((h4 (@ (class ,(mk-class (append color size weight family))))
        ,content)))

(define* (sub-h1 content
                 #:key (weight '(font-light))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (style '(italic))
                 (size '(text-3xl)))
  `((h1 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h2 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-2xl)))
  `((h2 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h3 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl)))
  `((h3 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (sub-h4 content
                 #:key (weight '(font-light))
                 (style '(italic))
                 (color '(text-onyx-300 dark:text-stone-500))
                 (family '(font-sans))
                 (size '(text-xl)))
  `((h4 (@ (class ,(mk-class (append color size weight style family))))
        ,content)))

(define* (p content
            #:key (weight '(font-medium))
            (color '(text-onyx-500 dark:text-stone-300))
            (family '(font-sans))
            (leading '(leading-6))
            (size '(text-lg)))
  `((p (@ (class ,(mk-class (append color size weight family leading))))
       ,content)))

(define* (em content
             #:key (weight '(font-light))
             (color '(text-onyx-300 dark:text-stone-500))
             (family '(font-sans))
             (leading '(leading-6))
             (style '(italic))
             (size '(text-md)))
  `((em (@ (class ,(mk-class (append color
                                     size
                                     weight
                                     style
                                     family
                                     leading))))
        ,content)))

(define* (strong content
                 #:key (weight '(font-bold))
                 (color '(text-onyx-500 dark:text-stone-300))
                 (family '(font-sans))
                 (leading '(leading-6))
                 (size '(text-lg)))
  `((strong (@ (class ,(mk-class (append color size weight family leading))))
            ,content)))

(define* (a content
            #:key (weight '(font-bold))
            (size '(text-md))
            (color '(text-jeans-blue-500 dark:text-jeans-blue-500))
            (family '(font-sans))
            (hover '(hover:text-jeans-blue-900 hover:dark:text-jeans-blue-100))
            (extra-classes '(no-underline hover:underline))
            (href #f))
  `((a (@ (href ,(if (not href) content href))
          (class ,(mk-class (append color
                                    hover
                                    size
                                    weight
                                    family
                                    extra-classes))))
       ,content)))

(define* (mono content
               #:key (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-lg))
               (mono-classes '(font-mono)))
  `((p (@ (class ,(mk-class (append color mono-classes size weight))))
       ,content)))

(define* (code content
               #:key (weight '(font-medium))
               (color '(text-onyx-500 dark:text-stone-300))
               (size '(text-md))
               (background '(bg-stone-300/75 dark:bg-onyx-700/75))
               (rounding '(rounded-lg))
               (shadow '(shadow-md))
               (padding-y '(py-1))
               (padding-x '(px-4))
               (code-classes '(font-mono)))
  `((code (@ (class ,(mk-class (append color
                                       background
                                       code-classes
                                       shadow
                                       size
                                       weight
                                       padding-y
                                       padding-x
                                       rounding))))
          ,content)))

(define* (pre content
              #:key (weight '(font-medium))
              (color '(text-onyx-500 dark:text-stone-300))
              (size '(text-md))
              (background '(bg-stone-300/75 dark:bg-onyx-700/75))
              (rounding '(rounded-lg))
              (shadow '(shadow-md))
              (width '(w-full))
              (leading '(leading-6))
              (text-wrap '(text-nowrap))
              (padding-y '(py-6))
              (padding-x '(px-8))
              (pre-classes '(font-mono overflow-auto whitespace-pre)))
  `((pre (@ (class ,(mk-class (append color
                                      leading
                                      background
                                      pre-classes
                                      shadow
                                      size
                                      weight
                                      text-wrap
                                      width
                                      padding-y
                                      padding-x
                                      rounding))))
         ,content)))
