/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
*/

/* The keyboard models the overlay markup promises: filtering a command
   palette, arrow keys in a menu, Escape everywhere, and the one shortcut
   everyone tries (Ctrl/Cmd+K). The overlays themselves open and close
   without any of this. */

(function () {
  const paletteFilter = (palette) => {
    const input = palette.querySelector('[data-hg-command-input]')
    const items = Array.from(palette.querySelectorAll('[data-hg-command-item]'))
    const empty = palette.querySelector('[data-hg-command-empty]')
    if (!input || !items.length) return
    const apply = () => {
      const needle = input.value.trim().toLowerCase()
      let visible = 0
      items.forEach((item) => {
        const haystack = (item.textContent + ' ' + (item.getAttribute('data-hg-command-keywords') || '')).toLowerCase()
        const match = !needle || haystack.includes(needle)
        item.hidden = !match
        if (match) visible += 1
        item.setAttribute('aria-selected', 'false')
      })
      if (empty) empty.classList.toggle('hidden', visible > 0)
      const first = items.find((item) => !item.hidden)
      if (first) first.setAttribute('aria-selected', 'true')
    }
    input.addEventListener('input', apply)
    input.addEventListener('keydown', (event) => {
      const shown = items.filter((item) => !item.hidden)
      if (!shown.length) return
      const current = shown.findIndex((item) => item.getAttribute('aria-selected') === 'true')
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        event.preventDefault()
        const step = event.key === 'ArrowDown' ? 1 : -1
        const next = (current + step + shown.length) % shown.length
        shown.forEach((item, index) => item.setAttribute('aria-selected', index === next ? 'true' : 'false'))
        const link = shown[next].querySelector('a')
        if (link) link.focus({ preventScroll: true })
      } else if (event.key === 'Enter') {
        const selected = shown.find((item) => item.getAttribute('aria-selected') === 'true') || shown[0]
        const link = selected.querySelector('a')
        if (link) window.location.href = link.getAttribute('href')
      } else if (event.key === 'Escape') {
        window.location.hash = '#'
      }
    })
    apply()
  }

  document.querySelectorAll('[data-hg-command-palette]').forEach(paletteFilter)

  document.querySelectorAll('[data-hg-dropdown]').forEach((menu) => {
    const summary = menu.querySelector('summary')
    const items = () => Array.from(menu.querySelectorAll('[role="menuitem"]'))
    summary.addEventListener('keydown', (event) => {
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        event.preventDefault()
        menu.open = true
        const all = items()
        if (all.length) all[0].focus()
      }
    })
    menu.addEventListener('keydown', (event) => {
      const all = items()
      if (!all.length) return
      const current = all.indexOf(document.activeElement)
      if (event.key === 'Escape') {
        menu.open = false
        summary.focus()
      } else if (event.key === 'ArrowDown') {
        event.preventDefault()
        all[(current + 1 + all.length) % all.length].focus()
      } else if (event.key === 'ArrowUp') {
        event.preventDefault()
        all[(current - 1 + all.length) % all.length].focus()
      } else if (event.key === 'Home') {
        event.preventDefault()
        all[0].focus()
      } else if (event.key === 'End') {
        event.preventDefault()
        all[all.length - 1].focus()
      }
    })
  })

  document.addEventListener('keydown', (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
      const palette = document.querySelector('[data-hg-command-palette]')
      if (!palette) return
      event.preventDefault()
      window.location.hash = '#' + palette.id
      const input = palette.querySelector('[data-hg-command-input]')
      if (input) setTimeout(() => input.focus(), 0)
    }
  })
})()
