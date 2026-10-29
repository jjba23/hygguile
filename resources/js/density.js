/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

/* The density preference: one class on the root, remembered across visits.
   The server can render a density of its own; this only keeps a reader's
   choice, and it runs before the first paint when it is loaded in the head
   or on DOMContentLoaded otherwise. */

(function () {
  const apply = (density) => {
    const root = document.documentElement
    root.setAttribute('data-density', density)
    root.classList.toggle('hg-density-compact', density === 'compact')
    document.querySelectorAll('[data-hg-density-toggle]').forEach((control) => {
      control.setAttribute('aria-pressed', density === 'compact' ? 'true' : 'false')
    })
  }

  const stored = localStorage.getItem('hg-density')
  if (stored === 'compact' || stored === 'comfortable') apply(stored)

  window.hygguileToggleDensity = () => {
    const current = document.documentElement.getAttribute('data-density') === 'compact'
      ? 'compact' : 'comfortable'
    const next = current === 'compact' ? 'comfortable' : 'compact'
    localStorage.setItem('hg-density', next)
    apply(next)
  }
})()
