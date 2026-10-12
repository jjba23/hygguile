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

(define-module (veritas unit abstraction-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile abstraction)
  #:export (spec))

(define abstraction-suite
  (suite "Abstraction test suite"
         (test "mk-class"
               (assert-equal #:name
                             "mk-class empty list returns empty class string"
                             #:got (mk-class '())
                             #:expect "")
               (assert-equal #:name
                "mk-class list of symbols is converted to sorted space-separated string"
                #:got (mk-class '(p-2 my-2 bg-stone-900/75 hover:bg-stone-900))
                #:expect "bg-stone-900/75 hover:bg-stone-900 my-2 p-2")

               (assert-equal #:name
                             "mk-class list of symbols removes duplication"
                             #:got (mk-class '(p-2 my-2 p-2 p-2 my-2))
                             #:expect "my-2 p-2")

               (assert-equal #:name
                "mk-class false value returns empty class string"
                #:got (mk-class #f)
                #:expect ""))

         (test "override-classes"
               (assert-equal #:name
                "a later colour utility replaces the earlier one"
                #:got (override-classes '(text-onyx-300 dark:text-stone-300)
                                        '(text-stone-100 dark:text-onyx-900))
                #:expect '(text-stone-100 dark:text-onyx-900))
               (assert-equal #:name
                "a font-size utility is not mistaken for a colour"
                #:got (override-classes '(text-sm text-onyx-300)
                                        '(text-stone-100))
                #:expect '(text-sm text-stone-100))
               (assert-equal #:name
                "variants are part of the identity, so themes do not collide"
                #:got (override-classes '(dark:text-stone-300)
                                        '(text-stone-100))
                #:expect '(dark:text-stone-300 text-stone-100))
               (assert-equal #:name
                             "border widths survive a border-colour override"
                             #:got (override-classes '(border-2
                                                       border-stone-500/25)
                                                     '(border-onyx-300))
                             #:expect '(border-2 border-onyx-300))
               (assert-equal #:name
                "an empty override list leaves the base list untouched"
                #:got (override-classes '(text-onyx-300)
                                        '())
                #:expect '(text-onyx-300))
               (assert-equal #:name
                "the merged class list carries a single text colour"
                #:got (mk-class (override-classes '(text-onyx-300
                                                    dark:text-stone-300)
                                                  '(text-stone-100
                                                    dark:text-onyx-900)))
                #:expect "dark:text-onyx-900 text-stone-100"))

         (test "render-if"
               (assert-equal #:name "render-if-nestring with valid string"
                             #:expect "HELLO"
                             #:got (render-if-nestring string-upcase "hello"))
               (assert-equal #:name "render-if-nestring with empty string"
                             #:expect '()
                             #:got (render-if-nestring string-upcase ""))
               (assert-equal #:name "render-if-nestring with #f"
                             #:expect '()
                             #:got (render-if-nestring string-upcase #f)))

         (test "pretty-quote"
               (assert-equal #:name "No quoted expressions"
                             #:got (pretty-quote "some text without quotes")
                             #:expect "some text without quotes")

               (assert-equal #:name "Single simple quoted expression"
                             #:got (pretty-quote "(quote user)")
                             #:expect "'user")

               (assert-equal #:name "Multiple simple quoted expressions"
                             #:got (pretty-quote
                                    "(quote name) and (quote age)")
                             #:expect "'name and 'age")

               (assert-equal #:name "Quoted expression with spaces"
                             #:got (pretty-quote "(quote some value)")
                             #:expect "'some value")

               (assert-equal #:name
                "Quoted expression with special characters (excluding ')')'"
                #:got (pretty-quote "(quote value-with-$&+,./:;=?@_~)")
                #:expect "'value-with-$&+,./:;=?@_~")
               (assert-equal #:name
                             "Quoted expression with nested parentheses"
                             #:got (pretty-quote "(quote (nested value))")
                             #:expect "'(nested value)")

               (assert-equal #:name
                "Multiple quoted expressions with different types"
                #:got (pretty-quote
                       "start (quote item) middle (quote (sub item)) end")
                #:expect "start 'item middle '(sub item) end")

               (assert-equal #:name
                "Quoted expression at the beginning of the string"
                #:got (pretty-quote "(quote first) then more text")
                #:expect "'first then more text")

               (assert-equal #:name
                             "Quoted expression at the end of the string"
                             #:got (pretty-quote "some text (quote last)")
                             #:expect "some text 'last")

               (assert-equal #:name "Empty quoted expression"
                             #:got (pretty-quote "(quote )")
                             #:expect "'")

               (assert-equal #:name
                "String with a mix of quoted and non-quoted content"
                #:got (pretty-quote
                       "prefix (quote data) infix (quote (more data)) suffix")
                #:expect "prefix 'data infix '(more data) suffix")

               (assert-equal #:name "Real-world like string"
                #:got (pretty-quote
                       "(quote user) #:content \"user\" #:background (quote bg-amber-500) #:hover-background (quote hover:bg-amber-700) #:color (quote text-onyx-500) #:icon-css (quote (text-onyx-500 text-xl))")
                #:expect
                "'user #:content \"user\" #:background 'bg-amber-500 #:hover-background 'hover:bg-amber-700 #:color 'text-onyx-500 #:icon-css '(text-onyx-500 text-xl)")

               (assert-equal #:name
                "Multiple occurrences of the same quoted expression"
                #:got (pretty-quote "(quote same) and also (quote same)")
                #:expect "'same and also 'same"))))

(define (spec)
  (veritas-run abstraction-suite))

