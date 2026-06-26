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
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 format)
  #:use-module (ice-9 regex)
  #:export (mk-class render-if-nestring
                     render-if-nempty
                     pretty-quote
                     syscall
                     get-short-commit-sha
                     mk-style))

(define (mk-style pairs)
  "Convert an association list of properties and values into a CSS inline style string.

@table @var
@item pairs
An association list or list of pairs where each element's @code{car} is the CSS property name and its @code{cdr} is the value.
@end table

@example
(mk-style '((background-color . \"red\") (color . \"blue\")))
@end example"
  (string-join (map (lambda (p)
                      (format #f "~a: ~a"
                              (car p)
                              (cdr p))) pairs) "; "))

(define* (mk-class xs)
  "Return a sorted, space-separated string of unique class names from @var{xs}.

Takes a list of symbols @var{xs}, removes any duplicates, converts them
to strings, sorts them alphabetically, and returns them as a single,
space-separated string. This is useful for creating a canonical CSS
class attribute value.

If @var{xs} is the empty list, an empty string is returned.

@table @var
@item xs
A list of symbols.
@end table

@example
(mk-class '(p-2 bg-stone-900/75))
@end example"
  (cond
    ((nil? xs)
     "")
    (else (string-join (sort (map symbol->string
                                  (delete-duplicates xs)) string<?) " "))))

(define* (render-if-nestring expr x)
  "Evaluate and return the result of @var{expr} with @var{x} if @var{x} is a non-empty string.

If @var{x} is false or an empty string, returns an empty list.

@table @var
@item expr
A single-argument procedure to apply to @var{x}.
@item x
The string value or condition to check.
@end table

@example
(render-if-nestring (lambda (val) `((p ,val))) \"Hello\")
@end example"
  (if (and x
           (not (equal? "" x)))
      (expr x)
      '()))

(define* (render-if-nempty render-func item)
  "Apply @var{render-func} to @var{item} if @var{item} is neither empty nor false.

Returns an empty list if @var{item} evaluates to null or false.

@table @var
@item render-func
A single-argument procedure to evaluate the layout with @var{item}.
@item item
The data element or fragment list to inspect.
@end table

@example
(render-if-nempty (lambda (i) `(b ,i)) \"Bold Text\")
@end example"
  (cond
    ((or (nil? item)
         (equal? item #f))
     '())
    (else (render-func item))))

(define (string-drop-first-last-n s n)
  "Drop the first @var{n} characters and the trailing @var{n}+1 characters from string @var{s}.

If the string length is less than or equal to 2, the original string is returned unchanged.

@table @var
@item s
The target source string.
@item n
The number of leading characters to remove.
@end table

@example
(string-drop-first-last-n \"(quote sample)\" 1)
@end example"
  (if (> (string-length s) 2)
      (string-take (string-drop s n)
                   (- (string-length s)
                      (+ 1 n))) s))

(define (pretty-quote str)
  "Transform explicit S-expression @code{(quote symbol)} fragments within a string into shorthand syntax.

@table @var
@item str
The target input string containing raw code snippets or text representations.
@end table

@example
(pretty-quote \"This is a (quote example) line.\")
@end example"
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
  "Execute a shell command synchronous process and capture its complete standard output.

@table @var
@item cmd
A string designating the system command execution pipeline.
@end table

@example
(syscall \"uname -a\")
@end example"
  (let* ((process (open-input-pipe cmd))
         (process-output (get-string-all process)))
    (close-pipe process) process-output))

(define* (get-short-commit-sha #:key (cmd "git log --pretty=format:'%h' -n 1"))
  "Retrieve the short Git commit SHA or execute a custom version control command.

@table @var
@item cmd
The shell command string to execute, defaulting to the command that fetches the 7-character short commit hash.
@end table

@example
(get-short-commit-sha)
@end example"
  (syscall cmd))
