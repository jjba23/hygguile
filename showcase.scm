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
    ;; each specimen gets a soft, frosted card of its own, which makes the
    ;; grid of examples read like a tray of parts instead of loose markup
    `((div (@ (class ,(mk-class '(flex flex-col
                                       gap-4
                                       rounded-2xl
                                       border-2
                                       border-stone-500/25
                                       dark:border-onyx-100/25
                                       bg-stone-100/75
                                       dark:bg-onyx-900/50
                                       shadow-sm
                                       p-4))))
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
                        (class ,(mk-class '(text-onyx-500 dark:text-stone-300
                                                          text-md
                                                          bg-stone-300/75
                                                          dark:bg-onyx-700/75
                                                          rounded-lg
                                                          shadow-md
                                                          text-wrap
                                                          py-4
                                                          px-4
                                                          font-mono
                                                          leading-6
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
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 justify-center
                                     items-center))))
         ,(button "🔔 trigger simple notification"
                  #:on-click (trigger-notification-function-js #:title
                              "You are notified!"))
         ,(button "✨ trigger full notification"
                  #:on-click (trigger-notification-function-js #:title
                              "Notified succesfully!"
                              #:body
                              "The reason we notified you like this is to showcase the possibilities that hygguile offers for easy and convenient, good-looking notifications.")))))

(define button-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center items-center))))
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
                  ;; the fill is the dark end of the ramp so the near-white
                  ;; label keeps its contrast on the rose swatch
                  ,(as-example '(icon-button #:icon 'airplane-tilt
                                             #:content "airplane-tilt"
                                             #:background '(bg-china-rose-900)
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
                                          items-center items-center))))
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
                       ,(as-example '(p (list "Press "
                                              (kbd "Ctrl") " then "
                                              (kbd "l"))))
                       ,(as-example '(p (list "The daemon answers: "
                                              (samp
                                               "substitute: updating substitutes"))))
                       ,(as-example '(p (list "Export "
                                              (var "GC_ROOT")
                                              " before you collect")))
                       ,(as-example '(p (list "Paint to first byte improved "
                                              (mark "again this week"))))
                       ,(as-example '(p (list "Updated "
                                              (time "11 October 2026"
                                                    #:datetime "2026-10-11")
                                              ".")))
                       ,(as-example '(p (list "The "
                                         (abbr "HTML"
                                               #:title
                                               "HyperText Markup Language")
                                         " arrives finished, on the server")))
                       ,(as-example '(p (list "H"
                                              (sub "2") "O, and E = mc"
                                              (sup "2")))))
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
                                              items-center items-center))))
                  (span "☑️")
                  ,(sub-h2 "Forms"))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 w-full))))
                  ,(as-example '(input #:label "Your name:"
                                 #:name "full-name"
                                 #:type 'name
                                 #:autocomplete "name"
                                 #:placeholder "Ada Lovelace"
                                 #:help-text
                                 "Browsers and password managers can fill this in."))
                  ,(as-example '(textarea #:label "some textarea:"
                                          #:name "textarea-1"
                                          #:autocomplete "off"))
                  ,(as-example '(select #:label "Language:"
                                        #:name 'user-lang
                                        #:options (list (optgroup #:label
                                                                  "Americas"
                                                                  #:options (list
                                                                             (option
                                                                              #:value 'en_US
                                                                              #:content
                                                                              "English (US)"
                                                                              #:selected-value
                                                                              "en_US")))
                                                        (optgroup #:label
                                                                  "Europe"
                                                                  #:options (list
                                                                             (glyph-option
                                                                              #:value 'nl_NL
                                                                              #:glyph
                                                                              "🇳🇱"
                                                                              #:content
                                                                              "Nederlands"
                                                                              #:selected-value
                                                                              "en_US")
                                                                             (glyph-option
                                                                              #:value 'es_ES
                                                                              #:glyph
                                                                              "🇪🇸"
                                                                              #:content
                                                                              "Español"
                                                                              #:selected-value
                                                                              "en_US")))))))
             (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-2))))
                  ,(p
                    "A select states its own selection: exactly one option carries the selected attribute, written from the value the server rendered. The rows here are built with symbols and compared with strings, which used to lose the selection between the two; an option whose value the menu does not have falls back to the first row a reader can actually pick, and rows grouped under an optgroup are still rows -- the headings are the browser's own, and the group a reader cannot choose never holds the selection."
                    #:weight '(font-light)
                    #:size '(text-md)))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6
                                              items-center w-full))))
                  ,(as-example '(checkbox #:label "I accept the terms"
                                          #:name "terms"
                                          #:required #t))
                  ,(as-example '(radio #:label "Small"
                                       #:name "size"
                                       #:value "s"
                                       #:checked #t))
                  ,(as-example '(switch #:label "Notifications"
                                        #:name "notify"
                                        #:checked #t))
                  ,(as-example '(range #:label "Volume"
                                       #:name "volume"
                                       #:min 0
                                       #:max 11
                                       #:value 7))))
    (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-4))))
         ,(p
           "A form is the wrapper for the most common case of all: the browser serialises the fields and reloads the page with the answers. The labels, the native validation and the submit button are all markup, so the form still works with JavaScript disabled."
           #:weight '(font-light))
         ,(p
           "The example posts nothing: this showcase is a static page, so it uses a harmless GET. A real signup would post to your own endpoint."
           #:weight '(font-light)
           #:size '(text-md)))
    ,(as-example '(form (list (fieldset (list (input #:label "Your email:"
                                               #:name "email"
                                               #:type 'email
                                               #:autocomplete "email"
                                               #:required #t
                                               #:help-text
                                               "Used once, to confirm the subscription.")
                                              (select #:id "plan"
                                               #:label "Plan:"
                                               #:name 'plan
                                               #:help-text
                                               "You can change this later, at any time."
                                               #:options (list (option #:value
                                                                "cozy"
                                                                #:content
                                                                "Cozy (free)")
                                                               (option #:value
                                                                "calm"
                                                                #:content
                                                                "Calm (€ 9 / month)")))
                                              (checkbox #:label
                                               "I agree to the terms"
                                               #:name "terms"
                                               #:required #t))
                                        #:legend "Subscribe to the newsletter"))
                        #:action "#"
                        #:method 'get
                        #:submit "Subscribe"))))

(define media-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center))))
                  (span "🖼️")
                  ,(sub-h2 "Media"))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-8
                                              items-start))))
                  ,(figure (img #:src
                            "https://jointhefreeworld.org/static-assets/hygguile/hygguile-2-small.png"
                            #:alt "Hygguile logo"
                            #:width 220
                            #:height 130
                            #:rounding '(rounded-2xl))
                           #:caption "figure + img + figcaption"
                           #:align 'center)
                  ,(figure (picture #:sources (list (source #:type
                                                     "image/webp"
                                                     #:srcset
                                                     "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg"))
                                    #:image (img #:src
                                             "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg"
                                             #:alt "WikiMusic"
                                             #:width 220
                                             #:aspect-ratio 'square
                                             #:fit 'cover))
                           #:caption "picture with source + fallback img"
                           #:align 'center)
                  (div (@ (class ,(mk-class '(flex flex-col items-center gap-2))))
                       ,(avatar #:initials "HG"
                                #:size 'xl
                                #:ring #t)
                       ,(p "avatar with initials fallback"
                           #:size '(text-sm)
                           #:weight '(font-light))))
             ,(image-gallery (list (img #:src
                                    "https://jointhefreeworld.org/static-assets/byggsteg/logo-small.png"
                                    #:alt "Byggsteg"
                                    #:aspect-ratio 'square)
                                   (img #:src
                                    "https://jointhefreeworld.org/static-assets/lucidplan/img/logo-small.jpg"
                                    #:alt "LucidPlan"
                                    #:aspect-ratio 'square)
                                   (img #:src
                                    "https://jointhefreeworld.org/static-assets/sss/dall-e-3-thumb.png"
                                    #:alt "Static Site Starter"
                                    #:aspect-ratio 'square))
                             #:columns 3))))

(define cards-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center))))
                  (span "🗂️")
                  ,(sub-h2 "Cards, badges and stats"))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-8
                                              items-start))))
                  ,(card (list (card-header (list (card-title "Card title")
                                                  (badge "New"
                                                         #:variant 'success)))
                               (card-body (list (card-description
                                                 "Cards group related content with a header, a body and a footer.")
                                                (stat-card #:value "1,204"
                                                           #:label
                                                           "Active users"
                                                           #:trend "+12%")))
                               (card-footer (list (button "Action"
                                                          #:size '(text-sm)))))
                         #:card-classes '(bg-stone-300/75 dark:bg-onyx-700/75
                                          rounded-xl
                                          shadow-md
                                          border-2
                                          border-stone-500/50
                                          dark:border-onyx-100/50
                                          overflow-hidden
                                          my-4
                                          flex
                                          flex-col
                                          w-full
                                          max-w-100))
                  (div (@ (class ,(mk-class '(flex flex-col gap-3))))
                       (div (@ (class ,(mk-class '(flex flex-row flex-wrap
                                                        gap-2))))
                            ,(badge "neutral")
                            ,(badge "info"
                                    #:variant 'info)
                            ,(badge "success"
                                    #:variant 'success)
                            ,(badge "warning"
                                    #:variant 'warning)
                            ,(badge "danger"
                                    #:variant 'danger)))))))

(define feedback-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center))))
                  (span "📣")
                  ,(sub-h2 "Feedback"))
             (div (@ (class ,(mk-class '(flex flex-col gap-4 max-w-prose))))
                  ,(alert #:title "Information"
                          #:body
                          "Alerts carry a semantic color and an ARIA role."
                          #:variant 'info)
                  ,(alert #:title "Success"
                          #:body "Your changes were saved."
                          #:variant 'success)
                  ,(alert #:title "Warning"
                          #:body "This action is irreversible."
                          #:variant 'warning)
                  ,(alert #:title "Error"
                          #:body "Something went wrong. Please retry."
                          #:variant 'danger))
             (div (@ (class ,(mk-class '(flex flex-col gap-3 w-full
                                              max-w-prose))))
                  ,(progress #:value 65
                             #:label "Progress"
                             #:show-value #t)
                  ,(skeleton #:lines 2)
                  (div (@ (class ,(mk-class '(flex flex-row items-center gap-4))))
                       ,(spinner #:size 'lg
                                 #:label "Loading")
                       ,(p "spinner"
                           #:weight '(font-light)))))))

(define navigation-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center))))
                  (span "🧭")
                  ,(sub-h2 "Navigation"))
             ,(breadcrumbs #:items (list (a "Home"
                                            #:href "#")
                                         (a "Library"
                                            #:href "#")
                                         (em "Components")))
             ,(navbar (list (nav-link "Home"
                                      #:href "#"
                                      #:active #t)
                            (nav-link "Docs"
                                      #:href "#")
                            (nav-link "About"
                                      #:href "#"))
                      #:brand "Hygguile"
                      #:sticky #f)
             ,(tabs #:id "showcase-tabs"
                    #:tab-items (list (tab #:id "overview"
                                           #:label "Overview"
                                           #:content (list (p
                                                            "Tabs are pure CSS: no JavaScript required.")))
                                      (tab #:id "details"
                                           #:label "Details"
                                           #:content (list (p
                                                            "Selecting a label reveals the matching panel.")))))
             ,(pagination #:current 2
                          #:total 4
                          #:base-url "#page-"))))

(define disclosure-section
  `((section (@ (class ,(mk-class '(flex flex-col gap-6))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                              items-center))))
                  (span "🧩")
                  ,(sub-h2 "Disclosure"))
             ,(accordion #:items (list (accordion-item #:summary
                                        "Native details element"
                                        #:content (list (p
                                                         "Built on the browser's own disclosure widget.")))
                                       (accordion-item #:summary
                                                       "Zero JavaScript"
                                                       #:content (list (p
                                                                        "Accordions keep working with scripting disabled.")))))
             (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6
                                              items-center))))
                  ,(a "Open a CSS-only modal"
                      #:href "#showcase-modal")
                  (div (@ (class ,(mk-class '(flex flex-row flex-wrap
                                                   items-center gap-2))))
                       ,(p "Hover or focus for a tooltip:"
                           #:size '(text-sm)
                           #:weight '(font-light))
                       ,(tooltip (code "guix shell")
                                 #:text
                                 "Enter a reproducible development shell")))
             ,(modal #:id "showcase-modal"
                     #:title "CSS-only modal"
                     #:content (list (p
                                      "This dialog is revealed through the :target pseudo-class, so it opens and closes without any JavaScript. Follow the close link to dismiss it."))
                     #:footer (list (a "Close"
                                       #:href "#"))))))

