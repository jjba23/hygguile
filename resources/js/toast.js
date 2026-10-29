/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

/* A queue for toasts, with the three things a queue needs: a maximum on
   screen, a duration per toast (paused while hovered or focused), and a
   dismissal that removes the node rather than merely hiding it. A toast's
   text is written with textContent, so a query string or an API response
   cannot become markup. */

(function () {
  const timers = new WeakMap()

  const remove = (toast) => {
    if (!toast) return
    const timer = timers.get(toast)
    if (timer) clearTimeout(timer)
    toast.classList.add('hg-toast-leaving')
    setTimeout(() => toast.remove(), 220)
  }

  window.hygguileDismissToast = (button) => {
    remove(button && button.closest('[data-hg-toast]'))
  }

  const schedule = (toast, duration) => {
    if (!duration || duration <= 0) return
    const timer = setTimeout(() => remove(toast), duration)
    timers.set(toast, timer)
    ;['mouseenter', 'focusin'].forEach((name) => toast.addEventListener(name, () => {
      clearTimeout(timers.get(toast))
    }))
    ;['mouseleave', 'focusout'].forEach((name) => toast.addEventListener(name, () => {
      const next = setTimeout(() => remove(toast), duration)
      timers.set(toast, next)
    }))
  }

  window.hygguileToast = (options) => {
    const settings = options || {}
    const tray = document.querySelector('[data-hg-toast-tray]')
    if (!tray) return null
    const template = tray.querySelector('template')
    const node = template && template.content
      ? template.content.firstElementChild.cloneNode(true)
      : null
    if (!node) return null
    const title = node.querySelector('[data-hg-toast-title]')
    const body = node.querySelector('[data-hg-toast-body]')
    if (title) title.textContent = settings.title || ''
    if (body) body.textContent = settings.body || ''
    if (settings.variant === 'danger') {
      node.setAttribute('role', 'alert')
      node.setAttribute('aria-live', 'assertive')
    }
    tray.appendChild(node)
    const max = Number(tray.getAttribute('data-hg-toast-max')) || 4
    const toasts = Array.from(tray.querySelectorAll('[data-hg-toast]'))
    if (toasts.length > max) remove(toasts[0])
    schedule(node, settings.duration || Number(node.getAttribute('data-hg-toast-duration')) || 5000)
    return node
  }

  document.querySelectorAll('[data-hg-toast-tray] [data-hg-toast]').forEach((toast) => {
    schedule(toast, Number(toast.getAttribute('data-hg-toast-duration')) || 5000)
  })
})()
