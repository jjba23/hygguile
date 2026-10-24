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

(define-module (maak)
  #:declarative? #t
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (maak maak))

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
    (error (format #f
                   "maak: no ~a here; run this task from the root of a hygguile checkout"
                   version-source)))
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
        (string-append directory "/" file)))

  (define (read-text file)
    (let ((full (path file)))
      (if (file-exists? full)
          (call-with-input-file full get-string-all)
          (error (format #f
                         "sync-version: no ~a in ~a; name the checkout's root"
                         file directory)))))

  (define (write-text file text)
    (call-with-output-file (path file)
      (lambda (port)
        (display text port))))

  (define (current-version)
    (let ((found (string-match
                  "hygguile-version[ \t\n]+\"([0-9]+\\.[0-9]+\\.[0-9]+)\""
                  (read-text version-source))))
      (unless found
        (error (format #f
                       "sync-version: ~a does not define hygguile-version as a version"
                       (path version-source))))
      (match:substring found 1)))

  (define (sites-of file)
    (filter (lambda (site)
              (string=? (car site)
                        file)) version-sites))

  (define (named-files)
    (fold (lambda (site files)
            (if (member (car site)
                        files)
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
  ;; git runs as a program with its arguments, never through a shell, and is
  ;; pointed at DIRECTORY with `-C', so a release of another checkout commits
  ;; there and not wherever maak was started from.

  (define (git . arguments)
    "Run git in the checkout, and return the exit code it ended with.

`system*' answers with the wait status rather than the exit code, so a command
that exited 1 reads as 256 and one that could not be started reads as #f; both
are turned into the number a shell would report here, 127 when git never ran."
    (let ((status (apply system*
                         "git" "-C" repo arguments)))
      (or (and status
               (status:exit-val status))
          127)))

  (define (checkout?)
    "Return whether DIRECTORY is a git checkout."
    (file-exists? (path ".git")))

  (define (tag-exists? tag)
    "Return whether TAG is already a tag of the checkout."
    (zero? (git "rev-parse" "--verify" "--quiet"
                (string-append "refs/tags/" tag))))

  (define (changes-to-commit?)
    "Return whether anything tracked differs from the last commit."
    (case (git "diff" "--quiet" "HEAD")
      ((0) #f)
      ((1) #t)
      (else (error (format #f
                           "sync-version: git could not compare ~a with a commit; is it a checkout with one?"
                           repo)))))

  (define (commit-release version)
    "Commit every tracked change as the release VERSION, and return the message."
    (let ((message (format #f
                           "chore: Release v~a"
                           version)))
      (unless (zero? (git "commit" "-am" message))
        (error "sync-version: git commit failed, so nothing was tagged"))
      message))

  (define (tag-release version)
    "Tag the current commit as the release VERSION, and return the tag."
    (let ((tag (string-append "v" version)))
      (unless (zero? (git "tag" tag))
        (error (format #f
                       "sync-version: `git tag ~a' failed; the release was committed, but not tagged"
                       tag)))
      tag))

  (let* ((version (current-version))
         (tag (string-append "v" version)))
    (unless (checkout?)
      (error (format #f
                     "sync-version: ~a is not a git checkout, so there is nothing to commit or tag"
                     repo)))
    (when (tag-exists? tag)
      (error (format #f
                     "sync-version: ~a is already released as ~a; bump ~a first"
                     version tag version-source)))
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
  (time-machine-manifest-shell (list "guild compile -L ./src" "-W3"
                                     "./src/**/*.scm")))

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")))

(define (repl)
  "Development REPL."
  (manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (embed)
  "Embed static assets into Scheme code."
  (manifest-shell '("guile -L ./src" "./scripts/embedder.scm")))

(define (olive-css)
  "Get latest version of Olive CSS."
  ($ '("curl --output resources/css/olive.min.css"
       "\"https://codeberg.org/jjba23/olive-css/raw/branch/trunk/resources/css/olive.min.css\"")))

(define (docs)
  "Generate technical API documentation for Hygguile."
  (delete-file-recursively "doc")
  (manifest-shell (list (~ "documenta api ./src/~a && " project-name)
                        (~ "texi2any -v --html --css-ref=~a" api-docs-css-url)
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
      (~ "~a/api-docs/~a" deploy-api-docs-dir project-name))
  (delete-file-recursively "doc"))

(define (example)
  "Render the onboarding example page to dist/example.html.

`build' renders this page too, next to the showcase; reach for this one
when you are working on the example and want to re-render just it."
  ($ '("mkdir -pv dist"))
  ($ '("cp -rfv resources/css/olive.min.css dist/olive.min.css"))
  (manifest-shell (list "guile -L ./src examples/minimal.scm")))

(define (example-server)
  "Serve the server-driven sortable table example on port 8095.

The other half of the sorting contract: a real server that reads the
table's two query parameters back and re-renders the rows. Run it from
the project root
so the example can find resources/css/olive.min.css."
  (manifest-shell (list "guile -L ./src examples/sortable-table.scm")))

(define (test)
  "Run project's tests."
  (manifest-shell (list "guile -L ./src -L ./test"
                        "-c '((@ (veritas runner) run-tests))'")))

(define (kill-server)
  "Kill any running HTTP server in the same port."
  ($ (list (~ "fuser -k ~a/tcp || true" http-port))))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  (kill-server)
  ($ (list (~ "darkhttpd ./dist --port ~a" http-port))))

(define (render-pages)
  "Render every page of the site into dist/."
  (remkdir-p "dist")
  ($ '("cp -rfv resources/css/olive.min.css dist/olive.min.css"))
  ;; the showcase's sections live in (showcase ...) modules beside its entry
  ;; script, so the repository root joins the load path
  (manifest-shell (list "guile -L ./src -L . showcase.scm"))
  (manifest-shell (list "guile -L ./src examples/minimal.scm")))

(define (contrast)
  "Check every text pair on the built pages against WCAG AA, in every theme.

Renders nothing: it reads dist/ as it is, opens each page in a headless
Chrome or Chromium on $PATH ($CHROME_BIN points at one kept elsewhere),
and exits non-zero as soon as a pair is below the contrast the audit asks
of it. A shade that makes a sentence unreadable is a bug like any other,
which is why `build' runs this."
  (manifest-shell (list "guile ./scripts/contrast-gate.scm")))

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
  ($ '("guile ./scripts/readme-assets.scm logo")))

(define (gif)
  "Capture the deployed showcase into assets/readme/hygguile-demo.gif."
  ($ '("guile ./scripts/readme-assets.scm gif")))

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
  (manifest-shell (list "watchexec"
                        "--clear"
                        (~ "--exts ~a"
                           (string-join (map symbol->string
                                             hot-reload-file-types) ","))
                        "--ignore=src/hygguile/embed/*.scm"
                        "--on-busy-update=restart"
                        "--shell bash"
                        "--watch . --"
                        "maak test-build-and-serve")))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (default)
  "Default task to be run, list available tasks."
  ($ '("maak --list")))

(define (validate)
  "Format, compile and test."
  (fmt)
  (compile)
  (test))

;; ====== Container tasks ======

(define (container-build)
  "Build the container image for hygguile."
  ($ '("podman build -t hygguile .")))

(define (container-run)
  "Run the container image for hygguile."
  ($ '("podman run --rm -it hygguile:latest")))

(define (package-docker)
  "Build the container image for hygguile."
  (container-build))
