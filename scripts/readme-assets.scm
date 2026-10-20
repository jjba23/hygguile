;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; hygguile is free software: you can redistribute it and/or modify
;; it under the terms of the Lesser GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; hygguile is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; Lesser GNU General Public License for more details.

;; You should have received a copy of the Lesser GNU General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

;; ===== the README's two assets =====
;;
;; The images at the top of the README are generated rather than drawn, and this
;; is the tool that generates them:
;;
;;   guile ./scripts/readme-assets.scm logo   # `maak logo'
;;   guile ./scripts/readme-assets.scm gif    # `maak gif'
;;
;; The logo is one hand-drawn SVG, rendered to PNG by the browser, so the mark a
;; chat client shows as a raster and the mark a page embeds as a vector are the
;; same file.
;;
;; The demo is the *deployed* showcase, not a second page written to look like
;; it: the script fetches https://hygguile.jointhefreeworld.org once, opens it in
;; both themes, cuts the sections a reader should see out of two tall
;; screenshots, and assembles them into assets/readme/hygguile-demo.gif. Which
;; sections, and where each frame starts, is read from the page itself at capture
;; time, so a card that grows taller moves its own frame instead of leaving the
;; demo pointing at the wrong paragraph.
;;
;; Three things it needs: a Chrome or Chromium ($CHROME_BIN points at one kept
;; elsewhere), ImageMagick's `convert' and `gifsicle', all on $PATH. It is not
;; part of `maak build': it wants a network and a browser, and a README that lags
;; a commit is not an emergency.

(use-modules (ice-9 format)
             (ice-9 popen)
             (ice-9 regex)
             (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-13))

;; ===== what gets generated =====

(define site
  "https://hygguile.jointhefreeworld.org")

;; The one stylesheet the deployed page links rather than inlines, fetched beside
;; it so the copy this script screenshots is the page as it is served.
(define stylesheet
  "olive.min.css")

(define logo-svg
  "assets/hygguile-logo.svg")

(define logo-png
  "assets/hygguile-logo.png")

(define logo-pixels
  512)

(define gif-path
  "assets/readme/hygguile-demo.gif")

(define frame-width
  1280)

(define frame-height
  800)

;; How far above a section its frame starts, so the card's own header sits inside
;; the frame rather than flush with its top edge.
(define frame-lead
  140)

;; The delay between frames, in hundredths of a second: long enough to read a
;; card, short enough that the demo does not feel stuck.
(define frame-delay
  170)

(define gif-colours
  128)

;; Where the fetch, the screenshots and the frames are put, and taken away from
;; again. Nothing here is worth keeping: the two assets are the output.
(define work-dir
  (string-append (or (getenv "TMPDIR") "/tmp") "/hygguile-readme-assets"))

;; The frames of the demo, in the order a reader meets them: the top of the page,
;; then the three cards that say the most about the framework, then the same page
;; in the other theme. A #f section is the top of the document; anything else is
;; an id the showcase gives one of its cards, and the frame is that card's own
;; address, which the browser scrolls to for us.
(define frames
  '(("light" #f)
    ("light" "cards")
    ("light" "colors")
    ("light" "tables")
    ("dark" #f)
    ("dark" "cards")
    ("dark" "tables")))

;; ===== the shell =====

(define (report format-string . args)
  (apply format
         (current-output-port) format-string args)
  (newline))

(define (fail! format-string . args)
  "Print a reason for giving up and exit non-zero."
  (apply format
         (current-error-port)
         (string-append "\nreadme assets: " format-string "\n") args)
  (exit 1))

