;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; ===== the contrast gate =====
;;
;; "cozy and professional" is a promise about every shade in the palette,
;; and a palette is precisely the kind of thing a refactor changes by
;; accident: one shade lighter, one opacity lower, and a paragraph that
;; was readable is not. This script makes the promise checkable. It opens
;; each built page in every theme in a headless browser, runs
;; `scripts/contrast-audit.js' on every rendering, and exits non-zero the
;; moment a text pair falls below the WCAG AA contrast the audit asks of
;; it.
;;
;;   guile ./scripts/contrast-gate.scm    # `maak contrast', part of `maak build'
;;
;; Two things it needs: `dist/' to have been rendered, and a Chrome or
;; Chromium binary on $PATH ($CHROME_BIN points at one kept elsewhere).

(use-modules (ice-9 format)
             (ice-9 string-fun)
             (ice-9 textual-ports)
             (srfi srfi-1)
             (srfi srfi-13))

;; ===== what gets checked =====

;; Every page a build produces, audited in every theme below.
(define pages
  '(("showcase" . "dist/index.html") ("example" . "dist/example.html")))

(define themes
  '("light" "dark"))

(define audit-js
  "scripts/contrast-audit.js")

(define page-js
  "scripts/contrast-page.js")

;; The id of the text/plain block the in-page half leaves its findings in.
(define block-id
  "hygguile-contrast-gate")

;; The same browser under its usual names; $CHROME_BIN wins over all of them.
(define browser-names
  '("google-chrome-stable" "google-chrome" "chromium" "chromium-browser"))

(define chrome-flags
  '("--disable-gpu" "--hide-scrollbars"
    "--no-first-run"
    "--no-default-browser-check"
    "--disable-extensions"
    ;; Containers and Guix builds often cannot start Chrome's sandbox, and
    ;; the gate only ever opens files it wrote itself a moment earlier.
    "--no-sandbox"))

;; Long enough for both themes and their colour transitions to settle.
(define virtual-time-budget-ms
  6000)

;; A browser that never settles must not hang a build.
(define browser-timeout-s
  120)

(define viewport
  "1280,900")

;; ===== the shell and the inputs =====

(define (report format-string . args)
  (apply format
         (current-output-port) format-string args)
  (newline))

(define (fail! format-string . args)
  "Print a reason for giving up and exit non-zero."
  (apply format
         (current-error-port)
         (string-append "\ncontrast gate: " format-string "\n") args)
  (exit 1))

(define (sh str)
  "Quote @var{str} as a single word for the shell."
  (string-append "'"
                 (string-join (string-split str #\') "'\\''") "'"))

(define (run-silently command)
  "Run @var{command}, swallowing any failure.  Used for tidying up."
  (catch #t
         (lambda ()
           (system command))
         (lambda args
           #f)))

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

(define (browser)
  "The browser to drive, or #f when there is none to drive."
  (let ((wanted (getenv "CHROME_BIN")))
    (if (and wanted
             (not (string-null? wanted)))
        (and (file-exists? wanted)
             (access? wanted X_OK) wanted)
        (or-map in-path browser-names))))

(define (read-text path)
  (get-string-all (open-input-file path)))

;; ===== building the page the browser will audit =====

(define (audit-source)
  "The audit, as the JavaScript expression a function can return.

The file is a single immediately-invoked arrow function, so its closing
semicolon has to go before the whole thing can be that expression -- which
is what lets the gate run the audit once per theme instead of once per
page load."
  (let* ((source (string-trim-right (read-text audit-js)))
         (source (if (string-suffix? ";" source)
                     (string-drop-right source 1) source)))
    (string-trim-right source)))

(define (injection)
  "What the gate adds to a page: a stylesheet that stills it, then the audit
and its driver.

The stylesheet is not optional. The gate reaches the page through
`--virtual-time-budget', which fast-forwards timers but not the clock a
colour transition runs on, so a theme change would be measured mid-fade
and a settled, readable pair would be reported as its half-faded self.
Turning transitions and animations off measures the colours a reader
eventually sees, and turns an accessory that pulses (and would therefore be
skipped whenever it was caught at zero opacity) into an ordinary one."
  (let ((audit (audit-source))
        (driver (read-text page-js)))
    (when (or (string-contains audit "</script")
              (string-contains driver "</script"))
      (fail!
       "refusing to inject a script containing \"</script\": the browser's parser would end the tag early"))
    (format #f
     "<style>*, *::before, *::after { transition: none !important; animation: none !important; }</style>
<script>window.__hygguileContrastAudit = function () {
  return (
~a
  );
};</script>
<script>~a</script>
"
     audit driver)))

(define (instrument html)
  "The page with the gate's scripts appended to its body, or #f when it has
no body to append them to."
  (let ((at (string-contains html "</body>")))
    (and at
         (string-append (substring html 0 at)
                        (injection)
                        (substring html at)))))

