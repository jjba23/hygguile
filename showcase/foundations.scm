;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Foundations: the type scale, the gradients and the palette.

(define-module (showcase foundations)
  #:use-module (hygguile hygguile)
  #:use-module (showcase specimens)
  #:export (typography-section gradients-section custom-colors-section))

(define typography-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(p
           "The scale is a handful of headings, a lighter subheading, body copy with its inline elements, and the two faces the framework sets code in."
           #:weight '(font-light))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(showcase-specimen "Headings"
                                  (list (showcase-type-row
                                         "h1 · text-4xl · bold"
                                         (h1 "Cozy by default"))
                                        (showcase-type-row "h2 · text-3xl"
                                                           (h2
                                                            "Settings and preferences"))
                                        (showcase-type-row "h3 · text-2xl"
                                                           (h3 "A card title"))
                                        (showcase-type-row "h4 · text-xl"
                                                           (h4
                                                            "A quieter heading"))))
              ,(showcase-specimen "Secondary and serif"
                                  (list (showcase-type-row
                                         "sub-h3 · italic · light"
                                         (sub-h3 "A lighter secondary heading"))
                                        (showcase-type-row "h2 · font-serif"
                                                           (h2 "Read slowly"
                                                               #:family '(font-serif)))
                                        (showcase-type-row "h3 · font-serif"
                                                           (h3
                                                            "An editorial note"
                                                            #:family '(font-serif)))
                                        (showcase-type-row "a · underline"
                                                           (p (list
                                                               "Read the "
                                                               (a
                                                                "API documentation"
                                                                #:href
                                                                "#typography")
                                                               " for the details."))))))
         ,(showcase-specimen "Body and inline elements"
                             (list (showcase-type-row "p · strong · em · mark"
                                    (p (list "Cozy copy with "
                                             (strong "importance")
                                             ", "
                                             (em "emphasis")
                                             " and "
                                             (mark "a highlight")
                                             ".")))
                                   (showcase-type-row
                                    "kbd · samp · var · abbr · sub · sup"
                                    (p (list "Press "
                                             (kbd "Ctrl")
                                             " then "
                                             (kbd "l")
                                             ", read "
                                             (samp "ok")
                                             ", export "
                                             (var "GC_ROOT")
                                             ", meet "
                                             (abbr "HTML"
                                              #:title
                                              "HyperText Markup Language")
                                             ", or write H"
                                             (sub "2")
                                             "O and E = mc"
                                             (sup "2")
                                             ".")))))
         ,(showcase-specimen "Quotations"
                             (list (showcase-type-row "blockquote · cite"
                                                      (blockquote
                                                       "Good design is as little design as possible."
                                                       #:source "Dieter Rams"))
                                   (showcase-type-row
                                    "a quotation that links its source"
                                    (blockquote
                                     "Simplicity is about subtracting the obvious and adding the meaningful."
                                     #:source "John Maeda"
                                     #:href
                                     "https://en.wikipedia.org/wiki/John_Maeda"))))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(showcase-specimen "Mono and code"
                                  (list (showcase-type-row "mono"
                                                           (mono
                                                            "$ guix shell -m manifest.scm"))
                                        (showcase-type-row "code"
                                                           (p (list "Call "
                                                               (code
                                                                "(render page)")
                                                               " from the request handler.")))))
              ,(showcase-specimen "Preformatted"
                                  (list (pre
                                         ";;; A simple Guile Scheme HTTP server
(use-modules (web server))

(define (my-handler request request-body)
  (values '((content-type . (text/plain)))
          \"Hello World!\"))

(run-server my-handler)")))))))

(define (gradients-section)
  (let* ((specimen-class (mk-class '(flex items-end
                                          min-h-32
                                          p-3
                                          rounded-2xl
                                          ;; a specimen draws its own edge
                                          ;; rather than wearing the panel's: a
                                          ;; two-pixel stone hairline over a
                                          ;; saturated gradient reads as a grey
                                          ;; band, so it is a one-pixel line of
                                          ;; the gradient's own light or dark
                                          ;; and a lighter shadow instead
                                          border
                                          border-onyx-900/10
                                          dark:border-stone-100/10
                                          shadow-md)))
         ;; the label is frosted, which is the whole point: a gradient
         ;; under glass is the look people mean by "macOS"
         (label-class (mk-class '(rounded-512 bg-stone-100/75
                                              dark:bg-onyx-900/75
                                              hg-frost
                                              shadow-md
                                              px-3
                                              py-1
                                              text-md
                                              font-bold
                                              text-onyx-500
                                              dark:text-stone-300)))
         (label (lambda (text)
                  (list `(span (@ (class ,label-class))
                               ,text)))))
    `((div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-2 py-4))))
           ,(p
             "A gradient is a container whose background image you describe with colour steps and a direction. Stops accept any CSS colour, oklch with an alpha channel included, so a gradient can stay inside the same palette as the rest of the interface."
             #:weight '(font-light)))
      (div (@ (class ,(mk-class '(grid grid-cols-1 sm:grid-cols-2
                                       md:grid-cols-3 gap-4 my-2))))
           ,(linear-gradient (label "hygge morning")
                             #:direction 'top
                             #:container-class specimen-class
                             #:steps '("oklch(1 0.0164 91.55 / 1)"
                                       "oklch(0.5777 0.4081 93.34 / 0.7)"))
           ,(linear-gradient (label "warm horizon")
                             #:direction 'right
                             #:container-class specimen-class
                             #:steps '("oklch(0.9622 0.0384 83.83 / 1)"
                                       "oklch(0.6183 0.1557 45.26 / 1)"))
           ,(linear-gradient (label "coastal dusk")
                             #:direction "bottom left"
                             #:container-class specimen-class
                             #:steps '("oklch(0.6609 0.0708 213.97 / 1)"
                                       "oklch(0.452 0.0712 256.28 / 1)"))
           ,(linear-gradient (label "linden light")
                             #:direction 'right
                             #:container-class specimen-class
                             #:steps '("oklch(0.9511 0.1449 97.97 / 1)"
                                       "oklch(0.7214 0.1697 119.64 / 1)"))
           ,(linear-gradient (label "tyrian velvet")
                             #:direction "bottom right"
                             #:container-class specimen-class
                             #:steps '("oklch(0.7404 0.1399 348.9 / 1)"
                                       "oklch(0.3409 0.1048 358.88 / 1)"
                                       "oklch(0.2588 0.0044 247.95 / 1)"))
           ,(linear-gradient (label "dusk in onyx")
                             #:direction "bottom left"
                             #:container-class specimen-class
                             #:steps '("oklch(0.3088 0.0044 247.95 / 1)"
                                       "oklch(0.4929 0.161 279.98 / 1) 60%"
                                       "oklch(0.6023 0.1041 7.06 / 1)"))
           ,(linear-gradient (label "mint frost")
                             #:direction 'right
                             #:container-class specimen-class
                             #:steps '("oklch(0.9606 0.0516 164.71 / 1)"
                                       "oklch(0.7606 0.1116 168.11 / 1)"))
           ,(linear-gradient (label "fjord morning")
                             #:direction "top left"
                             #:container-class specimen-class
                             #:steps '("oklch(0.9006 0.0608 240.19 / 1)"
                                       "oklch(0.6006 0.1108 245.19 / 1)"))
           ,(linear-gradient (label "northern lights")
                             #:direction "bottom right"
                             #:container-class specimen-class
                             #:steps '("oklch(0.3506 0.1008 160 / 1)"
                                       "oklch(0.7006 0.1508 190 / 1)"
                                       "oklch(0.5006 0.2008 300 / 1)")))
      (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
           ,(p
             "Pass a list of stops and a direction and you have a panel; the same call is the slide behind a headline, or a hairline of colour (this page marks every section with one) — the container classes decide which."
             #:weight '(font-light)))
      ,(code-sample '(linear-gradient (p "hygge morning"
                                         #:color '(text-onyx-500)
                                         #:weight '(font-bold))
                                      #:direction 'top
                                      #:container-class (mk-class '(flex
                                                                    items-end
                                                                    w-full
                                                                    min-w-64
                                                                    min-h-32
                                                                    p-3
                                                                    rounded-2xl))
                                      #:steps '("oklch(1 0.0164 91.55 / 1)"
                                                "oklch(0.5777 0.4081 93.34 / 0.7)"))))))

