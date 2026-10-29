;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components table-spec)
  #:use-module (veritas veritas)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components table)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (find-tag node tag)
  "Return the first descendant element of @var{node} whose tag is @var{tag}."
  (cond
    ((and (pair? node)
          (symbol? (car node))
          (eq? tag
               (car node)))
     node)
    ((list? node)
     (any (lambda (child)
            (find-tag child tag)) node))
    (else #f)))

(define (attr-value node name)
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (class-has? node token)
  "Return #t when the rendered @var{token} appears in the node's class list."
  (let ((classes (attr-value node
                             'class)))
    (and (string? classes)
         (string-contains classes token) #t)))

(define sample-body
  (lambda ()
    (tbody (list (tr (list (td "Cozy")
                           (td "9"
                               #:numeric #t)))))))

;; ===== helpers for the server-driven sorting assertions =====

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

(define (unamp href)
  "Turn the escaped ampersands of rendered HTML back into query separators."
  (string-replace-substring href "&amp;" "&"))

(define (sort-link-href html label)
  "The href of the sort link whose visible label is LABEL, or #f."
  (let ((m (string-match (format #f "<a href=\"([^\"]*)\"[^>]*>~a<span" label)
                         html)))
    (and m
         (match:substring m 1))))

(define (link-markup html label)
  "The whole rendered markup of the sort link labelled LABEL, or #f."
  (let ((m (string-match (format #f
                          "<a href=\"[^\"]*\"[^>]*>~a<span[^>]*>[^<]*</span></a>"
                          label) html)))
    (and m
         (match:substring m 0))))

(define (link-arrow html label)
  "The arrow the sort link labelled LABEL shows, or #f.

The arrow tells a sighted reader which way the column it belongs to is
ordered, so it is only meaningful on the sorted column itself."
  (let ((m (string-match (format #f ">~a<span[^>]*>([^<]*)</span>" label) html)))
    (and m
         (match:substring m 1))))

(define (link-direction html label)
  "The direction parameter's value in the sort link labelled LABEL, or #f."
  (let ((href (sort-link-href html label)))
    (and href
         (let* ((clean (unamp href))
                (at (string-contains clean "hygguile-table-dir=")))
           (and at
                (substring clean
                           (+ at
                              (string-length "hygguile-table-dir="))))))))

(define sort-columns
  (list (table-column #:key 'plan
                      #:label "Plan")
        (table-column #:key 'seats
                      #:label "Seats"
                      #:numeric #t)
        (table-column #:label "Actions"
                      #:key #f)))

(define sort-rows
  (list (list "Cozy" "3" "edit")
        (list "Calm" "14" "edit")))

(define (query->params href)
  "Split a rendered href back into the decoded query an app would hand in."
  (map (lambda (pair)
         (let ((eq (string-index pair #\=)))
           (cons (substring pair 0 eq)
                 (substring pair
                            (1+ eq)))))
       (string-split (substring (unamp href) 2) #\&)))

(define sorted-html
  (render (sortable-table #:columns sort-columns
                          #:rows sort-rows
                          #:sort 'seats
                          #:direction 'desc
                          #:params (list (cons "filter" "active"))
                          #:caption "Plans")))

(define table-suite
  (suite "Tables"
         (test "hygguile tables"
               (assert-equal #:name
                "table wraps itself in a scroll region by default"
                #:got (caar (table (list (sample-body))))
                #:expect 'div)
               (assert-equal #:name "the scroll region is a named landmark"
                             #:got (attr-value (car (table (list (sample-body))
                                                           #:caption "Plans"))
                                               'role)
                             #:expect "region")
               (assert-equal #:name
                "the scroll region is reachable with the keyboard"
                #:got (attr-value (car (table (list (sample-body))))
                                  'tabindex)
                #:expect "0")
               (assert-equal #:name
                "the scroll region borrows a string caption as its name"
                #:got (attr-value (car (table (list (sample-body))
                                              #:caption "Plans"))
                                  'aria-label)
                #:expect "Plans")
               (assert-equal #:name "table can opt out of the scroll region"
                             #:got (caar (table (list (sample-body))
                                                #:scroll #f))
                             #:expect 'table)
               (assert-equal #:name "table renders a real <table> element"
                             #:got (car (find-tag (table (list (sample-body)))
                                                  'table))
                             #:expect 'table)
               (assert-equal #:name "table renders its <caption>"
                             #:got (car (find-tag (table (list (sample-body))
                                                         #:caption "Plans")
                                                  'caption))
                             #:expect 'caption)
               (assert-equal #:name
                             "the caption sits above the table by default"
                             #:got (class-has? (find-tag (table (list (sample-body))
                                                                #:caption
                                                                "Plans")
                                                         'caption)
                                               "caption-top")
                             #:expect #t)
               (assert-equal #:name "the caption can sit below the table"
                             #:got (class-has? (caption "Plans"
                                                        #:position 'bottom)
                                               "caption-bottom")
                             #:expect #t)
               (assert-equal #:name "thead renders a <thead> row group"
                             #:got (caar (thead (list (tr (list (th "Plan"))))))
                             #:expect 'thead)
               (assert-equal #:name "tbody renders a <tbody> row group"
                             #:got (caar (tbody (list (tr (list (td "Cozy"))))))
                             #:expect 'tbody)
               (assert-equal #:name "tfoot renders a <tfoot> row group"
                             #:got (caar (tfoot (list (tr (list (td "9"))))))
                             #:expect 'tfoot)
               (assert-equal #:name "tr renders a <tr> row"
                             #:got (caar (tr (list (td "Cozy"))))
                             #:expect 'tr)
               (assert-equal #:name "th renders a <th> header cell"
                             #:got (caar (th "Plan"))
                             #:expect 'th)
               (assert-equal #:name "th declares its scope for assistive tech"
                             #:got (attr-value (car (th "Plan"
                                                        #:scope 'col))
                                               'scope)
                             #:expect "col")
               (assert-equal #:name
                             "th can describe a row instead of a column"
                             #:got (attr-value (car (th "Total"
                                                        #:scope 'row))
                                               'scope)
                             #:expect "row")
               (assert-equal #:name "td renders a <td> data cell"
                             #:got (caar (td "9"))
                             #:expect 'td)
               (assert-equal #:name "numeric cells are right-aligned"
                             #:got (class-has? (car (td "9"
                                                        #:numeric #t))
                                               "text-right")
                             #:expect #t)
               (assert-equal #:name "numeric cells use tabular figures"
                             #:got (class-has? (car (td "9"
                                                        #:numeric #t))
                                               "tabular-nums")
                             #:expect #t)
               (assert-equal #:name
                "an explicit alignment overrides the numeric default"
                #:got (class-has? (car (td "9"
                                           #:numeric #t
                                           #:align 'left)) "text-right")
                #:expect #f)
               (assert-equal #:name "text cells keep the table's alignment"
                             #:got (class-has? (car (td "Cozy")) "text-right")
                             #:expect #f)
               (assert-equal #:name "th passes through an explicit alignment"
                             #:got (class-has? (car (th "Price"
                                                        #:numeric #t))
                                               "text-right")
                             #:expect #t))

         (test "server-driven sorting"
               (assert-equal #:name
                "sort-href puts the order in a bare query by default"
                #:got (sort-href #:sort 'seats
                                 #:direction 'desc)
                #:expect "?hygguile-table-sort=seats&hygguile-table-dir=desc")
               (assert-equal #:name "sort-href can prefix an explicit path"
                #:got (sort-href #:path "/plans"
                                 #:sort 'plan)
                #:expect
                "/plans?hygguile-table-sort=plan&hygguile-table-dir=asc")
               (assert-equal #:name "sort-href carries other parameters along"
                #:got (sort-href #:params (list (cons "filter" "active"))
                                 #:sort 'seats)
                #:expect
                "?filter=active&hygguile-table-sort=seats&hygguile-table-dir=asc")
               (assert-equal #:name
                "a parameter of the page's own called sort is left alone"
                #:got (sort-href #:params (list (cons "sort" "cozy"))
                                 #:sort 'seats)
                #:expect
                "?sort=cozy&hygguile-table-sort=seats&hygguile-table-dir=asc")
               (assert-equal #:name
                             "the table reads only its own two names back"
                             #:got (parse-sort (list (cons "sort" "seats")
                                                     (cons "dir" "desc"))
                                               #:columns sort-columns)
                             #:expect '(#f asc))
               (assert-equal #:name
                "sort-href drops the page it would invalidate"
                #:got (sort-href #:params (list (cons "page" "4"))
                                 #:sort 'seats)
                #:expect "?hygguile-table-sort=seats&hygguile-table-dir=asc")
               (assert-equal #:name "sort-href keeps the page when asked to"
                #:got (sort-href #:params (list (cons "page" "4"))
                                 #:drop-params '()
                                 #:sort 'seats)
                #:expect
                "?page=4&hygguile-table-sort=seats&hygguile-table-dir=asc")
               (assert-equal #:name
                "sort-href replaces an order already in the query"
                #:got (sort-href #:params (list (cons "region" "europe")
                                                (cons "hygguile-table-sort"
                                                      "plan")
                                                (cons "hygguile-table-dir"
                                                      "asc"))
                                 #:sort 'seats
                                 #:direction 'desc)
                #:expect
                "?region=europe&hygguile-table-sort=seats&hygguile-table-dir=desc")
               (assert-equal #:name
                "sort-href leaves one order in the URL it builds"
                #:got (count-of (sort-href #:params (list (cons
                                                           "hygguile-table-sort"
                                                           "plan")
                                                          (cons
                                                           "hygguile-table-dir"
                                                           "asc"))
                                           #:sort 'seats)
                                "hygguile-table-sort=")
                #:expect 1)
               (assert-equal #:name
                "sort-href encodes what it puts in the URL"
                #:got (sort-href #:params (list (cons "q" "a b"))
                                 #:sort 'seats)
                #:expect
                "?q=a%20b&hygguile-table-sort=seats&hygguile-table-dir=asc")
               (assert-equal #:name "sort-href can ask for the natural order"
                             #:got (sort-href #:params (list (cons "filter"
                                                                   "active")))
                             #:expect "?filter=active")
               (assert-equal #:name
                "with nothing left to say, sort-href returns an empty query"
                #:got (sort-href)
                #:expect "?")
               (assert-equal #:name
                             "parse-sort reads the key and the direction"
                             #:got (parse-sort (list (cons
                                                      "hygguile-table-sort"
                                                      "seats")
                                                     (cons
                                                      "hygguile-table-dir"
                                                      "desc"))
                                               #:columns sort-columns)
                             #:expect '(seats desc))
               (assert-equal #:name
                "parse-sort answers an unknown key with the natural order"
                #:got (parse-sort (list (cons "hygguile-table-sort" "nope"))
                                  #:columns sort-columns)
                #:expect '(#f asc))
               (assert-equal #:name
                             "parse-sort answers an absent key with a #f"
                             #:got (parse-sort '()
                                               #:columns sort-columns)
                             #:expect '(#f asc))
               (assert-equal #:name
                "parse-sort falls back to the caller's default direction"
                #:got (parse-sort (list (cons "hygguile-table-sort" "seats"))
                                  #:columns sort-columns
                                  #:default-direction 'desc)
                #:expect '(seats desc))
               (assert-equal #:name
                "parse-sort accepts symbol names and (name value) pairs"
                #:got (parse-sort '((hygguile-table-sort seats)
                                    (hygguile-table-dir "DESC"))
                                  #:columns sort-columns)
                #:expect '(seats desc))
               (assert-equal #:name "parse-sort works on a plain list of keys"
                             #:got (parse-sort (list (cons
                                                      "hygguile-table-sort"
                                                      "name"))
                                               #:columns '(name seats))
                             #:expect '(name asc))
               (assert-equal #:name
                "the order a header link carries parses back to itself"
                #:got (parse-sort (query->params (sort-link-href sorted-html
                                                                 "Plan"))
                                  #:columns sort-columns)
                #:expect '(plan asc))
               (assert-equal #:name
                "a link clicked on a sorted page asks for the new column"
                #:got (parse-sort (query->params (sort-link-href (render (sortable-table
                                                                          #:columns
                                                                          sort-columns
                                                                          #:rows
                                                                          sort-rows
                                                                          #:sort 'seats
                                                                          #:direction 'desc
                                                                          #:params
                                                                          (list
                                                                           (cons
                                                                            "hygguile-table-sort"
                                                                            "seats")
                                                                           (cons
                                                                            "hygguile-table-dir"
                                                                            "desc")
                                                                           (cons
                                                                            "filter"
                                                                            "active"))))
                                                                 "Plan"))
                                  #:columns sort-columns)
                #:expect '(plan asc))
               (assert-equal #:name
                "the sorted column announces the direction it is in"
                #:got (contains? sorted-html "aria-sort=\"descending\"")
                #:expect #t)
               (assert-equal #:name
                "a sortable column that is not sorted announces that too"
                #:got (contains? sorted-html "aria-sort=\"none\"")
                #:expect #t)
               (assert-equal #:name
                             "only the sortable columns carry a sort state"
                             #:got (count-of sorted-html "aria-sort=")
                             #:expect 2)
               (assert-equal #:name
                             "clicking the sorted column asks to reverse it"
                             #:got (link-direction sorted-html "Seats")
                             #:expect "asc")
               (assert-equal #:name
                "clicking another column starts it in its own order"
                #:got (link-direction sorted-html "Plan")
                #:expect "asc")
               (assert-equal #:name
                "the sorted column's arrow points the way the rows run"
                #:got (link-arrow sorted-html "Seats")
                #:expect "↓")
               (assert-equal #:name
                             "an ascending order points the arrow up instead"
                             #:got (link-arrow (render (sortable-table
                                                        #:columns sort-columns
                                                        #:rows sort-rows
                                                        #:sort 'seats
                                                        #:direction 'asc))
                                               "Seats")
                             #:expect "↑")
               (assert-equal #:name
                "a column that is not ordering the table shows a neutral arrow"
                #:got (link-arrow sorted-html "Plan")
                #:expect "↕")
               (assert-equal #:name
                "a neutral arrow is dimmed, the meaningful one is not"
                #:got (list (contains? (link-markup sorted-html "Plan")
                                       "opacity-60")
                            (contains? (link-markup sorted-html "Seats")
                                       "opacity-60"))
                #:expect (list #t #f))
               (assert-equal #:name
                "the arrow is decorative and stays out of the label"
                #:got (contains? (link-markup sorted-html "Plan")
                                 "aria-hidden=\"true\"")
                #:expect #t)
               (assert-equal #:name
                "a sort link names its own ink instead of the default blue"
                #:got (contains? (link-markup sorted-html "Seats")
                                 "text-jeans-blue-500")
                #:expect #t)
               (assert-equal #:name
                "and names a readable one for the dark theme too"
                #:got (contains? (link-markup sorted-html "Seats")
                                 "dark:text-moonstone-300")
                #:expect #t)
               (assert-equal #:name
                "the sort links carry the other query parameters"
                #:got (contains? (sort-link-href sorted-html "Plan")
                                 "filter=active")
                #:expect #t)
               (assert-equal #:name "a column without a key is not sortable"
                             #:got (sort-link-href sorted-html "Actions")
                             #:expect #f)
               (assert-equal #:name
                "a sortable header hands its padding to the link"
                #:got (count-of sorted-html "p-0")
                #:expect 2)
               (assert-equal #:name "that link covers the whole cell"
                             #:got (contains? sorted-html
                                              "block cursor-pointer")
                             #:expect #t)
               (assert-equal #:name
                "sortable-table names the table with its caption"
                #:got (contains? sorted-html ">Plans</caption>")
                #:expect #t)
               (assert-equal #:name
                "a column can choose the order the first click asks for"
                #:got (link-direction (render (sortable-table #:columns (list (table-column
                                                                               #:key 'seats
                                                                               #:label
                                                                               "Seats"
                                                                               #:default-direction 'desc))
                                                              #:rows '()))
                                      "Seats")
                #:expect "desc")
               (assert-equal #:name
                "the table's own default order covers columns that omit one"
                #:got (link-direction (render (sortable-table #:columns (list (table-column
                                                                               #:key 'seats
                                                                               #:label
                                                                               "Seats"))
                                                              #:rows '()
                                                              #:default-direction 'desc))
                                      "Seats")
                #:expect "desc")
               (assert-equal #:name
                             "a key without a label is presented as itself"
                             #:got (contains? (render (sortable-table
                                                                      #:columns '
                                                                      (name)
                                                                      #:rows '()))
                                              ">name<span")
                             #:expect #t)
               (assert-equal #:name
                             "an empty table says so across every column"
                             #:got (contains? (render (sortable-table
                                                       #:columns sort-columns
                                                       #:rows '()))
                                              "colspan=\"3\"")
                             #:expect #t)
               (assert-equal #:name
                "a row shorter than the columns still fills its cells"
                #:got (count-of (render (sortable-table #:columns sort-columns
                                                        #:rows (list (list
                                                                      "Cozy"))))
                                "<td")
                #:expect 3)
               (assert-equal #:name
                             "numeric columns are right-aligned and tabular"
                             #:got (count-of (render (sortable-table #:columns
                                                                     (list (table-column
                                                                            #:key 'seats
                                                                            #:label
                                                                            "Seats"
                                                                            #:numeric
                                                                            #t))
                                                                     #:rows (list
                                                                             (list
                                                                              "3"))))
                                             "tabular-nums")
                             #:expect 2))))

(define (spec)
  (veritas-run table-suite))