(define footer
  (footer `(,(em "Copyright &copy; Josep Bigorra &lt;jjbigorra@gmail.com&gt;"
                 #:size '(text-sm)) ,(em
                                      "licensed under the LGPL v3, or newer at your convenience"
                                      #:size '(text-sm))
            (div (@ (class ,(mk-class '(flex flex-col
                                             gap-2
                                             sm:flex-row
                                             sm:flex-wrap
                                             sm:items-center
                                             sm:gap-6))))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "source:"
                           #:size '(text-sm))
                      ,(a "codeberg.org/jjba23/hygguile"
                          #:href "https://codeberg.org/jjba23/hygguile"
                          #:size '(text-sm)
                          #:weight '(font-medium)))
                 (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                                  items-center))))
                      ,(em "version:"
                           #:size '(text-sm))
                      ,(mono (format #f "~a"
                                     (get-short-commit-sha))
                             #:size '(text-sm)
                             #:weight '(font-light)))))))

(define settings-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          items-center))))
              (span "⚙️")
              ,(sub-h2 "Settings"))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
              ,(p
                "Two settings you can try right here: the theme, which is a class on the document remembered in local storage, and the notification tray, which is a plain list that slides in from the corner. Both are ordinary HTML and CSS with a little script on top, so nothing blocks the first paint."
                #:weight '(font-light)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              (div ,(ui-mode-button)))
         ,trigger-notifications-section)))

(define containers-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6 items-center))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          items-center items-center))))
              (span "📦")
              ,(sub-h2 "Containers"))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6
                                          items-center items-center))))

              ,(row `(,(p "first element") ,(p "second element")
                      ,(p "third element")))
              ,(col `(,(p "first element") ,(p "second element")
                      ,(p "third element"))))
         (sub-h3 "Glass panels")
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-4))))
              ,(p
                "A glass panel is a surface you can see through: a translucent tint over a backdrop blur, so what sits behind the panel is softened rather than hidden. Nothing in it is cut short by default -- a panel decides that with #:clip? -- and the ink of a line flush with the glass stays whole. The washes are the wallpaper trick -- a few oversized, blurred discs of colour thrown across the glass -- and they are optional, as is their drift."
                #:weight '(font-light)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6 items-start))))
              ,(glass-panel (list (h3 "Static washes")
                                  (p (list
                                      "The discs are there, but nothing moves. This is the panel without "
                                      (code "#:drift?")
                                      " -- the washes are simply still.")
                                     #:weight '(font-light)))
                            #:classes '(w-96 max-w-full)
                            #:washes (list (glass-wash '(bg-naples-yellow-500/75
                                                         w-72 h-72 left-8
                                                         top-4)
                                                       #:delay -4)
                                           (glass-wash '(bg-jeans-blue-500/50
                                                         w-64 h-64 right-8
                                                         bottom-4)
                                                       #:delay -12)))
              ,(glass-panel (list (h3 "Drifting washes")
                                  (p (list "The same panel with "
                                      (code "#:drift? #t")
                                      ", and a pace and a distance of its own: "
                                      (code "#:pace")
                                      " and "
                                      (code "#:distance")
                                      " are the page's to choose, so these discs cross their corner in a few rems while the hero's wander for half a minute.")
                                     #:weight '(font-light)))
                            #:classes '(w-96 max-w-full)
                            #:washes (list (glass-wash '(bg-china-rose-500/50
                                                         w-72 h-72 left-8
                                                         top-4)
                                                       #:delay -4
                                                       #:pace 11
                                                       #:distance '(2.5 -2))
                                           (glass-wash '(bg-asparagus-500/50
                                                         w-64 h-64 right-8
                                                         bottom-4)
                                                       #:delay -6
                                                       #:pace 18
                                                       #:distance '(1 -2.5)))
                            #:drift? #t))
         ,(as-example '(glass-panel (list (h3 "Frosted, not opaque")
                                          (p
                                           "Any content can live behind the glass."))
                                    #:washes (list (glass-wash '(bg-naples-yellow-500/75
                                                                 w-72 h-72
                                                                 left-8 top-4)
                                                               #:delay -4)
                                                   (glass-wash '(bg-jeans-blue-500/50
                                                                 w-64 h-64
                                                                 right-8
                                                                 bottom-4)
                                                               #:delay -12))
                                    #:drift? #t)))))

(define dl-section
  `((div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 items-center
                                     items-center))))
         (span "🗒️")
         ,(sub-h2 "Detail lists"))
    (div ,(dl (list (dt "foo:")
                    (dd "bar")
                    (dt "abcdefghij:")
                    (dd "1234567890")
                    (dt "some key:")
                    (dd "some value"))))))

