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

(define-module (veritas unit components table-extras-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components table)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define columns
  (list (table-column #:key 'a #:label "A")
        (table-column #:key 'b #:label "B")))

(define table-extras-suite
  (suite "Table extras"
         (test "data grid features"
               (assert-equal #:name "a sticky header says so"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:rows '(("1" "2"))
                                                  #:sticky-header? #t))
                                         "hg-sticky-header")
                             #:expect #t)
               (assert-equal #:name "a selectable table renders checkboxes"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:rows '(("1" "2"))
                                                  #:selectable? #t))
                                         "data-hg-select-all")
                             #:expect #t)
               (assert-equal #:name "a selectable row carries its key"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:rows '(("1" "2"))
                                                  #:selectable? #t
                                                  #:row-keys '("row-1")))
                                         "value=\"row-1\"")
                             #:expect #t)
               (assert-equal #:name "a resizable table opts into the script"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:rows '(("1" "2"))
                                                  #:resizable? #t))
                                         "data-hg-resizable")
                             #:expect #t)
               (assert-equal #:name "a compact table names its density"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:rows '(("1" "2"))
                                                  #:density 'compact))
                                         "hg-density-compact")
                             #:expect #t))
         (test "loading and failure states"
               (assert-equal #:name "a loading table is a skeleton"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:loading? #t))
                                         "hg-skeleton-table")
                             #:expect #t)
               (assert-equal #:name "a failed table explains itself"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:error "Offline"))
                                         "Offline")
                             #:expect #t)
               (assert-equal #:name "a failed table can offer a retry"
                             #:got (has? (render (sortable-table
                                                  #:columns columns
                                                  #:error "Offline"
                                                  #:retry "Try again"))
                                         "Try again")
                             #:expect #t))))

(define (spec)
  (veritas-run table-extras-suite))
