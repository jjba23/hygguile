;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (veritas unit components media-spec)
  #:use-module (veritas veritas)
  #:use-module (hygguile components media)
  #:export (spec))

(define (attr-value node name)
  (let* ((root (car node))
         (hit (assq name
                    (cdr (cadr root)))))
    (if (pair? hit)
        (let ((value (cdr hit)))
          (if (pair? value)
              (car value) value)) #f)))

(define media-suite
  (suite "Media"
         (test "hygguile media"
               (assert-equal #:name "img renders an <img> element"
                             #:got (caar (img #:src "a.png"
                                              #:alt "A"))
                             #:expect 'img)
               (assert-equal #:name "img always renders the alt attribute"
                             #:got (attr-value (img #:src "a.png")
                                               'alt)
                             #:expect "")
               (assert-equal #:name "img renders a custom alt attribute"
                             #:got (attr-value (img #:src "a.png"
                                                    #:alt "Portrait")
                                               'alt)
                             #:expect "Portrait")
               (assert-equal #:name "img defaults to lazy loading"
                             #:got (attr-value (img #:src "a.png")
                                               'loading)
                             #:expect "lazy")
               (assert-equal #:name "source renders a <source> element"
                             #:got (caar (source #:srcset "a.webp"
                                                 #:type "image/webp"))
                             #:expect 'source)
               (assert-equal #:name "picture renders a <picture> element"
                             #:got (caar (picture #:sources '()
                                                  #:image (img #:src "a.png")))
                             #:expect 'picture)
               (assert-equal #:name
                             "figcaption renders a <figcaption> element"
                             #:got (caar (figcaption "Figure 1"))
                             #:expect 'figcaption)
               (assert-equal #:name "figure renders a <figure> element"
                             #:got (caar (figure (img #:src "a.png")))
                             #:expect 'figure)
               (assert-equal #:name "avatar renders a <span> element"
                             #:got (caar (avatar #:initials "HG"))
                             #:expect 'span)
               (assert-equal #:name
                             "avatar falls back to initials without a source"
                             #:got (caddr (car (avatar #:initials "HG")))
                             #:expect "HG")
               (assert-equal #:name "image-gallery renders a <div> grid"
                             #:got (caar (image-gallery '()))
                             #:expect 'div))))

(define (spec)
  (veritas-run media-suite))
