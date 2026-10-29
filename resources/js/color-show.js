/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

function cycleBgClass(currentClass) {
  const parts = currentClass.split('-')
  const currentNumber = parseInt(parts.toReversed()[0], 10)
  const nextNumber = currentNumber >= 900 ? 100 : currentNumber + 200
  const startParts = parts.slice(0, parts.length - 1).join("-")

  return `${startParts}-${nextNumber}`
}

function cycleColorShow(el) {
  const currentClass = [...el.classList].find(cls => cls.startsWith('bg-'))
  const newClass = cycleBgClass(currentClass)
  el.classList.toggle(currentClass)
  el.classList.toggle(newClass)
  el.children[0].innerText = newClass.replace("bg-", "")
}
