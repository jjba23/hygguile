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

(define* (mk-tshirt-sized-class #:key class properties
                                (multiplier "0.8em")
                                (sizes default-tshirt-sizes))
  (map (lambda (s)
         (write s)
         (format #f ".~a-~a { ~a }" class
                 (car s)
                 (string-join (map (lambda (p)
                                     (format #f "~a: calc(~a * ~a);" p
                                             multiplier
                                             (cadr s))) properties) " ")))
       sizes))

(define* (mk-udtryk #:key (font-size "0.2em")
                    (margin "0.2rem")
                    (padding "0.2rem"))
  (append (mk-tshirt-sized-class #:class 'text
                                 #:properties '(font-size)
                                 #:multiplier font-size)
          (mk-tshirt-sized-class #:class 'padding
                                 #:properties '(padding)
                                 #:multiplier padding)
          (mk-tshirt-sized-class #:class 'padding-x
                                 #:properties '(padding-left padding-right)
                                 #:multiplier padding)
          (mk-tshirt-sized-class #:class 'padding-y
                                 #:properties '(padding-top padding-bottom)
                                 #:multiplier padding)
          (mk-tshirt-sized-class #:class 'margin
                                 #:properties '(margin)
                                 #:multiplier margin)
          (mk-tshirt-sized-class #:class 'margin-x
                                 #:properties '(margin-left margin-right)
                                 #:multiplier margin)
          (mk-tshirt-sized-class #:class 'margin-y
                                 #:properties '(margin-top margin-bottom)
                                 #:multiplier margin)))

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
