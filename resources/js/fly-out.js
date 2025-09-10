// hygguile - cozy and professional user-interfaces for everyone

// Copyright © Josep Bigorra <jjbigorra@gmail.com>

// hygguile is free software: you can redistribute it and/or modify
// it under the terms of the Lesser GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// hygguile is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// Lesser GNU General Public License for more details.

// You should have received a copy of the Lesser GNU General Public License
// along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

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
