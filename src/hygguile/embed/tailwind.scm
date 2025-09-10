(define-module (hygguile embed tailwind) 
 #:declarative? #t 
 #:export (tailwind-js))

(define-public (tailwind-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))