(define tables-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          items-center))))
              (span "📊")
              ,(sub-h2 "Data tables"))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-4))))
              ,(p
                "Tabular data deserves real table markup: columns are declared with &lt;th&gt; and an explicit scope, the rows live in &lt;tbody&gt;, and the totals sit in &lt;tfoot&gt;, so the header that describes a cell is never guessed by a screen reader."
                #:weight '(font-light))
              ,(p
                "A wide table is also the classic way to break a phone layout. Every table therefore arrives wrapped in a region you can scroll sideways, named for assistive technology and reachable with the keyboard."
                #:weight '(font-light)))
         ,(table (list (thead (list (tr (list (th "Day"
                                                  #:scope 'col)
                                              (th "Coffees"
                                                  #:scope 'col
                                                  #:numeric #t)
                                              (th "Pastries"
                                                  #:scope 'col
                                                  #:numeric #t)
                                              (th "Takings"
                                                  #:scope 'col
                                                  #:numeric #t)))))
                       (tbody (list (tr (list (th "Monday"
                                                  #:scope 'row)
                                              (td "42"
                                                  #:numeric #t)
                                              (td "18"
                                                  #:numeric #t)
                                              (td "€ 248.50"
                                                  #:numeric #t)))
                                    (tr (list (th "Tuesday"
                                                  #:scope 'row)
                                              (td "51"
                                                  #:numeric #t)
                                              (td "22"
                                                  #:numeric #t)
                                              (td "€ 301.75"
                                                  #:numeric #t)))
                                    (tr (list (th "Wednesday"
                                                  #:scope 'row)
                                              (td "47"
                                                  #:numeric #t)
                                              (td "19"
                                                  #:numeric #t)
                                              (td "€ 274.20"
                                                  #:numeric #t)))
                                    (tr (list (th "Thursday"
                                                  #:scope 'row)
                                              (td "58"
                                                  #:numeric #t)
                                              (td "26"
                                                  #:numeric #t)
                                              (td "€ 349.90"
                                                  #:numeric #t)))
                                    (tr (list (th "Friday"
                                                  #:scope 'row)
                                              (td "73"
                                                  #:numeric #t)
                                              (td "31"
                                                  #:numeric #t)
                                              (td "€ 438.05"
                                                  #:numeric #t)))))
                       (tfoot (list (tr (list (th "Week"
                                                  #:scope 'row)
                                              (td "271"
                                                  #:numeric #t)
                                              (td "116"
                                                  #:numeric #t)
                                              (td "€ 1 612.40"
                                                  #:numeric #t))))))
                 #:caption "Café takings, week of 5 October 2026")
         ,(as-example '(table (list (thead (list (tr (list (th "Plan"
                                                               #:scope 'col)
                                                           (th "Price"
                                                               #:scope 'col
                                                               #:numeric #t)))))
                                    (tbody (list (tr (list (td "Cozy")
                                                           (td "9"
                                                               #:numeric #t)))
                                                 (tr (list (td "Calm")
                                                           (td "14"
                                                               #:numeric #t)))))
                                    (tfoot (list (tr (list (th "Total"
                                                               #:scope 'row)
                                                           (td "23"
                                                               #:numeric #t))))))
                              #:caption "Plans")))
    (sub-h3 "Sorting without JavaScript")
    ,(p
      "Sorting is not a rendering trick, it is a question a page asks the server: in which order? A sortable header cell is therefore an ordinary link that carries the order in the query string, and the cell announces the state it is in with aria-sort. Clicking a column is a plain navigation: it works with JavaScript disabled, a reload reproduces the order, and the URL can be shared or bookmarked."
      #:weight '(font-light))
    ,(p
      "Only a server can answer that link, and this showcase is a static page, so what you see below is the markup it produces: each header carries ?hygguile-table-sort= and ?hygguile-table-dir=, and the current column says which way it is going. The names are prefixed so that a sort or a dir parameter of the page's own is never read as the table's state. examples/sortable-table.scm runs the other half -- a server that reads the order back with parse-sort and re-renders the rows in it."
      #:weight '(font-light))
    ,(sortable-table #:columns (list (table-column #:key 'plan
                                                   #:label "Plan")
                                     (table-column #:key 'seats
                                                   #:label "Seats"
                                                   #:numeric #t)
                                     (table-column #:key 'revenue
                                                   #:label "Revenue"
                                                   #:numeric #t
                                                   #:default-direction 'desc))
                     #:rows (list (list "Cozy" "3" "€ 27")
                                  (list "Calm" "14" "€ 196")
                                  (list "Roomy" "9" "€ 81"))
                     #:sort 'seats
                     #:direction 'desc
                     #:params '(("region" . "europe") ("page" . "2"))
                     #:caption "Plans, sorted by seats")
    ,(as-example '(sortable-table #:columns (list (table-column #:key 'plan
                                                                #:label "Plan")
                                                  (table-column #:key 'seats
                                                                #:label
                                                                "Seats"
                                                                #:numeric #t))
                                  #:rows (list (list "Cozy" "3")
                                               (list "Calm" "14"))
                                  #:sort 'seats
                                  #:direction 'desc
                                  #:caption "Plans"))))

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
                           #:item-width '(w-48 sm:w-64)
                           #:fragments other-fragments)
                ,(carousel #:id 'showcase-carousel
                           #:item-width '(w-48 sm:w-64)
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
                                              text-sm
                                              font-bold
                                              text-onyx-500
                                              dark:text-stone-300)))
         (label (lambda (text)
                  (list `(span (@ (class ,label-class))
                               ,text)))))
    `(,(sub-h2 "🖌️ Gradients") (div (@ (class ,(mk-class '(max-w-prose flex
                                                           flex-col gap-2 py-4))))
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
      ,(as-example '(linear-gradient (p "hygge morning"
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

(define* (mk-color-show #:key color)
  ;; the swatch keeps the palette colour on the tile itself, while the label
  ;; sits on a frosted panel: a swatch can be any lightness, so a fixed
  ;; white or black ink would be illegible on half of them
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
         (span (@ (class ,(mk-class '(self-start rounded-2xs
                                                 bg-stone-100/75
                                                 dark:bg-onyx-900/75
                                                 hg-frost
                                                 hg-frost-pill
                                                 px-2
                                                 py-1
                                                 text-sm
                                                 font-medium
                                                 text-onyx-500
                                                 dark:text-stone-100))))
               ,(format #f "~a" color)))))

(define (custom-colors-section)
  (let* ((color-grid-class (mk-class '(flex flex-row
                                            flex-wrap
                                            gap-2
                                            items-center
                                            items-center
                                            py-4))))
    `(,(sub-h2 "🎨 Colors") (div (@ (class ,(mk-class '(py-4))))
                                (div (@ (class ,(mk-class '(max-w-prose flex
                                                            flex-col gap-2))))
                                     ,(p
                                       "Hygguile offers colors in the 100, 300, 500, 700 and 900 variants. Some of these colors are essential for the hygguile components, however not all of them are."
                                       #:weight '(font-light)))
                                (div (@ (class ,color-grid-class))
                                     ,(map (lambda (x)
                                             (mk-color-show #:color x))
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

;; ====== Showcase scaffolding ======

(define (anchored id content)
  "Wrap a showcase block in a @code{<section>} element carrying an @code{id}, so
the table of contents can link to it and assistive technology gets a real
landmark."
  `((section (@ (id ,id)
                (class ,(mk-class '(flex flex-col gap-2))))
             ,content)))

;; a thin sweep of the palette that separates two showcase sections; the
;; sections are already their own landmarks with their own headings, so the
;; rule is decoration: a soft warm-to-cool line instead of a flat one
(define gradient-rule
  (linear-gradient '()
                   #:container-class (mk-class '(h-1 w-full my-8 rounded-512
                                                     opacity-25))
                   #:direction 'right
                   #:steps '("oklch(0.7404 0.1399 91.55 / 1)"
                             "oklch(0.6609 0.0708 213.97 / 1)"
                             "oklch(0.4929 0.161 279.98 / 1)")))

;; the page reads as a tour: try the theme, watch the palette move through
;; the gradients and the carousel, wander through the components, and only
;; at the end sit down with the long argument for rendering on the server
(define toc-entries
  '(("settings" . "Settings") ("gradients" . "Gradients")
    ("carousel" . "Carousel")
    ("cards" . "Cards")
    ("colors" . "Colors")
    ("buttons" . "Buttons")
    ("typography" . "Typography")
    ("media" . "Media")
    ("forms" . "Forms")
    ("tables" . "Data tables")
    ("feedback" . "Feedback")
    ("navigation" . "Navigation")
    ("disclosure" . "Disclosure")
    ("fly-out" . "Fly-out")
    ("containers" . "Containers")
    ("detail-lists" . "Detail lists")
    ("why-ssr" . "Why server-side rendering?")))

(define (toc-link entry)
  (a (cdr entry)
     #:href (format #f "#~a"
                    (car entry))
     #:size '(text-sm)
     #:weight '(font-medium)
     #:extra-classes '(no-underline rounded-512
                                    px-3
                                    py-1
                                    bg-stone-100/50
                                    dark:bg-onyx-900/50
                                    border-2
                                    border-stone-500/25
                                    dark:border-onyx-100/25
                                    hover:bg-stone-100/90
                                    dark:hover:bg-onyx-900/75
                                    transition-colors
                                    duration-150)))

;; a frosted rail of pills that follows the page from the small
;; breakpoint up, so any section is one tap away
(define showcase-toc
  `((nav (@ (aria-label "Page sections")
            (class ,(mk-class '(my-2 rounded-2xl
                                     border-2
                                     border-stone-500/25
                                     dark:border-onyx-100/25
                                     bg-stone-100/75
                                     dark:bg-onyx-900/75
                                     hg-frost
                                     shadow-lg
                                     px-3
                                     py-3
                                     sm:sticky
                                     top-2
                                     z-20))))
         (ul (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 list-none
                                         p-0))))
             ,@(map (lambda (entry)
                      `(li ,(toc-link entry))) toc-entries)))))

(define ssr-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2
                                          items-center))))
              (span "🧭")
              ,(sub-h2 "Why server-side rendering?"))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-4))))
              ,(p
                "Hygguile renders complete HTML on the server. The browser receives a finished document — headings, links, labels and controls included — and a little JavaScript enhances it afterwards."
                #:weight '(font-light))
              ,(p
                "\"Old school\" server rendering is not nostalgia. For the kinds of software most of us ship — content, forms, dashboards, admin panels — rendering on the server keeps the fast path fast and the simple path simple."
                #:weight '(font-light)))
         ,(dl (list (dt "First paint without the framework tax")
                    (dd
                     "The HTML is ready to paint. There is no framework bundle to download, parse and execute before the first pixel, so pages feel immediate even on slow connections and modest hardware.")
                    (dt "No hydration, no double work")
                    (dd
                     "Nothing is re-rendered on the client just to attach behaviour. The server has already produced the final tree, so there is no hydration step that can disagree with the markup.")
                    (dt "It works when JavaScript does not")
                    (dd
                     "Links navigate and forms submit. Disclosure, tabs, the modal and tooltips keep working with scripting disabled; the theme toggle, carousel arrows and live notifications simply step in when they can.")
                    (dt "One source of truth")
                    (dd
                     "State lives in the database and in the URL, not in a second client-side store. There is no model to duplicate, no cache to invalidate, and no stale-UI bug class caused by the two drifting apart.")
                    (dt "Cacheable and cheap to serve")
                    (dd
                     "A page is a pure function of its request, which makes responses easy to cache, compress and proxy. Payloads stay small: mostly text, styled by one stylesheet the browser already holds.")
                    (dt "Accessible and discoverable by default")
                    (dd
                     "Real headings, landmarks, labels and form controls are present in the first byte, so assistive technology and crawlers never wait on a client-side rendering race.")
                    (dt "A smaller, calmer stack")
                    (dd
                     "No client router, no global store, no build step that has to agree with the server. The mental model is the one the web began with: request a URL, receive a document, follow a link.")))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
              ,(p
                "Single-page applications earn their complexity when you genuinely need offline support or a deeply interactive workspace. Even then it is a spectrum rather than a binary: ship mostly-static HTML and add interactivity only where it repays its cost. That is exactly how Hygguile is built — a document first, with small islands of behaviour."
                #:weight '(font-light))
              (pre (@ (class ,(mk-class '(text-onyx-500 dark:text-stone-300
                                                        text-md
                                                        bg-stone-300/75
                                                        dark:bg-onyx-700/75
                                                        rounded-lg
                                                        shadow-md
                                                        py-4
                                                        px-4
                                                        font-mono
                                                        leading-6
                                                        overflow-x-scroll
                                                        whitespace-pre-wrap))))
               ";; A page is a pure function of its data
(define (page request)
  `((h1 \"Posts\")
    (ul ,@(map render-post (posts-for request)))))

;; Render it once, on the server, and send text to the browser")))))

(define (showcase-body)
  (with-footer #:main `((div (@ (class ,(mk-class '(py-8 px-4 sm:px-6
                                                         max-w-256 mx-auto))))
                             ;; a glass hero: soft, out-of-focus colour washes
                             ;; behind frosted glass, the macOS wallpaper trick
                             ;; done with plain Olive utilities -- the same panel
                             ;; any page can have, shown again in the containers
                             ;; section below
                             ,(glass-panel
                               ;; a real list of nodes, not `(list ...)`: a
                               ;; literal head would render as a <list> element
                               `((div (@ (id "top")
                                         (class ,(mk-class '(flex flex-col
                                                                  gap-2))))
                                      ,(h1 "Hygguile"
                                           ;; the class list of `color` is
                                           ;; simply appended, so a gradient
                                           ;; treatment belongs here
                                           #:color '(hg-gradient-text))
                                      ,(sub-h3
                                        "cozy and professional user-interfaces for everyone"))
                                 (div (@ (class ,(mk-class '(flex flex-row
                                                                  flex-wrap
                                                                  gap-2))))
                                      ,(a "Source on Codeberg"
                                        #:href
                                        "https://codeberg.org/jjba23/hygguile"
                                        #:size '(text-sm)
                                        #:weight '(font-medium)
                                        #:extra-classes '(no-underline
                                                          rounded-lg
                                                          px-3
                                                          py-1
                                                          bg-stone-100/50
                                                          dark:bg-onyx-900/50
                                                          hg-frost
                                                          hg-frost-pill
                                                          border-2
                                                          border-stone-500/25
                                                          dark:border-onyx-100/25
                                                          hover:bg-stone-100/75
                                                          dark:hover:bg-onyx-900/75
                                                          transition-colors
                                                          duration-150))
                                      ,(a "API documentation"
                                        #:href
                                        "https://jointhefreeworld.org/api-docs/hygguile/API.html"
                                        #:size '(text-sm)
                                        #:weight '(font-medium)
                                        #:extra-classes '(no-underline
                                                          rounded-lg
                                                          px-3
                                                          py-1
                                                          bg-stone-100/50
                                                          dark:bg-onyx-900/50
                                                          hg-frost
                                                          hg-frost-pill
                                                          border-2
                                                          border-stone-500/25
                                                          dark:border-onyx-100/25
                                                          hover:bg-stone-100/75
                                                          dark:hover:bg-onyx-900/75
                                                          transition-colors
                                                          duration-150))
                                      ,(a "LGPL-3.0-or-later"
                                        #:href
                                        "https://www.gnu.org/licenses/lgpl-3.0.html"
                                        #:size '(text-sm)
                                        #:weight '(font-medium)
                                        #:extra-classes '(no-underline
                                                          rounded-lg
                                                          px-3
                                                          py-1
                                                          bg-stone-100/50
                                                          dark:bg-onyx-900/50
                                                          hg-frost
                                                          hg-frost-pill
                                                          border-2
                                                          border-stone-500/25
                                                          dark:border-onyx-100/25
                                                          hover:bg-stone-100/75
                                                          dark:hover:bg-onyx-900/75
                                                          transition-colors
                                                          duration-150)))
                                 (div (@ (class ,(mk-class '(max-w-prose flex
                                                             flex-col gap-5))))
                                      ,(p
                                        "Hygguile is an opinionated, batteries-included UI framework written in Guile Scheme. It gives you a small, expressive DSL for building cozy and professional interfaces from S-expressions, SXML and modern CSS."
                                        #:weight '(font-light))
                                      ,(p
                                        "It is built on Olive CSS: a utility-class framework whose syntax will feel familiar to anyone who has used Tailwind, but which is plain CSS rather than JavaScript."
                                        #:weight '(font-light))
                                      ,(p
                                        "Every component renders to real HTML on the server and is enhanced in the browser only where that helps. Pages stay fast, accessible, and fully usable without JavaScript."
                                        #:weight '(font-light))
                                      ,(noscript (alert #:title
                                                  "JavaScript is disabled"
                                                  #:body
                                                  "hygguile progressively enhances. Theme toggles and carousel arrows hide themselves, fly-out submenus open up, and tabs, accordions, modals, tooltips and every form control keep working without a single line of JavaScript."
                                                  #:variant 'info))))
                               ;; a generous gap between the rows, so the
                               ;; tagline is not crowded by the links that
                               ;; follow it
                               #:content-classes '(flex flex-col gap-10)
                               ;; the washes drift very slowly, and out of phase,
                               ;; so the glass has something to frost without
                               ;; ever stealing attention
                               #:washes (list (glass-wash '(bg-naples-yellow-500/75
                                                            w-96 h-96 left-4
                                                            top-4)
                                                          #:delay -6)
                                              (glass-wash '(bg-china-rose-500/50
                                                            w-72 h-72 right-4
                                                            top-4)
                                                          #:delay -14)
                                              (glass-wash '(bg-jeans-blue-500/50
                                                            w-96 h-96 right-24
                                                            bottom-4)
                                                          #:delay -22)
                                              (glass-wash '(bg-asparagus-500/50
                                                            w-72 h-72 left-4
                                                            bottom-4)
                                                          #:delay -9))
                               #:drift? #t
                               ;; a hairline of the title's own gradient along
                               ;; the top edge of the glass
                               #:accent (linear-gradient '()
                                                         #:container-class (mk-class '
                                                                            (absolute
                                                                             top-0
                                                                             left-0
                                                                             h-1
                                                                             w-full
                                                                             opacity-90))
                                                         #:direction 'right
                                                         #:steps '("oklch(0.7404 0.1399 91.55 / 1)"
                                                                   "oklch(0.6183 0.1557 45.26 / 1)"
                                                                   "oklch(0.4929 0.161 279.98 / 1)"
                                                                   "oklch(0.6609 0.0708 213.97 / 1)")))
                             ,showcase-toc
                             ,gradient-rule
                             ,(anchored "settings" settings-section)
                             ,gradient-rule
                             ,(anchored "gradients"
                                        (gradients-section))
                             ,gradient-rule
                             ,(anchored "carousel" carousel-section)
                             ,gradient-rule
                             ,(anchored "cards" cards-section)
                             ,gradient-rule
                             ,(anchored "colors"
                                        (custom-colors-section))
                             ,gradient-rule
                             ,(anchored "buttons" button-section)
                             ,gradient-rule
                             ,(anchored "typography" typography-section)
                             ,gradient-rule
                             ,(anchored "media" media-section)
                             ,gradient-rule
                             ,(anchored "forms" forms-section)
                             ,gradient-rule
                             ,(anchored "tables" tables-section)
                             ,gradient-rule
                             ,(anchored "feedback" feedback-section)
                             ,gradient-rule
                             ,(anchored "navigation" navigation-section)
                             ,gradient-rule
                             ,(anchored "disclosure" disclosure-section)
                             ,gradient-rule
                             ,(anchored "fly-out"
                                        (fly-out-section))
                             ,gradient-rule
                             ,(anchored "containers" containers-section)
                             ,gradient-rule
                             ,(anchored "detail-lists" dl-section)
                             ,gradient-rule
                             ,(anchored "why-ssr" ssr-section)))
               #:footer footer))

(define* (html-template #:key title body)
  `(,doctype-html (html (@ (lang en)
                           (class ,(mk-class '(scroll-smooth))))
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
