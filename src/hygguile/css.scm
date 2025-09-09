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
  #:export (custom-tailwind-theme custom-fonts phosphor-icons))

(define* (custom-tailwind-theme #:key (sans-font "IBM Plex Sans")
                                (mono-font "IBM Plex Mono")
                                (serif-font "IBM Plex Serif"))
  `((style (@ (type "text/css"))
           "
/* Flyout menu / dropdown */
.flyout-submenu-button[aria-expanded=\"true\"]::after {
  content: \"▲\";
  padding-left: 0.8em;
}

.flyout-submenu-button[aria-expanded=\"false\"]::after {
  content: \"▼\";
  padding-left: 0.8em;
}

.flyout-submenu[hidden] {
  display: none;
}
")
    (style (@ (type "text/tailwindcss"))
           ,(format #f
             "
@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));

@theme {
  --font-sans: \"~a\", sans-serif;
  --font-mono: \"~a\", monospace;
  --font-serif: \"~a\", serif;
  --animate-wiggle: wiggle 750ms ease-in-out 50ms;

  @keyframes wiggle {
    0%,
    100% {
      transform: rotate(-3deg);
    }
    50% {
      transform: rotate(3deg);
    }
  }

  --color-spicedterracotta: #BB7546;
  --color-burntumber: #943524;
  --color-bistre: #261903;
  --color-oldlace: #FFF8EB;
  --color-floralwhite: #FDF9ED;
  --color-cornsilk: #FBF3DA;
  --color-papayawhip: #FFF1D6;
  --color-chinarose: #944C63;
  --color-earthyellow: #F7AE50;
  --color-cafenoir: #392605;
}
"
             sans-font mono-font serif-font))))

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
  (let* ((font-string (string-join fonts "&family=") ))
    `(,preconnects (link (@ (rel stylesheet)
                            (href ,(string-append
                                    "https://fonts.googleapis.com/css2?family="
                                    font-string "&" display-swap)))))))



(define* (phosphor-icons #:key (stylesheet-href
                                "https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.1/src/regular/style.css"))
  `((link (@ (rel stylesheet)
             (type text/css)
             (href ,stylesheet-href)))))
