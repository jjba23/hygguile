;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;;; Commentary:
;;
;; The single place the framework's version is written by hand, together with
;; the handful of facts it reports about itself.  A page prints them where a
;; reader looks for the version of the thing that rendered it -- the showcase
;; does, in its footer -- and `maak version' prints them in a terminal.
;;
;; The copies that cannot read a Scheme module -- the README, the pages already
;; deployed somewhere -- are rewritten from this file by the `sync-version'
;; task in maak.scm, which reads this file rather than the library it happens to
;; be running under.  A release is therefore one edit here, not a search of the
;; tree, and the suite fails while any copy disagrees with this one.

;;; Code:

(define-module (hygguile version)
  ;; Deliberately not declarative.  A declarative module lets Guile inline its
  ;; bindings into the modules that use them, and the version is the one value
  ;; here that changes between builds: inlined, it would be baked into a
  ;; consumer's compiled file while that file's source stayed the same, and a
  ;; bump would leave a page compiled against one version printing another.
  #:declarative? #f
  #:export (hygguile-version hygguile-homepage hygguile-license
                             hygguile-version-string print-version))

(define hygguile-version
  "2.7.6")

(define hygguile-homepage
  "https://hygguile.jointhefreeworld.org")

(define hygguile-license
  "MIT")

(define (hygguile-version-string)
  "Return the one-line version banner for hygguile, as `maak version' prints it."
  (format #f "hygguile ~a" hygguile-version))

(define* (print-version #:optional (port (current-output-port)))
  "Print the version banner, the license and the homepage of hygguile to PORT.

The three lines are written to be read as they are: the banner first, then the
license and the homepage, each on its own line and each naming what it is.

@table @var
@item port
The port to print to, @code{(current-output-port)} by default.
@end table

@example
(print-version)
;; hygguile 2.6.0
;; License: MIT
;; Homepage: https://hygguile.jointhefreeworld.org
@end example"
  (format port "~a\n~a\n~a\n"
          (hygguile-version-string)
          (format #f "License: ~a" hygguile-license)
          (format #f "Homepage: ~a" hygguile-homepage)))
