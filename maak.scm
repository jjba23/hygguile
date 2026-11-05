;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (maak)
  #:declarative? #t
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (maak maak)
  #:use-module ((ice-9 rdelim) #:select (read-line))
  ;; The container and git helpers are imported under prefixes because the
  ;; tasks below are named the way maak exposes them on the command
  ;; line -- `maak container-build' -- and a task may not shadow the
  ;; helper it calls.
  #:use-module ((maak container) #:prefix ct:)
  #:use-module ((maak git) #:prefix git:))

;; ====== Maak constants ======

;; The URL for the CSS style-sheet used to style API documentation.
(define api-docs-css-url
  "https://jointhefreeworld.org/static/css/jointhefreeworld.css")

;; The TCP port on which the development web server will listen.
(define http-port
  50054)

;; The absolute path to the directory where the main project files will be deployed.
(define deploy-dir
  "/srv/http/hygguile.jointhefreeworld.org")

;; The absolute path to the directory where the API documentation will be deployed.
(define deploy-api-docs-dir
  "/srv/http/jointhefreeworld.org")

;; The name of the project, represented as a symbol.
(define project-name
  'hygguile)

(define hot-reload-file-types
  '(scm js))

;; ====== The version ======
;;
;; The version is written by hand once, in src/hygguile/version.scm, and
;; everything else follows it: `maak version' prints it, a page prints it in its
;; own footer, and the README -- which cannot read a Scheme module -- carries a
;; copy that `sync-version' rewrites from the file before it cuts the release.
;;
;; The module is resolved when a task asks for it rather than imported at the
;; top of this file. A top-level import would stop this whole Maak file loading
;; on a machine where ./src is not on the load path, and take every other task
;; down with it, and the version a running library knows is its own rather than
;; the checkout's.

(define version-source
  "src/hygguile/version.scm")

;; Each site is a file and a regular expression matching one place in it where
;; the version is written, with the version itself as the first group. Only that
;; group is replaced, so the wording around it stays the file's business rather
;; than this list's.
(define version-sites
  '(("README.org"
     . "hygguile ([0-9]+\\.[0-9]+\\.[0-9]+)")))

(define (version)
  "Print the hygguile version, its license and its homepage.

The module is resolved when the task runs rather than imported at the top of
this file. A top-level import would stop this whole Maak file loading on a
machine where ./src is not on the load path, and take every other task down with
it, and the version a running library knows is its own rather than the
checkout's."
  (unless (file-exists? version-source)
    (task-error "no ~a here" #:args (list version-source)
                #:hint "Run this task from the root of a hygguile checkout."))
  (add-to-load-path "src")
  ((module-ref (resolve-module '(hygguile version))
               'print-version)))

(define* (sync-version #:optional (directory "."))
  "Write the version into every file that cannot read it from the module, then
commit and tag the release.

The version is written by hand once, in src/hygguile/version.scm, which is what
`maak version' prints and what a page prints in its footer. The README cannot
read a Scheme module, so it carries a copy, and this task rewrites that copy
from the file.

A release is then the whole ritual in one command: the copies are made to agree,
everything tracked that changed is committed as `chore: Release vX.Y.Z', and
that commit is tagged `vX.Y.Z'. The commit is `git commit -am', so it takes
every tracked change in the tree rather than only the ones this task made;
commit anything unrelated first if it should not ride along. A version whose tag
already exists is refused rather than committed again or retagged, and a tree
with nothing left to commit is tagged where it stands.

DIRECTORY is the checkout to work in, the current directory by default. The
version is read from the file there rather than from the library, so the task
writes the checkout's version whether it is run by this checkout or by an
installed maak that knows nothing of hygguile.

