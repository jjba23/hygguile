/*
  hygguile - cozy and professional user-interfaces for everyone

  SPDX-License-Identifier: MIT
  Copyright © Josep Bigorra <jjbigorra@gmail.com>
*/

function hygguileCopyPreInnerText(elementId) {
  const id = elementId + '-pre'
  console.log('copying inner text of element: ' + id)

  var el = document.getElementById(id)

  navigator.clipboard.writeText(el.innerText)

  console.log(el.innerText)
}
