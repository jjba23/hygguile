(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen)
             (hygguile hss hss)
             (hygguile hss dsl)
             (hygguile hss decl colors))

(define hss-dest-file
  "./resources/css/hss.min.css")

(define hss-rc-huidkliniek-dest-file
  "./resources/css/rc-huidkliniek-hss.min.css")

;; generate entire HSS
(let* ((all-hss (hss)))
  (catch #t
         (lambda ()
           (delete-file hss-dest-file))
         (lambda _
           (display "")))
  (with-output-to-file hss-dest-file
    (lambda ()
      (display (string-join (flatten-list (map format-css all-hss)) "\n")))))

;; generate RC Huidkliniek HSS
(let* ((all-hss (parameterize ((responsive reduced-responsive)
                               (palettes (list (cons 'floral-white
                                                     (floral-white))
                                               (cons 'china-rose
                                                     (china-rose))
                                               (cons 'spiced-terracotta
                                                     (spiced-terracotta))
                                               (cons 'onyx
                                                     (onyx))
                                               (cons 'jeans-blue
                                                     (jeans-blue))
                                               (cons 'asparagus
                                                     (asparagus)))))
                  (hss))))
  (catch #t
         (lambda ()
           (delete-file hss-rc-huidkliniek-dest-file))
         (lambda _
           (display "")))
  (with-output-to-file hss-rc-huidkliniek-dest-file
    (lambda ()
      (display (string-join (flatten-list (map format-css all-hss)) "\n")))))

