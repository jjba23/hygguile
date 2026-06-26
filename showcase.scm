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

(use-modules (ice-9 string-fun)
             (ice-9 textual-ports)
             (ice-9 format)
             (ice-9 match)
             (ice-9 regex)
             (srfi srfi-13)
             (hygguile hygguile)
             (hygguile sxml)
             (uuid generate))

;;
;; ====== Showcase section ======
;;

(define (as-example thunk)
  (let* ((tt (with-output-to-string (lambda ()
                                      (write thunk))))
         (t (pretty-quote tt))
         (uid (generate-string-uuid)))
    `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
           (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2))))
                (div ,(eval-string tt))
                (button (@ (aria-label "Show code for example")
                           (class ,(mk-class '(font-light text-sm
                                                          text-onyx-300
                                                          dark:text-stone-300)))
                           (onclick ,(format #f
                                      "document.getElementById('~a-example').classList.toggle('hidden')"
                                      uid)))
                        ,(icon #:type 'dots-three
                               #:icon-css '(text-xl cursor-pointer))))
           (div (@ (id ,(format #f "~a-example" uid))
                   (class ,(mk-class '(hidden flex flex-col gap-2))))
                (pre (@ (id ,(format #f "~a-pre" uid))
                        (class ,(mk-class '(font-medium text-onyx-500
                                                        dark:text-stone-300
                                                        text-md
                                                        bg-stone-300/75
                                                        dark:bg-onyx-700/75
                                                        rounded-lg
                                                        shadow-md
                                                        text-wrap
                                                        py-4
                                                        px-4
                                                        font-mono
                                                        overflow-x-scroll
                                                        whitespace-pre-wrap))))
                     ,t)
                (div (@ (class ,(mk-class '(w-min))))
                     ,(icon-button #:icon 'copy
                                   #:content "copy"

                                   #:on-click (format #f
                                               "hygguileCopyPreInnerText('~a'); ~a"
                                               uid
                                               (trigger-notification-function-js
                                                #:title "Copied to clipboard!"
                                                #:body t
                                                #:body-font-family "font-mono")))))))))

(define trigger-notifications-section
  `((div (@ (class ,(mk-class '(flex flex-row
                                     flex-wrap
                                     gap-2
                                     justify-center
                                     align-center
                                     max-w-96))))
         ,(button "trigger simple notification"
                  #:on-click (trigger-notification-function-js #:title
                              "You are notified!"))
         ,(button "trigger full notification"
                  #:on-click (trigger-notification-function-js #:title
                              "Notified succesfully!"
                              #:body
                              "The reason we notified you like this is to showcase the possibilities that hygguile offers for easy and convenient, good-looking notifications.")))))

