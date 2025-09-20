(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen))

(define udtryk-dest-file
  "./resources/css/udtryk.css")

(define* (~ #:rest args)
  (apply format
         (append '(#f) args)))

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

(define* (ud-tshirt #:key class properties
                    (multiplier "0.8em")
                    (sizes default-tshirt-sizes))
  (map (lambda (s)
         (format #f ".~a-~a { ~a }" class
                 (car s)
                 (string-join (map (lambda (p)
                                     (format #f "~a: calc(~a * ~a);" p
                                             multiplier
                                             (cadr s))) properties) " ")))
       sizes))

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

(define* (ud-numeric #:key class properties
                     (multiplier "0.8em")
                     (sizes default-numeric-sizes))
  (map (lambda (s)
         (format #f ".~a-~a { ~a }" class s
                 (string-join (map (lambda (p)
                                     (format #f "~a: calc(~a * ~a);" p
                                             multiplier s)) properties) " ")))
       sizes))

(define* (ud #:key class properties)
  (format #f ".~a { ~a }" class
          (string-join (map (lambda (p)
                              (format #f "~a: ~a;"
                                      (car p)
                                      (cadr p))) properties) " ")))

(define* (mk-udtryk #:key (font-size "0.2em")
                    (margin "0.2rem")
                    (padding "0.2rem"))
  (append (ud-tshirt #:class 'text
                     #:properties '(font-size)
                     #:multiplier font-size)
          (ud-numeric #:class 'p
                      #:properties '(padding)
                      #:multiplier padding)
          (ud-numeric #:class 'px
                      #:properties '(padding-left padding-right)
                      #:multiplier padding)
          (ud-numeric #:class 'py
                      #:properties '(padding-top padding-bottom)
                      #:multiplier padding)
          (ud-numeric #:class 'm
                      #:properties '(margin)
                      #:multiplier margin)
          (ud-numeric #:class 'mx
                      #:properties '(margin-left margin-right)
                      #:multiplier margin)
          (ud-numeric #:class 'mt
                      #:properties '(margin-top margin-bottom)
                      #:multiplier margin)
          (ud-numeric #:class 'mt
                      #:properties '(margin-top)
                      #:multiplier margin)
          (ud-numeric #:class 'mb
                      #:properties '(margin-bottom)
                      #:multiplier margin)
          (list (ud #:class 'flex
                    #:properties '((display flex)))
                (ud #:class 'flex-col
                    #:properties '((flex-direction column)))
                (ud #:class 'flex-row
                    #:properties '((flex-direction row)))

                )))

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