(define (dump-page browser work name)
  "Open @var{name} in @var{work} in the browser and return its DOM, or #f
when the browser failed.

The browser's own chatter is kept in the work directory instead of on the
build's output, where it would drown the verdict."
  (let* ((out (format #f "~a/dump.html" work))
         (log (format #f "~a/browser.log" work))
         (profile (format #f "~a/profile" work))
         (url (format #f "file://~a/~a" work name))
         (command (format #f
                   "timeout ~a ~a --headless ~a --user-data-dir=~a --virtual-time-budget=~a --window-size=~a --dump-dom ~a > ~a 2> ~a"
                   browser-timeout-s
                   (sh browser)
                   (string-join chrome-flags " ")
                   (sh profile)
                   virtual-time-budget-ms
                   viewport
                   (sh url)
                   (sh out)
                   (sh log))))
    (and (zero? (system command))
         (file-exists? out)
         (read-text out))))

;; ===== reading what came back =====

(define (extract-block dom)
  "The findings block out of @var{dom}, or #f when the page never reported.

A missing block is never a pass: it means the page's JavaScript did not
run, and an audit that did not happen cannot clear anything."
  (let* ((at (string-contains dom
                              (format #f "id=\"~a\"" block-id))))
    (and at
         (let* ((open-end (string-index dom #\> at))
                (from (and open-end
                           (1+ open-end)))
                (end (and from
                          (string-contains dom "</script>" from))))
           (and end
                (substring dom from end))))))

(define (records block)
  "The tab-separated records in @var{block}, each as a list of fields."
  (filter-map (lambda (line)
                (let ((fields (string-split (string-trim-both line) #\tab)))
                  (and (pair? fields)
                       (not (string-null? (car fields))) fields)))
              (string-split block #\newline)))

(define (field fields index)
  (and (> (length fields) index)
       (list-ref fields index)))

(define (number-field fields index)
  (let ((raw (field fields index)))
    (and raw
         (string->number raw))))

(define (split-by-theme records)
  "Group the records into (theme-record . its-following-records) pairs."
  (let lp
    ((rest records)
     (current #f)
     (collected '())
     (out '()))
    (cond
      ((null? rest)
       (reverse (if current
                    (cons (cons current
                                (reverse collected)) out) out)))
      ((equal? (car (car rest)) "theme")
       (lp (cdr rest)
           (car rest)
           '()
           (if current
               (cons (cons current
                           (reverse collected)) out) out)))
      (else (lp (cdr rest) current
                (cons (car rest) collected) out)))))

;; ===== the verdict =====

(define (check-theme name asked-fields extras)
  "Print the verdict for one theme and return the failures it found.

@var{asked-fields} is the theme record; @var{extras} are the group records
that follow it, worst pair first, and the closest passing pair."
  (let ((asked (field asked-fields 1))
        (seen (field asked-fields 2))
        (checked (number-field asked-fields 3))
        (failing (number-field asked-fields 4))
        (groups (filter (lambda (r)
                          (equal? (car r) "group")) extras))
        (near (find (lambda (r)
                      (equal? (car r) "near")) extras)))
    (cond
      ((not (equal? asked seen))
       (report "    ~a~10t  the page reported the ~a theme" asked seen)
       (list (format #f
                     "~a (~a): asked for the ~a theme, the page reported ~a"
                     name
                     asked
                     asked
                     seen)))
      ((or (not checked)
           (zero? checked))
       (report "    ~a~10t  nothing was measured" asked)
       (list (format #f "~a (~a): the audit measured no text at all" name
                     asked)))
      ((and failing
            (positive? failing))
       (report "    ~a~10t  ~a pairs checked, ~a below WCAG AA" asked checked
               failing)
       (for-each (lambda (group)
                   (report
                    "        ~a | ~a  ~a:1 (needs ~a)  ~a on ~a  ~ax  \"~a\""
                    (field group 1)
                    (field group 2)
                    (field group 3)
                    (field group 4)
                    (field group 6)
                    (field group 7)
                    (field group 5)
                    (field group 8))) groups)
       (list (format #f
                     "~a (~a): ~a of ~a pairs below WCAG AA"
                     name
                     asked
                     failing
                     checked)))
      (else (report "    ~a~10t  ~a pairs checked, all at or above WCAG AA~a"
                    asked checked
                    (if near
                        (format #f "  (tightest ~a:1, needs ~a)"
                                (field near 4)
                                (field near 5)) ""))
            '()))))

(define (theme-name pair)
  "The theme a page's report covers."
  (field (car pair) 1))

(define (report-verdicts name by-theme)
  "The failures found by the themes a page did report on."
  (append-map (lambda (pair)
                (check-theme name
                             (car pair)
                             (cdr pair))) by-theme))

(define (report-errors name errors)
  "A theme whose audit threw is a failure with a reason, not a silence."
  (append-map (lambda (error)
                (let ((theme (field error 1))
                      (message (field error 2)))
                  (report "    ~a~10t  the audit threw: ~a" theme message)
                  (list (format #f "~a (~a): the audit threw: ~a" name theme
                                message)))) errors))

(define (report-missing name missing)
  "A theme the page never reported on at all: name it and fail."
  (if (null? missing)
      '()
      (begin
        (report "    no report for: ~a"
                (string-join missing ", "))
        (list (format #f "~a: no report for the ~a theme" name
                      (string-join missing ", "))))))

(define (verdicts name block)
  "Everything the findings block says about one page, as failures."
  (let* ((all (records block))
         (by-theme (split-by-theme all))
         (errors (filter (lambda (record)
                           (equal? (car record) "error")) all))
         ;; a theme whose audit threw reports an error record instead of a
         ;; theme record, so it is absent from by-theme but not unreported
         (reported (append (map (lambda (error)
                                  (field error 1)) errors)
                           (map theme-name by-theme)))
         (missing (lset-difference string=? themes reported)))
    (append (report-errors name errors)
            (report-missing name missing)
            (report-verdicts name by-theme))))

(define (check-page browser work name path)
  "Audit one page in every theme and return the failures it found."
  (report "")
  (report "  ~a  (~a)" name path)
  (cond
    ((not (file-exists? path))
     (report "    not rendered")
     (list (format #f "~a: ~a does not exist; render it first (maak build)"
                   name path)))
    (else (let* ((instrumented (instrument (read-text path)))
                 (file (format #f ".contrast-~a.html" name)))
            (cond
              ((not instrumented)
               (report "    nothing to inject into")
               (list (format #f "~a: ~a has no </body> for the audit" name
                             path)))
              (else (call-with-output-file (format #f "~a/~a" work file)
                      (lambda (port)
                        (display instrumented port)))
                    (let ((dom (dump-page browser work file)))
                      (cond
                        ((not dom)
                         (report "    the browser produced no DOM")
                         (report-note work)
                         (list (format #f
                                "~a: the browser produced no DOM for ~a" name
                                path)))
                        (else (let ((block (extract-block dom)))
                                (if block
                                    (verdicts name block)
                                    (begin
                                      (report "    the page reported nothing")
                                      (list (format #f
                                             "~a: the page ran no audit (no report block in the DOM)"
                                             name))))))))))))))
(define (report-note work)
  "Show the tail of the browser's log, which is all the diagnosis there is
when a browser fails to render at all."
  (let* ((log (format #f "~a/browser.log" work))
         (lines (if (file-exists? log)
                    (filter (lambda (line)
                              (not (string-null? (string-trim line))))
                            (string-split (string-trim-both (read-text log))
                                          #\newline))
                    '())))
    (for-each (lambda (line)
                (report "      | ~a" line))
              (take-right lines
                          (min 20
                               (length lines))))))

;; ===== the gate =====

(define (check-inputs)
  "Refuse to run against files that are not there."
  (for-each (lambda (path)
              (if (not (file-exists? path))
                  (fail! "~a is missing; run this from the project root" path)))
            (cons audit-js
                  (cons page-js
                        '()))))

(define (gate)
  "Audit every page in every theme and return the number of failures."
  (check-inputs)
  (let* ((driver (browser))
         (work (mkdtemp "/tmp/hygguile-contrast-XXXXXX"))
         (failures '()))
    (if (not driver)
        (begin
          (run-silently (format #f "rm -rf ~a"
                                (sh work)))
          (fail!
           "no Chrome or Chromium found; install one, or set CHROME_BIN to point at it")))
    (report "contrast gate: ~a pages x ~a themes, WCAG AA"
            (length pages)
            (length themes))
    (report "  browser: ~a" driver)
    ;; the browser works on a copy, so a build running beside this one
    ;; cannot swap a page out from under an audit halfway through
    (if (not (zero? (system (format #f "cp -r dist/. ~a"
                                    (sh work)))))
        (begin
          (run-silently (format #f "rm -rf ~a"
                                (sh work)))
          (fail!
           "dist/ could not be copied for auditing; has it been rendered?")))
    (for-each (lambda (page)
                (set! failures
                      (append failures
                              (check-page driver work
                                          (car page)
                                          (cdr page))))) pages)
    (run-silently (format #f "rm -rf ~a"
                          (sh work)))
    (report "")
    (if (null? failures)
        (report "contrast gate: every text pair checked is readable.")
        (begin
          (report "contrast gate: ~a ~a, so the build stops here."
                  (length failures)
                  (if (null? (cdr failures)) "finding" "findings"))
          (report
           "  Raise the ink, lower the surface, or fix what is reported above.")))
    (length failures)))

(exit (if (zero? (gate)) 0 1))
