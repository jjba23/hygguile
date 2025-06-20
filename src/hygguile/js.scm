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
  #:export (toggle-dark-theme-js copy-pre-inner-text-js remember-dark-theme-js
                                 show-notifications-from-url-js
                                 trigger-notification-function-js))

(define (toggle-dark-theme-js)
  `((script
     "
function hygguileSaveDarkThemePreference(preference) {
  document.documentElement.setAttribute('data-theme', preference)
  localStorage.setItem('data-theme', preference)
}

function hygguileToggleDarkTheme() {
  const currentTheme = document.documentElement.getAttribute('data-theme')
  if (currentTheme == null) {
    //
    // by default set dark since hygguile has a light theme by default
    //
    hygguileSaveDarkThemePreference('dark')
  } else {
    if (currentTheme == 'dark') {
      hygguileSaveDarkThemePreference('light')
    } else {
      hygguileSaveDarkThemePreference('dark')
    }
  }
}
")))

(define (copy-pre-inner-text-js)
  `((script "
function hygguileCopyPreInnerText(elementId) {
  const id = elementId + '-pre'
  console.log('copying inner text of element: ' + id)

  var el = document.getElementById(id)

  navigator.clipboard.writeText(el.innerText)

  console.log(el.innerText)
}
")))

(define (remember-dark-theme-js)
  `((script "
document.addEventListener('DOMContentLoaded', () => {
  const themePreference = localStorage.getItem('data-theme')
  if (themePreference === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark')
  } else if (themePreference === 'light') {
    document.documentElement.setAttribute('data-theme', 'light')
  }
})
")))

(define* (trigger-notification-function-js #:key (title "")
                                           (body "")
                                           (duration 5000))
  (format #f "
(() => {
  const params = new URLSearchParams(window.location.search);
  params.set('notify-title', `~a`)
  params.set('notify-body', `~a`)
  params.set('notify-duration-millis', ~a)
  window.location.search = params;
})()
"
          title body duration))

(define* (show-notifications-from-url-js #:key (header-classes (mk-class '(text-xl
                                                                           text-stone-800
                                                                           dark:text-stone-200)))
                                         (close-icon-on-click
                                          "document.getElementById('notification-tray').innerHTML = ''")
                                         (close-icon-classes (mk-class '(ph
                                                                         ph-x
                                                                         text-stone-800
                                                                         cursor-pointer
                                                                         dark:text-stone-200
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
                                                                                sm:max-w-120
                                                                                rounded-xl
                                                                                bg-stone-200/90
                                                                                border-stone-500
                                                                                dark:bg-stone-900/90
                                                                                border-2
                                                                                dark:border-stone-800
                                                                                text-stone-700
                                                                                dark:text-stone-300
                                                                                font-sans
                                                                                py-6
                                                                                px-4))))
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
    const notification = `<div class=\"~a\">` +
      `<div class=\"~a\"><h4 class=\"~a\">${notificationTitle}</h4><i onclick=\"~a\" class=\"~a\"></i></div>` +
      `<p>${notificationBody}</p>` + `</div>`
    document.getElementById('notification-tray').innerHTML = notification
    setTimeout(() => { document.getElementById('notification-tray').innerHTML = '' }, notificationDurationMillis);
})
"
              notification-tray-container-classes
              title-container-classes
              header-classes
              close-icon-on-click
              close-icon-classes))))
