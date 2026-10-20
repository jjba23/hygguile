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

;; Layout: the structural primitives, containers and cards.

(define-module (showcase layout)
  #:use-module (hygguile hygguile)
  #:use-module (showcase specimens)
  #:export (layout-extras-section utility-extras-section containers-section
                                  cards-section))

(define layout-extras-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(p
           "Structural primitives that keep spacing and responsive behaviour consistent."
           #:weight '(font-light))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(showcase-specimen "Stack"
                                  (list (stack (list (h3 "Account"
                                                         #:size '(text-lg))
                                                     (p "Signed in as Ada."
                                                        #:weight '(font-light))
                                                     (secondary-button
                                                      "Manage"))
                                               #:gap '(gap-2)
                                               #:align 'start)))
              ,(showcase-specimen "Cluster"
                                  (list (cluster (list (badge "one")
                                                       (badge "two"
                                                              #:variant 'info)
                                                       (badge "three"
                                                              #:variant 'success)))))
              ,(showcase-specimen "Center"
                                  (list (center (list (p
                                                       "A measured reading width, centred in its column."
                                                       #:weight '(font-light)))
                                                #:max-width '(max-w-128))))
              ,(showcase-specimen "Aspect ratio"
                                  (list (aspect-ratio (list `(div (@ (class ,(mk-class '
                                                                              (w-full
                                                                               h-full
                                                                               flex
                                                                               items-center
                                                                               justify-center
                                                                               bg-naples-yellow-500/25
                                                                               dark:bg-onyx-900/50))))
                                                                  ,(p "16 / 9"
                                                                    #:size '(text-md))))
                                                      #:ratio 'video)))
              ,(showcase-specimen "Grid"
                                  (list (grid (list (card (card-body (p
                                                                      "A cell"
                                                                      #:size '
                                                                      (text-md))))
                                                    (card (card-body (p
                                                                      "Another cell"
                                                                      #:size '
                                                                      (text-md)))))
                                              #:columns 2
                                              #:gap '(gap-2))))
              ,(showcase-specimen "Split"
                                  (list (split #:start (list (card (card-body (p
                                                                               "Start"
                                                                               #:size '
                                                                               (text-md)))))
                                               #:end (list (card (card-body (p
                                                                             "End, two thirds"
                                                                             #:size '
                                                                             (text-md)))))
                                               #:ratio '(1 2)
                                               #:gap '(gap-2))))))))

(define utility-extras-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-3))))
         (h4 (@ (class ,(mk-class '(text-md font-semibold uppercase
                                            tracking-wide text-onyx-300
                                            dark:text-stone-300))))
             "Utility & composition")
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4
                                          items-start))))
              ,(showcase-specimen "Clipboard"
                                  (list (copy-button #:text
                                         "(use-modules (hygguile hygguile))"
                                         #:show-text? #t)))
              ,(showcase-specimen "Density"
                                  (list (density-toggle #:current 'comfortable
                                                        #:classes '(w-fit
                                                                    self-start))))
              ,(showcase-specimen "Truncation"
                                  (list (truncate-text
                                         "The quick brown fox jumps over the lazy dog, and then keeps going for long enough that a card would grow a second and a third line if nothing stopped it."
                                         #:lines 2)))
              ,(showcase-specimen "Motion"
                                  (list (fade-in (list (alert #:title
                                                        "Fade in"
                                                        #:body
                                                        "Reads the motion tokens, so reduced-motion turns it off."
                                                        #:variant 'info)))))
              ,(showcase-specimen "RTL and language"
                                  (list (locale (list (p "مرحبا بالعالم"
                                                         #:weight '(font-light)))
                                                #:lang "ar"
                                                #:dir 'rtl)))
              ,(showcase-specimen "Responsive"
                                  (list (p
                                         "Resize the window: only one of these badges is shown."
                                         #:size '(text-md)
                                         #:weight '(font-light))
                                        (show (list (badge "Wide screens only"
                                                     #:variant 'info))
                                              #:from 'md)
                                        (hide (list (badge
                                                     "Narrow screens only"
                                                     #:variant 'warning))
                                              #:from 'md)))))))

(define containers-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6 items-center))))
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
         ,(code-sample '(glass-panel (list (h3 "Frosted, not opaque")
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

(define cards-section
  ;; a card is shown one under another rather than side by side: half a column
  ;; is not enough width for the card specimen itself to keep its own shape
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(showcase-specimen "Header, body and footer"
                             (list (card (list (card-header (list (card-title
                                                                   "Card title")
                                                                  (badge "New"
                                                                   #:variant 'success)))
                                               (card-body (list (card-description
                                                                 "Cards group related content with a header, a body and a footer.")
                                                                (stat-card
                                                                 #:value
                                                                 "1,204"
                                                                 #:label
                                                                 "Active users"
                                                                 #:trend
                                                                 "+12%")))
                                               (card-footer (list (button
                                                                   "Action"
                                                                   #:size '(text-md)))))
                                         #:card-classes '(bg-stone-300/75
                                                          dark:bg-onyx-700/75
                                                          rounded-xl
                                                          shadow-md
                                                          border-2
                                                          border-stone-500/50
                                                          dark:border-onyx-100/50
                                                          overflow-hidden
                                                          flex
                                                          flex-col
                                                          w-full))))
         ,(showcase-specimen "An expandable card"
                             (list (expandable-card (list (p
                                                           "The card this page is built out of: a native disclosure whose header is the control, so it opens and closes without a line of script."
                                                           #:weight '(font-light)))
                                                    #:title "Opens in place"
                                                    #:icon 'caret-double-down
                                                    #:tag "Layout"
                                                    #:open #t)))
         ,(showcase-specimen "Badges"
                             (list (p
                                    "A badge is a short label with a semantic tint; a card header is a natural home for one."
                                    #:size '(text-md)
                                    #:weight '(font-light))
                                   (cluster (list (badge "neutral")
                                                  (badge "info"
                                                         #:variant 'info)
                                                  (badge "success"
                                                         #:variant 'success)
                                                  (badge "warning"
                                                         #:variant 'warning)
                                                  (badge "danger"
                                                         #:variant 'danger))))))))
