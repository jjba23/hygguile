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

;; ===== a minimal hygguile page =====
;;
;; This is the smallest useful hygguile program: one page, rendered to one
;; HTML file, using the components you would reach for on day one. Read it
;; top to bottom and you have read the shape of the framework.
;;
;; Render it with:
;;
;;   maak example        (writes dist/example.html, next to olive.min.css)
;;   maak serve          (then open http://localhost:50054/example.html)
;;
;; `maak build' renders this page too, next to the showcase, and checks
;; both against WCAG AA before it hands them over; `maak example' re-renders
;; just this one.
;;
;; Two rules it demonstrates:
;;
;;   * pages are data: every component returns an SXML tree, and
;;     `sxml->xml' turns that tree into the HTML string we write out;
;;   * the framework hands you the head: `hygguile-recommended-meta' and
;;     `hygguile-recommended-resources' load the fonts, the companion
;;     stylesheet and the handful of progressive-enhancement scripts, while
;;     olive.min.css stays a plain <link> you serve yourself and cache.

(use-modules (ice-9 textual-ports)
             (hygguile hygguile)
             (hygguile sxml))

;; ===== the page body =====

(define (page-main)
  (list
   (h1 "A minimal hygguile page")

   (p (list "Server-rendered, accessible, and " (strong "readable")
            " in both themes. Press " (kbd "Ctrl") " " (kbd "l") " in a real "
            "browser, or follow "
            (a "this link" #:href "https://codeberg.org/jjba23/hygguile")
            "."))
   (p (list "Rendered " (time "11 October 2026" #:datetime "2026-10-11")
            " by hygguile."))

   ;; ---- cards and stats ----
   `(div (@ (class ,(mk-class '(grid sm:grid-cols-2 gap-4 my-6))))
         ,(card (list (card-header (h3 "Active users" #:size '(text-lg)))
                      (card-body (list
                                  (stat-card #:value "1,204"
                                             #:label "Active users"
                                             #:trend "+12%"
                                             #:trend-variant 'success)
                                  (badge "new" #:variant 'info))))))

   ;; ---- feedback ----
   (alert #:title "Heads up"
          #:body "Your session expires in ten minutes."
          #:variant 'warning)
   (progress #:value 72 #:show-value #t)

   ;; ---- a native form: labels bound to fields, browser validation, none
   ;; of it needing a line of client-side code ----
   (form (list (input #:label "Your email:"
                      #:name "email"
                      #:type 'email
                      #:autocomplete "email"
                      #:required #t)
               (input #:label "Password:"
                      #:name "password"
                      #:type 'password
                      #:autocomplete "current-password"
                      #:help-text "At least twelve characters."
                      #:required #t))
         #:action "/subscribe"
         #:submit "Subscribe")

   ;; ---- tabular data, with the caption assistive technology reads out ----
   (table (list (thead (list (tr (list (th "Plan" #:scope 'col)
                                      (th "Seats" #:scope 'col #:numeric #t)))))
                (tbody (list (tr (list (td "Cozy")
                                       (td "3" #:numeric #t)))))
                (tfoot (list (tr (list (th "Total" #:scope 'row)
                                       (td "3" #:numeric #t))))))
          #:caption "Plans")

   ;; ---- a disclosure that is just <details> and <summary> ----
   (details (p "Plain <details> and <summary>, straight from the browser.")
            #:summary "Why so much native HTML?")

   ;; ---- page navigation ----
   (pagination #:current 2 #:total 4 #:base-url "?page=")))

(define (page-body)
  `((navbar ,(list (nav-link "Home" #:href "#" #:active #t)
                   (nav-link "Docs" #:href "#docs")
                   (nav-link "About" #:href "#about"))
            #:brand "hygguile")
    ;; with-footer wraps a page in a real <main> landmark plus a <footer>
    ,(with-footer
      #:main (page-main)
      #:footer (footer (list (p "hygguile is free software, LGPL-3.0-or-later."))))))

;; ===== the page shell =====

(define* (html-template #:key title body)
  `(,doctype-html
    (html (@ (lang en))
          (head (title ,title)
                ,(hygguile-recommended-meta)
                ,(hygguile-recommended-resources)
                ;; serving olive.min.css as a cacheable file beats inlining
                ;; a few hundred kilobytes into every response
                (link (@ (rel stylesheet) (href "olive.min.css"))))
          (body (@ (class ,(mk-class '(bg-stone-100 dark:bg-onyx-900
                                                 font-sans))))
                ,notification-tray
                ,@body))))

(define (example)
  (with-output-to-string
    (lambda ()
      (sxml->xml (html-template #:title "hygguile minimal example"
                                #:body (page-body))))))

;; ===== run =====

(with-output-to-file "dist/example.html"
  (lambda ()
    (display (example))))

(display "\n>>= wrote dist/example.html (serve it with: maak serve)\n")
