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

(define-module (hygguile hss decl reset)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:export (reset-css))

(define all-html-elements
  '("*" "::after" "::before" "::backdrop" "::file-selector-button"))

(define reset-css
  (make-parameter (list (rul (string-join all-html-elements ", ")
                             (dec 'margin 0)
                             (dec 'padding 0)
                             (dec 'border "0 solid")
                             (dec 'box-sizing 'border-box)
                             (dec 'font
                                  'inherit)
                             (dec 'vertical-align
                                  'baseline))
                        (rul (string-join (map symbol->string '(h1 h2 h3 h4 h5 h6)) ",")
                             (dec 'font-size 'inherit)
                             (dec 'font-weight 'inherit))
                        (rul (string-join (map symbol->string
                                               '(article aside
                                                         details
                                                         figcaption
                                                         figure
                                                         footer
                                                         header
                                                         hgroup
                                                         menu
                                                         nav
                                                         section)) ", ")
                             (dec 'display
                                  'block))
                        (rul 'button
                             (dec 'background
                                  'transparent)
                             (dec 'border
                                  'none))
                        (rul 'body
                             (dec 'line-height 1))

                        (rul (string-join (map symbol->string
                                               '(blockquote q)) ", ")
                             (dec 'quotes
                                  'none))

                        (rul 'table
                             (dec 'borser-collpase
                                  'collapse)
                             (dec 'border-spacing 0))

                        (rul (string-join (map symbol->string
                                               '(blockquote:before
                                                 blockquote:after

                                                 q:before q:after)) ", ")
                             (dec 'content "''")
                             (dec 'content
                                  'none))
                        (rul (string-join (map symbol->string
                                               '(ol ul)) ", ")
                             (dec 'list-style
                                  'none))

                        )))

