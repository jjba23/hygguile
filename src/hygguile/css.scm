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

(define-module (hygguile css)
  #:use-module (hygguile abstraction)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile embed css)
  #:use-module (hygguile embed tailwind-css)
  #:export (custom-fonts phosphor-icons))

(define* (custom-fonts #:key (preconnects `((link (@ (rel preconnect)
                                                     (href
                                                      "https://fonts.googleapis.com")))
                                            (link (@ (rel preconnect)
                                                     (href
                                                      "https://fonts.gstatic.com")
                                                     (crossorigin "")))))
                       (fonts `("IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700"
                                "IBM+Plex+Sans:ital,wght@0,100..700;1,100..700"
                                "IBM+Plex+Serif:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700"))
                       (display-swap "display=swap"))
  (let* ((font-string (string-join fonts "&family=")))
    `(,preconnects (link (@ (rel stylesheet)
                            (href ,(string-append
                                    "https://fonts.googleapis.com/css2?family="
                                    font-string "&" display-swap)))))))

(define* (phosphor-icons #:key (stylesheet-href
                                "https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.1/src/regular/style.css"))
  `((link (@ (rel stylesheet)
             (type text/css)
             (href ,stylesheet-href)))))
