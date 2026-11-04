#!/usr/bin/env node
'use strict';

// hygguile — keynote film recorder
//
// Builds a short, Apple-keynote-flavoured film about the showcase: it captures
// the real dist/index.html in both themes, stages those screenshots on a dark
// title-card stage, steps through the animation one frame at a time so the
// result is identical on every run, and encodes the frames to a GIF with
// ffmpeg's palette pipeline plus gifsicle's optimizer.
//
//   node scripts/keynote/record.js
//   node scripts/keynote/record.js --width 960 --fps 24
//   node scripts/keynote/record.js --stills 2.6,13.4,18.6
//
// Requirements: Node 18+, a Chrome/Chromium, ffmpeg and gifsicle on $PATH, and
// a built showcase
// (`guix shell -m manifest.scm -- guile -L ./src -L . showcase.scm`).

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOT = path.resolve(__dirname, '..', '..');
const BUILD = path.join(__dirname, 'build');
const SHOTS = path.join(BUILD, 'shots');
const FRAMES = path.join(BUILD, 'frames');
const STAGE_SRC = path.join(__dirname, 'stage.html');
const PAGE = path.join(ROOT, 'dist', 'index.html');
const DEFAULT_OUT = path.join(ROOT, 'assets', 'readme', 'hygguile-keynote.gif');

// ===== arguments =====

const argv = process.argv.slice(2);

function option(name, fallback) {
  const i = argv.indexOf('--' + name);
  if (i === -1) return fallback;
  const value = argv[i + 1];
  if (value === undefined || value.startsWith('--')) return true;
  return value;
}

function has(name) {
  return argv.includes('--' + name);
}

const fps = Number(option('fps', 20));
const width = Number(option('width', 900));
const out = path.resolve(option('out', DEFAULT_OUT));
const stills = option('stills', null);
const keepFrames = has('keep-frames');
const noEncode = has('no-encode');
const chromeFlag = option('chrome', null);

// ===== helpers =====

function log(message) {
  process.stdout.write(message + '\n');
}

function fail(message) {
  process.stderr.write('\nkeynote: ' + message + '\n');
  process.exit(1);
}

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function inPath(bin) {
  const dirs = (process.env.PATH || '').split(path.delimiter);
  for (const dir of dirs) {
    const candidate = path.join(dir || '.', bin);
    try {
      fs.accessSync(candidate, fs.constants.X_OK);
      return candidate;
    } catch (e) {
      // keep looking
    }
  }
  return null;
}

function findChrome() {
  if (typeof chromeFlag === 'string' && fs.existsSync(chromeFlag)) return chromeFlag;
  if (process.env.CHROME_BIN && fs.existsSync(process.env.CHROME_BIN)) return process.env.CHROME_BIN;
  const candidates = [
    '/usr/bin/google-chrome',
    '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium',
    '/usr/bin/chromium-browser',
  ];
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  const fromPath = inPath('google-chrome') || inPath('chromium');
  if (fromPath) return fromPath;
  fail('no Chrome or Chromium found; set CHROME_BIN or pass --chrome /path/to/chrome');
}

function run(command, args, opts) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      stdio: 'inherit',
      ...(opts || {}),
    });
    child.on('error', reject);
    child.on('close', (code) => {
      if (code === 0) resolve();
      else reject(new Error(command + ' exited with ' + code));
    });
  });
}

async function download(url, destination) {
  if (fs.existsSync(destination) && fs.statSync(destination).size > 2048) return true;
  try {
    const response = await fetch(url);
    if (!response.ok) return false;
    const bytes = Buffer.from(await response.arrayBuffer());
    if (bytes.length < 2048) return false;
    fs.writeFileSync(destination, bytes);
    return true;
  } catch (e) {
    return false;
  }
}

// ===== capture =====

const SECTIONS = ['typography', 'cards', 'forms', 'field-extras', 'tables', 'feedback'];

const SHOT_ARGS = [
  '--no-sandbox',
  '--disable-gpu',
  '--hide-scrollbars',
  '--force-color-profile=srgb',
  '--font-render-hinting=none',
  '--disable-lcd-text',
  '--no-first-run',
  '--no-default-browser-check',
  '--disable-extensions',
];

const FREEZE_JS = `
  *, *::before, *::after {
    animation-play-state: paused !important;
    caret-color: transparent !important;
  }
`;

async function settle(page, ms) {
  await page.evaluate(() => document.fonts.ready);
  await new Promise((resolve) => setTimeout(resolve, ms === undefined ? 500 : ms));
}

async function setTheme(page, theme) {
  await page.evaluate((value) => {
    localStorage.setItem('data-theme', value);
    document.documentElement.setAttribute('data-theme', value);
    document.documentElement.classList.toggle('dark', value === 'dark');
  }, theme);
  await new Promise((resolve) => setTimeout(resolve, 450));
}

function pageUrl() {
  return 'file://' + PAGE;
}

async function shoot(page, name, clip) {
  const file = path.join(SHOTS, name + '.png');
  await page.screenshot(clip ? { path: file, clip } : { path: file });
  log('  · ' + name);
}

