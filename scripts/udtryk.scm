(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen)
             (hygguile udtryk reset)
             (hygguile udtryk udtryk)
             (hygguile udtryk dsl))

(define udtryk-dest-file
  "./resources/css/udtryk.css")

(let* ((styles (list (udtryk))))
  (delete-file udtryk-dest-file)
  (with-output-to-file udtryk-dest-file
    (lambda ()
      (for-each display-css styles))))

