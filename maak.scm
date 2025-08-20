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

(define api-docs-css-url
  "https://jointhefreeworld.org/static-assets/api-docs/css/style.css")

(define http-port
  50054)

(define deploy-dir
  "/srv/http/hygguile.jointhefreeworld.org")

(define deploy-api-docs-dir
  "/srv/http/jointhefreeworld.org")

(define project-name
  'hygguile)

(define hot-reload-file-types
  "scm,css,js")

;; ====== Maak file tasks ======

(define (fmt)
  "Format Scheme source code files according to the Guix style guide."
  ($ '("find . -maxdepth 8 -name '*.scm'" "-type f -exec guix style -f {} \\;")))

(define (repl)
  "Development REPL."
  ($ '("guix shell -m manifest.scm --" "guile -L ./src"
       "-c '((@ (ares server) run-nrepl-server))'")))

(define (docs)
  "Generate technical API documentation for Maak."
  ($ '("rm -rfv doc"))
  ($ (list "guix shell -m manifest.scm --"
           (format #f "documenta api ./src/~a &&" project-name)
           (format #f "texi2any -v --html --css-ref=~a" api-docs-css-url)
           "./doc/api/index.texi")
     #:verbose #t)
  ($ '("mv ./index ./doc/api-dist")))

(define (deploy)
  "Generate documentation for the project and publish to web directory."
  (build)
  (docs)
  ($ (list (format #f "rm -rfv ~a" deploy-dir)
           (format #f "cp -rfv dist ~a" deploy-dir)
           (format #f "rm -rfv ~a/api-docs/~a" deploy-api-docs-dir
                   project-name)
           (format #f "mkdir -p ~a/api-docs/~a" deploy-api-docs-dir
                   project-name)
           (format #f "mv doc/api-dist/* ~a/api-docs/~a" deploy-api-docs-dir
                   project-name))
     #:join " && ")
  ($ '("rm -rfv doc")))

(define (test)
  "Run project's tests."
  ($ (list "guix shell -m manifest.scm --" "guile -L ./src -L ./test"
           (format #f "-c '((@ (~a test-runners) run-project-tests))'"
                   project-name))))

(define (serve)
  "Run HTTP server serving the rendered production result of running."
  ($ (list (format #f "darkhttpd ./dist --port ~a" http-port))))

(define (build)
  "Build production release of the project."
  ($ '("rm -rfv dist && mkdir -p dist"))
  ($ '("guix shell -m manifest.scm --" "guile -L ./src showcase.scm")))

(define (dev)
  "Developer's hot-reloading on file changes."
  ($ (list (format #f "watchexec -i 'dist/**'" "-r -e ~a --"
                   hot-reload-file-types) "'maak build && maak serve'")))


