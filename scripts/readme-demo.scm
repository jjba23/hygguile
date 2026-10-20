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

;; The small pages used for the README's animated demo. They are not part of
;; the shipped site; they exist so the screenshots in the README can be
;; regenerated from the same components a reader sees. Every page is written
;; twice, once per theme, so the demo can show both.
;;
;;   mkdir -p dist
;;   guix shell -m manifest.scm -- guile -L ./src scripts/readme-demo.scm
;;
;; The files land in dist/demo-hero-{light,dark}.html, dist/demo-forms-*.html
;; and dist/demo-data-*.html. Screenshot each at 1280x800 with a headless
;; browser, then combine the frames into assets/readme/hygguile-demo.gif.

(use-modules (hygguile hygguile)
             (hygguile sxml))

(define* (page title body #:key (theme "light"))
  `(,doctype-html
    (html (@ (lang en) (data-theme ,theme))
          (head (title ,title)
                ,(hygguile-recommended-meta)
                ,(hygguile-recommended-resources)
                (link (@ (rel stylesheet) (href "olive.min.css"))))
          (body (@ (class ,(mk-class '(bg-stone-100 dark:bg-onyx-900 font-sans))))
                ,(navbar (list (nav-link "Home" #:href "#" #:active #t)
                               (nav-link "Components" #:href "#")
                               (nav-link "Docs" #:href "#"))
                         #:brand "Hygguile"
                         #:sticky #f)
                (main (@ (class ,(mk-class '(max-w-6xl mx-auto p-6))))
                      ,@body)))))

(define hero-body
  (list (glass-panel
         (list (h1 "Hygguile" #:color '(hg-gradient-text))
               (p "cozy and professional user-interfaces for everyone"
                  #:size '(text-2xl)
                  #:weight '(font-light))
               (p "Server-rendered HTML from S-expressions, styled with Olive CSS, usable without JavaScript."
                  #:weight '(font-light))
               (cluster (list (primary-button "Get started")
                              (secondary-button "Browse components")
                              (ghost-button "Read the docs")))
               (cluster (list (badge "SXML" #:variant 'info)
                              (badge "SSR" #:variant 'success)
                              (badge "Accessible" #:variant 'warning)
                              (badge "LGPL-3.0+" #:variant 'neutral))))
         #:padding '(p-8)
         #:classes '(flex flex-col gap-4))
        (grid (list (card (list (card-header (h3 "Layout" #:size '(text-lg)))
                                (card-body (p "Stack, grid, split, centre and a reserved ratio box."))))
                    (card (list (card-header (h3 "Controls" #:size '(text-lg)))
                                (card-body (p "Fields, selects, dates, files and a form-field shell."))))
                    (card (list (card-header (h3 "Data" #:size '(text-lg)))
                                (card-body (p "Tables, cards, timelines, trees and first-class states.")))))
              #:columns 3)
        (grid (list (alert #:title "Nothing to hydrate"
                           #:body "The markup you see is the page the server sent: links, labels and controls included."
                           #:variant 'success)
                    (card (list (card-body (list (p "Small islands of behaviour"
                                                   #:size '(text-lg))
                                                (progress #:value 72
                                                          #:label "Enhancement"
                                                          #:show-value #t)
                                                (cluster (list (chip "details" #:variant 'info)
                                                               (chip "tabs" #:variant 'success)
                                                               (chip "dialog" #:variant 'warning))))))))
              #:columns 2)))

(define form-body
  (list (h2 "A form in a page")
        (p "Every field is a native control with a bound label, helper copy and an error slot."
           #:weight '(font-light))
        (form (list (grid (list (input #:label "Your name" #:name "readme-name"
                                       #:placeholder "Ada Lovelace")
                                (select #:label "Plan" #:name "readme-plan"
                                        #:options (list (option #:value "cozy" #:content "Cozy (free)")
                                                        (option #:value "calm" #:content "Calm")))
                                (stepper #:label "Seats" #:name "readme-seats"
                                         #:value 3 #:min 1 #:max 12)
                                (number-field #:label "Guests" #:name "readme-guests"
                                              #:value 2 #:min 1 #:max 12))
                          #:columns 2)
                    (search-field #:name "readme-q" #:action "#")
                    (date-range-field #:label "Stay" #:name "readme-stay"
                                      #:start "2026-10-11" #:end "2026-10-14"))
              #:action "#"
              #:submit "Save")
        (alert #:title "A native form"
               #:body "It submits with JavaScript disabled and validates with the browser."
               #:variant 'info)))

(define data-body
  (list (h2 "Data, states and feedback")
        (grid (list (stat-card #:value "1,204" #:label "Active users" #:trend "+12%")
                    (stat-card #:value "98.6%" #:label "Uptime" #:trend "+0.2%")
                    (stat-card #:value "12 ms" #:label "First byte" #:trend "-3 ms"
                               #:trend-variant 'neutral))
              #:columns 3)
        (table (list (thead (list (tr (list (th "Plan" #:scope 'col)
                                         (th "Seats" #:scope 'col #:numeric #t)
                                         (th "Price" #:scope 'col #:numeric #t)))))
                     (tbody (list (tr (list (td "Cozy") (td "3" #:numeric #t)
                                           (td "9" #:numeric #t)))
                                  (tr (list (td "Calm") (td "10" #:numeric #t)
                                            (td "29" #:numeric #t))))))
               #:caption "Plans")
        (grid (list (timeline (list (timeline-item #:time "09:12"
                                                   #:title "Build started"
                                                   #:variant 'info)
                                   (timeline-item #:time "09:14"
                                                   #:title "Tests passed"
                                                   #:variant 'success)
                                   (timeline-item #:time "09:16"
                                                   #:title "Deployed"
                                                   #:current? #t))
                             #:label "Deployment")
                    (stack (list (alert #:title "Saved"
                                        #:body "Your changes are live."
                                        #:variant 'success)
                                 (progress #:value 72 #:label "Importing"
                                           #:show-value #t)
                                                                    (cluster (list (chip "SXML" #:variant 'info)
                                                                                   (chip "SSR" #:variant 'success))))
                                                            #:gap '(gap-3)))
                                               #:columns 2)
                                                         (cluster (list (circular-progress #:value 68
                                                                                           #:label "Importing"
                                                                                           #:show-value #t)
                                                                        (circular-progress #:label "Working")
                                                                        (spinner #:size 'lg
                                                                                 #:label "Loading")
                                                                        (badge "Live" #:variant 'success)))))

(define (write-page path title theme body)
  (with-output-to-file path
    (lambda ()
      (display (call-with-output-string
                (lambda (port)
                  (sxml->xml (page title body #:theme theme) port)))))))

(for-each (lambda (theme)
            (write-page (string-append "dist/demo-hero-" theme ".html")
                        (string-append "Hygguile — hero (" theme ")")
                        theme hero-body)
            (write-page (string-append "dist/demo-forms-" theme ".html")
                        (string-append "Hygguile — forms (" theme ")")
                        theme form-body)
            (write-page (string-append "dist/demo-data-" theme ".html")
                        (string-append "Hygguile — data (" theme ")")
                        theme data-body))
          '("light" "dark"))
