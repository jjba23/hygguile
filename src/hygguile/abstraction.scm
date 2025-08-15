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

(define-module (hygguile abstraction)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 format)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:export (mk-class render-if-nestring render-if-nempty pretty-quote syscall
                     get-short-commit-sha))

;; mk-class: Convert a list of symbols into a CSS `class` attribute pair.
;;
;; This function takes a list of symbols representing CSS class names and
;; returns an S-expression `(class "class-names")`. The class names are
;; space-separated in a string. If the input is an empty list or `#f`,
;; it returns `(class "")`, ensuring that an empty class attribute is still valid.
;;
;; Examples:
;; (mk-class '())                       ⇒ ""
;; (mk-class '(p-2 bg-stone-900/75))    ⇒ "bg-stone-900/75 p-2 "
;; (mk-class #f)                        ⇒ ""
;;
(define* (mk-class xs)
  "Return a sorted, space-separated string of unique class names from @var{xs}.

@deffn Procedure mk-class xs
Takes a list of symbols @var{xs}, removes any duplicates, converts them
to strings, sorts them alphabetically, and returns them as a single,
space-separated string. This is useful for creating a canonical CSS
class attribute value.

If @var{xs} is the empty list, an empty string is returned.

@table @var
@item xs
A list of symbols.
@end table

@returns A string of unique, sorted names, joined by spaces.

@example
(mk-class '(input button primary input))
@result{} \"button input primary\"

(mk-class '(baz foo bar))
@result{} \"bar baz foo\"

(mk-class '())
@result{} \"\"
@end example
@end deffn"  
  (cond
    ((nil? xs)
     "")
    (else (string-join (sort (map symbol->string
                                  (delete-duplicates xs)) string<?) " "))))

(define* (render-if-nestring expr x)
  (if (and x
           (not (equal? "" x)))
      (expr x)
      '()))

(define* (render-if-nempty render-func item)
  (cond
    ((or (nil? item)
         (equal? item #f))
     '())
    (else (render-func item))))

(define (string-drop-first-last-n s n)
  (if (> (string-length s) 2)

      (string-take (string-drop s n)
                   (- (string-length s)
                      (+ 1 n))) s))

(define (pretty-quote str)
  (regexp-substitute/global #f
                            "\\((quote [^)]*)\\)*"
                            str
                            'pre
                            (lambda (m)
                              
                              (let* ((mm (string-drop-first-last-n (match:substring
                                                                    m) 1)))
                                (string-replace-substring mm "quote " "'")))
                            'post))

(define (syscall cmd)
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define (get-short-commit-sha)
  (syscall "git log --pretty=format:'%h' -n 1"))
