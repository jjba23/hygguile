(define-module (hygguile embed js) 
 #:declarative? #t 
 #:export (carousel-button-js copy-pre-inner-text-js fly-out-js remember-dark-theme-js toggle-dark-theme-js))

(define-public (carousel-button-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))

(define-public (copy-pre-inner-text-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))

(define-public (fly-out-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))

(define-public (remember-dark-theme-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))

(define-public (toggle-dark-theme-js) (quasiquote ((script (@ (type (unquote script-type))) (unquote (cdr cm))))))