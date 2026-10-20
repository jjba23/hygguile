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

;; Data: tables, the display pieces and detail lists.

(define-module (showcase data)
  #:use-module (hygguile hygguile)
  #:export (tables-section data-extras-section dl-section))

(define tables-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-4))))
              ,(p
                "Tabular data deserves real table markup: columns are declared with &lt;th&gt; and an explicit scope, the rows live in &lt;tbody&gt;, and the totals sit in &lt;tfoot&gt;, so the header that describes a cell is never guessed by a screen reader."
                #:weight '(font-light))
              ,(p
                "A wide table is also the classic way to break a phone layout. Every table therefore arrives wrapped in a region you can scroll sideways, named for assistive technology and reachable with the keyboard."
                #:weight '(font-light)))
         ,(table (list (thead (list (tr (list (th "Day"
                                                  #:scope 'col)
                                              (th "Coffees"
                                                  #:scope 'col
                                                  #:numeric #t)
                                              (th "Pastries"
                                                  #:scope 'col
                                                  #:numeric #t)
                                              (th "Takings"
                                                  #:scope 'col
                                                  #:numeric #t)))))
                       (tbody (list (tr (list (th "Monday"
                                                  #:scope 'row)
                                              (td "42"
                                                  #:numeric #t)
                                              (td "18"
                                                  #:numeric #t)
                                              (td "€ 248.50"
                                                  #:numeric #t)))
                                    (tr (list (th "Tuesday"
                                                  #:scope 'row)
                                              (td "51"
                                                  #:numeric #t)
                                              (td "22"
                                                  #:numeric #t)
                                              (td "€ 301.75"
                                                  #:numeric #t)))
                                    (tr (list (th "Wednesday"
                                                  #:scope 'row)
                                              (td "47"
                                                  #:numeric #t)
                                              (td "19"
                                                  #:numeric #t)
                                              (td "€ 274.20"
                                                  #:numeric #t)))
                                    (tr (list (th "Thursday"
                                                  #:scope 'row)
                                              (td "58"
                                                  #:numeric #t)
                                              (td "26"
                                                  #:numeric #t)
                                              (td "€ 349.90"
                                                  #:numeric #t)))
                                    (tr (list (th "Friday"
                                                  #:scope 'row)
                                              (td "73"
                                                  #:numeric #t)
                                              (td "31"
                                                  #:numeric #t)
                                              (td "€ 438.05"
                                                  #:numeric #t)))))
                       (tfoot (list (tr (list (th "Week"
                                                  #:scope 'row)
                                              (td "271"
                                                  #:numeric #t)
                                              (td "116"
                                                  #:numeric #t)
                                              (td "€ 1 612.40"
                                                  #:numeric #t))))))
                 #:caption "Café takings, week of 5 October 2026")
         ,(code-sample '(table (list (thead (list (tr (list (th "Plan"
                                                                #:scope 'col)
                                                            (th "Price"
                                                                #:scope 'col
                                                                #:numeric #t)))))
                                     (tbody (list (tr (list (td "Cozy")
                                                            (td "9"
                                                                #:numeric #t)))
                                                  (tr (list (td "Calm")
                                                            (td "14"
                                                                #:numeric #t)))))
                                     (tfoot (list (tr (list (th "Total"
                                                                #:scope 'row)
                                                            (td "23"
                                                                #:numeric #t))))))
                               #:caption "Plans")))
    (sub-h3 "Sorting without JavaScript")
    ,(p
      "Sorting is not a rendering trick, it is a question a page asks the server: in which order? A sortable header cell is therefore an ordinary link that carries the order in the query string, and the cell announces the state it is in with aria-sort. Clicking a column is a plain navigation: it works with JavaScript disabled, a reload reproduces the order, and the URL can be shared or bookmarked."
      #:weight '(font-light))
    ,(p
      "Only a server can answer that link, and this showcase is a static page, so what you see below is the markup it produces: each header carries ?hygguile-table-sort= and ?hygguile-table-dir=, and the current column says which way it is going. The names are prefixed so that a sort or a dir parameter of the page's own is never read as the table's state. examples/sortable-table.scm runs the other half -- a server that reads the order back with parse-sort and re-renders the rows in it."
      #:weight '(font-light))
    ,(sortable-table #:columns (list (table-column #:key 'plan
                                                   #:label "Plan")
                                     (table-column #:key 'seats
                                                   #:label "Seats"
                                                   #:numeric #t)
                                     (table-column #:key 'revenue
                                                   #:label "Revenue"
                                                   #:numeric #t
                                                   #:default-direction 'desc))
                     #:rows (list (list "Cozy" "3" "€ 27")
                                  (list "Calm" "14" "€ 196")
                                  (list "Roomy" "9" "€ 81"))
                     #:sort 'seats
                     #:direction 'desc
                     #:params '(("region" . "europe") ("page" . "2"))
                     #:caption "Plans, sorted by seats")
    ,(code-sample '(sortable-table #:columns (list (table-column #:key 'plan
                                                                 #:label
                                                                 "Plan")
                                                   (table-column #:key 'seats
                                                                 #:label
                                                                 "Seats"
                                                                 #:numeric #t))
                                   #:rows (list (list "Cozy" "3")
                                                (list "Calm" "14"))
                                   #:sort 'seats
                                   #:direction 'desc
                                   #:caption "Plans"))))

(define data-extras-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2))))
              ,(chip "Scheme"
                     #:variant 'info)
              ,(chip "Draft"
                     #:variant 'warning
                     #:remove-href "#")
              ,(chip "Published"
                     #:variant 'success))
         ,(avatar-group (list (avatar #:initials "AB")
                              (avatar #:initials "CD")
                              (avatar #:initials "EF")
                              (avatar #:initials "GH")
                              (avatar #:initials "IJ"))
                        #:max 4
                        #:label "Contributors")
         ,(timeline (list (timeline-item #:time "09:12"
                                         #:title "Build started"
                                         #:variant 'info)
                          (timeline-item #:time "09:14"
                                         #:title "Tests passed"
                                         #:variant 'success)
                          (timeline-item #:time "09:16"
                                         #:title "Deployed"
                                         #:current? #t))
                    #:label "Deployment")
         ,(tree-view #:label "Documentation"
                     #:items (list (tree-item "Guides"
                                              #:open #t
                                              #:children (list (tree-item
                                                                "Install"
                                                                #:href "#")
                                                               (tree-item
                                                                "Forms"
                                                                #:href
                                                                "#forms")))
                                   (tree-item "Reference"
                                              #:href "#"))))))

(define dl-section
  `((div ,(dl (list (dt "foo:")
                    (dd "bar")
                    (dt "abcdefghij:")
                    (dd "1234567890")
                    (dt "some key:")
                    (dd "some value"))))))