(define (custom-colors-section)
  (let* ((color-grid-class (mk-class '(flex flex-row
                                            flex-wrap
                                            gap-2
                                            items-center
                                            items-center
                                            py-4))))
    `((div (@ (class ,(mk-class '(py-4))))
           (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-2))))
                ,(p
                  "Hygguile offers colors in the 100, 300, 500, 700 and 900 variants. Some of these colors are essential for the hygguile components, however not all of them are."
                  #:weight '(font-light)))
           (div (@ (class ,color-grid-class))
                ,(map (lambda (x)
                        (color-swatch #:color x))
                      '(apple-green-500 ash-gray-500
                                        asparagus-500
                                        beaver-500
                                        bistre-500
                                        black-bean-500
                                        black-olive-500
                                        buff-500
                                        cadet-gray-500
                                        cambridge-green-500
                                        castleton-green-500
                                        charcoal-500
                                        china-rose-500
                                        china-violet-500
                                        claret-500
                                        coffee-500
                                        dark-purple-500
                                        ferrari-red-500
                                        floral-white-500
                                        glaucous-500
                                        iris-500
                                        jeans-blue-500
                                        lapis-lazuli-500
                                        light-coral-500
                                        mantis-500
                                        melon-500
                                        midnight-green-500
                                        mikado-yellow-500
                                        moonstone-500
                                        naples-yellow-500
                                        onyx-500
                                        orange-500
                                        pale-dogwood-500
                                        papaya-whip-500
                                        persia-pink-500
                                        pomp-and-power-500
                                        prussian-blue-500
                                        raisin-black-500
                                        redwood-500
                                        russia-violet-500
                                        sienna-500
                                        spiced-terracotta-500
                                        stone-500
                                        tawny-500
                                        tyrian-500
                                        umber-500
                                        van-dyke-500
                                        white-smoke-500
                                        wine-500
                                        olive-500
                                        dark-khaki-500)))))))
