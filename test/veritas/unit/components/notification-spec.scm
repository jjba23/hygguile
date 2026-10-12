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

;; You should have received a copy of the GNU Lesser General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.

(define-module (veritas unit components notification-spec)
  #:use-module (veritas veritas)
  #:use-module (ice-9 regex)
  #:use-module (hygguile components notification)
  #:use-module (hygguile js)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  "Serialize an SXML fragment to the HTML a server would send."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define card-html
  (render (notification-card)))

(define script
  (render (show-notifications-from-url-js)))

(define (classes-of html)
  "The class list of the first element in HTML, or #f."
  (let ((m (string-match "class=\"([^\"]*)\"" html)))
    (and m
         (match:substring m 1))))

(define (has-class? classes name)
  "True when a space-separated class string contains exactly NAME."
  (and classes
       (member name
               (string-split classes #\space)) #t))

(define (attr-of node name)
  "The value of attribute NAME on an SXML element, or #f."
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (contains? text needle)
  "True when NEEDLE appears in TEXT."
  (and (string-contains text needle) #t))

(define (count-of text needle)
  "How many times NEEDLE appears in TEXT."
  (let loop
    ((at 0)
     (n 0))
    (let ((hit (string-contains text needle at)))
      (if hit
          (loop (+ hit
                   (string-length needle))
                (1+ n)) n))))

(define notification-suite
  (suite "Notifications"
         (test "hygguile notification tray and card"
               (assert-equal #:name "the tray is a place, not a surface"
                             #:got (let ((classes (classes-of (render
                                                               notification-tray))))
                                     (list (car (car notification-tray))
                                           (has-class? classes "hg-frost")
                                           (has-class? classes
                                                       "bg-stone-100/75")))
                             #:expect (list 'div #f #f))
               (assert-equal #:name "and holds nothing until one arrives"
                #:got (render notification-tray)
                #:expect
                "<div id=\"notification-tray\" role=\"status\" aria-live=\"polite\" aria-atomic=\"true\" class=\"fixed right-8 top-8 z-32\"></div>")
               (assert-equal #:name "it is a polite live region"
                             #:got (let ((tray (car notification-tray)))
                                     (list (attr-of tray
                                                    'role)
                                           (attr-of tray
                                                    'aria-live)
                                           (attr-of tray
                                                    'aria-atomic)))
                             #:expect (list 'status
                                            'polite "true"))
               (assert-equal #:name "the card is glass"
                             #:got (let ((classes (classes-of card-html)))
                                     (list (has-class? classes "hg-frost")
                                           (has-class? classes
                                                       "bg-stone-300/90")
                                           (has-class? classes
                                                       "dark:bg-onyx-700/75")))
                             #:expect (list #t #t #t))
               (assert-equal #:name "and keeps the shape it always had"
                             #:got (let ((classes (classes-of card-html)))
                                     (list (has-class? classes "rounded-xl")
                                           (has-class? classes "border-2")
                                           (has-class? classes "py-5")
                                           (has-class? classes "px-5")
                                           (has-class? classes "max-w-prose")
                                           (has-class? classes "flex")
                                           (has-class? classes "flex-col")
                                           (has-class? classes "gap-4")))
                             #:expect (list #t
                                            #t
                                            #t
                                            #t
                                            #t
                                            #t
                                            #t
                                            #t))
               (assert-equal #:name "the card holds still: nothing bounces it"
                             #:got (let ((classes (classes-of card-html)))
                                     (list (has-class? classes
                                                       "animate-bounce")
                                           (has-class? classes "animate-pulse")
                                           (has-class? classes "animate-spin")))
                             #:expect (list #f #f #f))
               (assert-equal #:name "it does not wear the panel's own dress"
                             #:got (let ((classes (classes-of card-html)))
                                     (list (has-class? classes "rounded-3xl")
                                           (has-class? classes "shadow-lg")
                                           (has-class? classes "p-6")))
                             #:expect (list #f #f #f))
               (assert-equal #:name
                             "and wears the quiet hairline every pane wears"
                             #:got (let ((classes (classes-of card-html)))
                                     (list (has-class? classes
                                                       "border-stone-500/25")
                                           (has-class? classes
                                            "dark:border-onyx-100/25")
                                           ;; a full-strength outline is
                                           ;; the noisy thing this avoids
                                           (has-class? classes
                                                       "border-stone-500")
                                           (has-class? classes
                                                       "dark:border-onyx-100")))
                             #:expect (list #t #t #f #f))
               (assert-equal #:name
                "the title and the body wait empty for the script"
                #:got (list (count-of card-html "id=\"notification-title\"")
                            (count-of card-html "id=\"notification-body\"")
                            (contains? card-html "\"></h4>")
                            (contains? card-html
                                       "<p id=\"notification-body\"></p>"))
                #:expect (list 1 1 #t #t))
               (assert-equal #:name
                "the tray's places are filled with text, not markup"
                #:got (list (contains? script
                             "notificationTitleNode.textContent = notificationTitle")
                            (contains? script
                             "notificationBodyNode.textContent = notificationBody")
                            ;; no query parameter is ever
                            ;; interpolated into the page
                            (count-of script "${"))
                #:expect (list #t #t 0))
               (assert-equal #:name
                             "the card the script puts there is the panel's"
                             #:got (list (contains? script "hg-frost")
                                         (contains? script
                                          "getElementById('notification-title')")
                                         (contains? script
                                          "const notificationTray = document.getElementById('notification-tray')"))
                             #:expect (list #t #t #t)))))

(define (spec)
  (veritas-run notification-suite))
