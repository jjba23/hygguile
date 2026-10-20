;; hygguile - cozy and professional user-interfaces for everyone

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

;; ====== The showcase ======
;;
;; The page is one module per shelf of components, so a section can be read --
;; and changed -- on its own:
;;
;;   showcase/specimens.scm     the labelled panel and row a section is built from
;;   showcase/hero.scm          the glass hero, and the glossary it names
;;   showcase/foundations.scm   type scale, gradients, palette
;;   showcase/layout.scm        layout primitives, containers, cards
;;   showcase/controls.scm      buttons, fields, forms, disclosure
;;   showcase/data.scm          tables, display pieces, detail lists
;;   showcase/media.scm         images and the carousel
;;   showcase/navigation.scm    breadcrumbs, tabs, sidebar, rail, fly-out
;;   showcase/application.scm   overlays, feedback, states, settings
;;   showcase/overview.scm      why the framework renders on the server
;;   showcase/entries.scm       every section, its shelf and its icon
;;   showcase/page.scm          the tray, the sort control and the writer
;;
;; This file only writes the page out:
;;
;;   guix shell -m manifest.scm -- guile -L ./src -L . showcase.scm

(use-modules (showcase page))

;; ====== Run ======

(with-output-to-file "dist/index.html"
  (lambda ()
    (display (showcase))))

(display
 "
>>= successfully built hygguile showcase to destination: dist/index.html
")
