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

;; Application chrome: overlays, feedback, states and settings.

(define-module (showcase application)
  #:use-module (hygguile hygguile)
  #:use-module (showcase specimens)
  #:export (trigger-notifications-section feedback-section states-section
                                          overlays-section settings-section))

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

(define feedback-section
  `((div (@ (class ,(mk-class '(grid grid-cols-1 lg:grid-cols-2 gap-4
                                     items-start))))
         ,(showcase-specimen "Alerts"
                             (list (alert #:title "Information"
                                    #:body
                                    "Alerts carry a semantic color and an ARIA role."
                                    #:variant 'info)
                                   (alert #:title "Success"
                                          #:body "Your changes were saved."
                                          #:variant 'success)
                                   (alert #:title "Warning"
                                          #:body
                                          "This action is irreversible."
                                          #:variant 'warning)
                                   (alert #:title "Error"
                                    #:body
                                    "Something went wrong. Please retry."
                                    #:variant 'danger)))
         ,(showcase-specimen "Progress, skeleton and spinner"
                             (list (progress #:value 65
                                             #:label "Progress"
                                             #:show-value #t)
                                   (skeleton #:lines 2)
                                   (cluster (list (spinner #:size 'lg
                                                           #:label "Loading")
                                                  (p
                                                   "The spinner is a CSS ring and the bars are a quiet placeholder."
                                                   #:size '(text-sm)
                                                   #:weight '(font-light)))))))))

(define states-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         (h4 (@ (class ,(mk-class '(text-xs font-semibold uppercase
                                            tracking-wide text-onyx-300
                                            dark:text-stone-500))))
             "Empty, error and loading shapes")
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4))))
              ,(empty-state #:title "Nothing here yet"
                            #:body "An empty list is not an error."
                            #:action (secondary-button "Create one"))
              ,(error-state #:title "Could not load"
                            #:body "The request failed."
                            #:retry (a "Try again"
                                       #:href "#")))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap items-center
                                          gap-6))))
              ,(circular-progress #:value 68
                                  #:label "Importing"
                                  #:show-value #t)
              ,(circular-progress #:label "Working")
              ,(spinner #:size 'lg
                        #:label "Loading"))
         ,(skeleton-card #:lines 2
                         #:avatar? #t)
         ,(skeleton-table #:rows 2
                          #:columns 3)
         ,(toast #:title "A toast"
                 #:body "Rendered by the server, queued by the script."
                 #:variant 'success))))

(define overlays-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-4))))
         ,(p
           "Drawers and the command palette open from the URL; popovers and dropdowns use the browser's own overlay machinery. The menu here starts open so you can see it."
           #:weight '(font-light))
         (div (@ (class ,(mk-class '(grid grid-cols-1 md:grid-cols-2 gap-4))))
              ,(showcase-specimen "Triggers"
                                  (list (stack (list (cluster (list (a
                                                                     "Open a drawer"
                                                                     #:href
                                                                     "#showcase-drawer")
                                                                    (a
                                                                     "Open the command palette"
                                                                     #:href
                                                                     "#showcase-commands")))
                                                     (cluster (list (popover
                                                                     #:id
                                                                     "showcase-popover"
                                                                     #:trigger
                                                                     "A popover"
                                                                     #:title
                                                                     "Native popover"
                                                                     #:content
                                                                     (list `(p
                                                                             "Placed and dismissed by the browser.")))
                                                                    (hover-card
                                                                     #:trigger
                                                                     "Hover me"
                                                                     #:title
                                                                     "A hover card"
                                                                     #:content
                                                                     (list `(p
                                                                             "Richer than a tooltip."))))))
                                               #:gap '(gap-3))))
              ,(showcase-specimen "An open menu"
                                  (list (dropdown-menu #:label "Actions"
                                                       #:open? #t
                                                       #:items (list (dropdown-item
                                                                      "Rename"
                                                                      #:href
                                                                      "#")
                                                                     (dropdown-item
                                                                      "Duplicate"
                                                                      #:href
                                                                      "#")
                                                                     (dropdown-item
                                                                      "Delete"
                                                                      #:danger?
                                                                      #t))))
                                  #:classes '(pb-32)))
         ,(drawer #:id "showcase-drawer"
                  #:title "A drawer"
                  #:content (list `(p "Revealed by :target."))
                  #:footer (list (a "Close"
                                    #:href "#")))
         ,(command-palette #:id "showcase-commands"
                           #:commands (list (command-item "Home"
                                                          #:href "#"
                                                          #:hint "G H")
                                            (command-item "Buttons"
                                                          #:href "#buttons"
                                                          #:hint "G B"))))))

(define settings-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(max-w-prose flex flex-col gap-3))))
              ,(p
                "Two settings you can try right here: the theme, which is a class on the document remembered in local storage, and the notification tray, which is a plain list that slides in from the corner. Both are ordinary HTML and CSS with a little script on top, so nothing blocks the first paint."
                #:weight '(font-light)))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-3
                                          items-center))))
              (div ,(ui-mode-button)))
         ,trigger-notifications-section)))
