/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
*/

/*
  The small interactions every page otherwise re-implements: keeping focus
  inside an open overlay, moving through a roving tab group, marking the
  section a reader is in, copying a value, and announcing a resize.

  Everything here is progressive. A page that never loads this file still has
  working drawers, menus and copyable text (the copy button hides itself, and
  the value is shown as selectable text instead); this file only makes the
  experience better, never possible.
*/

(function () {
  const focusable = (root) => Array.from(root.querySelectorAll(
    'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
  )).filter((node) => node.offsetParent !== null || node === document.activeElement)

  let lastTrigger = null
  let trapWasOpen = false

  /* A `:target` overlay is shown by the URL, so the hash is the state.
     When one opens, move focus into it; while it is open, Tab cycles inside
     it and Escape closes it by clearing the hash. */
  const syncTrap = () => {
    const open = Array.from(document.querySelectorAll('[data-hg-focus-trap]'))
      .find((node) => node.id && ('#' + node.id) === window.location.hash)
    document.querySelectorAll('[data-hg-focus-trap]').forEach((node) => {
      if (node !== open) node.removeAttribute('data-hg-trap-active')
    })
    if (!open) {
      if (trapWasOpen && lastTrigger) lastTrigger.focus()
      trapWasOpen = false
      return
    }
    if (open.hasAttribute('data-hg-trap-active')) return
    open.setAttribute('data-hg-trap-active', '')
    trapWasOpen = true
    lastTrigger = document.activeElement
    const items = focusable(open)
    if (items.length) items[0].focus()
    open.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') {
        event.preventDefault()
        window.location.hash = '#'
        return
      }
      if (event.key !== 'Tab') return
      const now = focusable(open)
      if (!now.length) return
      const first = now[0]
      const last = now[now.length - 1]
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault()
        last.focus()
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault()
        first.focus()
      }
    }, { once: false })
  }

  window.addEventListener('hashchange', syncTrap)
  document.addEventListener('DOMContentLoaded', syncTrap)

  /* Roving tabindex: one tab stop for the group, arrow keys move inside it. */
  const roving = (group) => {
    const items = Array.from(group.querySelectorAll('[data-hg-roving-item]'))
    if (!items.length) return
    const selected = items.findIndex((item) => item.getAttribute('aria-selected') === 'true')
    const start = selected >= 0 ? selected : 0
    items.forEach((item, index) => { item.tabIndex = index === start ? 0 : -1 })
    group.addEventListener('keydown', (event) => {
      const keys = ['ArrowRight', 'ArrowDown', 'ArrowLeft', 'ArrowUp', 'Home', 'End']
      if (!keys.includes(event.key)) return
      event.preventDefault()
      const current = items.indexOf(document.activeElement)
      let next = current
      if (event.key === 'Home') next = 0
      else if (event.key === 'End') next = items.length - 1
      else if (event.key === 'ArrowRight' || event.key === 'ArrowDown') next = (current + 1) % items.length
      else if (event.key === 'ArrowLeft' || event.key === 'ArrowUp') next = (current - 1 + items.length) % items.length
      items.forEach((item, index) => { item.tabIndex = index === next ? 0 : -1 })
      items[next].focus()
    })
  }
  document.querySelectorAll('[data-hg-roving]').forEach(roving)

  /* Scroll spy: mark the section link a reader is currently inside. The
     section ids come from the rail's own links, so a page adds nothing. */
  const spy = (nav) => {
    const links = Array.from(nav.querySelectorAll('a[href^="#"]'))
    if (!links.length || !('IntersectionObserver' in window)) return
    const sections = links.map((link) => document.getElementById(link.getAttribute('href').slice(1))).filter(Boolean)
    if (!sections.length) return
    const mark = (id) => {
      links.forEach((link) => {
        if (link.getAttribute('href') === '#' + id) link.setAttribute('aria-current', 'true')
        else link.removeAttribute('aria-current')
      })
    }
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) mark(entry.target.id)
      })
    }, { rootMargin: '-20% 0px -70% 0px' })
    sections.forEach((section) => observer.observe(section))
  }
  document.querySelectorAll('[data-hg-scroll-spy]').forEach(spy)

  /* Copy buttons: the value is data, never parsed as markup, and the label
     says what happened for a moment before returning. */
  document.addEventListener('click', (event) => {
    const button = event.target.closest('[data-hg-copy]')
    if (!button) return
    const value = button.getAttribute('data-hg-copy') || ''
    const label = button.getAttribute('data-hg-copy-label') || 'Copy'
    const copied = button.getAttribute('data-hg-copied-label') || 'Copied'
    if (!navigator.clipboard) return
    navigator.clipboard.writeText(value).then(() => {
      button.setAttribute('aria-label', copied)
      const text = button.querySelector('span:not(.sr-only)')
      if (text) {
        const original = text.textContent
        text.textContent = copied
        setTimeout(() => { text.textContent = original }, 1600)
      }
      setTimeout(() => button.setAttribute('aria-label', label), 1600)
    })
  })

  /* A resize observer wrapper: the observer says when a component's box
     changed, the component decides what that means. */
  if ('ResizeObserver' in window) {
    const observer = new ResizeObserver((entries) => {
      entries.forEach((entry) => {
        entry.target.dispatchEvent(new CustomEvent('hg:resize', {
          bubbles: true,
          detail: { width: entry.contentRect.width, height: entry.contentRect.height }
        }))
      })
    })
    document.querySelectorAll('[data-hg-resize-observer]').forEach((node) => observer.observe(node))
  }
})()
