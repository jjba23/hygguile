;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ===== a server-driven sortable table =====
;;
;; The showcase can only show you the markup of a sortable table, because a
;; static page has nobody to answer its sort links. This is the other half:
;; a real Guile web server that renders the page, reads the table's two
;; query parameters back with `parse-sort', and re-renders the rows in the
;; order it was asked for.
;;
;; Run it from the repository root:
;;
;;   maak example-server            (or: guix shell -m manifest.scm --
;;                                        guile -L ./src examples/sortable-table.scm)
;;   and open http://localhost:8095/
;;
;; Then click a column header and watch the URL: no JavaScript runs, the
;; page is an ordinary form-less navigation, and a reload, a bookmark or a
;; shared link lands on the same order because the order lives in the URL.
;; The response also prints what the server understood, so the contract
;; (hygguile-table-sort=<key>&hygguile-table-dir=asc|desc) is visible
;; rather than implied. The names are prefixed with the library's own, so a
;; page's own `sort' or `dir' parameter -- see the links at the bottom of
;; the page -- is left to the page.
;;
;; Swapping the in-memory list for a database is the only change a real
;; application needs: ask the database for `order by <key> <direction>'
;; instead of sorting the list here.

(use-modules (ice-9 iconv)
             (ice-9 string-fun)
             (ice-9 textual-ports)
             (srfi srfi-1)
             (web uri)
             (web request)
             (web response)
             (web server)
             (hygguile hygguile)
             (hygguile sxml))

;; ===== the data =====
;;
;; One row per plan, as an association list so a column key can find its
;; own field. In a real application this is a query, not a list.

(define plans
  (list (list (cons 'plan "Cozy")
              (cons 'seats 3)
              (cons 'revenue 27))
        (list (cons 'plan "Calm")
              (cons 'seats 14)
              (cons 'revenue 196))
        (list (cons 'plan "Roomy")
              (cons 'seats 9)
              (cons 'revenue 81))
        (list (cons 'plan "Airy")
              (cons 'seats 6)
              (cons 'revenue 54))
        (list (cons 'plan "Snug")
              (cons 'seats 21)
              (cons 'revenue 312))))

(define columns
  (list (table-column #:key 'plan
                      #:label "Plan")
        (table-column #:key 'seats
                      #:label "Seats"
                      #:numeric #t)
        (table-column #:key 'revenue
                      #:label "Revenue"
                      #:numeric #t
                      #:default-direction 'desc)))

;; ===== ordering, the server's side of the contract =====

(define (before? left right)
  "True when LEFT orders before RIGHT, by number when both are numbers."
  (if (and (number? left)
           (number? right))
      (< left right)
      (string<? (format #f "~a" left)
                (format #f "~a" right))))

(define (ordered-plans key direction)
  "Return the plans in the requested order, or in their natural order.

A database would do this in its own `order by' clause; the point here is
that the ordering is decided by the request and nothing else."
  (if (not key) plans
      (sort plans
            (lambda (a b)
              (let ((left (assq-ref a key))
                    (right (assq-ref b key)))
                (if (eq? 'desc direction)
                    (before? right left)
                    (before? left right)))))))

