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
                                                                                dark:bg-raisin-black-700/75
                                                                                border-2
                                                                                dark:border-stone-900
                                                                                text-onyx-300
                                                                                dark:text-stone-300
                                                                                font-sans
                                                                                py-6
                                                                                px-4
                                                                                flex
                                                                                flex-col
                                                                                gap-6))))
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

