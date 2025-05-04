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
(load "./src/hygguile/components/typography.scm")

(use-modules (ice-9 string-fun)
             (ice-9 textual-ports)
             (ice-9 format)
             (ice-9 match)
             (sxml ssax input-parse)
             (sxml ssax)
             (sxml transform)
             (srfi srfi-13)
             (hygguile abstraction)
             (hygguile components button)
             (hygguile components input)
             (hygguile components icon)
             (hygguile components select)
             (hygguile components typography))

(begin
  (define* (build-asset-library assets)
    (display "\nBuilding static asset cache...\n")
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
  (export build-asset-library))

(define-public asset-library
  (build-asset-library '("resources/css/fonts.css"
                         "resources/css/phosphor.css"
                         "resources/js/tailwind.js"
                         "resources/js/tailwind.config.js")))

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

(begin
  
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
                                              "resources/js/tailwind.config.js")))
                              (body (@ (class ,(->css '(bg-stone-200))))
                                    (div (@ (class ,(->css '(flex flex-col
                                                             h-screen
                                                             justify-between))))
                                         (div (@ (class ,(->css '(my-4
                                                                  container
                                                                  mx-auto))))
                                              ,@body))))))
  (export html-template))

(define typography-pangram
  "Sphinx of black quartz, judge my vow")

(define (showcase-body)
  `((div (@ (class ,(->css '(py-4 px-2))))
         (h1 (@ (class ,(->css '(text-3xl font-black text-stone-800 py-6))))
             "hygguile showcase")
         (section (h2 (@ (class ,(->css '(text-xl font-black text-stone-700
                                                  py-3)))) "buttons")
                  (div (@ (class ,(->css '(flex flex-row flex-wrap gap-2))))
                       ,(hyg-button "hyg-button")
                       ,(hyg-submit-button "hyg-submit-button")
                       ,(hyg-danger-submit-button "hyg-danger-submit-button")))
         (hr (@ (class ,(->css '(my-4)))))
         (section (h2 (@ (class ,(->css '(text-xl font-black text-stone-700
                                                  py-3)))) "inputs")
                  (div (@ (class ,(->css '(flex flex-row flex-wrap gap-2))))
                       ,(hyg-input #:name "input-1"
                                   #:placeholder "hyg-input")))
         (hr (@ (class ,(->css '(my-4)))))
         (section ,(hyg-h1 typography-pangram)
                  ,(hyg-h2 typography-pangram)
                  ,(hyg-h3 typography-pangram)
                  ,(hyg-h4 typography-pangram)
                  ,(hyg-p typography-pangram)))))

(define (showcase)
  (with-output-to-string (lambda ()
                           (sxml->xml (html-template #:title
                                                     "hygguile showcase"
                                                     #:body (showcase-body))))))

(with-output-to-file "dist/index.html"
  (lambda ()
    (display (showcase))))
