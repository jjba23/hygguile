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

/*
  The fold on a `code-sample': the source of a specimen is hidden until a
  reader asks for it.

  The component says everything this needs. The control carries an
  `aria-controls' naming the panel and an `aria-expanded' saying whether the
  panel is showing, and the panel carries the `hidden' attribute the component
  wrote; the whole state the script keeps is those two attributes, so a page
  that renders its own markup without the component gains nothing by loading
  this file.

  Without scripting the panel is revealed by the `noscript' stylesheet and the
  control is hidden as a `.js-only' element, so a reader who cannot fold the
  source still reads it.
*/

function hygguileToggleCodeSample(button) {
  const id = button.getAttribute('aria-controls')
  const panel = id && document.getElementById(id)

  if (!panel) return

  panel.hidden = !panel.hidden
  button.setAttribute('aria-expanded', panel.hidden ? 'false' : 'true')
}
