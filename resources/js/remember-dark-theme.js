/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

document.addEventListener('DOMContentLoaded', () => {
  const themePreference = localStorage.getItem('data-theme')
  if (themePreference === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark')
  } else if (themePreference === 'light') {
    document.documentElement.setAttribute('data-theme', 'light')
  }
})
