(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen))

(define udtryk-dest-file
  "./resources/css/udtryk.css")

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

(define* (css* #:key class
               properties
               (direct-size? #f)
               (multiplier "0.7em")
               sizes)
  (map (lambda (s)
         (~ ".~a-~a { ~a }" class
            (if direct-size? s
                (car s))
            (string-join (map (lambda (p)
                                (~ "~a: calc(~a * ~a);" p multiplier
                                   (if direct-size? s
                                       (cadr s)))) properties) " "))) sizes))

(define* (css #:key class properties)
  (~ ".~a { ~a }" class
     (string-join (map (lambda (p)
                         (~ "~a: ~a;"
                            (car p)
                            (cadr p))) properties) " ")))

;; ===========================

(define default-tshirt-sizes
  `(("xxs" 1)
    ("xs" 2)
    ("sm" 3)
    ("md" 4)
    ("lg" 5)
    ("xl" 6)
    ("2xl" 7)
    ("3xl" 8)
    ("4xl" 9)
    ("5xl" 10)))

(define default-numeric-sizes
  (list 1
        2
        3
        4
        5
        6
        7
        8
        9
        10
        11
        12
        14
        16
        18
        20
        22
        24
        28
        32
        64
        72
        128))

(define default-weight-sizes
  '((100 100)
    (thin 100)
    (200 200)
    (300 300)
    (light 300)
    (400 400)
    (500 500)
    (medium 500)
    (600 600)
    (700 700)
    (bold 700)
    (800 800)
    (900 900)
    (black 900)))

(define font-size-multiplier
  (make-parameter "0.24rem"))
(define margin-multiplier
  (make-parameter "0.24rem"))
(define padding-multiplier
  (make-parameter "0.24rem"))
(define gap-multiplier
  (make-parameter "0.24rem"))
(define rounded-multiplier
  (make-parameter "0.1rem"))
(define width-multiplier
  (make-parameter "0.4rem"))
(define weight-multiplier
  (make-parameter 1))

(define mono-font-family
  (make-parameter "'IBM Plex Mono', monospace"))
(define serif-font-family
  (make-parameter "'IBM Plex Serif', ui-serif, serif, 'Times New Roman'"))
(define sans-font-family
  (make-parameter (string-join '("'IBM Plex Sans', ui-sans-serif, system-ui, sans-serif,"
                                 "'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'")
                               " ")))

(define* (mk-udtryk)
  (append (list (css-reset))
          (css* #:class 'text
                #:sizes default-tshirt-sizes
                #:properties '(font-size)
                #:multiplier (font-size-multiplier))
          (css* #:class 'rounded
                #:sizes default-tshirt-sizes
                #:properties '(border-radius)
                #:multiplier (rounded-multiplier))
          ;; ====== Paddings ======
          (css* #:class 'p
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding)
                #:multiplier (padding-multiplier))
          (css* #:class 'px
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding-left padding-right)
                #:multiplier (padding-multiplier))
          (css* #:class 'py
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding-top padding-bottom)
                #:multiplier (padding-multiplier))
          ;; ====== Margins ======
          (css* #:class 'm
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin)
                #:multiplier (margin-multiplier))
          (css* #:class 'mx
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-left margin-right)
                #:multiplier (margin-multiplier))
          (css* #:class 'my
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-top margin-bottom)
                #:multiplier (margin-multiplier))
          (css* #:class 'mt
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-top)
                #:multiplier (margin-multiplier))
          (css* #:class 'mb
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-bottom)
                #:multiplier (margin-multiplier))

          ;; ====== Font Weights ======
          (css* #:class 'font
                #:sizes default-weight-sizes
                #:properties '(font-weight)
                #:multiplier (weight-multiplier))

          ;; ====== Flex utilities ======
          (css* #:class 'gap
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(gap)
                #:multiplier (gap-multiplier))
          (list (css #:class 'flex
                     #:properties '((display flex)))
                (css #:class 'flex-col
                     #:properties '((flex-direction column)))
                (css #:class 'flex-row
                     #:properties '((flex-direction row)))
                (css #:class 'flex-wrap
                     #:properties '((flex-wrap wrap)))
                (css #:class 'items-center
                     #:properties '((align-items center)))
                (css #:class 'justify-center
                     #:properties '((justify-content center))))
          ;; ====== Width ======
          (css* #:class 'max-w
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(max-width)
                #:multiplier (width-multiplier))
          ;; ====== Font utilities ======
          (list (css #:class 'font-sans
                     #:properties `((font-family ,(sans-font-family))))
                (css #:class 'font-mono
                     #:properties `((font-family ,(mono-font-family))))
                (css #:class 'font-serif
                     #:properties `((font-family ,(serif-font-family)))))
          ;; ====== Display utilities ======
          (list (css #:class 'hidden
                     #:properties `((display none)))
                (css #:class 'overflow-x-scroll
                     #:properties '((overflow-x scroll)))
                (css #:class 'italic
                     #:properties `((font-style italic)))
                (css #:class 'text-center
                     #:properties '((text-align center)))
                (css #:class 'cursor-pointer
                     #:properties `((cursor pointer))))))

(define css-reset
  (make-parameter "
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
	display: block;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: '';
	content: none;
}
table {
	border-collapse: collapse;
	border-spacing: 0;
}
"))

;; ===========================

(define* (display-css xs)
  
  (cond
    ((string? xs)
     (display xs)
     (newline))
    ((list? xs)
     (for-each display-css xs))
    (else (display xs))))

(let* ((xs (mk-udtryk))
       (udtryk (list xs)))
  
  (delete-file udtryk-dest-file)
  (with-output-to-file udtryk-dest-file
    (lambda ()
      (for-each display-css udtryk))))