// Frame capture trades a larger PNG for a much faster encode: nothing reads
// these files except ffmpeg, and they are deleted once the GIF is written.
async function frame(page, file) {
  await page.screenshot({ path: file, optimizeForSpeed: true });
}

async function sectionRects(page) {
  return page.evaluate((ids) => {
    const rects = {};
    for (const id of ids) {
      const anchor = document.getElementById(id);
      if (!anchor) {
        rects[id] = null;
        continue;
      }
      const card = anchor.closest('details') || anchor;
      const box = card.getBoundingClientRect();
      rects[id] = {
        x: box.left + window.scrollX,
        y: box.top + window.scrollY,
        width: box.width,
        height: box.height,
      };
    }
    return rects;
  }, SECTIONS);
}

function sectionClip(rect) {
  const x = Math.max(0, Math.floor(rect.x - 18));
  const y = Math.max(0, Math.floor(rect.y - 14));
  const right = Math.min(1440, Math.ceil(rect.x + rect.width + 18));
  return {
    x,
    y,
    width: right - x,
    height: Math.min(2200, Math.ceil(rect.height + 28)),
  };
}

async function capture(browser) {
  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900, deviceScaleFactor: 2 });
  await page.goto(pageUrl(), { waitUntil: 'networkidle2', timeout: 90000 });
  await page.addStyleTag({ content: FREEZE_JS });
  await settle(page, 900);

  log('capturing light theme');
  await page.evaluate(() => window.scrollTo(0, 0));
  await shoot(page, 'hero-light', { x: 0, y: 0, width: 1440, height: 2000 });

  const rects = await sectionRects(page);
  for (const id of SECTIONS) {
    if (!rects[id]) {
      log('  ! section #' + id + ' not found, skipped');
      continue;
    }
    await shoot(page, id + '-light', sectionClip(rects[id]));
  }

  // A wide, full-bleed slice used by the light/dark scene: page margins and the
  // card's own glass edges stay in frame, so the two themes line up exactly.
  const wideClip = {
    x: 0,
    y: Math.max(0, Math.floor(rects.cards.y - 30)),
    width: 1440,
    height: 640,
  };
  await shoot(page, 'cards-wide-light', wideClip);

  log('capturing dark theme');
  await setTheme(page, 'dark');
  await shoot(page, 'cards-wide-dark', wideClip);

  // The command palette, opened the way the URL opens it.
  const overlay = await browser.newPage();
  await overlay.setViewport({ width: 1440, height: 900, deviceScaleFactor: 2 });
  await overlay.goto(pageUrl() + '#showcase-commands', { waitUntil: 'networkidle2', timeout: 90000 });
  await overlay.addStyleTag({ content: FREEZE_JS });
  await setTheme(overlay, 'light');
  await settle(overlay, 700);
  // Crop to the palette panel itself (with a little air), so the tile shows the
  // overlay rather than a wall of dimmed page behind it.
  const palette = await overlay.evaluate(() => {
    const panel = document.querySelector('#showcase-commands [role="dialog"], #showcase-commands .hg-command-panel');
    const box = (panel || document.querySelector('#showcase-commands')).getBoundingClientRect();
    return { x: box.left, y: box.top, width: box.width, height: box.height };
  });
  const palettePad = 84;
  await shoot(overlay, 'commands', {
    x: Math.max(0, Math.round(palette.x - palettePad)),
    y: Math.max(0, Math.round(palette.y - palettePad)),
    width: Math.round(palette.width + palettePad * 2),
    height: Math.round(palette.height + palettePad * 2),
  });
  await overlay.close();

  // A phone, at a phone's own viewport.
  const phone = await browser.newPage();
  await phone.setViewport({ width: 402, height: 874, deviceScaleFactor: 3 });
  await phone.goto(pageUrl(), { waitUntil: 'networkidle2', timeout: 90000 });
  await phone.addStyleTag({ content: FREEZE_JS });
  await setTheme(phone, 'light');
  await settle(phone, 700);
  await shoot(phone, 'phone-light', { x: 0, y: 0, width: 402, height: 1100 });
  await phone.close();

  await page.close();
}

// ===== render =====

async function prepareStage() {
  ensureDir(SHOTS);
  ensureDir(FRAMES);
  ensureDir(path.join(BUILD, 'fonts'));
  fs.copyFileSync(STAGE_SRC, path.join(BUILD, 'stage.html'));
  fs.copyFileSync(path.join(ROOT, 'assets', 'hygguile-logo.svg'), path.join(SHOTS, 'logo.svg'));

  const fonts = [
    [
      'https://cdn.jsdelivr.net/npm/@fontsource-variable/inter@5/files/inter-latin-wght-normal.woff2',
      'inter.woff2',
    ],
    [
      'https://cdn.jsdelivr.net/npm/@fontsource-variable/jetbrains-mono@5/files/jetbrains-mono-latin-wght-normal.woff2',
      'mono.woff2',
    ],
  ];
  for (const [url, name] of fonts) {
    const destination = path.join(BUILD, 'fonts', name);
    const ok = await download(url, destination);
    if (!ok) {
      log('  ! could not download ' + name + '; the stage falls back to a system font');
    }
  }
}

