;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile js)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile sxml)
  #:use-module (hygguile components notification)
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
                                         (card-classes '()))
  "Generate a client-side script block that handles rendering notifications from URL parameters.

This macro sets up a DOM listener evaluating parameters matching @code{notify-title} and @code{notify-body} from the window URL properties. When populated, it puts a @code{notification-card} into the layout tray wrapper designated by the element identifier @code{notification-tray}, fills its title and body with @code{textContent}, and clears the tray again after the notification's duration.

@table @var
@item header-classes
A space-separated string containing CSS layout configuration targeting the card header text elements.
@item close-icon-on-click
The client-side callback script evaluated whenever a dismiss interaction triggers.
@item close-icon-classes
A space-separated string containing structural component icon identifiers and layout options.
@item title-container-classes
A space-separated string containing CSS layout parameters handling the alignment properties of the text boundaries.
@item card-classes
Extra classes for the notification's frosted card, appended to the panel's own.
@end table

@example
(show-notifications-from-url-js #:header-classes \"text-lg font-bold\")
@end example"
  (let ((card (call-with-output-string (lambda (port)
                                         (sxml->xml (notification-card
                                                     #:header-classes
                                                     header-classes
                                                     #:close-icon-on-click
                                                     close-icon-on-click
                                                     #:close-icon-classes
                                                     close-icon-classes
                                                     #:title-container-classes
                                                     title-container-classes
                                                     #:card-classes
                                                     card-classes) port)))))
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
    const notificationTray = document.getElementById('notification-tray')
    notificationTray.innerHTML = ~s
    const notificationTitleNode = document.getElementById('notification-title')
    const notificationBodyNode = document.getElementById('notification-body')
    if(notificationTitleNode){
        notificationTitleNode.textContent = notificationTitle
    }
    if(notificationBodyNode){
        notificationBodyNode.textContent = notificationBody
        notificationBodyNode.classList.toggle(notificationBodyFontFamily)
    }
    setTimeout(() => { notificationTray.innerHTML = '' }, notificationDurationMillis);
})
"
                card)))))
