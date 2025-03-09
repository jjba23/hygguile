;; hygguile - cozy and professional user-interfaces for everyone

;; Copyright (C) 2025 Josep Bigorra (jjba23) <jjbigorra@gmail.com>

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

(use-modules (ice-9 rdelim))
(use-modules (srfi srfi-64))

(define (run-test file)
  (display "Running: ")
  (display file)
  (newline)
  (primitive-load file))

(define (run-all-tests)
  (for-each run-test
            '("src/hygguile/abstraction.scm"
              "src/hygguile/components/icon.scm"
              "src/hygguile/components/button.scm"
              "src/hygguile/components/input.scm"
              )))

(run-all-tests)
