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

;; Navigation: breadcrumbs, tabs, rails, the sidebar and the fly-out.

(define-module (showcase navigation)
  #:use-module (hygguile hygguile)
  #:export (navigation-section nav-extras-section fly-out-section))

(define navigation-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         ,(breadcrumbs #:items (list (a "Home"
                                        #:href "#")
                                     (a "Library"
                                        #:href "#")
                                     (em "Components")))
         ,(navbar (list (nav-link "Home"
                                  #:href "#"
                                  #:active #t)
                        (nav-link "Docs"
                                  #:href "#")
                        (nav-link "About"
                                  #:href "#"))
                  #:brand "Hygguile"
                  #:sticky #f)
         ,(tabs #:id "showcase-tabs"
                #:tab-items (list (tab #:id "overview"
                                       #:label "Overview"
                                       #:content (list (p
                                                        "Tabs are pure CSS: no JavaScript required.")))
                                  (tab #:id "details"
                                       #:label "Details"
                                       #:content (list (p
                                                        "Selecting a label reveals the matching panel.")))))
         ,(pagination #:current 2
                      #:total 4
                      #:base-url "#page-"))))

(define nav-extras-section
  `((div (@ (class ,(mk-class '(grid grid-cols-1 lg:grid-cols-3 gap-6
                                     items-start))))
         ,(sidebar #:brand "Workspace"
                   #:current "#nav-extras"
                   #:sections (list (cons "Work"
                                          (list (cons "Overview" "#nav-extras")
                                                (cons "Reports" "#tables")))
                                    (cons "Account"
                                          (list (cons "Settings" "#settings")))))
         ,(nav-rail #:label "Primary"
                    #:current "#nav-extras"
                    #:items (list (list 'house "Home" "#")
                                  (list 'table "Tables" "#tables")
                                  (list 'gear "Settings" "#settings")))
         (div (@ (class ,(mk-class '(flex flex-col gap-4))))
              ,(wizard #:steps (list (cons "Cart" "#")
                                     (cons "Address" "#")
                                     (cons "Payment" "#"))
                       #:current 2)))))

(define some-fly-out-items
  (list (fly-out-item (list (h4 "First item"
                                #:weight '(font-light))))
        (fly-out-item (list (h4 "Third item"
                                #:weight '(font-light))))
        (fly-out-submenu #:button-content (list (h4 "IN VINO VERITAS"
                                                    #:weight '(font-light)))
                         #:items (list (fly-out-item (list (h4 "I"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "II"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "III"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "IV"
                                                               #:weight '(font-light))))
                                       (fly-out-item (list (h4 "V"
                                                               #:weight '(font-light))))))
        (fly-out-submenu #:button-content (list (h4 "λ Scheme"
                                                    #:weight '(font-light)))
                         #:items (list (fly-out-item (list (a "Guile"
                                                            #:href
                                                            "https://www.gnu.org/s/guile/"
                                                            #:weight '(font-light))))
                                       (fly-out-item (list (a "Chicken"
                                                            #:href
                                                            "https://call-cc.org/"
                                                            #:weight '(font-light))))))

        ))

(define (fly-out-section)
  (list (fly-out #:items some-fly-out-items)))
