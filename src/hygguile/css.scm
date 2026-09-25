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
  #:export (custom-fonts phosphor-icons))

(define* (custom-fonts #:key (preconnects `((link (@ (rel preconnect)
                                                     (href
                                                      "https://fonts.googleapis.com")))
                                            (link (@ (rel preconnect)
                                                     (href
                                                      "https://fonts.gstatic.com")
                                                     (crossorigin "")))))
                       (fonts `("Intel+One+Mono:ital,wght@0,300..700;1,300..700"
                                "Plus+Jakarta+Sans:ital,wght@0,200..800;1,200..800"))
                       ;; "IBM+Plex+Mono:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700"
                       ;; "IBM+Plex+Sans:ital,wght@0,100..700;1,100..700"
                       ;; "IBM+Plex+Serif:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;1,100;1,200;1,300;1,400;1,500;1,600;1,700"
                       )
  "Generate S-expression tags to optimize and load external web typography families asynchronously.

@table @var
@item preconnects
A list of S-expression initialization link tags specifying network domains to warm up.
@item fonts
A list of configuration strings selecting families and weights to include from the external repository API.
@item display-swap
A string directive identifying font rendering behaviors during file downloads.
@end table"
  (let* ((font-string (string-join fonts "&family=")))
    `(,preconnects (link (@ (rel preload)
                            (as style)
                            (onload "this.onload=null;this.rel='stylesheet'")
                            (href ,(string-append
                                    "https://fonts.googleapis.com/css2?family="
                                    font-string "&display=swap"))))
      (noscript (link (@ (rel stylesheet)
                         (href ,(string-append
                                 "https://fonts.googleapis.com/css2?family="
                                 font-string "&display=swap")))))
      (style
       "/* --- Lucida Sans --- */

@font-face {
  font-family: 'Lucida Sans';
  font-style: normal;
  font-weight: 400;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LSANS.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans';
  font-style: italic;
  font-weight: 400;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LSANSI.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans';
  font-style: normal;
  font-weight: 600;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LSANSD.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans';
  font-style: italic;
  font-weight: 600;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LSANSDI.woff') format('woff');
}


/* --- Lucida Sans Typewriter --- */

@font-face {
  font-family: 'Lucida Sans Typewriter';
  font-style: normal;
  font-weight: 400;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LTYPE.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans Typewriter';
  font-style: oblique;
  font-weight: 400;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LTYPEO.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans Typewriter';
  font-style: normal;
  font-weight: 700;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LTYPEB.woff') format('woff');
}

@font-face {
  font-family: 'Lucida Sans Typewriter';
  font-style: oblique;
  font-weight: 700;
  src: url('https://jointhefreeworld.org/static-assets/fonts/LTYPEBO.woff') format('woff');
}


/* --- Lucida Sans Unicode --- */

@font-face {
  font-family: 'Lucida Sans Unicode';
  font-style: normal;
  font-weight: 400;
  src: url('https://jointhefreeworld.org/static-assets/fonts/l_10646.woff') format('woff');
}
"))))

(define* (phosphor-icons #:key (stylesheet-href
                                "https://cdn.jsdelivr.net/npm/@phosphor-icons/web@2.1.1/src/regular/style.css"))
  "Generate S-expression link tags to pull down standard Phosphor icon asset libraries asynchronously.

Note: If the default value string containing an internal NPM handle is modified, any raw symbol characters must continue to obey parsing constraints.

@table @var
@item stylesheet-href
The source URL string pointing directly to the distributed stylesheet manifest location.
@end table

@example
(phosphor-icons #:stylesheet-href \"https://example.com/assets/icons.css\")
@end example"
  `((link (@ (rel preload)
             (as style)
             (onload "this.onload=null;this.rel='stylesheet'")
             (href ,stylesheet-href)))
    
    (noscript (link (@ (rel stylesheet)
                       (href ,stylesheet-href))))))