async function renderFrames(browser) {
  const page = await browser.newPage();
  await page.setViewport({ width: 1600, height: 900, deviceScaleFactor: 1 });
  await page.goto('file://' + path.join(BUILD, 'stage.html'), { waitUntil: 'load', timeout: 60000 });
  await page.waitForFunction('window.__ready === true', { timeout: 60000 });
  await new Promise((resolve) => setTimeout(resolve, 250));

  const duration = await page.evaluate(() => window.__duration || 34.2);

  if (stills) {
    const times = String(stills)
      .split(',')
      .map((value) => Number(value.trim()))
      .filter((value) => Number.isFinite(value));
    const dir = path.join(BUILD, 'stills');
    ensureDir(dir);
    for (const time of times) {
      await page.evaluate((t) => window.__seek(t), time);
      await new Promise((resolve) => setTimeout(resolve, 120));
      const file = path.join(dir, 't-' + time.toFixed(2) + '.png');
      await page.screenshot({ path: file });
      log('  still ' + file.replace(ROOT + '/', ''));
    }
    await page.close();
    return { duration, count: 0 };
  }

  const count = Math.round(duration * fps);
  // A previous run at another frame rate leaves frames this one will not
  // overwrite; ffmpeg reads the whole directory, so start from empty.
  fs.rmSync(FRAMES, { recursive: true, force: true });
  ensureDir(FRAMES);
  log('rendering ' + count + ' frames at ' + fps + ' fps (' + duration + ' s)');
  for (let i = 0; i < count; i++) {
    const time = i / fps;
    await page.evaluate((t) => window.__seek(t), time);
    await frame(page, path.join(FRAMES, String(i).padStart(5, '0') + '.png'));
    if (i % 120 === 0) log('  frame ' + i + ' / ' + count);
  }
  await page.close();
  return { duration, count };
}

// ===== encode =====

async function encode(count) {
  const rendered = fs.readdirSync(FRAMES).filter((name) => name.endsWith('.png')).length;
  if (rendered !== count) fail('expected ' + count + ' frames, found ' + rendered);

  const ffmpeg = inPath('ffmpeg');
  if (!ffmpeg) fail('ffmpeg is not on $PATH; install it to encode the GIF');
  const gifsicle = inPath('gifsicle');
  if (!gifsicle) fail('gifsicle is not on $PATH; install it to optimize the GIF');

  ensureDir(path.dirname(out));
  const raw = path.join(BUILD, 'keynote-raw.gif');
  log('encoding ' + out.replace(ROOT + '/', '') + ' at ' + width + ' px wide');

  // Two passes in one filter graph: palettegen builds a palette from the film,
  // paletteuse dithers onto it. Per-frame transparency is left to gifsicle's
  // optimizer rather than the encoder, which keeps scene changes intact.
  await run(ffmpeg, [
    '-y',
    '-framerate', String(fps),
    '-i', path.join(FRAMES, '%05d.png'),
    '-vf', 'scale=' + width + ':-1:flags=lanczos,split[a][b];' +
      '[a]palettegen=max_colors=112:stats_mode=diff[p];' +
      '[b][p]paletteuse=dither=bayer:bayer_scale=5',
    '-loop', '0',
    raw,
  ]);

  await run(gifsicle, ['-O3', '--lossy=100', raw, '-o', out]);
  fs.rmSync(raw, { force: true });

  const size = fs.statSync(out).size;
  log('wrote ' + out.replace(ROOT + '/', '') + ' (' + (size / 1024 / 1024).toFixed(2) + ' MB)');

  if (!keepFrames) {
    fs.rmSync(FRAMES, { recursive: true, force: true });
  }
}

// ===== main =====

(async function main() {
  if (!fs.existsSync(PAGE)) {
    fail('no built showcase at dist/index.html\n' +
      '  build it first: guix shell -m manifest.scm -- guile -L ./src -L . showcase.scm');
  }
  if (!Number.isFinite(fps) || fps < 1 || fps > 60) fail('--fps must be between 1 and 60');
  if (!Number.isFinite(width) || width < 320) fail('--width must be at least 320');

  const chrome = findChrome();
  const puppeteer = require('puppeteer-core');

  ensureDir(BUILD);
  ensureDir(SHOTS);
  await prepareStage();

  log('launching ' + chrome);
  const browser = await puppeteer.launch({
    executablePath: chrome,
    headless: 'new',
    args: SHOT_ARGS,
  });

  try {
    await capture(browser);
    const { count } = await renderFrames(browser);
    if (count > 0 && !noEncode) await encode(count);
    if (count > 0 && noEncode) log('frames kept in ' + FRAMES.replace(ROOT + '/', ''));
  } finally {
    await browser.close();
  }
})().catch((error) => {
  fail(error && error.stack ? error.stack : String(error));
});
