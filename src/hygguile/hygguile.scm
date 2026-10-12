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

(define-module (hygguile hygguile)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile js)
  #:use-module (hygguile embed js)
  #:use-module (hygguile embed css)
  #:use-module (hygguile components button)
  #:use-module (hygguile components container)
  #:use-module (hygguile components icon)
  #:use-module (hygguile components input)
  #:use-module (hygguile components media)
  #:use-module (hygguile components card)
  #:use-module (hygguile components feedback)
  #:use-module (hygguile components navigation)
  #:use-module (hygguile components disclosure)
  #:use-module (hygguile components fly-out)
  #:use-module (hygguile components select)
  #:use-module (hygguile components notification)
  #:use-module (hygguile components typography)
  #:use-module (hygguile components table)
  #:use-module (hygguile components carousel)
  #:use-module (hygguile components glass)
  #:use-module (hygguile css)
  #:re-export (a abbr
                 accordion
                 accordion-item
                 alert
                 avatar
                 badge
                 breadcrumbs
                 button
                 caption
                 card
                 card-body
                 card-description
                 card-footer
                 card-header
                 card-title
                 carousel
                 carousel-button-js
                 checkbox
                 code
                 col
                 copy-pre-inner-text-js
                 custom-fonts
                 details
                 danger-submit-button
                 dd
                 dl
                 dt
                 em
                 fieldset
                 figure
                 figcaption
                 fly-out
                 fly-out-css
                 fly-out-item
                 fly-out-js
                 fly-out-submenu
                 footer
                 form
                 form-error
                 get-short-commit-sha
                 glass-panel
                 glass-wash
                 glyph-option
                 h1
                 h2
                 h3
                 h4
                 help-text
                 hr
                 icon
                 icon-button
                 image-gallery
                 img
                 input
                 kbd
                 legend
                 light-button
                 linear-gradient
                 mark
                 mk-class
                 modal
                 mono
                 mono-button
                 navbar
                 nav-link
                 noscript
                 notification-card
                 notification-tray
                 option
                 optgroup
                 p
                 pagination
                 parse-sort
                 phosphor-icons
                 picture
                 pre
                 pretty-quote
                 progress
                 radio
                 range
                 remember-dark-theme-js
                 render-if-nempty
                 render-if-nestring
                 row
                 samp
                 select
                 show-notifications-from-url-js
                 skeleton
                 sort-href
                 sortable-table
                 source
                 spinner
                 stat-card
                 strong
                 sub-h1
                 sub-h2
                 sub-h3
                 sub-h4
                 sub
                 submit-button
                 summary
                 sup
                 switch
                 table
                 table-column
                 tab
                 tabs
                 tbody
                 td
                 textarea
                 tfoot
                 th
                 thead
                 time
                 toggle-dark-theme-js
                 tooltip
                 tr
                 trigger-notification-function-js
                 ui-mode-button
                 var
                 with-footer)
  #:export (doctype-html hygguile-recommended-meta
                         hygguile-recommended-resources))

(define* (hygguile-recommended-resources #:key (fonts (custom-fonts)))
  "Assemble a list of recommended UI resource fragments, including standard web typography assets and component script blocks.

@table @var
@item fonts
An S-expression block managing custom font loading configurations, defaulting to the result of @code{(custom-fonts)}.
@end table

@example
(hygguile-recommended-resources)
@end example"
  (list fonts
        (phosphor-icons)
        (fly-out-css)
        (hygguile-extras-css)
        `(noscript ,@(no-js-css))
        (toggle-dark-theme-js)
        (copy-pre-inner-text-js)
        (show-notifications-from-url-js)
        (carousel-button-js)
        (remember-dark-theme-js)
        (color-show-js)
        (fly-out-js)))

(define doctype-html
  "<!DOCTYPE html>")

(define (hygguile-recommended-meta)
  "Return an S-expression list containing basic framework-recommended HTML metadata tags.

Includes mobile-responsive viewport parameters and typical character set configurations.

@example
(hygguile-recommended-meta)
@end example"
  (list `(meta (@ (name viewport)
                  (content "width=device-width, initial-scale=1.0")))
        `(meta (@ (charset UTF-8)))))
