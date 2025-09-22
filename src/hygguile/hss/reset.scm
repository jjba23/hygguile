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

(define-module (hygguile hss reset)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:export (reset-css))

(define big-html-reset-list
  '(html body
         div
         span
         applet
         object
         iframe
         h1
         h2
         h3
         h4
         h5
         h6
         p
         blockquote
         pre
         a
         abbr
         acronym
         address
         big
         cite
         code
         del
         dfn
         em
         img
         ins
         kbd
         q
         s
         samp
         small
         strike
         strong
         sub
         sup
         tt
         var
         b
         u
         i
         center
         dl
         dt
         dd
         ol
         ul
         li
         fieldset
         form
         label
         legend
         table
         caption
         tbody
         tfoot
         thead
         tr
         th
         td
         article
         aside
         canvas
         details
         embed
         figure
         figcaption
         footer
         header
         hgroup
         menu
         nav
         output
         ruby
         section
         summary
         time
         mark
         audio
         video))

(define reset-css
  (make-parameter (list (r= (string-join (map symbol->string
                                              big-html-reset-list) ", ")
                            (list (d= 'margin 0)
                                  (d= 'padding 0)
                                  (d= 'border 0)
                                  (d= 'font-size "100%")
                                  (d= 'font
                                      'inherit)
                                  (d= 'vertical-align
                                      'baseline)))
                        (r= (string-join (map symbol->string
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
                            (list (d= 'display
                                      'block)))
                        (r= 'button
                            (list (d= 'background
                                      'transparent)
                                  (d= 'border
                                      'none)))
                        (r= 'body
                            (list (d= 'line-height 1)))

                        (r= (string-join (map symbol->string
                                              '(blockquote q)) ", ")
                            (list (d= 'quotes
                                      'none)))

                        (r= 'table
                            (list (d= 'borser-collpase
                                      'collapse)
                                  (d= 'border-spacing 0)))

                        (r= (string-join (map symbol->string
                                              '(blockquote:before
                                                blockquote:after

                                                q:before q:after)) ", ")
                            (list (d= 'content "''")
                                  (d= 'content
                                      'none)))
                        (r= (string-join (map symbol->string
                                              '(ol ul)) ", ")
                            (d= 'list-style
                                'none))

                        )))

