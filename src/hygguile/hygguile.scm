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
  #:re-export (mk-class render-if-nestring
                        render-if-nempty
                        custom-fonts
                        phosphor-icons
                        button
                        custom-tailwind-theme
                        icon-button
                        submit-button
                        danger-submit-button
                        pretty-quote
                        ui-mode-button
                        toggle-dark-theme-js
                        copy-pre-inner-text-js
                        carousel-button-js
                        get-short-commit-sha
                        light-button
                        mono-button
                        trigger-notification-function-js
                        notification-tray
                        show-notifications-from-url-js
                        remember-dark-theme-js
                        col
                        carousel
                        row
                        footer
                        with-footer
                        hr
                        icon
                        dl
                        dd
                        dt
                        input
                        textarea
                        option
                        glyph-option
                        select
                        h1
                        h2
                        h3
                        h4
                        sub-h1
                        sub-h2
                        sub-h3
                        sub-h4
                        p
                        em
                        a
                        strong
                        pre
                        mono
                        fly-out
                        fly-out-submenu
                        fly-out-item
                        fly-out-js
                        code))
