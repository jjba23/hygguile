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

(define-module (hygguile components button-test)
  #:use-module ((srfi srfi-64)
                #:hide (define-test))
  #:use-module (hygguile components button)
  #:use-module (hygguile test-utils))

(define-test test-buttons
             (test-group "hygguile buttons"
                         (test-equal
                          "danger-submit-button returns a valid button"
                          (car (danger-submit-button "hygguile"))
                          'button)

                         (test-equal "submit-button returns a valid button"
                                     (car (submit-button "hygguile"))
                                     'button)

                         (test-equal "icon-button returns a valid button"
                                     (car (icon-button #:icon 'lightbulb
                                                       #:content "hygguile"))
                                     'button)

                         (test-equal "button returns a valid button"
                                     (car (button "hygguile"))
                                     'button)))

