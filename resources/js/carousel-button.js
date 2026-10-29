/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
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
