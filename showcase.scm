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

(load "./src/hygguile/abstraction.scm")
(load "./src/hygguile/components/icon.scm")
(load "./src/hygguile/components/button.scm")
(load "./src/hygguile/components/select.scm")
(load "./src/hygguile/components/input.scm")
(load "./src/hygguile/components/container.scm")
(load "./src/hygguile/components/typography.scm")

(use-modules (ice-9 string-fun)
             (ice-9 textual-ports)
             (ice-9 format)
             (ice-9 match)
             (ice-9 regex)
             (sxml ssax input-parse)
             (sxml ssax)
             (sxml transform)
             (srfi srfi-13)
             (srfi srfi-64)
             (hygguile abstraction)
             (hygguile components button)
             (hygguile components input)
             (hygguile components icon)
             (hygguile components select)
             (hygguile components container)
             (hygguile components typography)
             (uuid generate))

(define* (load-assets assets)
  (let ((lib '()))
    (for-each (lambda (f)
                (let* ((file-contents (get-string-all (open-input-file f)))
                       (min-contents (cond
                                       ((string-suffix? ".css" f)
                                        (string-replace-substring
                                         file-contents "\n" ""))
                                       (else file-contents))))
                  (set! lib
                        (assoc-set! lib f min-contents)))) assets) lib))

(define-public asset-library
  (load-assets '("resources/css/fonts.css" "resources/css/phosphor.css"
                 "resources/js/tailwind.js" "resources/js/tailwind.config.js")))

;; ====== Serialize (SXML) ======

(define check-name
  (let ((*good-cache* (make-hash-table)))
    (lambda (name)
      (if (not (hashq-ref *good-cache* name))
          (let* ((str (symbol->string name))
                 (i (string-index str #\:))
                 (head (or (and i
                                (substring str 0 i)) str))
                 (tail (and i
                            (substring str
                                       (1+ i)))))
            (and i
                 (string-index (substring str
                                          (1+ i)) #\:)
                 (error "Invalid QName: more than one colon" name))
            (for-each (lambda (s)
                        (and s
                             (or (char-alphabetic? (string-ref s 0))
                                 (eq? (string-ref s 0) #\_)
                                 (error "Invalid name starting character" s
                                        name))
                             (string-for-each (lambda (c)
                                                (or (char-alphabetic? c)
                                                    (string-index
                                                     "0123456789.-_" c)
                                                    (error
                                                     "Invalid name character"
                                                     c s name))) s)))
                      (list head tail))
            (hashq-set! *good-cache* name #t))))))

;; The following two functions serialize tags and attributes. They are
;; being used in the node handlers for the post-order function, see
;; below.

(define (attribute-value->xml value port)
  (cond
    ((pair? value)
     (attribute-value->xml (car value) port)
     (attribute-value->xml (cdr value) port))
    ((null? value)
     *unspecified*)
    ((string? value)
     (string->escaped-xml value port))
    ((procedure? value)
     (with-output-to-port port value))
    (else (string->escaped-xml (call-with-output-string (lambda (port)
                                                          (display value port)))
                               port))))

(define (attribute->xml attr value port)
  (check-name attr)
  (display attr port)
  (display "=\"" port)
  (attribute-value->xml value port)
  (display #\" port))

(define (element->xml tag attrs body port)
  (check-name tag)
  (display #\< port)
  (display tag port)
  (if attrs
      (let lp
        ((attrs attrs))
        (if (pair? attrs)
            (let ((attr (car attrs)))
              (display #\space port)
              (if (pair? attr)
                  (attribute->xml (car attr)
                                  (cdr attr) port)
                  (error "bad attribute" tag attr))
              (lp (cdr attrs)))
            (if (not (null? attrs))
                (error "bad attributes" tag attrs)))))
  (if (pair? body)
      (begin
        (display #\> port)
        (let lp
          ((body body))
          (cond
            ((pair? body)
             (sxml->xml (car body) port)
             (lp (cdr body)))
            ((null? body)
             (display "</" port)
             (display tag port)
             (display ">" port))
            (else (error "bad element body" tag body)))))
      (display " />" port)))

;; FIXME: ensure name is valid
(define (entity->xml name port)
  (display #\& port)
  (display name port)
  (display #\; port))

;; FIXME: ensure tag and str are valid
(define (pi->xml tag str port)
  (display "<?" port)
  (display tag port)
  (display #\space port)
  (display str port)
  (display "?>" port))

(define* (sxml->xml tree
                    #:optional (port (current-output-port))
                    (escape? #f))
  "Serialize the sxml tree @var{tree} as XML. The output will be written
to the current output port, unless the optional argument @var{port} is
present."
  (cond
    ((pair? tree)
     (if (symbol? (car tree))
         ;; An element.
         (let ((tag (car tree)))
           (case tag
             ((*TOP*)
              (sxml->xml (cdr tree) port escape?))
             ((*ENTITY*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 1))
                  (entity->xml (cadr tree) port)
                  (error "bad *ENTITY* args"
                         (cdr tree))))
             ((*PI*)
              (if (and (list? (cdr tree))
                       (= (length (cdr tree)) 2))
                  (pi->xml (cadr tree)
                           (caddr tree) port)
                  (error "bad *PI* args"
                         (cdr tree))))
             (else (let* ((elems (cdr tree))
                          (attrs (and (pair? elems)
                                      (pair? (car elems))
                                      (eq? '@
                                           (caar elems))
                                      (cdar elems))))
                     (element->xml tag attrs
                                   (if attrs
                                       (cdr elems) elems) port)))))
         ;; A nodelist.
         (for-each (lambda (x)
                     (sxml->xml x port)) tree)))
    ((string? tree)
     (if escape?
         (string->escaped-xml tree port)
         (display tree port)))
    ((null? tree)
     *unspecified*)
    ((not tree)
     *unspecified*)
    ((eqv? tree #t)
     *unspecified*)
    ((procedure? tree)
     (with-output-to-port port tree))
    (else (when escape?
            (string->escaped-xml (call-with-output-string (lambda (port)
                                                            (display tree port)))
                                 port)))))

(define (sxml->string sxml)
  "Detag an sxml tree @var{sxml} into a string. Does not perform any
formatting."
  (string-concatenate-reverse (foldts (lambda (seed tree)
                                        ;; fdown
                                        '())
                                      (lambda (seed kid-seed tree)
                                        ;; fup
                                        (append! kid-seed seed))
                                      (lambda (seed tree)
                                        ;; fhere
                                        (if (string? tree)
                                            (cons tree seed) seed))
                                      '() sxml)))

(define (make-char-quotator char-encoding)
  (let ((bad-chars (list->char-set (map car char-encoding))))
    
    ;; Check to see if str contains one of the characters in charset,
    ;; from the position i onward. If so, return that character's index.
    ;; otherwise, return #f
    (define (index-cset str i charset)
      (string-index str charset i))

    ;; The body of the function
    (lambda (str port)
      (let ((bad-pos (index-cset str 0 bad-chars)))
        (if (not bad-pos)
            (display str port) ;str had all good chars
            (let loop
              ((from 0)
               (to bad-pos))
              (cond
                ((>= from
                     (string-length str))
                 *unspecified*)
                ((not to)
                 (display (substring str from
                                     (string-length str)) port))
                (else (let ((quoted-char (cdr (assv (string-ref str to)
                                                    char-encoding)))
                            (new-to (index-cset str
                                                (+ 1 to) bad-chars)))
                        (if (< from to)
                            (display (substring str from to) port))
                        (display quoted-char port)
                        (loop (1+ to) new-to))))))))))

;; Given a string, check to make sure it does not contain characters
;; such as '<' or '&' that require encoding. Return either the original
;; string, or a list of string fragments with special characters
;; replaced by appropriate character entities.

(define string->escaped-xml
  (make-char-quotator '((#\< . "&lt;") (#\> . "&gt;")
                        (#\& . "&amp;")
                        (#\" . "&quot;"))))

;;
;; ====== Showcase section ======
;;

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

(define (as-example thunk)
  (let* ((tt (with-output-to-string (lambda ()
                                      (write thunk))))
         (t (pretty-quote tt))
         (uid (generate-string-uuid)))
    `((div (@ (class ,(->css '(flex flex-col gap-6))))
           (div (@ (class ,(->css '(flex flex-row flex-wrap gap-2))))
                (div ,(eval-string tt))
                (button (@ (class ,(->css '(font-light text-sm text-stone-700)))
                           (onclick ,(format #f
                                      "document.getElementById('~a-example').classList.toggle('hidden')"
                                      uid)))
                        ,(hyg-icon #:type 'dots-three
                                   #:icon-css '(text-xl))))
           (div (@ (id ,(format #f "~a-example" uid))
                   (class ,(->css '(hidden flex flex-col gap-2))))
                (pre (@ (id ,(format #f "~a-pre" uid))
                        (class ,(->css '(font-medium text-stone-800
                                                     text-md
                                                     bg-stone-200/75
                                                     rounded-lg
                                                     shadow-md
                                                     w-full
                                                     text-wrap
                                                     py-4
                                                     px-4
                                                     overflow-x-scroll
                                                     whitespace-pre))))
                     ,t)
                (div (@ (class ,(->css '(w-min))))
                     ,(hyg-icon-button #:icon 'copy
                                       #:foreground 'text-stone-900
                                       #:icon-css '(text-stone-900 text-lg)
                                       #:content "copy"
                                       #:on-click (format #f
                                                   "copyInnerText('~a')" uid)
                                       #:background 'bg-stone-400/50)))))))

(define button-section
  `((section (@ (class ,(->css '(flex flex-col gap-6))))
             ,(hyg-sub-h2 "buttons")
             (div (@ (class ,(->css '(flex flex-row flex-wrap gap-6))))
                  ,(as-example '(hyg-button "hyg-button"))
                  ,(as-example '(hyg-submit-button "hyg-submit-button"))
                  ,(as-example '(hyg-danger-submit-button
                                 "hyg-danger-submit-button")))
             (div (@ (class ,(->css '(flex flex-row flex-wrap gap-6))))
                  ,(as-example '(hyg-icon-button #:icon 'gear
                                                 #:content "gear"
                                                 #:background 'bg-teal-700
                                                 #:hover-background 'hover:bg-teal-900))
                  ,(as-example '(hyg-icon-button #:icon 'user
                                                 #:content "user"
                                                 #:background 'bg-amber-400
                                                 #:hover-background 'hover:bg-amber-600
                                                 #:foreground 'text-stone-900
                                                 #:icon-css '(text-stone-900
                                                              text-xl)))
                  ,(as-example '(hyg-icon-button #:icon 'airplane-tilt
                                                 #:content "airplane-tilt"
                                                 #:background 'bg-orange-700
                                                 #:hover-background 'hover:bg-orange-900))))))

(define typography-section
  `((div (@ (class ,(->css '(flex flex-col gap-6))))
         ,(hyg-sub-h2 "typography")
         (div (@ (class ,(->css '(flex flex-row flex-wrap gap-8))))
              (section (@ (class ,(->css '(py-3 flex flex-col gap-3))))
                       ,(as-example '(hyg-h1
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-h2
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-h3
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-h4
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(->css '(py-3 flex flex-col gap-3))))
                       ,(as-example '(hyg-sub-h1
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-sub-h2
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-sub-h3
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-sub-h4
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(->css '(py-3 flex flex-col gap-3))))
                       ,(as-example '(hyg-strong
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-p
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-em
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(->css '(py-3 flex flex-col gap-3))))
                       ,(as-example '(hyg-mono
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(hyg-code
                                      "Sphinx of black quartz, judge my vow")))
              ,(as-example '(hyg-pre
                             "
;;; A simple Guile Scheme HTTP server
(use-modules (web server))

(define (my-handler request request-body)
  (values '((content-type . (text/plain)))
          \"Hello World!\"))

(run-server my-handler)"))))))

(define forms-section
  `((section (@ (class ,(->css '(flex flex-col gap-6))))
             ,(hyg-sub-h2 "forms")
             (div (@ (class ,(->css '(flex flex-row flex-wrap gap-2 w-full))))
                  ,(as-example '(hyg-input #:label "some input:"
                                           #:name "input-1"
                                           #:placeholder "hyg-input"))
                  ,(as-example '(hyg-textarea #:label "some textarea:"
                                              #:name "textarea-1"))))))

(define footer
  (hyg-footer `(,(hyg-p
                  "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;") ,
                (hyg-em
                 "licensed under the LGPL v3, or newer at your convenience")
                (div (@ (class ,(->css '(flex flex-row flex-wrap gap-3
                                              align-center items-center))))
                     ,(hyg-p "find the source code here:")
                     ,(hyg-a "https://codeberg.org/jjba23/hygguile")))
              #:background 'bg-stone-200))

(define (showcase-body)
  (hyg-with-footer #:main `((div (@ (class ,(->css '(py-9 px-2 container
                                                          mx-auto))))
                                 (div (@ (class ,(->css '(flex flex-col gap-4))))
                                      ,(hyg-h1 "hygguile")
                                      ,(hyg-sub-h2
                                        "cozy and professional user-interfaces for everyone"))
                                 ,(hyg-hr)
                                 ,button-section
                                 ,(hyg-hr)
                                 ,typography-section
                                 ,(hyg-hr)
                                 ,forms-section))
                   #:footer footer))

(define* (html-template #:key title body)
  `("<!DOCTYPE html>" (html (@ (lang en))
                            (head (title ,title)
                                  (style ,(assoc-ref asset-library
                                           "resources/css/fonts.css"))

                                  (style ,(assoc-ref asset-library
                                           "resources/css/phosphor.css"))

                                  (meta (@ (name viewport)
                                           (content
                                            "width=device-width, initial-scale=1.0")))
                                  (script ,(assoc-ref asset-library
                                            "resources/js/tailwind.js"))
                                  (script ,(assoc-ref asset-library
                                            "resources/js/tailwind.config.js"))
                                  (script
                                   "
function copyInnerText(elementId) {
  const id = elementId + '-pre';
  console.log('copying inner text of element: ' + id);

  // Get the text field
  var el = document.getElementById(id);

  // Copy the text inside the text field
  navigator.clipboard.writeText(el.innerText);

  console.log(el.innerText);
} 
"))
                            (body (@ (class ,(->css '()))))
                            ,@body)))

(define (showcase)
  (with-output-to-string (lambda ()
                           (sxml->xml (html-template #:title
                                                     "hygguile showcase"
                                                     #:body (showcase-body))))))

;; ====== Run ======

(with-output-to-file "dist/index.html"
  (lambda ()
    (display (showcase))))

(display
 "
>>= successfully built hygguile showcase to destination: dist/index.html
")

;; ====== Test ======

(test-begin "pretty-quote tests")

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
  "(quote user) #:content \"user\" #:background (quote bg-amber-400) #:hover-background (quote hover:bg-amber-600) #:foreground (quote text-stone-900) #:icon-css (quote (text-stone-900 text-xl))")
 "'user #:content \"user\" #:background 'bg-amber-400 #:hover-background 'hover:bg-amber-600 #:foreground 'text-stone-900 #:icon-css '(text-stone-900 text-xl)")

(test-equal "Multiple occurrences of the same quoted expression"
            (pretty-quote "(quote same) and also (quote same)")
            "'same and also 'same")

(test-end)

