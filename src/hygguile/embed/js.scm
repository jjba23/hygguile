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

(define-module (hygguile embed js)
  #:declarative? #t
  #:export (carousel-button-js copy-pre-inner-text-js color-show-js fly-out-js
                               remember-dark-theme-js toggle-dark-theme-js))

(define-public (carousel-button-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

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

(define-public (copy-pre-inner-text-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

function hygguileCopyPreInnerText(elementId) {
  const id = elementId + '-pre'
  console.log('copying inner text of element: ' + id)

  var el = document.getElementById(id)

  navigator.clipboard.writeText(el.innerText)

  console.log(el.innerText)
}
")))

(define-public (color-show-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

function cycleBgClass(currentClass) {
  const parts = currentClass.split('-')
  const currentNumber = parseInt(parts.toReversed()[0], 10)
  const nextNumber = currentNumber >= 900 ? 100 : currentNumber + 200
  const startParts = parts.slice(0, parts.length - 1).join(\"-\")

  return `${startParts}-${nextNumber}`
}

function cycleColorShow(el) {
  const currentClass = [...el.classList].find(cls => cls.startsWith('bg-'))
  const newClass = cycleBgClass(currentClass)
  el.classList.toggle(currentClass)
  el.classList.toggle(newClass)
  el.children[0].innerText = newClass.replace(\"bg-\", \"\")
}
")))

(define-public (fly-out-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

const closeMenu = (button, menu) => {
  button.setAttribute('aria-expanded', 'false')
  menu.hidden = true
}

const openMenu = (button, menu) => {
  button.setAttribute('aria-expanded', 'true')
  menu.hidden = false
}

const closeAllOpenMenus = () => {
  const menuContainers = document.querySelectorAll('.flyout-menu-container')
  menuContainers.forEach(menuContainer => {
    const menuButton = menuContainer.querySelector('.flyout-submenu-button')
    if (menuButton) {
      const isExpanded = menuButton.getAttribute('aria-expanded') === 'true'
      if (isExpanded) {
        menuButton.click()
      }
    }
  })
}

const HOVER_DELAY = 2000

document.addEventListener('DOMContentLoaded', () => {
  const menuContainers = document.querySelectorAll('.flyout-menu-container')

  menuContainers.forEach(menuContainer => {
    let hoverTimer
    menuContainer.addEventListener('mouseenter', () => {
      hoverTimer = setTimeout(() => {
        const menuButton = menuContainer.querySelector('.flyout-submenu-button')
        if (menuButton) {
          const isExpanded = menuButton.getAttribute('aria-expanded') === 'true'

          if (!isExpanded) {
            closeAllOpenMenus()
            menuButton.click()
          }
        }
      }, HOVER_DELAY)
    })

    menuContainer.addEventListener('mouseleave', () => {
      clearTimeout(hoverTimer)
    })
  })

  menuContainers.forEach(menuContainer => {
    const menuButton = menuContainer.querySelector('.flyout-submenu-button')
    const dropdownMenu = menuContainer.querySelector('.flyout-submenu')

    if (!menuButton || !dropdownMenu) {
      return
    }

    const menuItems = dropdownMenu.querySelectorAll('a[href], button:not([disabled])')
    const firstMenuItem = menuItems[0]
    const lastMenuItem = menuItems[menuItems.length - 1]

    menuButton.addEventListener('click', (event) => {
      event.preventDefault()
      const isExpanded = menuButton.getAttribute('aria-expanded') === 'true'
      if (isExpanded) {
        closeMenu(menuButton, dropdownMenu)
      } else {
        closeAllOpenMenus()
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

(define-public (remember-dark-theme-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

document.addEventListener('DOMContentLoaded', () => {
  const themePreference = localStorage.getItem('data-theme')
  if (themePreference === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark')
  } else if (themePreference === 'light') {
    document.documentElement.setAttribute('data-theme', 'light')
  }
})
")))

(define-public (toggle-dark-theme-js)
  '((script (@ (type "text/javascript")
               (defer ""))
     "/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

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
