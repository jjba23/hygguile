(use-modules (ice-9 string-fun)
             (ice-9 ports)
             (ice-9 textual-ports)
             (ice-9 popen))

(define* (mk-method-name #:key dir file extension)
  (let* ((file-without-extension (string-replace-substring (format #f "~a"
                                                                   file)
                                                           (format #f ".~a"
                                                                   extension)
                                                           ""))
         (fun-name-from-file (string-replace-substring file-without-extension
                                                       (format #f "~a/" dir)
                                                       "")))
    (string->symbol (format #f "~a-~a" fun-name-from-file extension))))

(define* (mk-css-embed-method content-map
                              #:key (style-type "text/css"))
  (let* ((embed-entries (map (lambda (cm)
                               (format #f "~s"
                                       `(define-public (,(car cm))
                                          '((style (@ (type ,style-type))
                                                   ,(cdr cm)))))) content-map)))
    (string-join embed-entries "\n\n")))

(define* (mk-js-embed-method content-map
                             #:key (script-type "text/javascript")
                             (defer? #t))
  (let* ((embed-entries (map (lambda (cm)
                               (format #f "~s"
                                       `(define-public (,(car cm))
                                          '((script (@ (type ,script-type)
                                                       ,(if defer?
                                                            '(defer "")
                                                            '(no-defer "")))
                                                    ,(cdr cm)))))) content-map)))
    (string-join embed-entries "\n\n")))

(define* (mk-module #:key name method-names methods)
  (list license-text "\n\n"
        `(define-module (hygguile embed
                                  ,name)
           "\n"
           #:declarative? #t
           "\n"
           #:export ,method-names) "\n\n" methods))

(define (get-method-name x)
  (format #f "~a"
          (car x)))

(define js-dir
  "./resources/js")

(define css-dir
  "./resources/css")

;; embed destination files
(define js-dest-file
  "./src/hygguile/embed/js.scm")

(define css-dest-file
  "./src/hygguile/embed/css.scm")

;; files to embed
(define js-files
  '(carousel-button copy-pre-inner-text color-show fly-out remember-dark-theme
                    toggle-dark-theme))

(define css-files
  '(fly-out))

(define license-text
  ";; hygguile - cozy and professional user-interfaces for everyone

;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; hygguile is free software: you can redistribute it and/or modify
;; it under the terms of the Lesser GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; hygguile is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; Lesser GNU General Public License for more details.

;; You should have received a copy of the Lesser GNU General Public License
;; along with hygguile.  If not, see <https://www.gnu.org/licenses/>.
")

(let* ( ;full path to files to embed
        (js-embed-files (map (lambda (file)
                               (format #f "~a/~a.js" js-dir file)) js-files))
       (css-embed-files (map (lambda (file)
                               (format #f "~a/~a.css" css-dir file)) css-files))
       ;; load contents into maps
       (js-content-map (map (lambda (file)
                              (cons (mk-method-name #:dir js-dir
                                                    #:file file
                                                    #:extension 'js)
                                    (get-string-all (open-input-file file))))
                            js-embed-files))
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
       (js-methods (mk-js-embed-method js-content-map))
       (js-method-names (map car js-content-map))
       (css-methods (mk-css-embed-method css-content-map))
       (css-method-names (map car css-content-map))

       ;; bundle in modules
       (js-module (mk-module #:name 'js
                             #:method-names js-method-names
                             #:methods js-methods))
       (css-module (mk-module #:name 'css
                              #:method-names css-method-names
                              #:methods css-methods)))
  
  (with-output-to-file js-dest-file
    (lambda ()
      (for-each display js-module)))

  (with-output-to-file css-dest-file
    (lambda ()
      (for-each display css-module))))

