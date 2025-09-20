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

(define* (mk-udtryk #:key (font-size "0.2rem")
                    (margin "0.2rem")
                    (gap "0.2rem")
                    (weight 1)
                    (sans
                     "'IBM Plex Sans', ui-sans-serif, system-ui, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'")
                    (serif
                     "'IBM Plex Serif', ui-serif, serif, 'Times New Roman'")

                    (mono "'IBM Plex Mono', monospace")
                    (padding "0.2rem"))
  (append (css* #:class 'text
                #:sizes default-tshirt-sizes
                #:properties '(font-size)
                #:multiplier font-size)
          ;; ====== Paddings ======
          (css* #:class 'p
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding)
                #:multiplier padding)
          (css* #:class 'px
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding-left padding-right)
                #:multiplier padding)
          (css* #:class 'py
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(padding-top padding-bottom)
                #:multiplier padding)
          ;; ====== Margins ======
          (css* #:class 'm
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin)
                #:multiplier margin)
          (css* #:class 'mx
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-left margin-right)
                #:multiplier margin)
          (css* #:class 'my
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-top margin-bottom)
                #:multiplier margin)
          (css* #:class 'mt
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-top)
                #:multiplier margin)
          (css* #:class 'mb
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(margin-bottom)
                #:multiplier margin)

          ;; ====== Font Weights ======
          (css* #:class 'font
                #:sizes default-weight-sizes
                #:properties '(font-weight)
                #:multiplier weight)

          ;; ====== Flex utilities ======
          (css* #:class 'gap
                #:sizes default-numeric-sizes
                #:direct-size? #t
                #:properties '(gap)
                #:multiplier gap)
          (list (css #:class 'flex
                     #:properties '((display flex)))
                (css #:class 'flex-col
                     #:properties '((flex-direction column)))
                (css #:class 'flex-row
                     #:properties '((flex-direction row)))
                (css #:class 'flex-wrap
                     #:properties '((flex-wrap wrap)))
                (css #:class 'justify-center
                     #:properties '((justify-content center))))
          ;; ====== Font utilities ======
          (list (css #:class 'font-sans
                     #:properties `((font-family ,sans)))
                (css #:class 'font-mono
                     #:properties `((font-family ,mono)))
                (css #:class 'font-serif
                     #:properties `((font-family ,serif))))
          ;; ====== Display utilities ======
          (list (css #:class 'hidden
                     #:properties `((display none)))
                (css #:class 'text-center
                     #:properties '((text-align center)))
                (css #:class 'cursor-pointer
                     #:properties `((cursor pointer))))))

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
