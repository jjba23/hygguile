
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


(define-module (hygguile embed tailwind-css) 
 #:declarative? #t 
 #:export (custom-tailwind-css))

(define-public (custom-tailwind-css) (quote ((style (@ (type "text/tailwindcss")) "/*\n  hygguile - cozy and professional user-interfaces for everyone\n\n  Copyright © Josep Bigorra <jjbigorra@gmail.com>\n\n  hygguile is free software: you can redistribute it and/or modify\n  it under the terms of the Lesser GNU General Public License as published by\n  the Free Software Foundation, either version 3 of the License, or\n  (at your option) any later version.\n\n  hygguile is distributed in the hope that it will be useful,\n  but WITHOUT ANY WARRANTY; without even the implied warranty of\n  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n  Lesser GNU General Public License for more details.\n\n  You should have received a copy of the Lesser GNU General Public License\n  along with hygguile.  If not, see <https://www.gnu.org/licenses/>.\n*/\n\n@custom-variant dark (&:where([data-theme=dark], [data-theme=dark] *));\n\n@theme {\n  --font-sans: \"IBM Plex Sans\", sans-serif;\n  --font-mono: \"IBM Plex Mono\", monospace;\n  --font-serif: \"IBM Plex Serif\", serif;\n  --animate-wiggle: wiggle 750ms ease-in-out 50ms;\n\n  @keyframes wiggle {\n    0%,\n    100% {\n      transform: rotate(-3deg);\n    }\n    50% {\n      transform: rotate(3deg);\n    }\n  }\n\n  --color-spicedterracotta: #BB7546;\n  --color-burntumber: #943524;\n  --color-bistre: #261903;\n  --color-oldlace: #FFF8EB;\n  --color-floralwhite: #FDF9ED;\n  --color-cornsilk: #FBF3DA;\n  --color-papayawhip: #FFF1D6;\n  --color-chinarose: #944C63;\n  --color-earthyellow: #F7AE50;\n  --color-cafenoir: #392605;\n}\n"))))