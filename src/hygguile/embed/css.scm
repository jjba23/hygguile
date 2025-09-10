(define-module (hygguile embed css) 
 #:declarative? #t 
 #:export (fly-out-css))

(define-public (fly-out-css) (quasiquote ((style (@ (type (unquote style-type))) (unquote (cdr cm))))))