/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
*/

/* Data-grid enhancements: resizing a column with the pointer, and a
   select-all checkbox that knows about the rows it selects. Both are
   enhancements over a table that is already readable and already submits
   its selection. */

(function () {
  document.querySelectorAll('table[data-hg-resizable]').forEach((table) => {
    const cells = Array.from(table.querySelectorAll('thead th'))
    cells.forEach((cell) => {
      const handle = cell.querySelector('[data-hg-column-resizer]')
      if (!handle) return
      let startX = 0
      let startWidth = 0
      const width = () => cell.getBoundingClientRect().width
      const begin = (event) => {
        startX = event.clientX
        startWidth = width()
        table.style.tableLayout = 'fixed'
        handle.setPointerCapture && handle.setPointerCapture(event.pointerId)
      }
      const move = (event) => {
        if (!startX) return
        const next = Math.max(48, startWidth + (event.clientX - startX))
        cell.style.width = next + 'px'
      }
      const end = () => { startX = 0 }
      handle.addEventListener('pointerdown', begin)
      handle.addEventListener('pointermove', move)
      handle.addEventListener('pointerup', end)
      handle.addEventListener('pointercancel', end)
    })
  })

  document.querySelectorAll('[data-hg-select-all]').forEach((control) => {
    const table = control.closest('table')
    if (!table) return
    const boxes = () => Array.from(table.querySelectorAll('tbody input[type="checkbox"]'))
    const sync = () => {
      const all = boxes()
      const checked = all.filter((box) => box.checked).length
      control.checked = all.length > 0 && checked === all.length
      control.indeterminate = checked > 0 && checked < all.length
    }
    control.addEventListener('change', () => {
      boxes().forEach((box) => { box.checked = control.checked })
      sync()
    })
    boxes().forEach((box) => box.addEventListener('change', sync))
    sync()
  })
})()
