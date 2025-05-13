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
  #:use-module (hygguile components select)
  #:use-module (hygguile components typography)
  #:re-export (mk-class render-if-nestring
                        render-if-nempty
                        button
                        icon-button
                        submit-button
                        danger-submit-button
                        ui-mode-button
                        toggle-dark-theme-js copy-pre-inner-text-js
                        remember-dark-theme-js
                        footer
                        with-footer
                        hr
                        icon
                        input
                        textarea
                        option
                        glyph-option
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
                        code))
