/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
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
