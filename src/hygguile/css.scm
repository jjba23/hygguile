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
  #:export (custom-tailwind-theme custom-fonts phosphor-icons))

(define* (custom-tailwind-theme #:key (sans-font "IBM Plex Sans")
                                (mono-font "IBM Plex Mono")
                                (serif-font "IBM Plex Serif"))
  `((style (@ (type "text/tailwindcss"))
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

  --color-burntumber: #943524;
  --color-bistre: #261903;
  --color-papayawhip: #FFF1D6;
  --color-chinarose: #944C63;
  --color-earthyellow: #F7AE50;
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
                       (stylesheet-href
                        "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700&family=IBM+Plex+Sans:ital,wght@0,100..700;1,100..700&family=IBM+Plex+Serif:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700&display=swap"))
  `(,preconnects (link (@ (rel stylesheet)
                          (href ,stylesheet-href)))))

(define* (phosphor-icons #:key (stylesheet-href
                                "https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.1/src/regular/style.css"))
  `((link (@ (rel stylesheet)
             (type text/css)
             (href ,stylesheet-href)))))
