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
  #:use-module (hygguile embed tailwind-js)
  #:use-module (hygguile embed css)
  #:use-module (hygguile embed tailwind-css)
  #:use-module (hygguile components button)
  #:use-module (hygguile components container)
  #:use-module (hygguile components icon)
  #:use-module (hygguile components input)
  #:use-module (hygguile components fly-out)
  #:use-module (hygguile components select)
  #:use-module (hygguile components notification)
  #:use-module (hygguile components typography)
  #:use-module (hygguile components carousel)
  #:use-module (hygguile css)
  #:re-export (a button
                 carousel
                 carousel-button-js
                 code
                 col
                 copy-pre-inner-text-js
                 custom-fonts
                 custom-tailwind-css
                 danger-submit-button
                 dd
                 dl
                 dt
                 em
                 fly-out
                 fly-out-css
                 fly-out-item
                 fly-out-js
                 fly-out-submenu
                 footer
                 get-short-commit-sha
                 glyph-option
                 h1
                 h2
                 h3
                 h4
                 hr
                 icon
                 icon-button
                 input
                 light-button
                 mk-class
                 mono
                 mono-button
                 notification-tray
                 option
                 p
                 phosphor-icons
                 pre
                 pretty-quote
                 remember-dark-theme-js
                 render-if-nempty
                 render-if-nestring
                 row
                 select
                 show-notifications-from-url-js
                 strong
                 sub-h1
                 sub-h2
                 sub-h3
                 sub-h4
                 submit-button
                 textarea
                 toggle-dark-theme-js
                 trigger-notification-function-js
                 ui-mode-button
                 with-footer)
  #:export (hygguile-recommended-resources))

(define hygguile-recommended-resources
  (list (tailwind-js)
        (custom-fonts)
        (phosphor-icons)
        (custom-tailwind-css)
        (fly-out-css)
        (toggle-dark-theme-js)
        (copy-pre-inner-text-js)
        (show-notifications-from-url-js)
        (carousel-button-js)
        (remember-dark-theme-js)
        (fly-out-js)))
