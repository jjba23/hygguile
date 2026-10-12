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

;; You should have received a copy of the GNU Lesser General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (veritas unit components select-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile components select)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  "Serialize an SXML fragment to the HTML a server would send."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (contains? text needle)
  "True when NEEDLE appears in TEXT."
  (and (string-contains text needle) #t))

(define (count-of text needle)
  "How many times NEEDLE appears in TEXT."
  (let loop
    ((at 0)
     (n 0))
    (let ((hit (string-contains text needle at)))
      (if hit
          (loop (+ hit
                   (string-length needle))
                (1+ n)) n))))

(define (element node)
  "The element inside a component's one-element node list."
  (car node))

(define (attr-value node name)
  "The value of attribute NAME on an SXML element, or #f."
  (let ((hit (assq name
                   (cdr (cadr node)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (class-list node)
  "The class attribute of NODE as a list of names."
  (let ((classes (attr-value node
                             'class)))
    (if (string? classes)
        (string-split classes #\space)
        '())))

;; One menu whose rows say which one they are showing, and one that says
;; nothing, so both the stated and the fallback selection are covered.
(define menu-options
  (list (option #:value 'en_US
                #:content "English (US)")
        (option #:value 'nl_NL
                #:content "Nederlands"
                #:selected-value "nl_NL")
        (option #:value 'es_ES
                #:content "Español"
                #:selected-value "nl_NL")))

(define (grouped-menu selected)
  "A menu whose rows stand in groups, one of them disabled.

SELECTED is the value the page states as its selection, or #f for a menu
that states none."
  (list (optgroup #:label "Americas"
                  #:options (list (option #:value "en_US"
                                          #:content "English (US)"
                                          #:selected-value selected)))
        (optgroup #:label "Europe"
                  #:disabled #t
                  #:options (list (option #:value "nl_NL"
                                          #:content "Nederlands"
                                          #:selected-value selected)
                                  (option #:value "es_ES"
                                          #:content "Español"
                                          #:selected-value selected)))
        (optgroup #:label "Asia"
                  #:options (list (option #:value "ja_JP"
                                          #:content "日本語"
                                          #:selected-value selected)))))

;; The tag is written out here rather than read from the module, so that
;; this spec states what a group is instead of agreeing with whatever the
;; implementation happens to say.
(define (group-entry? entry)
  "True when ENTRY is a group of rows standing in a menu."
  (and (pair? entry)
       (pair? (car entry))
       (eq? (car (car entry))
            'optgroup)))

(define (group-labels node)
  "The labels of every group in a rendered menu, in order."
  (map (lambda (entry)
         (attr-value (car entry)
                     'label))
       (filter group-entry?
               (cddr (menu-of node)))))

(define (rows-of-groups node)
  "The rows of every group in a rendered menu, flattened."
  (append-map (lambda (entry)
                (cddr (car entry)))
              (filter group-entry?
                      (cddr (menu-of node)))))

(define (menu-of node)
  "The <select> element inside a rendered select component."
  (let loop
    ((children (cddr (element node))))
    (cond
      ((null? children)
       #f)
      ((and (pair? (car children))
            (eq? (car (car children))
                 'select))
       (car children))
      (else (loop (cdr children))))))

(define (selected-values node)
  "The value of every row the rendered menu marks as selected.

A selection may stand inside a group, so the menu is walked the way a
reader reads it -- group rows flattened into their place -- rather than
looking only at the rows written directly under the control."
  (let loop
    ((entries (cddr (menu-of node)))
     (found '()))
    (cond
      ((null? entries)
       (reverse found))
      ((group-entry? (car entries))
       (loop (append (cddr (car (car entries)))
                     (cdr entries)) found))
      ((attr-value (element (car entries))
                   'selected)
       (loop (cdr entries)
             (cons (attr-value (element (car entries))
                               'value) found)))
      (else (loop (cdr entries) found)))))

(define (row-values node)
  "The value of every row of a rendered menu."
  (map (lambda (entry)
         (attr-value (element entry)
                     'value))
       (cddr (menu-of node))))

(define select-suite
  (suite "Dropdowns"
         (test "hygguile select and option"
               (assert-equal #:name "an option is an <option> with its value"
                             #:got (let ((el (element (option #:value "cozy"))))
                                     (list (car el)
                                           (attr-value el
                                                       'value)))
                             #:expect (list 'option "cozy"))
               (assert-equal #:name
                "and shows its value when given no content"
                #:got (render (option #:value "cozy"))
                #:expect
                "<option value=\"cozy\" class=\"font-sans\">cozy</option>")
               (assert-equal #:name
                "a symbol value and a string selection name the same row"
                #:got (let ((el (element (option #:value 'en_US
                                                 #:content "English (US)"
                                                 #:selected-value "en_US"))))
                        (list (attr-value el
                                          'value)
                              (attr-value el
                                          'selected)))
                #:expect (list "en_US" ""))
               (assert-equal #:name
                "and so does a string value with a symbol selection"
                #:got (attr-value (element (option #:value "en_US"
                                                   #:selected-value 'en_US))
                                  'selected)
                #:expect "")
               (assert-equal #:name
                "an option the menu is not showing is not selected"
                #:got (attr-value (element (option #:value 'es_ES
                                                   #:selected-value "en_US"))
                                  'selected)
                #:expect #f)
               (assert-equal #:name
                "a value is written the way a form reads it"
                #:got (render (option #:value 2026
                                      #:content "Two thousand"))
                #:expect
                "<option value=\"2026\" class=\"font-sans\">Two thousand</option>")
               (assert-equal #:name "a disabled row says so"
                             #:got (contains? (render (option #:value ""
                                                              #:content
                                                              "Choose one"
                                                              #:disabled #t))
                                              "disabled=\"\"")
                             #:expect #t)
               (assert-equal #:name
                "the menu states a selection even when no row matched"
                #:got (selected-values (select #:name 'plan
                                               #:options (list (option #:value
                                                                       "cozy")
                                                               (option #:value
                                                                       "calm"))))
                #:expect (list "cozy"))
               (assert-equal #:name
                "a placeholder row cannot be the one a menu states"
                #:got (selected-values (select #:name 'plan
                                               #:options (list (option #:value
                                                                ""
                                                                #:content
                                                                "Choose one"
                                                                #:disabled #t)
                                                               (option #:value
                                                                       "cozy"
                                                                       #:content
                                                                       "Cozy"))))
                #:expect (list "cozy"))
               (assert-equal #:name
                "a menu that already has a selection keeps exactly that one"
                #:got (selected-values (select #:name 'lang
                                               #:options menu-options))
                #:expect (list "nl_NL"))
               (assert-equal #:name
                             "a menu with nothing to select states nothing"
                             #:got (list (row-values (select #:name 'plan
                                                             #:options '()))
                                         (selected-values (select #:name 'plan
                                                                  #:options '())))
                             #:expect (list '()
                                            '()))
               (assert-equal #:name
                "the stated row is the one the browser would have shown"
                #:got (contains? (render (select #:name 'plan
                                                 #:options (list (option
                                                                  #:value
                                                                  "cozy"
                                                                  #:content
                                                                  "Cozy")
                                                                 (option
                                                                  #:value
                                                                  "calm"
                                                                  #:content
                                                                  "Calm"))))
                       "<option value=\"cozy\" class=\"font-sans\" selected=\"\">Cozy</option>")
                #:expect #t)
               (assert-equal #:name
                "the control carries a name and an id of its own"
                #:got (let ((html (render (select #:name 'plan
                                                  #:options (list (option
                                                                   #:value
                                                                   "cozy"))))))
                        (list (contains? html "name=\"plan\"")
                              (contains? html "id=\"plan\"")))
                #:expect (list #t #t))
               (assert-equal #:name
                             "nothing the caller left out is written as #f"
                             #:got (contains? (render (select #:name 'plan
                                                              #:options (list (option
                                                                               #:value
                                                                               "cozy"))))
                                              "#f")
                             #:expect #f)
               (assert-equal #:name
                "an id stands in for the name when the two differ"
                #:got (contains? (render (select #:name 'plan
                                                 #:id "plan-choice"
                                                 #:label "Plan:"
                                                 #:options (list (option
                                                                  #:value
                                                                  "cozy"))))
                                 "for=\"plan-choice\"")
                #:expect #t)
               (assert-equal #:name "a label is bound to the control"
                             #:got (contains? (render (select #:name 'plan
                                                              #:label "Plan:"
                                                              #:options (list (option
                                                                               #:value
                                                                               "cozy"))))
                                    "<label class=\"dark:text-stone-300 font-light font-sans py-2 text-lg text-onyx-100\" for=\"plan\">Plan:</label>")
                             #:expect #t)
               (assert-equal #:name
                "helper copy is linked as the control's description"
                #:got (let ((html (render (select #:name 'plan
                                                  #:label "Plan:"
                                                  #:help-text
                                                  "Change it later."
                                                  #:options (list (option
                                                                   #:value
                                                                   "cozy"))))))
                        (list (contains? html "aria-describedby=\"plan-help\"")
                              (contains? html "id=\"plan-help\"")))
                #:expect (list #t #t))
               (assert-equal #:name
                "a required menu says so to the browser and the reader"
                #:got (let ((html (render (select #:name 'plan
                                                  #:required #t
                                                  #:options (list (option
                                                                   #:value
                                                                   "cozy"))))))
                        (list (contains? html "required=\"\"")
                              (contains? html "aria-required=\"true\"")))
                #:expect (list #t #t))
               (assert-equal #:name
                "an error is announced and points back at the control"
                #:got (let ((html (render (select #:name 'plan
                                                  #:error "Pick a plan."
                                                  #:options (list (option
                                                                   #:value
                                                                   "cozy"))))))
                        (list (contains? html "aria-invalid=\"true\"")
                              (contains? html "role=\"alert\"")
                              (contains? html
                                         "aria-describedby=\"plan-error\"")))
                #:expect (list #t #t #t))
               (assert-equal #:name
                "an interaction handler is written only when there is one"
                #:got (let ((html (render (select #:name 'plan
                                                  #:on-change "console.log(1)"
                                                  #:options (list (option
                                                                   #:value
                                                                   "cozy"))))))
                        (contains? html "onchange=\"console.log(1)\""))
                #:expect #t)
               (assert-equal #:name
                             "a value inside a group is read like any other"
                             #:got (selected-values (select #:name 'lang
                                                            #:options (grouped-menu
                                                                       "ja_JP")))
                             #:expect (list "ja_JP"))
               (assert-equal #:name "a grouped menu keeps the groups in order"
                             #:got (group-labels (select #:name 'lang
                                                         #:options (grouped-menu
                                                                    #f)))
                             #:expect (list "Americas" "Europe" "Asia"))
               (assert-equal #:name "and keeps every row inside its group"
                             #:got (map (lambda (entry)
                                          (attr-value (element entry)
                                                      'value))
                                        (rows-of-groups (select #:name 'lang
                                                                #:options (grouped-menu
                                                                           #f))))
                             #:expect (list "en_US" "nl_NL" "es_ES" "ja_JP"))
               (assert-equal #:name
                             "a group is a heading over rows of its own"
                             #:got (let ((html (render (optgroup #:label
                                                                 "Europe"
                                                                 #:options (list
                                                                            (option
                                                                             #:value
                                                                             "nl"
                                                                             #:content
                                                                             "Nederlands"))))))
                                     (list (contains? html
                                            "<optgroup label=\"Europe\">")
                                           (contains? html
                                                      "<option value=\"nl\"")
                                           (contains? html "</optgroup>")))
                             #:expect (list #t #t #t))
               (assert-equal #:name "a group that cannot be chosen says so"
                             #:got (contains? (render (optgroup #:label
                                                                "Europe"
                                                                #:disabled #t
                                                                #:options '()))
                                    "<optgroup label=\"Europe\" disabled=\"\">")
                             #:expect #t)
               (assert-equal #:name "a group with no heading claims none"
                             #:got (contains? (render (optgroup #:options '()))
                                              "label=")
                             #:expect #f)
               (assert-equal #:name "a grouped menu states one row as well"
                             #:got (selected-values (select #:name 'lang
                                                            #:options (grouped-menu
                                                                       #f)))
                             #:expect (list "en_US"))
               (assert-equal #:name
                "and a menu of nothing but a disabled group states nothing"
                #:got (selected-values (select #:name 'lang
                                               #:options (list (optgroup
                                                                #:label
                                                                "Europe"
                                                                #:disabled #t
                                                                #:options (list
                                                                           (option
                                                                            #:value
                                                                            "nl_NL"
                                                                            #:content
                                                                            "Nederlands"))))))
                #:expect '())
               (assert-equal #:name
                             "a row selected inside a group is left alone"
                             #:got (selected-values (select #:name 'lang
                                                            #:options (grouped-menu
                                                                       "nl_NL")))
                             #:expect (list "nl_NL"))
               (assert-equal #:name
                "a glyph option writes its glyph and label as text"
                #:got (render (glyph-option #:value "nl"
                                            #:glyph "🇳🇱"
                                            #:content "Nederlands"))
                #:expect
                "<option value=\"nl\" class=\"font-sans\">🇳🇱 Nederlands</option>")
               (assert-equal #:name
                "and never nests an element a menu row cannot hold"
                #:got (contains? (render (glyph-option #:value "nl"
                                                       #:glyph "🇳🇱"
                                                       #:content "Nederlands"))
                                 "<div")
                #:expect #f))))

(define (spec)
  (veritas-run select-suite))
