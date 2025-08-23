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

;; ====== Maak file constants ======

;; The absolute URL for the CSS style-sheet used to style API documentation.
(define api-docs-css-url
  "https://jointhefreeworld.org/static-assets/api-docs/css/style.css")

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

;; A comma-separated string of file extensions to monitor for the hot-reloading feature.
(define hot-reload-file-types
  "scm,css,js")

;; ====== Maak file tasks ======

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")))

(define (repl)
  "Development REPL."
  (manifest-shell '("guile -L ./src"
                    "-c '((@ (ares server) run-nrepl-server))'")))

(define (docs)
  "Generate technical API documentation for Hygguile."
  (delete-file-recursively "doc")
  (manifest-shell (list "documenta api ./src/hygguile && "
                        (~ "texi2any -v --html --css-ref=~a" api-docs-css-url)
                        "./doc/api/index.texi"))
  (mv "./index" "./doc/api-dist"))

(define (deploy)
  "Generate documentation for the project and publish to web directory."
  (build)
  (docs)
  (delete-file-recursively deploy-dir)
  (mv "dist" deploy-dir)
  (remkdir-p "~a/api-docs/~a" deploy-api-docs-dir project-name)
  (mv "doc/api-dist/*" "~a/api-docs/~a" deploy-api-docs-dir project-name)
  (delete-file-recursively "doc"))

(define (test)
  "Run project's tests."
  (manifest-shell (list "guile -L ./src -L ./test"
                        (~ "-c '((@ (~a test-runners) run-project-tests))'"
                           project-name))))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  ($ (list (~ "darkhttpd ./dist --port ~a" http-port))))

(define (build)
  "Build production release of the project."
  (remkdir-p "dist")
  (manifest-shell (list "guile -L ./src showcase.scm")))

(define (dev)
  "Developer's setup."
  (docs)
  (build)
  (serve))

(define (default)
  "Default task to be run, list available tasks."
  ($ '("maak --list")))

