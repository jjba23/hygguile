;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; Media: images and the carousel.

(define-module (showcase media)
  #:use-module (hygguile hygguile)
  #:export (media-section carousel-section))

(define media-section
  `((div (@ (class ,(mk-class '(flex flex-col gap-6))))
         (div (@ (class ,(mk-class '(flex flex-row flex-wrap gap-8 items-start))))
              ,(figure (img #:src
                        "https://jointhefreeworld.org/static-assets/hygguile/hygguile-2-small.png"
                        #:alt "Hygguile logo"
                        #:width 220
                        #:height 130
                        #:rounding '(rounded-2xl))
                       #:caption "figure + img + figcaption"
                       #:align 'center)
              ,(figure (picture #:sources (list (source #:type "image/webp"
                                                 #:srcset
                                                 "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg"))
                                #:image (img #:src
                                         "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg"
                                         #:alt "WikiMusic"
                                         #:width 220
                                         #:aspect-ratio 'square
                                         #:fit 'cover))
                       #:caption "picture with source + fallback img"
                       #:align 'center)
              (div (@ (class ,(mk-class '(flex flex-col items-center gap-2))))
                   ,(avatar #:initials "HG"
                            #:size 'xl
                            #:ring #t)
                   ,(p "avatar with initials fallback"
                       #:size '(text-md)
                       #:weight '(font-light))))
         ,(image-gallery (list (img #:src
                                "https://jointhefreeworld.org/static-assets/byggsteg/logo-small.png"
                                #:alt "Byggsteg"
                                #:aspect-ratio 'square)
                               (img #:src
                                "https://jointhefreeworld.org/static-assets/lucidplan/img/logo-small.jpg"
                                #:alt "LucidPlan"
                                #:aspect-ratio 'square)
                               (img #:src
                                "https://jointhefreeworld.org/static-assets/sss/dall-e-3-thumb.png"
                                #:alt "Static Site Starter"
                                #:aspect-ratio 'square))
                         #:columns 3))))

(define carousel-section
  (let* ((imgs '(("Hygguile Logo" . "https://jointhefreeworld.org/static-assets/hygguile/hygguile-2-small.png")
                 ("WikiMusic Logo" . "https://jointhefreeworld.org/static-assets/wikimusic/img/wikimusic.jpg")
                 "https://jointhefreeworld.org/static-assets/byggsteg/logo-small.png"
                 "https://jointhefreeworld.org/static-assets/lucidplan/img/logo-small.jpg"
                 "https://jointhefreeworld.org/static-assets/sss/dall-e-3-thumb.png"
                 "https://jointhefreeworld.org/static-assets/guile-show-hub/guile-show-hub-small.png"))
         (other-content '("VENI VIDI VICI" "Alea iacta est"
                          "Carpe diem"
                          "COGITO ERGO SUM"
                          "IN VINO VERITAS"
                          "ACTA NON VERBA"
                          "DEUS EX MACHINA"))
         (render-img-with-figcaption (lambda (l)
                                       `((figure (img (@ (class ,(mk-class '(max-w-64
                                                                             rounded-xl)))
                                                         (alt ,(cond
                                                                 ((pair? l)
                                                                  (car l))
                                                                 (else
                                                                  "Carousel Image")))
                                                         (src ,(cond
                                                                 ((string? l)
                                                                  l)
                                                                 ((pair? l)
                                                                  (cdr l))))))

                                                 ,(cond
                                                    ((string? l)
                                                     '())
                                                    ((pair? l)
                                                     `(figcaption (@ (class ,(mk-class '
                                                                              (text-onyx-300
                                                                               dark:text-stone-500
                                                                               text-lg
                                                                               font-light))))
                                                                  ,(car l))))))))
         (render-other-content (lambda (c)
                                 `((div (@ (class ,(mk-class '(text-onyx-300
                                                               dark:text-stone-300
                                                               text-2xl
                                                               min-w-48
                                                               font-light))))
                                        ,c))))
         (fragments (map render-img-with-figcaption imgs))
         (other-fragments (map render-other-content other-content)))
    (list `(div (@ (class ,(mk-class '(flex flex-col gap-6))))
                ,(carousel #:id 'other-carousel
                           #:item-width '(w-48 sm:w-64)
                           #:fragments other-fragments)
                ,(carousel #:id 'showcase-carousel
                           #:item-width '(w-48 sm:w-64)
                           #:fragments fragments)))))
