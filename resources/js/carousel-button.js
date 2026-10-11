/*
  hygguile - cozy and professional user-interfaces for everyone

  Copyright © Josep Bigorra <jjbigorra@gmail.com>

  hygguile is free software: you can redistribute it and/or modify
  it under the terms of the Lesser GNU General Public License as published
  by the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  hygguile is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  Lesser GNU General Public License for more details.

  You should have received a copy of the Lesser GNU General Public License
  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
*/

const carouselItems = (list) => Array.from(list.querySelectorAll('.carousel-list-item'))

const carouselCentres = (list, items) => {
  const listCentre = list.getBoundingClientRect().left + list.clientWidth / 2
  const centres = items.map((item) => {
    const rect = item.getBoundingClientRect()
    return rect.left + rect.width / 2
  })
  const nearest = centres.reduce((best, itemCentre, index) => {
    if (Math.abs(itemCentre - listCentre) < Math.abs(centres[best] - listCentre)) {
      return index
    }
    return best
  }, 0)
  return { listCentre, centres, nearest }
}

// a real function declaration, so the inline onclick attributes emitted by
// the component always find it on the global scope
function handleCarouselClick(direction, id) {
  const list = document.getElementById(id)
  if (!list) {
    return
  }
  const items = carouselItems(list)
  if (!items.length) {
    return
  }
  // the items are centred snap points, so page one item at a time by
  // measuring where each one actually sits instead of guessing a step;
  // this keeps the gap between items (which changes at the responsive
  // breakpoints) and any width difference honest
  const { listCentre, centres, nearest } = carouselCentres(list, items)
  const step = direction === 'previous' ? -1 : 1
  const target = Math.min(Math.max(nearest + step, 0), items.length - 1)
  list.scrollBy({ left: centres[target] - listCentre, behavior: 'smooth' })
}