(define (ordered-rows key direction)
  (map (lambda (plan)
         (list (assq-ref plan
                         'plan)
               (format #f "~a"
                       (assq-ref plan
                                 'seats))
               (format #f "€ ~a"
                       (assq-ref plan
                                 'revenue))))
       (ordered-plans key direction)))

;; ===== reading the request =====

(define (parse-query query)
  "Split a raw query string into decoded @code{(name . value)} pairs."
  (if (or (not query)
          (string=? query ""))
      '()
      (map (lambda (pair)
             (let ((eq (string-index pair #\=)))
               (if eq
                   (cons (uri-decode (substring pair 0 eq))
                         (uri-decode (substring pair
                                                (1+ eq))))
                   (cons (uri-decode pair) ""))))
           (string-split query #\&))))

;; ===== rendering =====

(define (blank? text)
  "True when TEXT is missing or empty."
  (or (not text)
      (string=? text "")))

(define (as-text text)
  "Make TEXT safe to put in a text node.

hygguile's serializer writes text nodes exactly as it finds them -- the
components escape their own prose, which is why the showcase writes `&lt;'
by hand -- so a query string interpolated into a sentence has to escape
itself. A raw `&region' would otherwise be read by the browser as the
`&reg' entity and shown as a registered sign."
  (string-replace-substring (string-replace-substring (string-replace-substring
                                                       text "&" "&amp;") "<"
                                                      "&lt;") ">" "&gt;"))

(define (state-note state query)
  "Describe, in prose, what the server made of this request."
  (let ((key (car state))
        (direction (cadr state)))
    (if (not key)
        (format #f
         "This request asked for no particular order, so the table kept its natural one. The query was ~a."
         (if (blank? query) "empty"
             (as-text (format #f "?~a" query))))
        (format #f
         "The server read ~a and is showing the rows ordered by ~a, ~a."
         (if (blank? query) "no query"
             (as-text (format #f "?~a" query))) key
         (if (eq? 'desc direction) "descending" "ascending")))))

(define (page params query)
  (let* ((state (parse-sort params
                            #:columns columns))
         (key (car state))
         (direction (cadr state)))
    (list (navbar (list (nav-link "Home"
                                  #:href "/"
                                  #:active #t))
                  #:brand "cozy plans")
          (with-footer #:main (list (h1 "Plans")
                                    (p (list
                                        "Every column heading below is a link. The order is in the URL, the server answers it, and no script is involved: this page works with JavaScript turned off, and "
                                        (strong "a reload keeps the order")
                                        "."))
                                    (alert #:title
                                           "What the server understood"
                                           #:body (state-note state query)
                                           #:variant 'info)
                                    (sortable-table #:columns columns
                                                    #:rows (ordered-rows key
                                                            direction)
                                                    #:sort key
                                                    #:direction direction
                                                    #:params params
                                                    #:caption (if key
                                                                  (format #f
                                                                   "Plans, ordered by ~a"
                                                                   key)
                                                                  "Plans"))
                                    (p (list
                                        "The links carry the other query parameters along, so add your own to see them survive a sort: "
                                        (a "?region=europe"
                                           #:href "/?region=europe")
                                        ". A parameter called "
                                        (code "sort")
                                        " is the page's own, not the table's, so even "
                                        (a "?sort=cozy"
                                           #:href "/?sort=cozy&region=europe")
                                        " is carried through untouched.")))
                       #:footer (footer (list (p
                                               "hygguile's server-driven sorting, end to end.")))))))

(define* (html-template #:key title body)
  `(,doctype-html (html (@ (lang en))
                        (head (title ,title)
                              ,(hygguile-recommended-meta)
                              ,(hygguile-recommended-resources)
                              (link (@ (rel stylesheet)
                                       (href "/olive.min.css"))))
                        (body (@ (class ,(mk-class '(bg-stone-100
                                                     dark:bg-onyx-900
                                                     font-sans))))
                              ,notification-tray
                              ,@body))))

(define (render-page params query)
  (with-output-to-string (lambda ()
                           (sxml->xml (html-template #:title
                                       "hygguile sortable table"
                                       #:body (page params query))))))

;; ===== the server =====

(define (respond code type body)
  "Answer with BODY, encoded as UTF-8, and the given content type."
  (values (build-response #:code code
                          #:headers `((content-type ,type
                                                    (charset . "utf-8"))))
          (string->bytevector body "UTF-8")))

(define (stylesheet)
  (if (file-exists? "resources/css/olive.min.css")
      (respond 200
               'text/css
               (call-with-input-file "resources/css/olive.min.css"
                 get-string-all))
      (respond 404
               'text/plain "olive.min.css is not here\n")))

(define (handler request body)
  (let* ((uri (request-uri request))
         (path (uri-path uri))
         (query (uri-query uri)))
    (cond
      ((string=? path "/olive.min.css")
       (stylesheet))
      ((string=? path "/")
       (respond 200
                'text/html
                (render-page (parse-query query) query)))
      (else (respond 404
                     'text/plain "not found\n")))))

(define (main args)
  (let ((port (if (> (length args) 1)
                  (string->number (cadr args)) 8095)))
    (format #t "~%>>= hygguile sortable table on http://localhost:~a/~%" port)
    (format #t ">>= click a column heading; the URL does the sorting~%")
    (run-server handler
                'http
                (list #:port port))))

(main (command-line))
