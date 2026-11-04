# The keynote film

`record.js` produces `assets/readme/hygguile-keynote.gif`: a short, quiet film
about the showcase, in the spirit of an Apple keynote. It does not screen-record
a browser. It captures the built page as stills, stages them on a dark title-card
canvas (`stage.html`), and steps the animation one frame at a time, so every run
produces the same frames and the same GIF.

## Running it

From the repository root:

```sh
# 1. the film reads the built showcase
guix shell -m manifest.scm -- guile -L ./src -L . showcase.scm

# 2. install the recorder's one dependency
cd scripts/keynote
npm install

# 3. record
node record.js
```

Output: `assets/readme/hygguile-keynote.gif` (900 × 506, 20 fps, ~34 s, ~17 MB).

Requirements: Node 18+, a Chrome or Chromium (`CHROME_BIN` or `--chrome`), and
`ffmpeg` plus `gifsicle` on `$PATH`. The showcase itself pulls its icon font
from a CDN and the stage downloads Inter and JetBrains Mono once into
`build/fonts/`; both fall back to system fonts when the network is unavailable.

## What it does

1. **Capture.** Opens `dist/index.html` at 1440 × 900 (2× device pixels) in both
   themes and screenshots the page's own sections by their anchor ids, plus the
   command palette opened from its URL, a phone viewport, and a wide light/dark
   slice of the cards section. Section frames are found at capture time, so a
   card that grows taller moves its own frame.
2. **Stage.** `stage.html` is the film: seven scenes, each driven by a single
   `window.__seek(t)` function. Every animation is a pure function of `t`, which
   is what makes the output reproducible.
3. **Encode.** Renders `round(duration × fps)` PNG frames at 1600 × 900, has
   ffmpeg build a 112-colour palette and dither onto it, then runs gifsicle
   `-O3 --lossy=100` before removing the frames. The stage is rendered larger
   than the GIF so type and shadows are supersampled on the way down. Encoding
   scene changes as full frames (rather than encoder-side transparency diffs)
   is deliberate: it keeps a previous scene from ghosting through the next.

## Flags

| Flag | Default | Meaning |
| --- | --- | --- |
| `--width` | `900` | Output GIF width; height follows at 16:9. |
| `--fps` | `20` | Frames per second. |
| `--out` | `assets/readme/hygguile-keynote.gif` | Where the GIF is written. |
| `--stills` | – | Comma-separated times, e.g. `2.6,13.4,26.9`; writes stills and skips encoding. |
| `--keep-frames` | off | Keep the rendered PNG frames in `build/frames/`. |
| `--chrome` | – | Chrome/Chromium binary to drive. |

## Editing the film

- Copy lives in `stage.html`; scene timings are the `T` table at the bottom.
- Screenshots are addressed by the page ids in `SECTIONS` in `record.js`.
- `build/shots/` and `build/frames/` are disposable; delete `build/` to start clean.
