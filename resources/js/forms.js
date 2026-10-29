/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

/* The form enhancements the framework ships: stepper buttons, the file drop
   zone, the password reveal, the slider's printed value, the character
   counter, and inline validation. Every one of them is optional. The native
   number input, the native file picker, the masked password field, the
   native range, the browser's own maxlength and the browser's own constraint
   validation are the controls; these only save a reader some clicking,
   dragging or guessing. */

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

/* Show or hide a password field's value.

   The field stays a real password input; this flips its `type' for as long
   as the reader wants to check what they typed, and the button says which
   state it is in rather than which one it would move to. */
function hygguileTogglePassword(button) {
  const field = button.parentElement && button.parentElement.querySelector('input')
  if (!field) return
  const revealed = field.type === 'text'
  field.type = revealed ? 'password' : 'text'
  button.setAttribute('aria-pressed', revealed ? 'false' : 'true')
  button.setAttribute('aria-label', revealed ? 'Show password' : 'Hide password')
  button.textContent = revealed ? 'Show' : 'Hide'
  field.focus()
}

/* Print a slider's value beside it. The <output> is bound to the field with
   `for', so this only has to keep its text in step. */
function hygguileSliderValue(input) {
  const group = input.closest('.hg-slider')
  const output = group && group.querySelector('output')
  if (!output) return
  // the unit, when the page gave one, is whatever the rendered value had
  // after the number
  const suffix = output.textContent.replace(/^-?[0-9.]+/, '')
  output.textContent = String(input.value) + suffix
}

function hygguileCountField(field) {
  const id = field.id
  if (!id) return
  const counter = document.querySelector(`[data-hg-counter-for="${id}"]`)
  if (!counter) return
  const used = counter.querySelector('[data-hg-counter-used]')
  const limit = Number(field.getAttribute('maxlength')) || 0
  const length = field.value.length
  if (used) used.textContent = String(length)
  counter.setAttribute('data-hg-counter-over', limit && length > limit ? 'true' : 'false')
}

/* ----- Inline validation ------------------------------------------------

   A form that asks for it with `data-hg-validate' gets the browser's own
   verdict written where the page writes everything else: in the field's
   error paragraph, linked to the control that failed, instead of in a
   bubble that vanishes on the next click.

   The rules stay the browser's. This reads `validity' and the
   `validationMessage' the browser composed for each control, so a pattern,
   a minimum, a required field and an input type keep working -- and a page
   never keeps a second, drifting copy of its own rules in a script.

   Nothing here is needed for validation to happen: with scripting off the
   browser checks the form and refuses to submit it, exactly as before. This
   only says which field, and why, in the place the page says everything
   else. */

/* A radio group is one field, so its message belongs to the group; the name
   is what the server names the group's error after too. */
const hygguileErrorBase = (field) => (field.type === 'radio' ? field.name : field.id)

function hygguileErrorSlot(field, create) {
  const base = hygguileErrorBase(field)
  if (!base) return null
  const id = `${base}-error`
  let slot = document.getElementById(id)
  if (slot || !create) return slot
  const shell = field.closest('.hg-field') || field.parentElement
  if (!shell) return null
  slot = document.createElement('p')
  slot.id = id
  slot.className = 'hg-error-message'
  slot.setAttribute('role', 'alert')
  shell.appendChild(slot)
  // the description is what carries the message to a reader who never sees
  // the paragraph, so the control has to point at it, and keep pointing
  const described = (field.getAttribute('aria-describedby') || '')
    .split(/\s+/)
    .filter(Boolean)
  if (!described.includes(id)) {
    field.setAttribute('aria-describedby', described.concat(id).join(' '))
  }
  return slot
}

function hygguileShowError(field, message) {
  const shell = field.closest('.hg-field')
  field.setAttribute('aria-invalid', 'true')
  const slot = hygguileErrorSlot(field, true)
  if (!slot) return
  slot.textContent = message
  slot.hidden = false
  field.setAttribute('aria-errormessage', slot.id)
  if (shell) {
    shell.classList.add('hg-field-invalid')
    shell.classList.remove('hg-field-valid')
  }
}

function hygguileClearError(field) {
  const slot = hygguileErrorSlot(field, false)
  field.removeAttribute('aria-invalid')
  field.removeAttribute('aria-errormessage')
  if (slot) {
    // the paragraph stays where it is, empty: the description still points
    // at it, and a message put back later must not take its own anchor away
    slot.textContent = ''
    slot.hidden = true
  }
  const shell = field.closest('.hg-field')
  if (shell) shell.classList.remove('hg-field-invalid')
}

function hygguileValidateField(field) {
  if (!field.willValidate || field.disabled) return true
  if (field.checkValidity()) {
    hygguileClearError(field)
    return true
  }
  hygguileShowError(field, field.validationMessage)
  return false
}

function hygguileValidateForm(form) {
  const fields = Array.from(form.elements).filter((field) => field.willValidate && !field.disabled)
  return fields.filter((field) => !hygguileValidateField(field))
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

  // every field that has a counter is counted once before the reader types,
  // so a textarea re-rendered with text in it does not claim to be empty
  document.querySelectorAll('.hg-counter').forEach((counter) => {
    const id = counter.getAttribute('data-hg-counter-for')
    const field = id && document.getElementById(id)
    if (field) hygguileCountField(field)
  })
  document.querySelectorAll('textarea[maxlength], input[maxlength]').forEach((field) => {
    field.addEventListener('input', () => hygguileCountField(field))
  })

  document.querySelectorAll('form[data-hg-validate]').forEach((form) => {
    // the page's own messages are the only ones worth showing; the rules and
    // the verdict are still the browser's
    form.setAttribute('novalidate', '')

    // submitting is the first moment the page may say what is wrong: up to
    // then the reader is still writing
    form.addEventListener('submit', (event) => {
      const invalid = hygguileValidateForm(form)
      if (!invalid.length) return
      event.preventDefault()
      invalid[0].focus()
    })

    // once a field has something to say, it says it as the reader fixes it
    // rather than waiting for the next submit
    form.addEventListener('input', (event) => {
      const field = event.target
      const slot = field.willValidate && hygguileErrorSlot(field, false)
      if (!slot || !slot.textContent) return
      hygguileValidateField(field)
    })

    // leaving a field is the other moment worth checking -- but only once
    // the reader has actually filled it in, so an untouched form never opens
    // with a wall of complaints
    form.addEventListener('focusout', (event) => {
      const field = event.target
      if (!field.willValidate || !field.value) return
      hygguileValidateField(field)
    })
  })

  // a form that came back refused may ask for its summary to take focus: it
  // is where a reader should start, since it says what went wrong before the
  // first field does. A page opts in, because moving focus on load is the
  // page's decision and not a component's
  document.querySelectorAll('[data-hg-focus-summary]').forEach((summary) => {
    if (document.activeElement === document.body) summary.focus()
  })
})