(define button-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              align-center items-center))))
                  (span "🔳")
                  ,(sub-h2 "Buttons"))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6))))
                  ,(as-example '(button "button"))
                  ,(as-example '(submit-button "submit-button"))
                  ,(as-example '(danger-submit-button "danger-submit-button")))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6))))
                  ,(as-example '(icon-button #:icon 'gear
                                             #:content "gear"
                                             #:background '(bg-jeans-blue-500)
                                             #:hover-background '(hover:bg-jeans-blue-900)
                                             #:color '(text-stone-300
                                                       dark:text-stone-100)
                                             #:size '(text-md)
                                             #:icon-css '(text-stone-100
                                                          dark:text-stone-100
                                                          text-md)))
                  ,(as-example '(icon-button #:icon 'user
                                             #:content "user"
                                             #:background '(bg-naples-yellow-500)
                                             #:color '(text-onyx-500)
                                             #:hover-background '(hover:bg-naples-yellow-700)
                                             #:icon-css '(text-xl)))
                  ,(as-example '(icon-button #:icon 'calendar
                                             #:content "Book now"
                                             #:weight '(font-light)
                                             #:size '(text-md)
                                             #:background '(bg-wine-500)
                                             #:color '(text-papaya-whip-500)
                                             #:hover-background '(hover:bg-wine-700)
                                             #:icon-css '(text-xl)))
                  ,(as-example '(icon-button #:icon 'airplane-tilt
                                             #:content "airplane-tilt"
                                             #:background '(bg-china-rose-500)
                                             #:weight '(font-medium)
                                             #:color '(text-stone-300
                                                       dark:text-stone-100)
                                             #:icon-css '(text-stone-100
                                                          dark:text-stone-100
                                                          text-xl)
                                             #:hover-background '(hover:bg-orange-900)))))))

(define typography-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          items-center align-center))))
              ,(em "α"
                   #:size '(text-xl))
              ,(sub-h2 "Typography"))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-8))))
              (section (@ (class ,(mk-class '(py-4 flex flex-col gap-4))))
                       ,(as-example '(h1
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(h1
                                      "Sphinx of black quartz, judge my vow"
                                      #:weight '(font-light)))
                       ,(as-example '(h2
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(h3
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(h4
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(mk-class '(py-4 flex flex-col gap-4))))
                       ,(as-example '(h1
                                      "Sphinx of black quartz, judge my vow"
                                      #:family '(font-serif)))
                       ,(as-example '(h1
                                      "Sphinx of black quartz, judge my vow"
                                      #:family '(font-serif)
                                      #:weight '(font-light)))
                       ,(as-example '(h2
                                      "Sphinx of black quartz, judge my vow"
                                      #:family '(font-serif)))
                       ,(as-example '(h3
                                      "Sphinx of black quartz, judge my vow"
                                      #:family '(font-serif)))
                       ,(as-example '(h4
                                      "Sphinx of black quartz, judge my vow"
                                      #:family '(font-serif))))
              (section (@ (class ,(mk-class '(py-4 flex flex-col gap-4))))
                       ,(as-example '(sub-h1
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h2
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h3
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h4
                                      "Sphinx of black quartz, judge my vow")))

              (section (@ (class ,(mk-class '(py-4 flex flex-col gap-4))))
                       ,(as-example '(strong
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(p "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(em
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(mk-class '(py-4 flex flex-col gap-4))))
                       ,(as-example '(mono
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(code
                                      "Sphinx of black quartz, judge my vow")))
              ,(as-example '(pre "
;;; A simple Guile Scheme HTTP server
(use-modules (web server))

(define (my-handler request request-body)
  (values '((content-type . (text/plain)))
          \"Hello World!\"))

(run-server my-handler)"))))))

(define forms-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              align-center items-center))))
                  (span "☑️")
                  ,(sub-h2 "Forms"))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 w-full))))
                  ,(as-example '(input #:label "some input:"
                                       #:name "input-1"
                                       #:placeholder "input"))
                  ,(as-example '(textarea #:label "some textarea:"
                                          #:name "textarea-1"))
                  ,(as-example '(select #:name 'user-lang
                                        #:options (list (option #:value 'en_US
                                                         #:content
                                                         "English (US)"
                                                         #:selected-value
                                                         "en_US")
                                                        (option #:value 'nl_NL
                                                                #:content
                                                                "Nederlands"
                                                                #:selected-value
                                                                "en_US")
                                                        (option #:value 'es_ES
                                                                #:content
                                                                "Español"
                                                                #:selected-value
                                                                "en_US"))))))))

(define footer
  (footer `(,(em "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;") ,
            (em "licensed under the LGPL v3, or newer at your convenience")
            (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-4
                                             align-center items-center))))
                 ,(em "find the source code here:")
                 ,(a "https://codeberg.org/jjba23/hygguile"))
            (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                             align-center items-center))))
                 ,(em "version:")
                 ,(mono (format #f "~a"
                                (get-short-commit-sha))
                        #:size '(text-sm)
                        #:weight '(font-light))))))

(define settings-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          align-center items-center))))
              (span "⚙️")
              ,(sub-h2 "Utilities"))
         (div (@ (class ,(mk-class '(flex flex-wrap gap-2 flex-row))))
              (div ,(ui-mode-button))
              (div ,trigger-notifications-section)))))

(define containers-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6 align-center))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          align-center items-center))))
              (span "📦")
              ,(sub-h2 "Containers"))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6
                                          align-center items-center))))

              ,(row `(,(p "first element") ,(p "second element")
                      ,(p "third element")))
              ,(col `(,(p "first element") ,(p "second element")
                      ,(p "third element")))))))

(define dl-section
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 align-center
                                     items-center))))
         (span "🗒️")
         ,(sub-h2 "Detail lists"))
    (div ,(dl (list (dt "foo:")
                    (dd "bar")
                    (dt "abcdefghij:")
                    (dd "1234567890")
                    (dt "some key:")
                    (dd "some value"))))))

(define carousel-section
  (let* ((imgs '(("Hygguile Logo" . "https://jointhefreeworld.org/static-assets/hygguile/hygguile-2-small.png")
                 ("WikiMusic Logo" . "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg")
                 "https://jointhefreeworld.org/static-assets/byggsteg/logo-small.png"
                 "https://jointhefreeworld.org/static-assets/lucidplan/img/logo-small.jpg"
                 "https://jointhefreeworld.org/static-assets/sss/dall-e-3-thumb.png"
                 "https://jointhefreeworld.org/static-assets/guile-show-hub/guile-show-hub-small.png"))
         (other-content '("VENI VIDI VICI" "Alea iacta est"
                          "Carpe diem"
                          "COGITO ERGO SUM"
                          "IN VINO VERITAS"
                          "ACTA NON VERBA"
                          "DEUS EX MACHINA"))
         (render-img-with-figcaption (lambda (l)
                                       `((figure (img (@ (class ,(mk-class '(max-w-64
                                                                             rounded-xl)))
                                                         (alt ,(cond
                                                                 ((pair? l)
                                                                  (car l))
                                                                 (else
                                                                  "Carousel Image")))
                                                         (src ,(cond
                                                                 ((string? l)
                                                                  l)
                                                                 ((pair? l)
                                                                  (cdr l))))))

                                                 ,(cond
                                                    ((string? l)
                                                     '())
                                                    ((pair? l)
                                                     `(figcaption (@ (class ,(mk-class '
                                                                              (text-onyx-300
                                                                               dark:text-stone-500
                                                                               text-lg
                                                                               font-light))))
                                                                  ,(car l))))))))
         (render-other-content (lambda (c)
                                 `((div (@ (class ,(mk-class '(text-onyx-300
                                                               dark:text-stone-300
                                                               text-2xl
                                                               min-w-48
                                                               font-light))))
                                        ,c))))
         (fragments (map render-img-with-figcaption imgs))
         (other-fragments (map render-other-content other-content)))
    (list (sub-h2 "🎠 Carousels")
          `(div (@ (class ,(mk-class '(flex flex-col gap-6))))
                ,(carousel #:id 'other-carousel
                           #:fragments other-fragments)
                ,(carousel #:id 'showcase-carousel
                           #:fragments fragments)))))

(define some-fly-out-items
  (list (fly-out-item (list (h4 "First item"
                                #:weight '(font-light))))
        (fly-out-item (list (h4 "Third item"
                                #:weight '(font-light))))
        (fly-out-submenu #:button-content (list (h4 "IN VINO VERITAS"
                                                    #:weight '(font-light)))
                         #:items (list (fly-out-item (list (h4 "I"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "II"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "III"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "IV"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "V"
                                                               #:weight '(font-light))))))
        (fly-out-submenu #:button-content (list (h4 "λ Scheme"
                                                    #:weight '(font-light)))
                         #:items (list (fly-out-item (list (a "Guile"
                                                            #:href
                                                            "https://www.gnu.org/s/guile/"
                                                            #:weight '(font-light))))
                                       (fly-out-item (list (a "Chicken"
                                                            #:href
                                                            "https://call-cc.org/"
                                                            #:weight '(font-light))))))

        ))

(define (fly-out-section)
  (list (sub-h2 "🦋 Fly-out section")
        (fly-out #:items some-fly-out-items)))

(define (gradients-section)
  `(,(sub-h2 "🖌️ Gradients") (div (@ (class ,(mk-class '(py-4 flex flex-col
                                                              gap-4
                                                              max-w-prose))))
                                  ,(linear-gradient `(,(p
                                                        "simple vertical gradient"
                                                        #:color '(text-onyx-500)
                                                        #:weight '(font-bold)))
                                                    #:direction 'top
                                                    #:container-class (mk-class '
                                                                       (px-4
                                                                        py-8
                                                                        rounded-xl
                                                                        shadow-md))
                                                    #:steps '("oklch(1 0.0164 91.55 / 1)"
                                                              "oklch(0.5777 0.4081 93.34 / 0.7)"))
                                  ,(linear-gradient `(,(p
                                                        "simple horizontal gradient"
                                                        #:color '(text-onyx-500)
                                                        #:weight '(font-bold)))
                                                    #:container-class (mk-class '
                                                                       (px-4
                                                                        py-8
                                                                        rounded-xl
                                                                        shadow-md))
                                                    #:steps '("oklch(1 0.0164 41.55 / 1)"
                                                              "oklch(0.6777 0.2081 43.34 / 0.7) 90%")))))

(define* (mk-color-show #:key color text-class)
  `((div (@ (onclick "cycleColorShow(this)")
            (class ,(mk-class (append (list (string->symbol (format #f "bg-~a"
                                                                    color)))
                                      '(rounded-2xl shadow-md
                                                    p-4
                                                    cursor-pointer
                                                    w-32
                                                    h-32
                                                    flex
                                                    flex-col
                                                    justify-end)))))
         (span (@ (class ,(mk-class (append (list text-class)
                                            '(text-sm)))))
               ,(format #f "~a" color)))))

(define (custom-colors-section)
  (let* ((color-grid-class (mk-class '(flex flex-row
                                            flex-wrap
                                            gap-2
                                            items-center
                                            align-center
                                            py-4))))
    `(,(sub-h2 "🎨 Colors") (div (@ (class ,(mk-class '(py-4))))
                                (div (@ (class ,(mk-class '(max-w-prose flex
                                                            flex-col gap-2))))
                                     ,(p
                                       "Hygguile offers colors in the 100, 300, 500, 700 and 900 variants. Some of these colors are essential for the hygguile components, however not all of them are."
                                       #:weight '(font-light)))
                                (div (@ (class ,color-grid-class))
                                     ,(map (lambda (x)
                                             (mk-color-show #:color (car x)
                                                            #:text-class (cadr
                                                                          x)))
                                           '((apple-green-500 text-white)
                                             (ash-gray-500 text-black)
                                             (asparagus-500 text-white)
                                             (beaver-500 text-white)
                                             (bistre-500 text-white)
                                             (black-bean-500 text-white)
                                             (black-olive-500 text-white)
                                             (buff-500 text-black)
                                             (cadet-gray-500 text-black)
                                             (cambridge-green-500 text-white)
                                             (castleton-green-500 text-white)
                                             (charcoal-500 text-white)
                                             (china-rose-500 text-white)
                                             (china-violet-500 text-white)
                                             (claret-500 text-white)
                                             (coffee-500 text-white)
                                             (dark-purple-500 text-white)
                                             (ferrari-red-500 text-white)
                                             (floral-white-500 text-black)
                                             (glaucous-500 text-white)
                                             (iris-500 text-white)
                                             (jeans-blue-500 text-white)
                                             (lapis-lazuli-500 text-white)
                                             (light-coral-500 text-white)
                                             (mantis-500 text-white)
                                             (melon-500 text-black)
                                             (midnight-green-500 text-white)
                                             (mikado-yellow-500 text-black)
                                             (moonstone-500 text-black)
                                             (naples-yellow-500 text-black)
                                             (onyx-500 text-white)
                                             (orange-500 text-white)
                                             (pale-dogwood-500 text-white)
                                             (papaya-whip-500 text-black)
                                             (persia-pink-500 text-white)
                                             (pomp-and-power-500 text-white)
                                             (prussian-blue-500 text-white)
                                             (raisin-black-500 text-white)
                                             (redwood-500 text-white)
                                             (russia-violet-500 text-white)
                                             (sienna-500 text-white)
                                             (spiced-terracotta-500 text-white)
                                             (stone-500 text-black)
                                             (tawny-500 text-white)
                                             (tyrian-500 text-white)
                                             (umber-500 text-white)
                                             (van-dyke-500 text-white)
                                             (white-smoke-500 text-black)
                                             (wine-500 text-white)
                                             (olive-500 text-white)
                                             (dark-khaki-500 text-black))))))))

(define (showcase-body)
  (with-footer #:main `((div (@ (class ,(mk-class '(py-10 px-4 container
                                                          mx-auto))))
                             (div (@ (class ,(mk-class '(flex flex-col gap-4))))
                                  (a (@ (href "/")
                                        (class ,(mk-class '(no-underline
                                                            slide-from-right))))
                                     ,(h1 "Hygguile"))
                                  ,(sub-h3
                                    "cozy and professional user-interfaces for everyone")
                                  (div (@ (class ,(mk-class '(max-w-prose flex
                                                              flex-col gap-2))))
                                       ,(p
                                         "Hygguile is an opinionated, batteries-included UI framework written in a dialect of the Lisp programming language, Guile Scheme."
                                         #:weight '(font-light))
                                       ,(p
                                         "It uses OliveCSS, whose syntax is much inspired utility-class Tailwind CSS but functions 100% with vanilla CSS instead of JS."
                                         #:weight '(font-light))
                                       ,(p
                                         "It defines an expressive domain-specific language (DSL), and by leveraging the power of S-expressions, SXML and modern CSS."
                                         #:weight '(font-light))))
                             ,(hr)
                             ,settings-section
                             ,(hr)
                             ,button-section
                             ,(hr)
                             ,typography-section
                             ,(hr)
                             ,(custom-colors-section)
                             ,(hr)
                             ,carousel-section
                             ,(hr)
                             ,(fly-out-section)
                             ,(hr)
                             ,dl-section
                             ,(hr)
                             ,containers-section
                             ,(hr)
                             ,forms-section
                             ,(hr)
                             ,(gradients-section)))
               #:footer footer))

(define* (html-template #:key title body)
  `(,doctype-html (html (@ (lang en))
                        (head (title ,title)
                              ,(hygguile-recommended-meta)
                              ,(hygguile-recommended-resources)
                              (link (@ (rel stylesheet)
                                       (href "olive.min.css")))
                              (body (@ (class ,(mk-class '(bg-stone-100
                                                           dark:bg-onyx-900
                                                           font-sans))))
                                    ,notification-tray
                                    ,@body)))))

(define (showcase)
  (with-output-to-string (lambda ()
                           (sxml->xml (html-template #:title
                                                     "hygguile showcase"
                                                     #:body (showcase-body))))))

;; ====== Run ======

(with-output-to-file "dist/index.html"
  (lambda ()
    (display (showcase))))

(display
 "
>>= successfully built hygguile showcase to destination: dist/index.html
")
