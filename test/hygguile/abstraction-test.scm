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

(define-module (hygguile abstraction-test)
  #:use-module (srfi srfi-64)
  #:use-module (hygguile abstraction))

(test-begin "abstraction tests")

(test-equal "mk-class empty list returns empty class string"
  (mk-class '()) "")

(test-equal
    "mk-class list of symbols is converted to sorted space-separated string"
  (mk-class '(p-2 my-2 bg-stone-900/75 hover:bg-stone-800))
  "bg-stone-900/75 hover:bg-stone-800 my-2 p-2")

(test-equal "mk-class list of symbols removes duplication"
  (mk-class '(p-2 my-2 p-2 p-2 my-2)) "my-2 p-2")

(test-equal "mk-class false value returns empty class string"
  (mk-class #f) "")

(test-equal "render-if-nestring with valid string" "HELLO"
            (render-if-nestring string-upcase "hello"))
(test-equal "render-if-nestring with empty string"
  '()
  (render-if-nestring string-upcase ""))
(test-equal "render-if-nestring with #f"
  '()
  (render-if-nestring string-upcase #f))

(test-equal "No quoted expressions"
  (pretty-quote "some text without quotes")
  "some text without quotes")

(test-equal "Single simple quoted expression"
  (pretty-quote "(quote user)") "'user")

(test-equal "Multiple simple quoted expressions"
  (pretty-quote "(quote name) and (quote age)") "'name and 'age")

(test-equal "Quoted expression with spaces"
  (pretty-quote "(quote some value)") "'some value")

(test-equal "Quoted expression with special characters (excluding ')')'"
  (pretty-quote "(quote value-with-$&+,./:;=?@_~)")
  "'value-with-$&+,./:;=?@_~")

(test-equal "Quoted expression with nested parentheses"
  (pretty-quote "(quote (nested value))") "'(nested value)")

(test-equal "Multiple quoted expressions with different types"
  (pretty-quote "start (quote item) middle (quote (sub item)) end")
  "start 'item middle '(sub item) end")

(test-equal "Quoted expression at the beginning of the string"
  (pretty-quote "(quote first) then more text")
  "'first then more text")

(test-equal "Quoted expression at the end of the string"
  (pretty-quote "some text (quote last)") "some text 'last")

(test-equal "Empty quoted expression"
  (pretty-quote "(quote )") "'")

(test-equal "String with a mix of quoted and non-quoted content"
  (pretty-quote
   "prefix (quote data) infix (quote (more data)) suffix")
  "prefix 'data infix '(more data) suffix")

(test-equal "Real-world like string"
  (pretty-quote
   "(quote user) #:content \"user\" #:background (quote bg-amber-400) #:hover-background (quote hover:bg-amber-600) #:color (quote text-stone-900) #:icon-css (quote (text-stone-900 text-xl))")
  "'user #:content \"user\" #:background 'bg-amber-400 #:hover-background 'hover:bg-amber-600 #:color 'text-stone-900 #:icon-css '(text-stone-900 text-xl)")

(test-equal "Multiple occurrences of the same quoted expression"
  (pretty-quote "(quote same) and also (quote same)")
  "'same and also 'same")


(test-end)
