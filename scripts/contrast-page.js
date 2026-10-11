/* hygguile - cozy and professional user-interfaces for everyone

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
  The in-page half of the contrast gate.

  `scripts/contrast-gate.scm' injects this script, and the audit from
  `scripts/contrast-audit.js', into a built page and then asks a headless
  browser for the resulting DOM. Walking every theme is something only the
  browser can do -- a theme is `data-theme' plus a cascade -- so the work
  happens here and the verdict happens in Scheme.

  The findings travel back as one text/plain <script> block, which the
  browser prints verbatim, so the gate needs no WebSocket client and no
  JSON parser, and a dump that arrives without a block is a hard failure
  rather than an empty pass.

  One tab-separated record per line:

    theme  asked  seen  checked  failing  passing
    group  tag  classes  ratio  required  count  ink  background  sample
    near   theme  tag  classes  ratio  required  sample
    error  theme  message

  Fields are separated by tabs and records by newlines because a class
  list and a sample of page text can contain any other punctuation.
*/
(() => {
  const THEMES = ['light', 'dark']

  // The gate stills the page first -- its injected stylesheet turns
  // transitions and animations off -- so a theme change lands in the next
  // frame and this wait is only for layout and fonts to catch up. Grading
  // a colour mid-fade would fail a pair no reader ever sees.
  const SETTLE_MS = 200

  const BLOCK_ID = 'hygguile-contrast-gate'
  const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms))
  const cell = (value) => String(value).replace(/[\t\n\r]+/g, ' ').trim()
  const record = (fields) => fields.map(cell).join('\t')

  const lines = []

  const report = () => {
    const block = document.createElement('script')
    block.type = 'text/plain'
    block.id = BLOCK_ID
    block.textContent = '\n' + lines.join('\n') + '\n'
    document.body.appendChild(block)
  }

  window.addEventListener('load', () => {
    (async () => {
      for (const theme of THEMES) {
        document.documentElement.setAttribute('data-theme', theme)
        try {
          // the framework remembers the visitor's choice under this key, and
          // may restore it on load, so the gate states its own preference too
          localStorage.setItem('data-theme', theme)
        } catch (e) {
          // a file:// document may refuse storage; the attribute is enough
        }
        await wait(SETTLE_MS)
        let audit
        try {
          audit = window.__hygguileContrastAudit()
        } catch (e) {
          // report the failure rather than leaving the gate to guess at it
          // from a missing block
          lines.push(record(['error', theme, (e && e.message) || String(e)]))
          continue
        }
        const seen = document.documentElement.getAttribute('data-theme') || '(unset)'
        lines.push(record(['theme', theme, seen, audit.checked, audit.failing,
                           audit.passing]))
        for (const group of audit.groups) {
          lines.push(record(['group', group.tag, group.key, group.worst,
                             group.required, group.count, group.inkPainted,
                             group.backgroundPainted, group.sample]))
        }
        if (audit.borderline.length > 0) {
          const near = audit.borderline[0]
          lines.push(record(['near', theme, near.tag, near.key, near.ratio,
                             near.required, near.sample]))
        }
      }
      report()
    })()
  })
})()
