(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen))

(define* (mk-method-name #:key dir file extension)
  (let* ((file-without-extension (string-replace-substring file
                                                           (format #f ".~a"
                                                                   extension)
                                                           ""))
         (fun-name-from-file (string-replace-substring file-without-extension
                                                       (format #f "~a/" dir)
                                                       "")))
    (string->symbol (format #f "~a-~a" fun-name-from-file extension))))

(define* (mk-embed-method content-map)
  (let* ((embed-entries (map (lambda (cm)
                               (format #f "~s"
                                       `(define (,(car cm))
                                          ,(cdr cm)))) content-map)))
    (string-join embed-entries "\n\n")))

(let* ((js-dir "./resources/js")
       (tailwind-dir "./resources/js")
       (css-dir "./resources/css")
       ;; embed destination files
       (js-dest-file "./src/hygguile/embed-js.scm")
       (tailwind-dest-file "./src/hygguile/embed-tailwind.scm")
       (css-dest-file "./src/hygguile/embed-css.scm")
       ;; files to embed
       (js-files '(carousel-button copy-pre-inner-text fly-out
                                   remember-dark-theme toggle-dark-theme))
       (tailwind-files '(tailwind))
       (css-files '(fly-out))
       ;; full path to files to embed
       (js-embed-files (map (lambda (file)
                              (format #f "~a/~a.js" js-dir file)) js-files))
       (tailwind-embed-files (map (lambda (file)
                                    (format #f "~a/~a.js" tailwind-dir file))
                                  tailwind-files))
       (css-embed-files (map (lambda (file)
                               (format #f "~a/~a.css" css-dir file)) css-files))
       ;; load contents into maps
       (js-content-map (map (lambda (file)
                              (cons (mk-method-name #:dir js-dir
                                                    #:file file
                                                    #:extension 'js)
                                    (get-string-all (open-input-file file))))
                            js-embed-files))
       (tailwind-content-map (map (lambda (file)
                                    (cons (mk-method-name #:dir tailwind-dir
                                                          #:file file
                                                          #:extension 'js)
                                          (get-string-all (open-input-file
                                                           file))))
                                  tailwind-embed-files))
       (css-content-map (map (lambda (file)
                               (cons (mk-method-name #:dir css-dir
                                                     #:file file
                                                     #:extension 'css)
                                     (get-string-all (open-input-file file))))
                             css-embed-files))
       ;;
       ;; ====== generate Scheme code to embed =======
       ;;
       
       ;; generate methods
       (js-methods (mk-embed-method js-content-map))
       (tailwind-methods (mk-embed-method tailwind-content-map))
       (css-methods (mk-embed-method css-content-map))

       ;; bundle in modules
       (js-module `(define-module (hygguile embed js)
                     ,js-methods))
       (tailwind-module `(define-module (hygguile embed tailwind)
                           ,tailwind-methods))
       (css-module `(define-module (hygguile embed css)
                      ,css-methods)))
  
  (with-output-to-file js-dest-file
    (lambda ()
      (display js-module)))

  (with-output-to-file tailwind-dest-file
    (lambda ()
      (display tailwind-module)))

  (with-output-to-file css-dest-file
    (lambda ()
      (display css-module))))