(define (in-path name)
  "The absolute path of the executable @var{name} on $PATH, or #f."
  (let ((path (getenv "PATH")))
    (and path
         (let lp
           ((dirs (string-split path #\:)))
           (and (pair? dirs)
                (let ((candidate (string-append (if (string-null? (car dirs))
                                                    "."
                                                    (car dirs)) "/" name)))
                  (if (and (file-exists? candidate)
                           (access? candidate X_OK)) candidate
                      (lp (cdr dirs)))))))))

(define browser-names
  '("google-chrome-stable" "google-chrome" "chromium" "chromium-browser"))

(define (browser)
  "The browser to drive, or a sentence saying there is none to drive."
  (let ((wanted (getenv "CHROME_BIN")))
    (or (if (and wanted
                 (not (string-null? wanted)))
            (and (file-exists? wanted)
                 (access? wanted X_OK) wanted)
            (or-map in-path browser-names))
        (fail!
         "no browser to render with; put a Chrome or Chromium on $PATH, or point $CHROME_BIN at one"))))

(define* (tool name
               #:optional (why "to build the images"))
  "Return the path of @var{name}, or give up with a sentence naming it."
  (or (in-path name)
      (fail! "no ~a on $PATH, needed ~a" name why)))

(define chrome-flags
  '("--headless=old" "--disable-gpu"
    "--hide-scrollbars"
    "--no-first-run"
    "--no-default-browser-check"
    "--disable-extensions"
    ;; Containers and Guix builds often cannot start Chrome's sandbox, and this
    ;; script only ever opens files it wrote itself a moment earlier.
    "--no-sandbox"))

;; A capture that never returns must not hang a release.
(define browser-timeout-s
  300)

(define (run program . arguments)
  "Run PROGRAM with ARGUMENTS, and give up when it does not succeed."
  (let ((status (apply system* program arguments)))
    (unless (and status
                 (zero? (status:exit-val status)))
      (fail! "~a failed"
             (string-join (cons program arguments) " ")))))

(define (run-output program . arguments)
  "Run PROGRAM with ARGUMENTS, and return what it printed."
  (let* ((port (apply open-pipe* OPEN_READ program arguments))
         (output (get-string-all port)))
    (close-pipe port) output))

(define (read-text path)
  (get-string-all (open-input-file path)))

(define (write-text path text)
  (call-with-output-file path
    (lambda (port)
      (display text port))))

(define (in-work name)
  "The path of NAME inside the working directory."
  (string-append work-dir "/" name))

(define (file-url path)
  "PATH as the file: URL a browser opens."
  (string-append "file://"
                 (if (string-prefix? "/" path) path
                     (string-append (getcwd) "/" path))))

(define (browser-command browser . arguments)
  "The BROWSER with its flags and ARGUMENTS, behind a timeout."
  (append (list "timeout"
                (number->string browser-timeout-s) browser) chrome-flags
          arguments))

(define (screenshot browser target width height source)
  "Screenshot SOURCE into TARGET at WIDTH by HEIGHT, and return TARGET."
  (apply run
         (browser-command browser
                          (string-append "--screenshot=" target)
                          (string-append "--window-size="
                                         (number->string width) ","
                                         (number->string height))
                          ;; long enough for the fonts, the washes and the
                          ;; transitions of a page this size to settle
                          "--virtual-time-budget=20000"
                          (file-url source))) target)

(define (size-of path)
  (stat:size (stat path)))

(define (ensure-directory path)
  "Make the directory PATH names, if it is not there already.

A path with no directory in it names the working directory, which is always
there; anything else is made, because git does not keep a directory that only
ever held generated files."
  (let ((slash (string-rindex path #\/)))
    (when slash
      (run "mkdir" "-p"
           (substring path 0 slash)))))

;; ===== the logo =====

(define (render-logo)
  "Render the hand-drawn SVG to the PNG a raster-only reader can show."
  (let ((browser (browser)))
    (report "rendering ~a to ~a" logo-svg logo-png)
    (ensure-directory logo-png)
    (apply run
           (browser-command browser
                            (string-append "--screenshot=" logo-png)
                            (string-append "--window-size="
                                           (number->string logo-pixels) ","
                                           (number->string logo-pixels))
                            ;; the badge carries its own ground, so the corners
                            ;; outside its rounded edge stay transparent
                            "--default-background-color=00000000"
                            "--virtual-time-budget=4000"
                            (file-url logo-svg)))
    (unless (and (file-exists? logo-png)
                 (< 0
                    (size-of logo-png)))
      (fail! "the browser wrote no ~a" logo-png))
    (report "wrote ~a (~a bytes)" logo-png
            (size-of logo-png))))

;; ===== the demo =====

(define (fetch browser)
  "Fetch the deployed showcase, and the stylesheet it links, into the work dir."
  (let ((curl (tool "curl")))
    (run "mkdir" "-p" work-dir)
    (report "fetching ~a" site)
    (run curl
         "-sS"
         "--fail"
         "--location"
         "--max-time"
         "120"
         "-o"
         (in-work "page.html")
         site)
    (run curl
         "-sS"
         "--fail"
         "--location"
         "--max-time"
         "120"
         "-o"
         (in-work stylesheet)
         (string-append site "/" stylesheet))))

(define (inject html snippet)
  "HTML with SNIPPET placed at the end of its head.

A page's head ends before its body is parsed, which is early enough for both of
the things this script puts there: the theme the capture is to render in, and the
script that measures the page."
  (let ((at (or (string-contains html "</head>")
                (fail!
                 "the deployed page has no </head>; is ~a serving a page?"
                 site))))
    (string-append (substring html 0 at) snippet
                   (substring html at))))

(define (themed html theme)
  "HTML with the theme set before its body is parsed.

The theme is a pair of attributes on the document element -- @code{data-theme}
for the stylesheet's own rules and the @code{dark} class for the utility
variants -- so setting both before the body paints gives the browser a page that
never shows the other theme, not even for a frame."
  (if (string=? theme "light") html
      (inject html
              (format #f
               "<script>document.documentElement.setAttribute('data-theme','~a');document.documentElement.classList.add('~a');</script>"
               theme theme))))

(define (section-ids)
  "The sections the frames name, each once, in the order they are asked for."
  (delete-duplicates (delete #f
                             (map cadr frames))))

(define (probe html)
  "HTML carrying a script that reports the document's height and section offsets.

The demo's frames are cut out of one tall screenshot per theme, so where a frame
starts has to be asked of the page rather than written down in this script: a
card that grows an example moves every section below it. The answer is written
into the document's title, which is the one part of a page that `--dump-dom'
prints and the page's own markup never touches."
  (inject html
          (format #f
           "<script>window.addEventListener('load', function () {
  var parts = ['~a'].map(function (id) {
    var el = document.getElementById(id);
    return id + ':' + (el ? Math.round(el.getBoundingClientRect().top + window.scrollY) : -1);
  });
  document.title = 'offsets ' + Math.round(document.documentElement.scrollHeight) + ' ' + parts.join(',');
});</script>"
           (string-join (section-ids) "','"))))

(define (measure browser light)
  "Ask the page in BROWSER, at the width of a frame, how tall it is and where its
sections start.

Returns a pair of the document's height and an alist of section id to offset.
The window has to be as wide as a frame: the layout, and with it every offset,
is the one a reader at that width would see."
  (let* ((probe-path (in-work "probe.html"))
         (dom (begin
                (write-text probe-path
                            (probe (read-text light)))
                (apply run-output
                       (browser-command browser "--dump-dom"
                                        (string-append "--window-size="
                                                       (number->string
                                                        frame-width) ","
                                                       (number->string
                                                        frame-height))
                                        "--virtual-time-budget=20000"
                                        (file-url probe-path)))))
         (found (string-match "offsets ([0-9]+) ([a-z0-9:,-]+)" dom)))
    (unless found
      (fail!
       "the deployed page did not report its own measurements; has its markup changed?"))
    (cons (string->number (match:substring found 1))
          (map (lambda (part)
                 (let ((at (string-index part #\:)))
                   (cons (substring part 0 at)
                         (string->number (substring part
                                                    (+ at 1))))))
               (string-split (match:substring found 2) #\,)))))

(define (frame-top offsets section)
  "Where a frame showing SECTION starts, or 0 for the top of the page."
  (if section
      (let ((offset (assoc-ref offsets section)))
        (unless (and offset
                     (<= 0 offset))
          (fail! "the deployed page has no #~a anymore; name another section"
                 section))
        (max 0
             (- offset frame-lead))) 0))

(define (frame-page html top)
  "HTML holding still at TOP, so that a frame-sized screenshot of it is a frame.

The demo's frames are windows onto a page much taller than a window, and a
browser asked for a screenshot gives back the top of the document. Sliding the
body up by the offset does the scrolling instead: what was at TOP is now at the
top of the viewport, which is exactly the slice a frame wants. The page is
fetched once and one copy per frame is written from it, so nothing here has to
make an image taller than a frame either."
  (inject html
          (format #f
           "<style>html, body { margin: 0 !important; padding: 0 !important; overflow: hidden !important; } body { position: relative !important; top: -~apx !important; }</style>"
           top)))

(define (capture-frame browser theme index top)
  "Screenshot frame INDEX of THEME, held still at TOP, and return the PNG."
  (let ((page (in-work (format #f "frame-~2,'0d.html" index)))
        (png (in-work (format #f "frame-~2,'0d.png" index))))
    (write-text page
                (frame-page (read-text (in-work (string-append theme ".html")))
                            top))
    (screenshot browser png frame-width frame-height page)))

(define (assemble frame-paths)
  "Combine the frames into the demo GIF, and return its path."
  (let ((raw (in-work "demo.gif")))
    (ensure-directory gif-path)
    (apply run
           (append (list (tool "convert" "to assemble the demo") "-delay"
                         (number->string frame-delay) "-loop" "0") frame-paths
                   (list "-layers" "Optimize" raw)))
    (run (tool "gifsicle" "to shrink the demo")
         "-O3"
         "--colors"
         (number->string gif-colours)
         raw
         "-o"
         gif-path) gif-path))

(define (render-gif)
  "Capture the deployed showcase in both themes and assemble the demo."
  (let* ((browser (browser))
         (light (in-work "light.html"))
         (dark (in-work "dark.html")))
    (fetch browser)
    (let ((page (read-text (in-work "page.html"))))
      (write-text light
                  (themed page "light"))
      (write-text dark
                  (themed page "dark")))
    (let ((offsets (cdr (measure browser light))))
      (assemble (map (lambda (frame index)
                       (report "capturing frame ~a of ~a: ~a ~a"
                               (1+ index)
                               (length frames)
                               (car frame)
                               (or (cadr frame) "top"))
                       (capture-frame browser
                                      (car frame) index
                                      (frame-top offsets
                                                 (cadr frame)))) frames
                     (iota (length frames))))
      (report "wrote ~a (~a frames, ~a bytes)" gif-path
              (length frames)
              (size-of gif-path))
      (run "rm" "-rf" work-dir))))

;; ===== what to do =====

(define (main arguments)
  (let ((what (if (null? arguments) "all"
                  (car arguments))))
    (case (string->symbol what)
      ((logo)
       (render-logo))
      ((gif)
       (render-gif))
      ((all)
       (render-logo)
       (render-gif))
      (else (fail! "say `logo' or `gif'; got ~s" what)))))

(main (cdr (command-line)))
