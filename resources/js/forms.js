/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.
*/

/* The two form enhancements the framework ships: stepper buttons and the
   file drop zone. Both are optional: the native number input and the native
   file picker are the controls, and these only save a reader some clicking
   or dragging. */

function hygguileStep(button, delta) {
  const group = button.closest('.hg-stepper')
  const input = group && group.querySelector('input')
  if (!input) return
  const step = Number(input.getAttribute('step')) || 1
  const min = input.min === '' ? -Infinity : Number(input.min)
  const max = input.max === '' ? Infinity : Number(input.max)
  const current = input.value === '' ? 0 : Number(input.value)
  const next = Math.min(max, Math.max(min, current + delta * step))
  input.value = String(next)
  input.dispatchEvent(new Event('input', { bubbles: true }))
  input.dispatchEvent(new Event('change', { bubbles: true }))
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-hg-dropzone]').forEach((zone) => {
    const input = zone.parentElement && zone.parentElement.querySelector('[data-hg-file-input]')
    if (!input) return
    const list = zone.querySelector('[data-hg-file-list]')
    const show = () => {
      if (!list) return
      const names = Array.from(input.files || []).map((file) => file.name)
      list.textContent = names.length ? names.join(', ') : ''
    }
    input.addEventListener('change', show)
    ;['dragenter', 'dragover'].forEach((name) => {
      zone.addEventListener(name, (event) => {
        event.preventDefault()
        zone.classList.add('hg-dropzone-active')
      })
    })
    ;['dragleave', 'drop'].forEach((name) => {
      zone.addEventListener(name, (event) => {
        event.preventDefault()
        zone.classList.remove('hg-dropzone-active')
      })
    })
    zone.addEventListener('drop', (event) => {
      if (!event.dataTransfer || !event.dataTransfer.files.length) return
      const transfer = new DataTransfer()
      Array.from(event.dataTransfer.files).forEach((file) => transfer.items.add(file))
      input.files = transfer.files
      input.dispatchEvent(new Event('change', { bubbles: true }))
      show()
    })
  })
})