Each copy is found by a regular expression over the file and only the version
inside the match is replaced, so everything around it -- the README's wording,
its sample output -- is left exactly as it was."
  (define repo
    (if (string=? directory ".")
        "."
        directory))

  (define (path file)
    (if (string=? directory ".")
        file
        (~ "~a/~a" directory file)))

  (define (read-text file)
    (let ((full (path file)))
      (if (file-exists? full)
          (call-with-input-file full get-string-all)
          (task-error "sync-version: no ~a in ~a"
                      #:args (list file directory)
                      #:hint "Name the checkout's root as DIRECTORY."))))

  (define (write-text file text)
    (call-with-output-file (path file)
      (lambda (port)
        (display text port))))

  (define (current-version)
    (let ((found (string-match
                  "hygguile-version[ \t\n]+\"([0-9]+\\.[0-9]+\\.[0-9]+)\""
                  (read-text version-source))))
      (unless found
        (task-error "sync-version: ~a does not define hygguile-version as a version"
                    #:args (list (path version-source))))
      (match:substring found 1)))

  (define (sites-of file)
    (filter (lambda (site)
              (string=? (car site) file))
            version-sites))

  (define (named-files)
    (fold (lambda (site files)
            (if (member (car site) files)
                files
                (append files (list (car site)))))
          '()
          version-sites))

  (define (rewrite text pattern version)
    "Return TEXT with the version PATTERN names replaced by VERSION."
    (regexp-substitute/global
     #f pattern text 'pre
     (lambda (match)
       (regexp-substitute/global #f "[0-9]+\\.[0-9]+\\.[0-9]+"
                                 (match:substring match 0)
                                 'pre version 'post))
     'post))

  (define (sync-file file version)
    "Write VERSION into FILE, and return whether it had to."
    (let* ((text (read-text file))
           (rewritten (fold (lambda (site text)
                              (rewrite text (cdr site) version))
                            text
                            (sites-of file))))
      (if (string=? text rewritten)
          #f
          (begin (write-text file rewritten)
                 #t))))

  (define (sync-copies! version)
    "Write VERSION into every copy, and return the files that changed."
    (let ((changed '()))
      (for-each (lambda (file)
                  (when (sync-file file version)
                    (set! changed (append changed (list file)))))
                (named-files))
      changed))

  ;; ---- The commit and the tag --------------------------------------------
  ;;
  ;; The library wrappers take `#:directory', so a release of another checkout
  ;; commits there rather than wherever maak was started from.

  (define (checkout?)
    "Return whether DIRECTORY is a git checkout."
    (file-exists? (path ".git")))

  (define (tag-exists? tag)
    "Return whether TAG is already a tag of the checkout."
    (member tag (git:git-tags #:directory repo)))

  (define (changes-to-commit?)
    "Return whether anything tracked differs from the last commit."
    (not (string=? ""
                   (string-trim-both
                    (git:git-output (list "diff" "--name-only" "HEAD")
                                    #:directory repo)))))

  (define (commit-release version)
    "Commit every tracked change as the release VERSION, and return the message."
    (let ((message (~ "chore: Release v~a" version)))
      (unless (git:git (list "commit" "--all" "-m" message)
                       #:directory repo #:allow-failure? #t)
        (task-error "sync-version: git commit failed, so nothing was tagged"))
      message))

  (define (tag-release version)
    "Tag the current commit as the release VERSION, and return the tag."
    (let ((tag (~ "v~a" version)))
      (unless (git:git (list "tag" tag)
                       #:directory repo #:allow-failure? #t)
        (task-error "sync-version: `git tag ~a' failed; the release was committed, but not tagged"
                    #:args (list tag)))
      tag))

  (let* ((version (current-version))
         (tag (~ "v~a" version)))
    (unless (checkout?)
      (task-error "sync-version: ~a is not a git checkout, so there is nothing to commit or tag"
                  #:args (list repo)))
    (when (tag-exists? tag)
      (task-error "sync-version: ~a is already released as ~a; bump ~a first"
                  #:args (list version tag version-source)))
    (let ((changed (sync-copies! version)))
      (if (null? changed)
          (log-info "Every file that names the version already says ~a."
                    version)
          (for-each (lambda (file)
                      (log-info "Wrote ~a into ~a."
                                version file))
                    changed))
      (if (changes-to-commit?)
          (let ((message (commit-release version)))
            (tag-release version)
            (log-info "Committed `~a' and tagged ~a."
                      message tag))
          (begin (tag-release version)
                 (log-info "Nothing to commit; tagged ~a at the current commit."
                           tag))))))

;; ====== Maak tasks ======

(define (compile)
  "Compile all project source code."
  (time-machine-manifest-shell (list "guild" "compile" "-L" "./src" "-W3"
                                     "./src/**/*.scm")))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  (run (list "find" "." "-maxdepth" "8" "-name" "*.scm" "-type" "f"
             "-exec" "guix" "style" "-f" "{}" ";")
       #:verbose? #t))

(define (repl)
  "Development REPL."
  (manifest-shell (list "guile" "-L" "./src"
                        "-c" "'((@ (ares server) run-nrepl-server))'")))

(define (embed)
  "Embed static assets into Scheme code."
  (manifest-shell (list "guile" "-L" "./src" "./scripts/embedder.scm")))

(define (olive-css)
  "Get latest version of Olive CSS."
  (curl-download
   "https://codeberg.org/jjba23/olive-css/raw/branch/trunk/resources/css/olive.min.css"
   #:output "resources/css/olive.min.css"))

(define (docs)
  "Generate technical API documentation for Hygguile."
  (delete-file-recursively "doc")
  ;; Two calls rather than one `&&' chain, so the second only runs where the
  ;; first succeeded and fails where it happens.
  (manifest-shell (list "documenta" "api" (~ "./src/~a" project-name)))
  (manifest-shell (list "texi2any" "-v" "--html"
                        (~ "--css-ref=~a" api-docs-css-url)
                        "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  "Generate documentation for the project and publish to web directory."
  (fmt)
  (build)
  (embed)
  (docs)
  (delete-file-recursively deploy-dir)
  (mv "dist" deploy-dir)
  (remkdir-p (~ "~a/api-docs/~a" deploy-api-docs-dir project-name))
  (mv "doc/api-dist/*"
      (~ "~a/api-docs/~a" deploy-api-docs-dir project-name)
      #:expand? #t)
  (delete-file-recursively "doc"))

(define (example)
  "Render the onboarding example page to dist/example.html.

`build' renders this page too, next to the showcase; reach for this one
when you are working on the example and want to re-render just it."
  (mkdir-p "dist")
  (cp "resources/css/olive.min.css" "dist/olive.min.css" #:force? #t #:verbose? #t)
  (manifest-shell (list "guile" "-L" "./src" "examples/minimal.scm")))

(define (example-server)
  "Serve the server-driven sortable table example on port 8095.

The other half of the sorting contract: a real server that reads the
table's two query parameters back and re-renders the rows. Run it from
the project root
so the example can find resources/css/olive.min.css."
  (manifest-shell (list "guile" "-L" "./src" "examples/sortable-table.scm")))

(define (test)
  "Run project's tests."
  (manifest-shell (list "guile" "-L" "./src" "-L" "./test"
                        "-c" "'((@ (veritas runner) run-tests))'")))

(define (kill-server)
  "Kill any running HTTP server in the same port."
  ;; `|| true': nothing running is the usual answer, not a failure.
  (run (list "fuser" "-k" (~ "~a/tcp" http-port))
       #:allow-failure? #t))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  (kill-server)
  (run (list "darkhttpd" "./dist" "--port" (~ "~a" http-port))))

(define (render-pages)
  "Render every page of the site into dist/."
  (remkdir-p "dist")
  (cp "resources/css/olive.min.css" "dist/olive.min.css" #:force? #t #:verbose? #t)
  ;; the showcase's sections live in (showcase ...) modules beside its entry
  ;; script, so the repository root joins the load path
  (manifest-shell (list "guile" "-L" "./src" "-L" "." "showcase.scm"))
  (manifest-shell (list "guile" "-L" "./src" "examples/minimal.scm")))

(define (contrast)
  "Check every text pair on the built pages against WCAG AA, in every theme.

Renders nothing: it reads dist/ as it is, opens each page in a headless
Chrome or Chromium on $PATH ($CHROME_BIN points at one kept elsewhere),
and exits non-zero as soon as a pair is below the contrast the audit asks
of it. A shade that makes a sentence unreadable is a bug like any other,
which is why `build' runs this."
  (manifest-shell (list "guile" "./scripts/contrast-gate.scm")))

(define (build)
  "Build production release of the project, and gate its contrast."
  (render-pages)
  (contrast))

;; ====== The README's images ======
;;
;; Both are generated rather than drawn, by one script that knows how to find a
;; browser: the logo is the hand-drawn SVG rendered to a PNG, and the demo is the
;; *deployed* showcase captured in both themes. They run outside the development
;; shell because they need tools it does not carry -- ImageMagick and gifsicle
;; for the demo -- and neither is part of `build': a README that lags a commit is
;; not an emergency, and a build that needs a network is not a build.

(define (logo)
  "Render assets/hygguile-logo.svg to the PNG beside it."
  (run (list "guile" "./scripts/readme-assets.scm" "logo")))

(define (gif)
  "Capture the deployed showcase into assets/readme/hygguile-demo.gif."
  (run (list "guile" "./scripts/readme-assets.scm" "gif")))

(define (readme-assets)
  "Regenerate both of the README's images."
  (logo)
  (gif))

(define (test-build-and-serve)
  (test)
  (build)
  (embed)
  (docs)
  (serve))

(define (build-and-serve)
  (build)
  (docs)
  (serve))

(define (hot-reload)
  "Hot-reloading developer's setup."
  (embed)
  (fmt)
  ;; One token per word, so the glob `--ignore=...' reaches watchexec as it
  ;; was written rather than as whatever the shell matched.
  (manifest-shell (list "watchexec"
                        "--clear"
                        "--exts" (~ "~a"
                                    (string-join (map symbol->string
                                                      hot-reload-file-types)
                                                 ","))
                        "--ignore=src/hygguile/embed/*.scm"
                        "--on-busy-update=restart"
                        "--shell" "bash"
                        "--watch" "."
                        "--"
                        "maak" "test-build-and-serve")))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (default)
  "Default task to be run, list available tasks."
  (list-tasks))

(define (validate)
  "Format, compile and test."
  (fmt)
  (compile)
  (test))

;; ====== Agent skills ======

;; AGENTS.md is generated, never edited by hand.  The section has two halves:
;; the data below, which is this project's, and the task itself, which is not.
;; Another repository copies the whole section and replaces the data - the
;; header, the pinned skills (repository, commit, path, licence) and the
;; practices - and `maak agents' writes its own AGENTS.md.  Regeneration is
;; deterministic: the same pins and the same text produce the same file, byte
;; for byte, and it needs nothing but curl.  The skill URLs assume GitHub, so a
;; skill hosted elsewhere needs a URL of its own.

(define ponytail-commit
  "96608e078b2d5ea607c5c3b8b5a54d1c1fba6846")

(define tdd-commit
  "22f0b463e7a5e579904dd6211a520321035526f7")

;; Name, repository, commit, the path the repository keeps the skill at and the
;; licence.  A skill arrives whole: trimming it means scanning for headings, and
;; such a scan cannot tell a heading from a `##' line inside a code fence.
(define agent-skills
  (list (list "ponytail"
              "DietrichGebert/ponytail"
              ponytail-commit
              "skills/ponytail/SKILL.md"
              "MIT")
        (list "test-driven-development"
              "obra/superpowers"
              tdd-commit
              "skills/test-driven-development/SKILL.md"
              "MIT")))

(define agent-skills-dir
  "reports/agent-skills")

(define agents-header
  "# AGENTS.md

Generated by `maak agents` from the pinned skills and the practices in
`maak.scm`; edit that task, never this file.  The pins and the text are the whole
input, so regenerating gives the same document.  The repository's own rules win
over general advice, and the narrowest rule here wins over the broadest.
")

;; Practices this project keeps.  They are short on purpose: a rule a reader
;; checks in a second is a rule that gets followed.  The pinned skills are the
;; long form of the same habits.
(define agent-practices
  (list
   "## Documentation

- Every user-visible change reaches the documentation: the page that owns the
  feature, the manual page for a flag or an environment variable, and the
  release notes under the unreleased heading.
- Keep the table of contents in step with the headings.  A section with no entry
  is a section nobody finds.
- The guide is Org: one `*` heading per page, `**` for sections, `#+TITLE` and
  `#+EMAIL` at the top, a `CUSTOM_ID` on anything linked from elsewhere, and
  `file:` links between pages.
- Explain why and when, never what: the code already says what.  A docstring's
  first line works as a summary on its own.
- Spell an identifier the way the code spells it - the exact name, not a
  description of it.
- An example must run as written, copied from a real invocation.
- No promises about the future and no changelog in the guide; history lives in
  the release notes.
"
   "## Security

- No secrets in the tree.  Tokens, keys and passwords arrive through the
  environment, and no recipe, workflow or example embeds one.
- Validate at the edge: anything from a file, a report, a path or a subprocess
  is untrusted until it has been checked.
- Never build a shell string out of data.  Tasks pass argument lists, and Guile
  calls `(system \"program\" \"arg\")` or `open-pipe*`, never a command
  assembled with `string-append`.
- Do not `eval` or `read` input you did not write; parse with `(json)` or a
  reader built for the format.
- Escape what leaves the process: a name that came from input is escaped when
  it is written to XML, HTML or a data file.
- Fail closed.  A file that cannot be read is an error, not an empty result.
- Input never chooses the path of a written file; writes stay inside the
  directory reserved for them.
- A dependency is a security decision: it must be needed, MIT compatible and
  pinned.
- Report a vulnerability privately, not in a public issue.
"
   "## Performance

- Measure first.  A before and after belongs in the benchmark, and a speedup
  claimed without a number is not a speedup.
- Prefer not doing the work: cache it, skip it, batch it, or delete the call,
  before making the call faster.
- Then the algorithm, then the data structure (hash table, vector), then the
  micro-optimisation.  In that order, for that reason.
- Guile specifics: keep module resolution and long `assoc` chains out of loops,
  use `#:declarative?` modules and compiled `.go` files at startup, and reach
  for `statprof` instead of guessing where the time goes.
- A shortcut that buys speed costs clarity; it gets a measurement and a
  `shortcut:` comment saying what it costs and when to revisit it.
- Coverage instrumentation is slow by design: iterate without it, and measure
  before finishing.
"
   "## Architecture decisions

- A decision that is expensive to reverse gets a short record: the context, the
  decision, the consequences, and the alternatives that lost.  A small decision
  belongs in the commit body instead.
- Two paragraphs beat a design document; record the choice while it is still a
  choice, not after it has become a fact.
- An accepted record is not rewritten.  Supersede it with a new one and link the
  two directions.
- The record lives next to its subject: the documentation for anything a user
  would notice, the release notes for the release-level result.
- Changes to the public API, a file format, the pipeline or the licence get this
  treatment at a minimum in the commit body.
"
   "## Semantic versioning

- The project follows SemVer 2.0.0 for its public API: the exported functions,
  the CLI flags and environment variables, and the shape of its file formats.
- A breaking change bumps MAJOR, a new feature MINOR, a fix PATCH.  A new export
  is MINOR; removing or changing one is MAJOR.
- One version string, named everywhere it appears: the source, the build
  recipes, the manual page and the packaging.
- A release is a dated release-notes section, an annotated `vX.Y.Z` tag on the
  release commit, and a packaging checksum updated afterwards from the published
  archive.
"
   "## Conventional commits

- `type(scope): summary`, imperative, lower case, no full stop, about seventy
  characters.
- Types in use: `feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `build`, `ci`,
  `chore`.  A `!` after the type or a `BREAKING CHANGE:` footer marks a MAJOR
  change, and says what breaks.
- The subject says what changed.  The body says why, and what was rejected.
- One logical change per commit: a refactor and a fix travel apart, so either
  can be reverted alone.
- Run the full validation task before committing, and never commit a red suite
  without saying so in the message.
- Reference the issue in the footer - `Closes #12` - not in the subject.
"
   "## Functional programming and immutability

- Pure functions in the core, effects at the edges.  Whatever touches the file
  system or the clock sits at the edge; the core does not.
- Prefer `let` and new values to `set!`.  Build results with `map`, `filter`,
  `fold` and named `let`, not with index loops that push into a list.
- A record is a value: construct a new one instead of mutating a shared one, and
  pass configuration as arguments or parameters rather than as globals.
- Handle an exception at the boundary: catch it there, turn it into a result
  record, and let the caller decide what it means.
- A function that both computes and prints is two functions.
- Temporary effects - a changed directory, a bound environment variable - go
  through `dynamic-wind`.
- Prefer the expression style: `if` and `cond` that return a value, not a branch
  that assigns one.
"
   "## Do not reinvent the wheel

- Guile's standard library first: `(ice-9 ...)` for the runtime, `(srfi srfi-1)`
  for lists, `(srfi srfi-9)` for records, `(srfi srfi-13)` for strings, `(json)`
  for JSON.  The project already depends on all of them.
- Then this codebase: read the existing modules before writing a helper, and use
  the one that is nearly right instead of adding a second one.
- A new dependency needs a reason the standard library cannot meet, a licence
  the project can carry, and a paragraph in the commit body.
- Prefer deleting a special case to writing code that handles it.
- The best diff removes lines and keeps the behaviour; the second best is a
  small diff that is obvious a year later.
"))

(define (slurp path)
  "Return the whole of @var{path} as a string."
  (call-with-input-file path
    (lambda (port)
      (let loop ((lines '())
                 (line (read-line port)))
        (if (eof-object? line)
            (string-concatenate-reverse lines)
            (loop (cons (string-append line "\n") lines)
                  (read-line port)))))))

(define (fetch-skill name repository commit path)
  "Download one skill pinned at @var{commit}, into the reports tree.

  Returns the skill's text."
  (let ((target (~ "~a/~a.md" agent-skills-dir name))
        (url (~ "https://raw.githubusercontent.com/~a/~a/~a"
                repository commit path)))
    (run (list "curl" "--fail" "--silent" "--show-error" "--location"
               "--output" target url)
         #:verbose? #t)
    (slurp target)))

(define (agents)
  "Regenerate AGENTS.md from the pinned skills and the practices."
  (run (list "mkdir" "-p" agent-skills-dir))
  ;; Every download happens before the file is opened, so a fetch that fails
  ;; leaves the previous AGENTS.md in place rather than a half-written one.
  (let ((skills (map (lambda (skill)
                       (append skill
                               (list (fetch-skill (list-ref skill 0)
                                                  (list-ref skill 1)
                                                  (list-ref skill 2)
                                                  (list-ref skill 3)))))
                     agent-skills)))
    (call-with-output-file "AGENTS.md"
      (lambda (port)
        (display agents-header port)
        (for-each (lambda (skill)
                    (format port
                            "~%## ~a~%~%`~a` at `~a`, `~a`, ~a licensed.~%~%"
                            (list-ref skill 0)
                            (list-ref skill 1)
                            (list-ref skill 2)
                            (list-ref skill 3)
                            (list-ref skill 4))
                    (display (list-ref skill 5) port))
                  skills)
        (for-each (lambda (practice)
                    (newline port)
                    (display practice port))
                  agent-practices)))))
;; ====== Container tasks ======

(define (container-build)
  "Build the container image for hygguile."
  (ct:container-build "." #:tag "hygguile:latest" #:verbose? #t))

(define (container-run)
  "Run the container image for hygguile."
  (ct:container-run "hygguile" #:interactive? #t #:tty? #t #:verbose? #t))

(define (package-docker)
  "Build the container image for hygguile."
  (container-build))
