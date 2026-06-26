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

(define-module (hygguile js)
  #:use-module (hygguile abstraction)
  #:export (show-notifications-from-url-js trigger-notification-function-js))

(define* (trigger-notification-function-js #:key (title "")
                                           (body "")
                                           (duration 5000)
                                           (body-font-family "font-sans"))
  "Generate a JavaScript IIFE string that pushes notification parameters into the URL query string and reloads the window.

@table @var
@item title
The fallback string title of the notification.
@item body
The core informational content string of the notification.
@item duration
The visibility timeline limit in milliseconds before the notification is cleared.
@item body-font-family
The fallback typography class string applied to the notification's description field.
@end table

@example
(trigger-notification-function-js #:title \"Alert\" #:body \"System update complete.\")
@end example"
  (format #f
          "
(() => {
  const params = new URLSearchParams(window.location.search);
  params.set('notify-title', `~a`)
  params.set('notify-body', `~a`)
  params.set('notify-duration-millis', ~a)
  params.set('notify-body-font-family', `~a`)
  window.location.search = params;
})()
"
          title
          body
          duration
          body-font-family))

(define* (show-notifications-from-url-js #:key (header-classes (mk-class '(text-xl
                                                                           text-onyx-500
                                                                           dark:text-stone-300)))
                                         (close-icon-on-click
                                          "document.getElementById('notification-tray').innerHTML = ''")
                                         (close-icon-classes (mk-class '(ph
                                                                         ph-x
                                                                         text-onyx-500
                                                                         cursor-pointer
                                                                         dark:text-stone-300
                                                                         text-xl)))
                                         (title-container-classes (mk-class '(flex
                                                                              flex-row
                                                                              justify-between
                                                                              flex-wrap
                                                                              gap-10
                                                                              items-center)))
                                         (notification-tray-container-classes (mk-class '
                                                                               (max-w-full
                                                                                animate-wiggle
                                                                                max-w-prose
                                                                                rounded-xl
                                                                                bg-stone-300/90
                                                                                border-stone-500
                                                                                dark:bg-onyx-700/75
                                                                                border-2
                                                                                dark:border-onyx-100
                                                                                text-onyx-300
                                                                                dark:text-stone-300
                                                                                font-sans
                                                                                py-6
                                                                                px-4
                                                                                flex
                                                                                flex-col
                                                                                gap-6))))
  "Generate a client-side script block that handles rendering notifications from URL parameters.

This macro sets up a DOM listener evaluating parameters matching @code{notify-title} and @code{notify-body} from the window URL properties. When populated, it generates the corresponding component subtree inside the layout tray wrapper designated by the element identifier @code{notification-tray}.

@table @var
@item header-classes
A space-separated string containing CSS layout configuration targeting the card header text elements.
@item close-icon-on-click
The client-side callback script evaluated whenever a dismiss interaction triggers.
@item close-icon-classes
A space-separated string containing structural component icon identifiers and layout options.
@item title-container-classes
A space-separated string containing CSS layout parameters handling the alignment properties of the text boundaries.
@item notification-tray-container-classes
A space-separated string containing global structural box presentation layouts applied directly onto the notification layout wrapper block.
@end table

@example
(show-notifications-from-url-js #:header-classes \"text-lg font-bold\")
@end example"
  `((script ,(format #f
              "
document.addEventListener('DOMContentLoaded', () => {
    const params = new URLSearchParams(window.location.search);
    if(params.get('notify-body') == null && params.get('notify-title') == null){
        return
    }
    const notificationTitle = params.get('notify-title') ?? \"\"
    const notificationBody = params.get('notify-body') ?? \"\"
    const notificationDurationMillis = params.get('notify-duration-millis') ?? 3000
    const notificationBodyFontFamily = params.get('notify-body-font-family') ?? 'font-sans'
    const notification = `<div class=\"~a\">` +
      `<div class=\"~a\"><h4 class=\"~a\">${notificationTitle}</h4><i onclick=\"~a\" class=\"~a\"></i></div>` +
      `<p id=\"notification-body\">${notificationBody}</p>` + `</div>`
    document.getElementById('notification-tray').innerHTML = notification
    document.getElementById('notification-body').classList.toggle(notificationBodyFontFamily)

    setTimeout(() => { document.getElementById('notification-tray').innerHTML = '' }, notificationDurationMillis);
})
"
              notification-tray-container-classes
              title-container-classes
              header-classes
              close-icon-on-click
              close-icon-classes))))
