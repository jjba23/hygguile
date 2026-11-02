;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile css)
  #:export (custom-fonts font-faces phosphor-icons))

;; The families a hygguile page is set in: Work Sans for prose, Source Serif 4
;; for long-form reading and JuliaMono for code.  All three are libre (SIL Open
;; Font License 1.1) and are served from one base URL rather than from a font
;; service, so a page asks no third party for its typography.
(define default-font-base
  "https://jointhefreeworld.org/static-assets/fonts/")

;; One `@font-face' per family, style and subset.  Work Sans and Source Serif 4
;; are variable fonts, so a single file carries the whole weight axis; JuliaMono
;; ships static weights, hence two files split at 600.
(define font-face-specs
  '(("JuliaMono" normal "300 500" "juliamono-normal-latin.woff2")
    ("JuliaMono" normal "600 900" "juliamono-bold-latin.woff2")
    ("Work Sans" normal "100 900" "work-sans-normal-latin.woff2")
    ("Work Sans" italic "100 900" "work-sans-italic-latin.woff2")
    ("Source Serif 4" normal "200 900" "source-serif-4-normal-latin.woff2")
    ("Source Serif 4" italic "200 900" "source-serif-4-italic-latin.woff2")))

(define* (font-faces #:key (font-base default-font-base))
  "Render the @code{@@font-face} block for the three families hygguile sets its
pages in, with every file addressed relative to @var{font-base}.

@table @var
@item font-base
The URL the woff2 files are served from, ending in a slash.  Point it at your
own host to keep the files beside the rest of your assets.
@end table

@example
(font-faces #:font-base \"/fonts/\")
@end example"
  (string-join (map (lambda (spec)
                      (let ((family (list-ref spec 0))
                            (style (list-ref spec 1))
                            (weight (list-ref spec 2))
                            (file (list-ref spec 3)))
                        (format #f "@font-face {
  font-family: '~a';
  font-style: ~a;
  font-weight: ~a;
  font-display: swap;
  src: url('~a~a') format('woff2');
}
" family style weight font-base file)))
                    font-face-specs)
               "\n"))

(define* (custom-fonts #:key (font-base default-font-base))
  "Generate S-expression tags to load hygguile's own web typography: Work Sans
for prose, Source Serif 4 for serif text and JuliaMono for code, all three
self-hosted and declared from @var{font-base}.

Nothing is fetched from a font service, so a page built with this renders the
same offline and tells no third party who read it.

@table @var
@item font-base
The URL the woff2 files are served from, ending in a slash.
@end table

@example
(custom-fonts #:font-base \"https://example.com/fonts/\")
@end example"
  `((style (@ (type "text/css"))
           ,(font-faces #:font-base font-base))))

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
