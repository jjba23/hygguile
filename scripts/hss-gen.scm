(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen)
             (hygguile hss reset)
             (hygguile hss hss)
             (hygguile hss dsl))

(define hss-dest-file
  "./resources/css/hss.css")

(let* ((styles (list (hss))))
  (catch #t
         (lambda ()
           (delete-file hss-dest-file))
         (lambda _
           (display "")))
  (with-output-to-file hss-dest-file
    (lambda ()
      (display (string-join (flatten-list (map format-css styles)) "\n")))))

