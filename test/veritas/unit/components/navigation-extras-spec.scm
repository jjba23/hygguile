;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components navigation-extras-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components navigation)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (has? html needle)
  (and (string-contains html needle) #t))

(define navigation-extras-suite
  (suite "Navigation extras"
         (test "sidebars"
               (assert-equal #:name "sidebar is a navigation region"
                             #:got (caar (sidebar #:sections '()))
                             #:expect 'nav)
               (assert-equal #:name "a sidebar link can mark the current page"
                             #:got (has? (render (sidebar-link "Home"
                                                              #:href "/"
                                                              #:active #t))
                                         "aria-current=\"page\"")
                             #:expect #t)
               (assert-equal #:name "a sidebar section renders its heading"
                             #:got (has? (render (sidebar #:sections
                                                          (list (cons "Work"
                                                                      (list (cons "Home"
                                                                                  "/"))))))
                                         "Work")
                             #:expect #t))
         (test "rail and wizard"
               (assert-equal #:name "nav rail is a navigation region"
                             #:got (caar (nav-rail #:items '()))
                             #:expect 'nav)
               (assert-equal #:name "a rail item carries its label for assistive tech"
                             #:got (has? (render (nav-rail #:items
                                                           (list (list 'house "Home" "/"))))
                                         "sr-only")
                             #:expect #t)
               (assert-equal #:name "wizard is ordered"
                             #:got (has? (render (wizard #:steps '("A" "B")
                                                        #:current 2))
                                         "<ol")
                             #:expect #t)
               (assert-equal #:name "the current wizard step is announced"
                             #:got (has? (render (wizard #:steps '("A" "B")
                                                        #:current 2))
                                         "aria-current=\"step\"")
                             #:expect #t))
         (test "scroll spy"
               (assert-equal #:name "section nav opts into the scroll spy"
                             #:got (has? (render (section-nav '((a . "A"))))
                                         "data-hg-scroll-spy")
                             #:expect #t)
               (assert-equal #:name "the scroll spy can be switched off"
                             #:got (has? (render (section-nav '((a . "A"))
                                                              #:scroll-spy? #f))
                                         "data-hg-scroll-spy")
                             #:expect #f))))

(define (spec)
  (veritas-run navigation-extras-suite))
