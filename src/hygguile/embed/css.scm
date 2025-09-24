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

(define-module (hygguile embed css)
  #:declarative? #t
  #:export (fly-out-css))

(define-public (fly-out-css)
  '((style (@ (type "text/css"))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/
                                     
/* Flyout menu / dropdown */
.flyout-submenu-button[aria-expanded=\"true\"]::after {
  content: \"↑\";
  padding-left: 0.8em;
}

.flyout-submenu-button[aria-expanded=\"false\"]::after {
  content: \"↓\";
  padding-left: 0.8em;
}

.flyout-submenu[hidden] {
  display: none;
}
")))
