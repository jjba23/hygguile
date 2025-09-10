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

;; ====== Maak tasks ======

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

(define (docs)
  "Generate technical API documentation for Hygguile."
  (delete-file-recursively "doc")
  (manifest-shell (list (~ "documenta api ./src/~a && " project-name)
                        (~ "texi2any -v --html --css-ref=~a" api-docs-css-url)
                        "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  "Generate documentation for the project and publish to web directory."
  (embed)
  (fmt)
  (build)
  (docs)
  (delete-file-recursively deploy-dir)
  (mv "dist" deploy-dir)
  (remkdir-p (~ "~a/api-docs/~a" deploy-api-docs-dir project-name))
  (mv "doc/api-dist/*"
      (~ "~a/api-docs/~a" deploy-api-docs-dir project-name))
  (delete-file-recursively "doc"))

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

(define (build)
  "Build production release of the project."
  (remkdir-p "dist")
  (manifest-shell (list "guile -L ./src showcase.scm")))

(define (test-build-and-serve)
  (test)
  (build)
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

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (dev)
  "Developer's setup."
  (hot-reload))

(define (hr)
  "Alias to hot-reloading."
  (hot-reload))

(define (default)
  "Default task to be run, list available tasks."
  ($ '("maak --list")))

