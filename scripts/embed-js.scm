(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen))

(let* ((js-dir "./resources/js")
       (dest-file "./src/hygguile/embed-js.scm")
       (js-files '(carousel-button copy-pre-inner-text fly-out
                                   remember-dark-theme tailwind
                                   toggle-dark-theme))
       (embed-files (map (lambda (js-file)
                           (format #f "~a/~a.js" js-dir js-file)) js-files))
       (content-map (map (lambda (embed-file)
                           (let* ((chch (string-replace-substring (string-replace-substring
                                                                   embed-file
                                                                   ".js" "")
                                                                  (format #f
                                                                   "~a/"
                                                                   js-dir) ""))
                                  (fun-name (string->symbol (format #f "~a-js" chch))))
                             (cons fun-name
                                   (get-string-all (open-input-file embed-file)))))
                         embed-files))

       (embed-js-entries (map (lambda (cm)
                                (format #f "~s"
                                        `(define (,(car cm))
                                           "test"))) content-map))
       (_ (write embed-js-entries))
       (embed-js-data (string-join embed-js-entries "\n\n")))
  
  (with-output-to-file dest-file
    (lambda ()
      (display embed-js-data))))

