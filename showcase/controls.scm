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

;; Controls: buttons, the individual fields, forms and disclosure.

(define-module (showcase controls)
  #:use-module (hygguile hygguile)
  #:use-module (showcase specimens)
  #:export (button-section field-extras-section forms-section
                           validation-section disclosure-section))

(define button-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(p
           "Every variant is a native &lt;button&gt;: the fill and the shadow are utilities, the label and the focus ring come from the element itself."
           #:weight '(font-light))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(showcase-specimen "Variants"
                                  (list (cluster (list (primary-button
                                                        "Get started")
                                                       (secondary-button
                                                        "Browse components")
                                                       (ghost-button
                                                        "Read the docs")))))
              ,(showcase-specimen "Form buttons"
                                  (list (cluster (list (button "button")
                                                       (submit-button
                                                        "submit-button")
                                                       (danger-submit-button
                                                        "danger-submit-button")))))
              ,(showcase-specimen "Icon and label"
                                  (list (cluster (list (icon-button #:icon 'gear
                                                                    #:content
                                                                    "gear"
                                                                    #:background '
                                                                    (bg-jeans-blue-500)
                                                                    #:hover-background '
                                                                    (hover:bg-jeans-blue-900)
                                                                    #:color '(text-stone-300
                                                                              dark:text-stone-100)
                                                                    #:size '(text-md)
                                                                    #:icon-css '
                                                                    (text-stone-100
                                                                     dark:text-stone-100
                                                                     text-md))
                                                       (icon-button #:icon 'user
                                                                    #:content
                                                                    "user"
                                                                    #:background '
                                                                    (bg-naples-yellow-500)
                                                                    #:color '(text-onyx-500)
                                                                    #:hover-background '
                                                                    (hover:bg-naples-yellow-700)
                                                                    #:icon-css '
                                                                    (text-xl))))))
              ,(showcase-specimen "Tonally deep fills"
                                  (list (cluster (list (icon-button #:icon 'calendar
                                                        #:content "Book now"
                                                        #:weight '(font-light)
                                                        #:size '(text-md)
                                                        #:background '(bg-wine-500)
                                                        #:color '(text-papaya-whip-500)
                                                        #:hover-background '(hover:bg-wine-700)
                                                        #:icon-css '(text-xl))
                                                       ;; the fill is the dark end of the ramp so
                                                       ;; the near-white label keeps its contrast
                                                       ;; on the rose swatch
                                                       (icon-button #:icon 'airplane-tilt
                                                        #:content
                                                        "airplane-tilt"
                                                        #:background '(bg-china-rose-900)
                                                        #:weight '(font-medium)
                                                        #:color '(text-stone-300
                                                                  dark:text-stone-100)
                                                        #:icon-css '(text-stone-100
                                                                     dark:text-stone-100
                                                                     text-xl)
                                                        #:hover-background '(hover:bg-orange-900))))))))))

(define field-extras-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(p
           "A field is a native control with a bound label, helper copy and an error slot; the whole form below is server-rendered markup, not a widget."
           #:weight '(font-light))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(form-field #:label "Email"
                           #:name "showcase-email"
                           #:required #t
                           #:help-text "Wired by the form-field abstraction."
                           #:control showcase-email-control)
              ,(search-field #:name "showcase-q"
                             #:action "#")
              ,(password-field #:label "Password"
                               #:name "showcase-password"
                               #:autocomplete "current-password"
                               #:help-text
                               "The reveal control is a progressive enhancement, not the field.")
              ,(stepper #:label "Seats"
                        #:name "showcase-seats"
                        #:value 2
                        #:min 1
                        #:max 12)
              ,(combobox #:label "Colour"
                         #:name "showcase-colour"
                         #:placeholder "Start typing a colour"
                         #:options '("amber" "asparagus" "jeans-blue"))
              ,(multi-select #:label "Topics"
                             #:name "showcase-topics"
                             #:options '(("a" . "Accessibility") ("s" . "SSR"))
                             #:selected '("s"))
              ,(number-field #:label "Guests"
                             #:name "showcase-guests"
                             #:value 2
                             #:min 1
                             #:max 12
                             #:help-text
                             "A native number input with explicit bounds.")
              ,(input-group #:label "Price"
                            #:name "showcase-price"
                            #:type 'number
                            #:value 24
                            #:prefix "€"
                            #:suffix "/ month"
                            #:help-text
                            "The prefix and the suffix are written beside the value, not inside it.")
              ,(otp-field #:label "Verification code"
                          #:name "showcase-code"))
         ,(slider #:label "Warmth"
                  #:name "showcase-warmth"
                  #:value 21
                  #:min 16
                  #:max 26
                  #:unit " °C"
                  #:help-text "The number beside the field is the value, written out.")
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(rating #:label "How was your stay?"
                       #:name "showcase-score"
                       #:value 4)
              ,(rating #:label "Average score"
                       #:name "showcase-average"
                       #:value 4
                       #:readonly #t
                       #:help-text "A read-only rating is one image with one accessible name.")
              ,(segmented-control #:label "Range"
                                  #:name "showcase-range"
                                  #:options '((day . "Day")
                                              (week . "Week")
                                              (month . "Month"))
                                  #:selected "week")
              ,(segmented-control #:label "View"
                                  #:name "showcase-view"
                                  #:options '((list . "List") (grid . "Grid"))
                                  #:full-width? #t))
         ,(validation-summary #:errors '(("showcase-email" .
                                          "Enter an email address")))
         ,(date-range-field #:label "Stay"
                            #:name "showcase-stay"
                            #:start "2026-10-11"
                            #:end "2026-10-14")
         ,(dropzone #:label "Attachments"
                    #:name "showcase-files"
                    #:accept "image/*,.pdf"))))

(define forms-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-2 w-full))))
              ,(code-sample '(input #:label "Your name:"
                              #:name "full-name"
                              #:type 'name
                              #:autocomplete "name"
                              #:placeholder "Ada Lovelace"
                              #:help-text
                              "Browsers and password managers can fill this in."))
              ,(code-sample '(textarea #:label "some textarea:"
                                       #:name "textarea-1"
                                       #:autocomplete "off"))
              ,(code-sample '(select #:label "Language:"
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
              ,(code-sample '(checkbox #:label "I accept the terms"
                                       #:name "terms"
                                       #:required #t))
              ,(code-sample '(radio #:label "Small"
                                    #:name "size"
                                    #:value "s"
                                    #:checked #t))
              ,(code-sample '(switch #:label "Notifications"
                                     #:name "notify"
                                     #:checked #t))
              ,(code-sample '(range #:label "Volume"
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
    ,(code-sample '(form (list (fieldset (list (input #:label "Your email:"
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
                                                #:options (list (option
                                                                 #:value
                                                                 "cozy"
                                                                 #:content
                                                                 "Cozy (free)")
                                                                (option
                                                                 #:value
                                                                 "calm"
                                                                 #:content
                                                                 "Calm (€ 9 / month)")))
                                               (checkbox #:label
                                                "I agree to the terms"
                                                #:name "terms"
                                                #:required #t))
                                         #:legend
                                         "Subscribe to the newsletter"))
                         #:action "#"
                         #:method 'get
                         #:submit "Subscribe"))))

(define disclosure-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         ,(accordion #:items (list (accordion-item #:summary
                                                   "Native details element"
                                                   #:content (list (p
                                                                    "Built on the browser's own disclosure widget.")))
                                   (accordion-item #:summary "Zero JavaScript"
                                                   #:content (list (p
                                                                    "Accordions keep working with scripting disabled.")))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-6
                                          items-center))))
              ,(a "Open a CSS-only modal"
                  #:href "#showcase-modal")
              (div (@ (class ,(mk-class '(flex flex-row flex-wrap items-center
                                               gap-2))))
                   ,(p "Hover or focus for a tooltip:"
                       #:size '(text-md)
                       #:weight '(font-light))
                   ,(tooltip (code "guix shell")
                             #:text "Enter a reproducible development shell")))
         ,(modal #:id "showcase-modal"
                 #:title "CSS-only modal"
                 #:content (list (p
                                  "This dialog is revealed through the :target pseudo-class, so it opens and closes without any JavaScript. Follow the close link to dismiss it."))
                 #:footer (list (a "Close"
                                   #:href "#"))))))

;; ===== Validation =====
;;
;; The states a field can be in, and what a refused form says as a whole.
;; The form validates in the browser as well (`#:validate?'): the script
;; reads the browser's own verdict and writes it into the field's error
;; slot, so the sentence a page wrote is the sentence a reader reads, and
;; the browser's rules are the only copy of the rules there is.

(define validation-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
              ,(p
                "A field is in one of three states, and says which: nothing yet, wrong, or right. An error is announced and named (aria-errormessage as well as aria-describedby); a success is announced politely; and the control's own border follows the state, so a reader can find the one field that needs them without reading every line."
                #:weight '(font-light))
              ,(validation-summary
                #:errors '(("showcase-signup-email" . "Enter an email address.")
                           ("showcase-signup-seats" .
                            "Choose between 1 and 12 guests.")))
              ,(form (list (text-field #:label "Email"
                                       #:name "showcase-signup-email"
                                       #:type 'email
                                       #:required #t
                                       #:autocomplete "email"
                                       #:error "Enter an email address.")
                           (number-field #:label "Guests"
                                         #:name "showcase-signup-seats"
                                         #:value 14
                                         #:min 1
                                         #:max 12
                                         #:error "Choose between 1 and 12 guests.")
                           (text-field #:label "Name"
                                       #:name "showcase-signup-name"
                                       #:value "Ada Lovelace"
                                       #:valid "Looks good."))
                     #:action "#"
                     #:method 'get
                     #:validate? #t
                     #:submit "Sign up")
              ,(p
                "The form above checks itself in the browser too: #:validate? borrows the browser's verdict and writes it into the field's error slot, so the page's own sentence is the one a reader reads. Nothing about it needs a script to be safe -- with scripting off the browser still refuses the form, with its own bubble."
                #:weight '(font-light)
                #:size '(text-md)))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(text-field #:label "Untouched"
                           #:name "showcase-plain"
                           #:help-text "No state yet: a field is not wrong before it is filled in.")
              ,(text-field #:label "Wrong"
                           #:name "showcase-wrong"
                           #:value "not-an-email"
                           #:type 'email
                           #:error "Enter an email address.")
              ,(text-field #:label "Right"
                           #:name "showcase-right"
                           #:value "ada@example.org"
                           #:type 'email
                           #:valid "Looks good.")
              ,(segmented-control #:label "Range"
                                  #:name "showcase-range-bad"
                                  #:options '((day . "Day")
                                              (week . "Week")
                                              (month . "Month"))
                                  #:error "Pick a range.")))))
