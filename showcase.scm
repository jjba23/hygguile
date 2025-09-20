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
                                                          text-stone-700
                                                          dark:text-stone-200)))
                           (onclick ,(format #f
                                      "document.getElementById('~a-example').classList.toggle('hidden')"
                                      uid)))
                        ,(icon #:type 'dots-three
                               #:icon-css '(text-xl cursor-pointer))))
           (div (@ (id ,(format #f "~a-example" uid))
                   (class ,(mk-class '(hidden flex flex-col gap-2))))
                (pre (@ (id ,(format #f "~a-pre" uid))
                        (class ,(mk-class '(font-medium text-stone-800
                                                        dark:text-stone-200
                                                        text-md
                                                        bg-stone-200/75
                                                        dark:bg-stone-700/75
                                                        rounded-lg
                                                        shadow-md

                                                        text-wrap
                                                        py-4
                                                        px-4
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
                                             #:background '(bg-teal-700)
                                             #:color '(text-stone-200
                                                       dark:text-stone-100)
                                             #:size '(text-xs)
                                             #:icon-css '(text-stone-100
                                                          dark:text-stone-100
                                                          text-md)
                                             #:hover-background '(hover:bg-teal-900)))
                  ,(as-example '(icon-button #:icon 'user
                                             #:content "user"
                                             #:background '(bg-earthyellow)
                                             #:color '(text-stone-900)
                                             #:hover-background '(hover:bg-amber-500)
                                             #:icon-css '(text-xl)))
                  ,(as-example '(icon-button #:icon 'calendar
                                             #:content "Book now"
                                             #:weight '(font-light)
                                             #:background '(bg-vinrouge)
                                             #:color '(text-papayawhip)
                                             #:hover-background '(hover:bg-cafenoir)
                                             #:icon-css '(text-xl)))
                  ,(as-example '(icon-button #:icon 'airplane-tilt
                                             #:content "airplane-tilt"
                                             #:background '(bg-chinarose)
                                             #:weight '(font-medium)
                                             #:color '(text-stone-200
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
              (section (@ (class ,(mk-class '(py-3 flex flex-col gap-3))))
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
              (section (@ (class ,(mk-class '(py-3 flex flex-col gap-3))))
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
              (section (@ (class ,(mk-class '(py-3 flex flex-col gap-3))))
                       ,(as-example '(sub-h1
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h2
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h3
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(sub-h4
                                      "Sphinx of black quartz, judge my vow")))

              (section (@ (class ,(mk-class '(py-3 flex flex-col gap-3))))
                       ,(as-example '(strong
                                      "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(p "Sphinx of black quartz, judge my vow"))
                       ,(as-example '(em
                                      "Sphinx of black quartz, judge my vow")))
              (section (@ (class ,(mk-class '(py-3 flex flex-col gap-3))))
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
                                          #:name "textarea-1"))))))

(define footer
  (footer `(,(em "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;") ,
            (em "licensed under the LGPL v3, or newer at your convenience")
            (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
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
              ,(sub-h2 "Settings"))
         (div ,(ui-mode-button)))))

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

(define trigger-notifications-section
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2))))
         ,(button "trigger simple notification"
                  #:on-click (trigger-notification-function-js #:title
                              "You are notified!"))
         ,(button "trigger full notification"
                  #:on-click (trigger-notification-function-js #:title
                              "Notified succesfully!"
                              #:body
                              "The reason we notified you like this is to showcase the possibilities that hygguile offers for easy and convenient, good-looking notifications.")))))

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
                                       `((figure (img (@ (class ,(mk-class '(max-w-32
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
                                                                              (text-stone-600
                                                                               dark:text-stone-400
                                                                               text-lg
                                                                               font-light))))
                                                                  ,(car l))))))))
         (render-other-content (lambda (c)
                                 `((div (@ (class ,(mk-class '(text-stone-600
                                                               dark:text-stone-300
                                                               text-2xl
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

(define* (mk-color-show #:key color text-class)
  `((div (@ (class ,(mk-class (append (list (string->symbol (format #f "bg-~a"
                                                                    color)))
                                      '(rounded-2xl shadow-md
                                                    p-4
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
    `(,(sub-h2 "🎨 Colors") (div (@ (class ,(mk-class '(py-3))))
                                ,(p
                                  "Hygguile offers colors out of the box, in all their variants.")
                                (div (@ (class ,color-grid-class))
                                     ,(mk-color-show #:color 'red-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'orange-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'amber-500
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'yellow-500
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'lime-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'green-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'emerald-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'teal-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'cyan-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'cyan-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'sky-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'blue-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'indigo-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'violet-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'purple-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'fuchsia-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'pink-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'rose-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'slate-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'gray-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'zinc-500
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'stone-500
                                                     #:text-class 'text-white))
                                ,(p
                                  "It also offers some custom colors (no variants)")
                                (div (@ (class ,color-grid-class))
                                     ,(mk-color-show #:color 'spicedterracotta
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'burntumber
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'bistre
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'cafenoir
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'oldlace
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'floralwhite
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'cornsilk
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'papayawhip
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'chinarose
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'earthyellow
                                                     #:text-class 'text-black)
                                     ,(mk-color-show #:color 'burgundy
                                                     #:text-class 'text-white)
                                     ,(mk-color-show #:color 'vinrouge
                                                     #:text-class 'text-white))))))

(define (showcase-body)
  (with-footer #:main `((div (@ (class ,(mk-class '(py-9 px-2 container
                                                         mx-auto))))
                             (div (@ (class ,(mk-class '(flex flex-col gap-4))))
                                  (a (@ (href "/"))
                                     ,(h1 "hygguile"))
                                  ,(sub-h2
                                    "cozy and professional user-interfaces for everyone"))
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
                             ,trigger-notifications-section))
               #:footer footer))

(define* (html-template #:key title body)
  `(,doctype-html (html (@ (lang en))
                        (head (title ,title)
                              ,hygguile-recommended-meta
                              ,hygguile-recommended-resources
                              (body (@ (class ,(mk-class '(bg-white
                                                           dark:bg-stone-800))))
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

