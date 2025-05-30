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
  #:export (toggle-dark-theme-js copy-pre-inner-text-js remember-dark-theme-js))

(define toggle-dark-theme-js
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
")

(define copy-pre-inner-text-js
  "
function hygguileCopyPreInnerText(elementId) {
  const id = elementId + '-pre'
  console.log('copying inner text of element: ' + id)

  var el = document.getElementById(id)

  navigator.clipboard.writeText(el.innerText)

  console.log(el.innerText)
}
")

(define remember-dark-theme-js
  "
document.addEventListener('DOMContentLoaded', () => {
  const themePreference = localStorage.getItem('data-theme')
  if (themePreference === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark')
  } else if (themePreference === 'light') {
    document.documentElement.setAttribute('data-theme', 'light')
  }
})
")
