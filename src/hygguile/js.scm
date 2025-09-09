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
                                 carousel-button-js
                                 trigger-notification-function-js
                                 fly-out-js))

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

(define (carousel-button-js)
  `((script "
function handleCarouselClick(direction, id) {
  const list = document.getElementById(id)
  const item = document.querySelector('.carousel-list-item')
  const itemWidth = item.offsetWidth

  if (direction === 'previous') {
    list.scrollBy({ left: -itemWidth, behavior: 'smooth' })
  } else {
    list.scrollBy({ left: itemWidth, behavior: 'smooth' })
  }
}
")))

(define (fly-out-js)
  `((script "
document.addEventListener('DOMContentLoaded', () => {
  const menuContainers = document.querySelectorAll('.flyout-menu-container') 

  // Helper function to close a menu
  const closeMenu = (button, menu) => {
    button.setAttribute('aria-expanded', 'false')
    menu.hidden = true
  }

  // Helper function to open a menu
  const openMenu = (button, menu) => {
    button.setAttribute('aria-expanded', 'true')
    menu.hidden = false
  }

  menuContainers.forEach(container => {
    const menuButton = container.querySelector('.flyout-submenu-button')
    const dropdownMenu = container.querySelector('.flyout-submenu')

    // If a component is missing its button or menu, skip it.
    if (!menuButton || !dropdownMenu) {
      return
    }

    const menuItems = dropdownMenu.querySelectorAll('a[href], button:not([disabled])')
    const firstMenuItem = menuItems[0]
    const lastMenuItem = menuItems[menuItems.length - 1]

    // --- Event Listener for the Menu Button ---
    menuButton.addEventListener('click', (event) => {
      event.preventDefault()
      const isExpanded = menuButton.getAttribute('aria-expanded') === 'true'
      if (isExpanded) {
        closeMenu(menuButton, dropdownMenu)
      } else {
        openMenu(menuButton, dropdownMenu)
      }
    })

    menuButton.addEventListener('keydown', (event) => {
      if (event.key === 'ArrowDown') {
        event.preventDefault()
        openMenu(menuButton, dropdownMenu)
        if (firstMenuItem) {
          firstMenuItem.focus()
        }
      } else if (event.key === 'Escape') {
        closeMenu(menuButton, dropdownMenu)
        menuButton.focus()
      }
    })

    // --- Event Listener for the Dropdown Menu ---
    dropdownMenu.addEventListener('keydown', (event) => {
      const { key } = event
      const activeElement = document.activeElement

      if (key === 'Escape') {
        closeMenu(menuButton, dropdownMenu)
        menuButton.focus()
        return
      }

      if (key === 'ArrowUp') {
        event.preventDefault()
        if (activeElement === firstMenuItem) {
          lastMenuItem.focus()
        } else {
          const currentIndex = Array.from(menuItems).indexOf(activeElement)
          if (currentIndex > 0) {
            menuItems[currentIndex - 1].focus()
          }
        }
      } else if (key === 'ArrowDown') {
        event.preventDefault()
        if (activeElement === lastMenuItem) {
          firstMenuItem.focus()
        } else {
          const currentIndex = Array.from(menuItems).indexOf(activeElement)
          if (currentIndex < menuItems.length - 1) {
            menuItems[currentIndex + 1].focus()
          }
        }
      }
    })
  })
})


")))
