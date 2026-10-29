;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile hygguile)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components tray)
  #:use-module (hygguile components code)
  #:use-module (hygguile components color)
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
  #:use-module (hygguile components tokens)
  #:use-module (hygguile components layout)
  #:use-module (hygguile components utility)
  #:use-module (hygguile components field)
  #:use-module (hygguile components overlay)
  #:use-module (hygguile components data)
  #:use-module (hygguile components rating)
  #:use-module (hygguile components segmented)
  #:use-module (hygguile css)
  #:use-module (hygguile version)
  #:re-export (a abbr
                 accordion
                 accordion-item
                 alert
                 avatar
                 badge
                 blockquote
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
                 cite
                 code
                 code-sample
                 code-sample-js
                 col
                 color-swatch
                 copy-pre-inner-text-js
                 custom-fonts
                 details
                 disclosure-controls
                 danger-submit-button
                 dd
                 dl
                 dt
                 em
                 expandable-card
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
                 glossary-term
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
                 ;; the version the framework reports about itself, kept in
                 ;; (hygguile version) and re-exported so a page prints it
                 ;; without importing a module of its own
                 hygguile-homepage
                 hygguile-license
                 hygguile-version
                 hygguile-version-string
                 print-version
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
                 pretty-code
                 pretty-quote
                 progress
                 radio
                 range
                 remember-dark-theme-js
                 render-if-nempty
                 render-if-nestring
                 row
                 samp
                 section-nav
                 select
                 show-notifications-from-url-js
                 skeleton
                 sort-href
                 sortable-table
                 sort-control
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
                 tray-js
                 tr
                 trigger-notification-function-js
                 ui-mode-button
                 var
                 with-footer
                 ;; tokens
                 design-tokens-css
                 token-value
                 token-name
                 token-declarations
                 density-value
                 ;; layout
                 stack
                 cluster
                 grid
                 split
                 center
                 spacer
                 aspect-ratio
                 ratio-label
                 ;; utility and composition
                 visually-hidden
                 skip-link
                 truncate-text
                 line-clamp
                 copy-button
                 show
                 hide
                 fade-in
                 slide-in
                 collapse
                 layer
                 layer-root
                 locale
                 bdi
                 bdo
                 density-toggle
                 ;; fields
                 field-wiring
                 field-id
                 field-help-id
                 field-error-id
                 field-described-by
                 field-control-attributes
                 form-field
                 text-field
                 search-field
                 password-field
                 number-field
                 stepper
                 slider
                 date-field
                 time-field
                 date-range-field
                 file-field
                 dropzone
                 combobox
                 multi-select
                 otp-field
                 input-group
                 validation-errors
                 validation-summary
                 ;; choices
                 rating
                 segmented-control
                 segmented-item
                 ;; buttons
                 icon-only-button
                 primary-button
                 secondary-button
                 ghost-button
                 danger-button
                 ;; feedback
                 circular-progress
                 toast
                 toast-tray
                 empty-state
                 error-state
                 skeleton-heading
                 skeleton-text
                 skeleton-avatar
                 skeleton-card
                 skeleton-table
                 skeleton-form
                 ;; navigation
                 sidebar
                 sidebar-link
                 nav-rail
                 wizard
                 ;; overlays
                 drawer
                 sheet
                 popover
                 hover-card
                 dropdown-item
                 dropdown-menu
                 command-item
                 command-palette
                 ;; data display
                 chip
                 avatar-group
                 timeline
                 timeline-item
                 tree-view
                 tree-item
                 ;; enhancement scripts
                 interactions-js
                 forms-js
                 overlays-js
                 toast-js
                 table-js
                 density-js)
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
        (design-tokens-css)
        (fly-out-css)
        (hygguile-extras-css)
        `(noscript ,@(no-js-css))
        (toggle-dark-theme-js)
        (copy-pre-inner-text-js)
        (show-notifications-from-url-js)
        (carousel-button-js)
        (remember-dark-theme-js)
        (color-show-js)
        (fly-out-js)
        (code-sample-js)
        (interactions-js)
        (forms-js)
        (overlays-js)
        (toast-js)
        (table-js)
        (density-js)
        (tray-js)))

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
