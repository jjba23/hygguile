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
  Contrast audit for a rendered hygguile page.

  Olive's palette is oklch, and half the surfaces on a page are translucent
  (frosted panels, badges, translucent rules), so the only honest way to
  answer "is this readable?" is to ask the browser: read the computed ink of
  every element that renders text, composite every translucent background
  above it, and compare with the WCAG 2.1 contrast formula.

  Usage, from the browser console on the page you want to audit:

    await fetch('/contrast-audit.js').then(r => r.text()).then(eval)
    copy(window.__contrastAudit)

  or paste this whole file into the console.  Run it once per theme: the
  audit reports the theme it saw, and `hygguile` toggles themes with the
  `data-theme` attribute on <html>.

  The report lists the failures (below WCAG AA: 4.5 for body text, 3.0 for
  large text and non-text UI) grouped by the classes that produced them, so
  a design fix becomes a search-and-replace instead of a guessing game.
*/

(() => {
  const DEFAULTS = {
    // WCAG 2.1 AA for normal text, and for large text (>= 24px, or >= 18.66px
    // when bold) and non-text UI.
    body: 4.5,
    large: 3,
    // print at most this many grouped findings and raw rows
    limit: 40
  };
  const options = Object.assign({}, DEFAULTS, window.__contrastAuditOptions || {});

  // ===== colour parsing: oklch(), rgb()/rgba(), transparent =====
  const parseCache = new Map();

  const gammaEncode = (x) => {
    const v = Math.min(Math.max(x, 0), 1);
    return v <= 0.0031308 ? 12.92 * v : 1.055 * Math.pow(v, 1 / 2.4) - 0.055;
  };

  const oklchToSrgb = (L, C, H) => {
    const rad = (H * Math.PI) / 180;
    const a = C * Math.cos(rad);
    const b = C * Math.sin(rad);
    const l = Math.pow(L + 0.3963377774 * a + 0.2158037573 * b, 3);
    const m = Math.pow(L - 0.1055613458 * a - 0.0638541728 * b, 3);
    const s = Math.pow(L - 0.0894841775 * a - 1.291485548 * b, 3);
    return [
      gammaEncode(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
      gammaEncode(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
      gammaEncode(-0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s)
    ];
  };

  const toNumber = (token) => {
    const n = parseFloat(token);
    return token.includes('%') ? n / 100 : n;
  };

  const parseColor = (raw) => {
    if (!raw) return null;
    const str = raw.trim().toLowerCase();
    if (parseCache.has(str)) return parseCache.get(str);
    let out = null;
    const rgbMatch = str.match(/^rgba?\(([^)]+)\)$/);
    const oklchMatch = str.match(/^oklch\(([^)]+)\)$/);
    if (str === 'transparent') {
      out = [0, 0, 0, 0];
    } else if (rgbMatch) {
      // browsers serialize rgb()/rgba() as either 0-255 integers or
      // percentages, in comma or space separated form
      const parts = rgbMatch[1].split(/[,\s/]+/).filter(Boolean);
      const channel = (part) =>
        part.includes('%') ? parseFloat(part) / 100 : parseFloat(part) / 255;
      out = [
        channel(parts[0]),
        channel(parts[1]),
        channel(parts[2]),
        parts.length > 3 ? toNumber(parts[3]) : 1
      ];
    } else if (oklchMatch) {
      const parts = oklchMatch[1].split(/[\s/]+/).filter(Boolean);
      const [r, g, b] = oklchToSrgb(toNumber(parts[0]),
                                    toNumber(parts[1]),
                                    toNumber(parts[2]));
      out = [r, g, b, parts.length > 3 ? toNumber(parts[3]) : 1];
    }
    parseCache.set(str, out);
    return out;
  };

  // ===== WCAG relative luminance and contrast =====
  const linear = (c) => (c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4));

  const luminance = (rgb) =>
    0.2126 * linear(rgb[0]) + 0.7152 * linear(rgb[1]) + 0.0722 * linear(rgb[2]);

  const composite = (front, back) => [
    front[0] * front[3] + back[0] * (1 - front[3]),
    front[1] * front[3] + back[1] * (1 - front[3]),
    front[2] * front[3] + back[2] * (1 - front[3]),
    1
  ];

  const contrast = (a, b) => {
    const la = luminance(a);
    const lb = luminance(b);
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
  };

  // ===== effective background of an element =====
  const pageBackground = () => {
    const parsed = parseColor(getComputedStyle(document.documentElement).backgroundColor);
    return parsed && parsed[3] > 0 ? parsed : [1, 1, 1, 1];
  };

  const effectiveBackground = (el) => {
    const layers = [];
    let node = el;
    while (node && node.nodeType === 1) {
      const bg = parseColor(getComputedStyle(node).backgroundColor);
      // a fully transparent layer changes nothing
      if (bg && bg[3] > 0) layers.push(bg);
      node = node.parentElement;
    }
    let acc = pageBackground();
    for (let i = layers.length - 1; i >= 0; i--) acc = composite(layers[i], acc);
    return acc;
  };

  // ===== which elements carry text we should judge =====
  const ownText = (el) =>
    Array.from(el.childNodes)
      .filter((n) => n.nodeType === 3)
      .map((n) => n.textContent.trim())
      .filter(Boolean)
      .join(' ');

  // glyph-only runs (emoji, arrows, punctuation) are painted in their own
  // colours, so the `color` property says nothing about their legibility
  const isGlyphOnly = (text) => !/[\p{L}\p{N}]/u.test(text);

  const isSkipped = (el, cs) => {
    if (cs.visibility === 'hidden' || cs.display === 'none') return true;
    if (parseFloat(cs.opacity) === 0) return true;
    if (el.classList.contains('sr-only')) return true;
    if (el.closest('[aria-hidden="true"]')) return true;
    // <noscript> content is inert whenever scripting is on
    if (el.closest('noscript')) return true;
    // gradient text: the ink is a background image, not a colour
    if (cs.webkitBackgroundClip === 'text' || cs.backgroundClip === 'text') return true;
    if (!el.getClientRects().length) return true;
    return false;
  };

  const classKey = (el) =>
    (el.className || '').toString().split(/\s+/).filter(Boolean).sort().join(' ') ||
    el.tagName.toLowerCase();

  // the background actually seen behind the glyphs, after compositing every
  // translucent layer above it, as #rrggbb
  const hex = (rgb) =>
    '#' + rgb.slice(0, 3)
      .map((c) => Math.round(Math.min(Math.max(c, 0), 1) * 255)
        .toString(16).padStart(2, '0')).join('');

  const rows = [];
  for (const el of document.querySelectorAll('body *')) {
    const text = ownText(el);
    if (!text) continue;
    const cs = getComputedStyle(el);
    if (isSkipped(el, cs)) continue;
    if (isGlyphOnly(text)) continue;
    const ink = parseColor(cs.color);
    if (!ink || ink[3] === 0) continue;
    const bg = effectiveBackground(el);
    const painted = composite(ink, bg);
    const size = parseFloat(cs.fontSize);
    const bold = parseInt(cs.fontWeight, 10) >= 700;
    const large = size >= 24 || (size >= 18.66 && bold);
    const required = large ? options.large : options.body;
    rows.push({
      ratio: Math.round(contrast(painted, bg) * 100) / 100,
      required,
      passes: contrast(painted, bg) >= required,
      tag: el.tagName.toLowerCase(),
      key: classKey(el),
      text: text.slice(0, 60),
      fontPx: Math.round(size),
      bold,
      ink: cs.color,
      inkPainted: hex(painted),
      background: getComputedStyle(el).backgroundColor,
      backgroundPainted: hex(bg)
    });
  }

  const failures = rows.filter((r) => !r.passes).sort((a, b) => a.ratio - b.ratio);

  // things that pass, but with little room to spare: these are the pairs that
  // will fail on the next shade change, so they are worth knowing about
  const borderline = rows.filter((r) => r.passes && r.ratio < r.required * 1.2)
    .sort((a, b) => a.ratio / a.required - b.ratio / b.required);

  // group by the class list that produced the pair, which is what a fix
  // actually changes
  const groups = new Map();
  for (const f of failures) {
    const id = `${f.tag} | ${f.key} | ${f.ink} on ${f.backgroundPainted}`;
    const g = groups.get(id) || { tag: f.tag, key: f.key, ink: f.ink,
      inkPainted: f.inkPainted, background: f.background,
      backgroundPainted: f.backgroundPainted, worst: f.ratio,
      required: f.required, count: 0, sample: f.text };
    g.count += 1;
    g.worst = Math.min(g.worst, f.ratio);
    groups.set(id, g);
  }

  const report = {
    theme: document.documentElement.getAttribute('data-theme') || '(unset)',
    url: location.pathname,
    viewport: { width: window.innerWidth, height: window.innerHeight },
    thresholds: { body: options.body, large: options.large },
    checked: rows.length,
    passing: rows.length - failures.length,
    failing: failures.length,
    groups: Array.from(groups.values())
      .sort((a, b) => a.worst - b.worst)
      .slice(0, options.limit),
    borderline: borderline.slice(0, options.limit),
    worst: failures.slice(0, options.limit)
  };

  window.__contrastAudit = report;
  return report;
})();
