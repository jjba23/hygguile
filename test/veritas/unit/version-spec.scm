;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The version, and the copies of it that cannot read the module.
;;
;; The interesting assertion here is the last one: the version is written by
;; hand once, in src/hygguile/version.scm, and the README -- which cannot read
;; a Scheme module -- carries a copy that `maak sync-version' rewrites. A copy
;; that disagrees with the module is a release a reader would be misled by, so
;; the suite refuses it rather than leaving it to whoever remembers.

(define-module (veritas unit version-spec)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:use-module (veritas veritas)
  #:use-module (hygguile version)
  #:export (spec))

(define version-number-pattern
  "([0-9]+\\.[0-9]+\\.[0-9]+)")

(define (readme-copies)
  "Return every version the README claims hygguile is at."
  (let ((readme (call-with-input-file "README.org"
                  get-string-all)))
    (map (lambda (found)
           (match:substring found 1))
         (list-matches (string-append "hygguile " version-number-pattern)
                       readme))))

(define version-suite
  (suite "Version test suite"
         (test "the version the module reports"
               (assert-equal #:name "the version is three numbers"
                             #:got (and (string-match (string-append "^"
                                                       version-number-pattern
                                                       "$") hygguile-version)
                                        #t)
                             #:expect #t)
               (assert-equal #:name
                             "the banner names the framework and the version"
                             #:got (hygguile-version-string)
                             #:expect (format #f "hygguile ~a"
                                              hygguile-version))
               (assert-equal #:name
                             "the license is the MIT license"
                             #:got hygguile-license
                             #:expect "MIT")
               (assert-equal #:name "the homepage is the showcase"
                             #:got hygguile-homepage
                             #:expect "https://hygguile.jointhefreeworld.org"))

         (test "printing the version"
               (assert-equal #:name
                "print-version writes the banner, the license and the homepage, one per line"
                #:got (with-output-to-string print-version)
                #:expect (string-append (hygguile-version-string)
                          "\nLicense: MIT\n"
                          "Homepage: https://hygguile.jointhefreeworld.org
")))

         (test "the copies"
               (assert-equal #:name
                             "the README carries the version at least once"
                             #:got (pair? (readme-copies))
                             #:expect #t)
               (assert-equal #:name
                "every version the README names is the version the module names"
                #:got (delete-duplicates (readme-copies))
                #:expect (list hygguile-version)))))

(define (spec)
  (veritas-run version-suite))
