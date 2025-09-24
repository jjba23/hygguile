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

(define-module (hygguile components fly-out)
  #:use-module (hygguile abstraction)
  #:export (fly-out fly-out-submenu fly-out-item))

(define* (fly-out #:key (aria-label "Fly-out selection menu")
                  (nav-class '(py-4))
                  (top-ul-class '(flex flex-row flex-wrap justify-center
                                       items-start gap-4))
                  (items '()))
  `((nav (@ (class ,(mk-class nav-class))
            (aria-label ,aria-label))
         (ul (@ (class ,(mk-class top-ul-class)))
             ,items))))

(define* (fly-out-submenu #:key (li-class '(flyout-menu-container
                                            cursor-pointer px-4 py-4))
                          (button-class '(flyout-submenu-button cursor-pointer
                                          flex text-onyx-300
                                          dark:text-stone-300))
                          (ul-class '(flyout-submenu z-10
                                                     absolute
                                                     bg-stone-100/75
                                                     dark:bg-onyx-700/75
                                                     rounded-xl
                                                     shadow-md
                                                     my-2
                                                     px-4
                                                     py-1))
                          (button-content `((h4 "Menu")))
                          (items '()))
  `((li (@ (class ,(mk-class li-class)))
        (button (@ (class ,(mk-class button-class))
                   (aria-haspopup true)
                   (aria-expanded false)
                   (aria-controls submenu))
                ,button-content)
        (ul (@ (hidden "")
               (class ,(mk-class ul-class)))
            ,items))))

(define* (fly-out-item content
                       #:key (li-class '(px-4 py-4)))
  `((li (@ (class ,(mk-class li-class)))
        ,content)))
