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

(define-module (veritas unit components glass-spec)
  #:use-module (veritas veritas)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile components glass)
  #:use-module (hygguile embed css)
  #:use-module (hygguile sxml)
  #:export (spec))

(define (render node)
  "Serialize an SXML fragment to the HTML a server would send."
  (call-with-output-string (lambda (port)
                             (sxml->xml node port))))

(define (surface panel)
  "The element of a glass panel the classes live on."
  (car panel))

(define (layers panel)
  "The children of the surface, in the order they are painted."
  (cddr (surface panel)))

(define (two-layers? panel)
  "True when the panel has both a clip layer and a content layer."
  (let ((children (layers panel)))
    (and (pair? children)
         (pair? (cdr children)))))

(define (clip-layer panel)
  "The rounded layer the decorations are clipped in, or #f."
  (and (two-layers? panel)
       (car (layers panel))))

(define (content-layer panel)
  "The layer holding the panel's content, or #f."
  (let ((children (layers panel)))
    (and (pair? children)
         (if (pair? (cdr children))
             (cadr children)
             (car children)))))

(define (decorations panel)
  "The washes and the accent, as painted inside the clip layer."
  (cddr (clip-layer panel)))

(define (wash-of panel)
  "The first wash of a panel that has washes: the first disc."
  (car (decorations panel)))

(define (accent-of panel)
  "The caller's accent node, as painted inside the clip layer."
  (let loop
    ((nodes (decorations panel)))
    (cond
      ((null? nodes)
       #f)
      ((contains? (class-of (car nodes)) "hg-accent")
       (car nodes))
      (else (loop (cdr nodes))))))

(define (class-of node)
  "The class list of a rendered element, or #f."
  (let* ((root (if (symbol? (car node)) node
                   (car node)))
         (hit (assq 'class
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define (class-has? node token)
  "Return #t when the rendered @var{token} appears in the node's class list."
  (let ((classes (class-of node)))
    (and (string? classes)
         (string-contains classes token) #t)))

(define (attr-value node name)
  "The value of attribute NAME on a rendered element, or #f."
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

(define (extras-stylesheet)
  "The framework's companion stylesheet, as it ships inside the library."
  (car (filter string?
               (cdr (car (hygguile-extras-css))))))

(define (yellow-wash)
  (glass-wash '(bg-naples-yellow-500/75 w-96 h-96 left-4 top-4)
              #:delay -6))

(define (blue-wash)
  (glass-wash '(bg-jeans-blue-500/50 w-72 h-72 right-4 bottom-4)
              #:delay -14))

(define plain
  (glass-panel "Hi"))

;; The silhouette the framework's own chrome wears: a bar spanning the
;; viewport, which is why it brings its own tint and shape and leaves the
;; panel nothing but the frost.
(define bar-panel
  (glass-panel "Hi"
               #:tag 'header
               #:tint '(bg-stone-300/75 dark:bg-onyx-700/75)
               #:position '(sticky top-0)
               #:rounding '()
               #:border '()
               #:shadow '()
               #:padding '()
               #:classes '(w-full shadow-md)))

(define washed
  (glass-panel "Hi"
               #:washes (list (yellow-wash))))

(define still-panel
  (glass-panel "CONTENT"
               #:washes (list (yellow-wash)
                              (blue-wash))))

(define drifting-panel
  (glass-panel "CONTENT"
               #:washes (list (yellow-wash)
                              (blue-wash))
               #:drift? #t))

(define glass-suite
  (suite "Glass panels"
         (test "hygguile glass panels"
               (assert-equal #:name "glass-panel renders a <div> surface"
                             #:got (caar (glass-panel '()))
                             #:expect 'div)
               (assert-equal #:name "the surface is a translucent tint"
                             #:got (class-has? (surface plain)
                                               "bg-stone-100/75")
                             #:expect #t)
               (assert-equal #:name "and asks for its own dark-theme tint"
                             #:got (class-has? (surface plain)
                                               "dark:bg-onyx-900/75")
                             #:expect #t)
               (assert-equal #:name "what is behind the glass is blurred"
                             #:got (class-has? (surface plain) "hg-frost")
                             #:expect #t)
               (assert-equal #:name
                "the frost is a layer, not a backdrop filter on the surface: browsers paint that squarely"
                #:got (class-has? (surface plain) "backdrop-blur")
                #:expect #f)
               (assert-equal #:name
                "the frost's strength is the stylesheet's until a panel says otherwise"
                #:got (list (attr-value (surface plain)
                                        'style)
                            (contains? (render plain) "--hg-frost-blur"))
                #:expect (list #f #f))
               (assert-equal #:name
                "a panel can say how strong its frost is, in rems"
                #:got (let ((panel (glass-panel "Hi"
                                                #:frost 3)))
                        (list (attr-value (surface panel)
                                          'style)
                              (count-of (render panel) "style=")))
                #:expect (list "--hg-frost-blur: 3rem" 1))
               (assert-equal #:name
                "and in any CSS length, beside a style the caller brought"
                #:got (let ((panel (glass-panel "Hi"
                                                #:frost "2.5rem"
                                                #:attributes '((style
                                                                "color: red")))))
                        (list (attr-value (surface panel)
                                          'style)
                              (count-of (render panel) "style=")))
                #:expect (list "color: red; --hg-frost-blur: 2.5rem" 1))
               (assert-equal #:name
                             "the surface is bordered, rounded and raised"
                             #:got (list (class-has? (surface plain)
                                                     "border-2")
                                         (class-has? (surface plain)
                                                     "rounded-3xl")
                                         (class-has? (surface plain)
                                                     "shadow-lg"))
                             #:expect (list #t #t #t))
               (assert-equal #:name
                "the surface itself never clips: a child is always free to leave its corner"
                #:got (list (class-has? (surface washed) "overflow-hidden")
                            (class-has? (surface plain) "overflow-hidden")
                            (class-has? (surface (glass-panel "Hi"
                                                              #:clip? #t))
                                        "overflow-hidden"))
                #:expect (list #f #f #f))
               (assert-equal #:name
                "the washes are clipped in a rounded layer of their own"
                #:got (let ((layer (clip-layer washed)))
                        (list (class-has? layer "overflow-hidden")
                              (class-has? layer "rounded-3xl")
                              (class-has? layer "absolute")
                              (class-has? layer "inset-0")))
                #:expect (list #t #t #t #t))
               (assert-equal #:name
                             "and that layer wears the caller's rounding"
                             #:got (let ((layer (clip-layer (glass-panel "Hi"
                                                                         #:rounding '
                                                                         (rounded-xl)
                                                                         #:washes
                                                                         (list
                                                                          (yellow-wash))))))
                                     (list (class-has? layer "rounded-xl")
                                           (class-has? layer "rounded-3xl")))
                             #:expect (list #t #f))
               (assert-equal #:name
                "the layer the washes ride in names the clip that actually holds them"
                #:got (class-has? (clip-layer washed) "hg-glass-layer")
                #:expect #t)
               (assert-equal #:name
                "and the sheet clips that layer to a radius, the only clip a blur obeys"
                #:got (let ((css (extras-stylesheet)))
                        (list (contains? css
                                         (string-append ".hg-glass-layer {\n"
                                          "  clip-path: inset(0 round var(--hg-glass-clip, 1.28rem));"))
                              (contains? css
                               "clip-path: inset(0 round var(--hg-glass-clip,")))
                #:expect (list #t #t))
               (assert-equal #:name
                "every rounding the framework's own panes wear has a clip to match"
                #:got (map (lambda (token)
                             (contains? (extras-stylesheet)
                                        (string-append
                                         ".hg-glass-layer[class~=\"" token
                                         "\"]")))
                           '("rounded-none" "rounded-xl" "rounded-2xl"
                             "rounded-3xl" "rounded-4xl" "rounded-full"))
                #:expect (list #t
                               #t
                               #t
                               #t
                               #t
                               #t))
               (assert-equal #:name
                "a plain panel clips nothing, so a child can escape"
                #:got (class-has? (surface plain) "overflow-hidden")
                #:expect #f)
               (assert-equal #:name
                             "the padding defaults to a comfortable one"
                             #:got (list (class-has? (surface plain) "p-6")
                                         (class-has? (surface plain) "sm:p-8"))
                             #:expect (list #t #t))
               (assert-equal #:name "and can be replaced"
                             #:got (let ((root (surface (glass-panel "Hi"
                                                                     #:padding '
                                                                     (p-2)))))
                                     (list (class-has? root "p-2")
                                           (class-has? root "p-6")))
                             #:expect (list #t #f))
               (assert-equal #:name "extra classes reach the surface"
                             #:got (class-has? (surface (glass-panel "Hi"
                                                                     #:classes '
                                                                     (mt-8)))
                                               "mt-8")
                             #:expect #t)
               (assert-equal #:name
                "a caller's colour replaces the surface's own, not both"
                #:got (let ((root (surface (glass-panel "Hi"
                                                        #:classes (list 'bg-stone-300/75)))))
                        (list (class-has? root "bg-stone-300/75")
                              (class-has? root "bg-stone-100/75")))
                #:expect (list #t #f))
               (assert-equal #:name
                             "with no washes there is nothing decorative"
                             #:got (count-of (render plain) "aria-hidden")
                             #:expect 0)
               (assert-equal #:name
                "the content sits in a layer above the washes, and that layer is not a clip"
                #:got (let ((layer (content-layer still-panel)))
                        (list (class-has? layer "relative")
                              (class-has? layer "overflow-hidden")
                              (equal? (cddr layer)
                                      '("CONTENT"))))
                #:expect (list #t #f #t))
               (assert-equal #:name
                "a washed panel keeps its washes in with their layer, not by clipping its content"
                #:got (let ((panel still-panel))
                        (list (class-has? (clip-layer panel) "overflow-hidden")
                              (class-has? (content-layer panel)
                                          "overflow-hidden")))
                #:expect (list #t #f))
               (assert-equal #:name
                             "and above the clip layer rather than inside it"
                             #:got (< (string-contains (render still-panel)
                                                       "blur-3xl")
                                      (string-contains (render still-panel)
                                                       "CONTENT"))
                             #:expect #t)
               (assert-equal #:name
                "a panel with nothing to sit above adds no layer"
                #:got (count-of (render plain) "<div")
                #:expect 1)
               (assert-equal #:name "content-classes are added to that layer"
                             #:got (let ((layer (content-layer (glass-panel
                                                                "CONTENT"
                                                                #:washes (list
                                                                          (yellow-wash))
                                                                #:content-classes '
                                                                (flex gap-2)))))
                                     (list (class-has? layer "flex")
                                           (class-has? layer "gap-2")
                                           (class-has? layer "relative")))
                             #:expect (list #t #t #t))
               (assert-equal #:name "and do not leak onto the surface itself"
                             #:got (count-of (render (glass-panel "CONTENT"
                                                                  #:washes (list
                                                                            (yellow-wash))
                                                                  #:content-classes '
                                                                  (gap-2)))
                                             "gap-2")
                             #:expect 1)
               (assert-equal #:name
                "the recipe's smaller steps are the stylesheet's, so a disc or a pill names its strength rather than writing one"
                #:got (let ((sheet (extras-stylesheet)))
                        (list (contains? sheet ".hg-frost-soft {
  --hg-frost-blur: 3rem;")
                              (contains? sheet ".hg-frost-pill {
  --hg-frost-blur: 1rem;")))
                #:expect (list #t #t))
               (assert-equal #:name
                "asking to clip clips the content, not the frost"
                #:got (let ((panel (glass-panel "CONTENT"
                                                #:clip? #t)))
                        (list (class-has? (content-layer panel)
                                          "overflow-hidden")
                              (class-has? (content-layer panel) "rounded-3xl")
                              (class-has? (surface panel) "overflow-hidden")))
                #:expect (list #t #t #f))
               (assert-equal #:name
                             "a wash is an absolutely placed, blurred disc"
                             #:got (let ((disc (wash-of washed)))
                                     (list (class-has? disc "absolute")
                                           (class-has? disc "blur-3xl")
                                           (class-has? disc "rounded-512")
                                           (class-has? disc "opacity-75")))
                             #:expect (list #t #t #t #t))
               (assert-equal #:name
                "a wash is decoration: hidden from the reader and untouchable"
                #:got (let ((disc (wash-of washed)))
                        (list (attr-value disc
                                          'aria-hidden)
                              (class-has? disc "pointer-events-none")
                              (class-has? disc "select-none")))
                #:expect (list "true" #t #t))
               (assert-equal #:name
                             "a wash keeps the colour, size and place given"
                             #:got (let ((disc (wash-of washed)))
                                     (list (class-has? disc
                                            "bg-naples-yellow-500/75")
                                           (class-has? disc "w-96")
                                           (class-has? disc "left-4")
                                           (class-has? disc "top-4")))
                             #:expect (list #t #t #t #t))
               (assert-equal #:name
                             "the panel's colour does not join the wash"
                             #:got (class-has? (wash-of washed)
                                               "bg-stone-100/75")
                             #:expect #f)
               (assert-equal #:name "washes stand still unless asked to drift"
                             #:got (count-of (render still-panel) "hg-blob")
                             #:expect 0)
               (assert-equal #:name "drift? lets every wash drift"
                             #:got (count-of (render drifting-panel) "hg-blob")
                             #:expect 2)
               (assert-equal #:name
                             "a wash without a delay carries no style at all"
                             #:got (contains? (render (glass-panel "Hi"
                                                                   #:washes (list
                                                                             (glass-wash '
                                                                              (w-96
                                                                               h-96)))))
                                              "style=")
                             #:expect #f)
               (assert-equal #:name "a delay is written as a CSS time"
                             #:got (contains? (render washed)
                                              "style=\"animation-delay: -6s\"")
                             #:expect #t)
               (assert-equal #:name
                             "a pace is written as the disc's own duration"
                             #:got (contains? (render (glass-panel "Hi"
                                                                   #:washes (list
                                                                             (glass-wash '
                                                                              (w-96
                                                                               h-96)
                                                                              #:pace
                                                                              40))))
                                              "--hg-blob-duration: 40s")
                             #:expect #t)
               (assert-equal #:name
                "pace takes a CSS time string just as a delay does"
                #:got (contains? (render (glass-panel "Hi"
                                                      #:washes (list (glass-wash '
                                                                      (w-96
                                                                       h-96)
                                                                      #:pace
                                                                      "1.5m"))))
                                 "--hg-blob-duration: 1.5m")
                #:expect #t)
               (assert-equal #:name "pace and delay ride on one disc together"
                             #:got (contains? (render (glass-panel "Hi"
                                                                   #:washes (list
                                                                             (glass-wash '
                                                                              (w-96
                                                                               h-96)
                                                                              #:delay
                                                                              -3
                                                                              #:pace
                                                                              18
                                                                              #:distance '
                                                                              (2
                                                                               -1)))))
                                    "style=\"animation-delay: -3s; --hg-blob-duration: 18s; --hg-blob-x: 2rem; --hg-blob-y: -1rem\"")
                             #:expect #t)
               (assert-equal #:name
                "a distance is two custom properties, in rems by default"
                #:got (contains? (render (glass-panel "Hi"
                                                      #:washes (list (glass-wash '
                                                                      (w-96
                                                                       h-96)
                                                                      #:distance '
                                                                      (2 -1)))))
                                 "--hg-blob-x: 2rem; --hg-blob-y: -1rem")
                #:expect #t)
               (assert-equal #:name
                "a distance can be any CSS length, and one alone only moves x"
                #:got (let ((html (render (glass-panel "Hi"
                                                       #:washes (list (glass-wash '
                                                                       (w-96
                                                                        h-96)
                                                                       #:distance
                                                                       "2.5rem"))))))
                        (list (contains? html "--hg-blob-x: 2.5rem")
                              (contains? html "--hg-blob-y")))
                #:expect (list #t #f))
               (assert-equal #:name
                "a wash that asks for nothing carries no style at all"
                #:got (contains? (render (glass-panel "Hi"
                                                      #:washes (list (glass-wash '
                                                                      (w-96
                                                                       h-96)))))
                                 "style=")
                #:expect #f)
               (assert-equal #:name
                "a delay can be given as a CSS time string instead"
                #:got (contains? (render (glass-panel "Hi"
                                                      #:washes (list (glass-wash '
                                                                      (w-96
                                                                       h-96)
                                                                      #:delay
                                                                      "2.5s"))))
                                 "animation-delay: 2.5s")
                #:expect #t)
               (assert-equal #:name
                             "the washes are painted before the content"
                             #:got (< (string-contains (render still-panel)
                                                       "blur-3xl")
                                      (string-contains (render still-panel)
                                                       "CONTENT"))
                             #:expect #t)
               (assert-equal #:name
                "an accent is drawn inside the glass, over the washes"
                #:got (let ((html (render (glass-panel "CONTENT"
                                                       #:washes (list (yellow-wash))
                                                       #:accent '((div (@ (class
                                                                           "hg-accent"))))))))
                        (list (contains? html "hg-accent")
                              (< (string-contains html "blur-3xl")
                                 (string-contains html "hg-accent"))
                              (< (string-contains html "hg-accent")
                                 (string-contains html "CONTENT"))))
                #:expect (list #t #t #t))
               (assert-equal #:name
                "and it is clipped with the washes, not left to the surface"
                #:got (let ((panel (glass-panel "CONTENT"
                                                #:accent '((div (@ (class
                                                                    "hg-accent")))))))
                        (list (eq? (accent-of panel)
                                   (car (decorations panel)))
                              (caar (accent-of panel))
                              (class-has? (clip-layer panel) "overflow-hidden")))
                #:expect (list #t
                               'div #t))
               (assert-equal #:name "without one, no extra node is drawn"
                             #:got (contains? (render plain) "hg-accent")
                             #:expect #f)
               (assert-equal #:name
                             "every wash the panel is given is rendered"
                             #:got (count-of (render (glass-panel "Hi"
                                                                  #:washes (list
                                                                            (yellow-wash)
                                                                            (blue-wash)
                                                                            (glass-wash '
                                                                             (w-64
                                                                              h-64)))))
                                             "aria-hidden")
                             #:expect 3))
         (test "panel silhouettes"
               (assert-equal #:name
                             "the surface can be built from another element"
                             #:got (caar (glass-panel '()
                                                      #:tag 'header))
                             #:expect 'header)
               (assert-equal #:name "the surface can carry extra attributes"
                             #:got (contains? (render (glass-panel "Hi"
                                                                   #:attributes '
                                                                   ((hidden ""))))
                                              "<div hidden=\"\"")
                             #:expect #t)
               (assert-equal #:name
                "a surface can place itself, and stop being relative"
                #:got (let ((root (surface (glass-panel "Hi"
                                                        #:position '(sticky
                                                                     top-0)))))
                        (list (class-has? root "sticky")
                              (class-has? root "top-0")
                              (class-has? root "relative")))
                #:expect (list #t #t #f))
               (assert-equal #:name
                "the tint, rounding, border and shadow can be the caller's"
                #:got (let ((root (surface bar-panel)))
                        (list (class-has? root "bg-stone-300/75")
                              (class-has? root "dark:bg-onyx-700/75")
                              (class-has? root "bg-stone-100/75")
                              (class-has? root "rounded-3xl")
                              (class-has? root "border-2")
                              (class-has? root "shadow-lg")
                              (class-has? root "p-6")))
                #:expect (list #t
                               #t
                               #f
                               #f
                               #f
                               #f
                               #f))
               (assert-equal #:name
                "the frost is never the caller's: it is what glass is"
                #:got (class-has? (surface bar-panel) "hg-frost")
                #:expect #t)
               (assert-equal #:name "a surface that must not clip can say so"
                             #:got (let ((root (surface (glass-panel "Hi"
                                                                     #:clip?
                                                                     #t))))
                                     (list (class-has? root "overflow-hidden")
                                           (class-has? root "relative")))
                             #:expect (list #f #t)))))

(define (spec)
  (veritas-run glass-suite))
