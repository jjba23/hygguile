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

(define-module (hygguile components notification)
  #:use-module (hygguile abstraction)
  #:export (notification-tray))

;; A polite live region: injected notifications are announced by
;; assistive technology without interrupting whatever the user is
;; doing, and the default empty value keeps the region silent until
;; something is actually added.
(define notification-tray
  `((div (@ (id notification-tray)
            (role status)
            (aria-live polite)
            (aria-atomic "true")
            (class ,(mk-class '(fixed z-32 top-8 right-8)))) "")))

