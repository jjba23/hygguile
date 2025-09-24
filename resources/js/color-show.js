/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
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
