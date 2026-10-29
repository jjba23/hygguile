/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

/*
  The tray controls: the two things a page asks of a whole tray of cards at
  once, which order it is in and whether all of it is open. Both are declared
  in the markup by `sort-control' and `disclosure-controls', so the only
  JavaScript a page carries is the call each button already makes.

  Ordering is data, not code. A button reaches this file as

    hygguileSortTray(this, 'title')

  and the tray it orders is whichever container the button's group names in
  its `data-hg-sort-target'. The items are ordered by their `data-title'
  attribute --  numerically when both values are numbers, so data-order="10"
  follows data-order="9" instead of sorting in front of it, and
  alphabetically otherwise. The sort is stable, so items that compare equal
  keep the order they are already in. A mode that no item carries is the
  tray's own order: the items go back to the order the page wrote them in,
  which is what a "Page order" button is for and why it needs no attribute
  anywhere.
*/

(function () {
  /* The order each tray was written in, read once the document is parsed:
     by the time a button has been clicked it is too late to ask. */
  const written = new Map()

  const writtenOrder = (container) => written.get(container)
    || Array.prototype.slice.call(container.children)

  const asNumber = (text) => {
    const trimmed = text.trim()
    return trimmed !== '' && !isNaN(Number(trimmed)) ? Number(trimmed) : null
  }

  const compare = (mode) => (a, b) => {
    const left = a.getAttribute('data-' + mode) || ''
    const right = b.getAttribute('data-' + mode) || ''
    const leftNumber = asNumber(left)
    const rightNumber = asNumber(right)
    if (leftNumber !== null && rightNumber !== null) {
      return leftNumber - rightNumber
    }
    return left.localeCompare(right)
  }

  const groupOf = (button) => button.closest('[data-hg-sort-target]')

  /* One button of the group is the order in force; the stylesheet draws that
     as the pressed one, and a screen reader reads it out. */
  const mark = (button, group) => {
    Array.prototype.forEach.call(group.querySelectorAll('button'),
                                 (other) => {
                                   other.setAttribute('aria-pressed',
                                                      other === button
                                                        ? 'true' : 'false')
                                 })
  }

  window.hygguileSortTray = (button, mode) => {
    const group = groupOf(button)
    const container = group
      && document.getElementById(group.getAttribute('data-hg-sort-target'))
    if (!container) {
      return
    }
    const items = Array.prototype.slice.call(container.children)
    const carries = items.some((item) => item.hasAttribute('data-' + mode))
    const ordered = carries
      ? items.sort(compare(mode))
      : writtenOrder(container).slice()
    ordered.forEach((item) => container.appendChild(item))
    mark(button, group)
  }

  window.hygguileToggleTray = (open, selector) => {
    Array.prototype.forEach.call(document.querySelectorAll(selector),
                                 (details) => {
                                   details.open = open
                                 })
  }

  /* The tray is in the order the page wrote it in, and the first button of a
     group is the order it opens in, so a page states its own order by writing
     that mode first. */
  document.addEventListener('DOMContentLoaded', () => {
    Array.prototype.forEach.call(
      document.querySelectorAll('[data-hg-sort-target]'),
      (group) => {
        const container = document.getElementById(
          group.getAttribute('data-hg-sort-target'))
        if (container) {
          written.set(container, Array.prototype.slice.call(container.children))
        }
        const first = group.querySelector('button')
        if (first) {
          mark(first, group)
        }
      })
  })
})()
