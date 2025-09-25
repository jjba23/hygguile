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

(define-module (hygguile hss decl colors)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl))

(define-public redwood-oklch
  '(0.5591 0.1288 31.7))

(define-public redwood
  (param (make-palette redwood-oklch)))

(define-public melon-oklch
  '(0.7664 0.0661 30.56))

(define-public melon
  (param (make-palette melon-oklch)))

(define-public charcoal-oklch
  '(0.3798 0.0343 266.95))

(define-public charcoal
  (param (make-palette charcoal-oklch)))

(define-public glaucous-oklch
  '(0.5653 0.0696 251.18))

(define-public glaucous
  (param (make-palette glaucous-oklch)))

(define-public cambridge-green-oklch
  '(0.6443 0.0467 168.05))

(define-public cambridge-green
  (param (make-palette cambridge-green-oklch)))

(define-public iris-oklch
  '(0.4929 0.161 279.98))

(define-public iris
  (param (make-palette iris-oklch)))

(define-public mantis-oklch
  '(0.7048 0.1321 144.02))

(define-public mantis
  (param (make-palette mantis-oklch)))

(define-public china-rose-oklch
  '(0.6023 0.1041 7.06))

(define-public china-rose
  (param (make-palette china-rose-oklch)))

(define-public china-violet-oklch
  '(0.5161 0.0609 310.77))

(define-public china-violet
  (param (make-palette china-violet-oklch)))

(define-public light-coral-oklch
  '(0.6751 0.152 20.02))

(define-public light-coral
  (param (make-palette light-coral-oklch)))

(define-public jeans-blue-oklch
  '(0.452 0.0712 256.28))

(define-public jeans-blue
  (param (make-palette jeans-blue-oklch)))

(define-public buff-oklch
  '(0.7871 0.0895 49.68))

(define-public buff
  (param (make-palette buff-oklch)))

(define-public tawny-oklch
  '(0.6183 0.1557 45.26))

(define-public tawny
  (param (make-palette tawny-oklch)))

(define-public moonstone-oklch
  '(0.6609 0.0708 213.97))

(define-public moonstone
  (param (make-palette moonstone-oklch)))

(define-public claret-oklch
  '(0.4111 0.1625 5.42))

(define-public claret
  (param (make-palette claret-oklch)))

(define-public castleton-green-oklch
  '(0.3771 0.0754 167.02))

(define-public castleton-green
  (param (make-palette castleton-green-oklch)))

(define-public lapis-lazuli-oklch
  '(0.4595 0.0968 251.94))

(define-public lapis-lazuli
  (param (make-palette lapis-lazuli-oklch)))

(define-public cadet-gray-oklch
  '(0.654 0.0185 225.33))

(define-public cadet-gray
  (param (make-palette cadet-gray-oklch)))

(define-public ash-gray-oklch
  '(0.8342 0.0248 196.69))

(define-public ash-gray
  (param (make-palette ash-gray-oklch)))

(define-public dark-purple-oklch
  '(0.3022 0.0506 0.51))

(define-public dark-purple
  (param (make-palette dark-purple-oklch)))

(define-public pomp-and-power-oklch
  '(0.5818 0.0719 310.07))

(define-public pomp-and-power
  (param (make-palette pomp-and-power-oklch)))

(define-public black-olive-oklch
  '(0.4087 0.0176 128.95))

(define-public black-olive
  (param (make-palette black-olive-oklch)))

(define-public white-smoke-oklch
  '(0.9702 0 0))

(define-public white-smoke
  (param (make-palette white-smoke-oklch)))

(define-public russia-violet-oklch
  '(0.3016 0.1166 317.88))

(define-public russia-violet
  (param (make-palette russia-violet-oklch)))

(define-public tyrian-oklch
  '(0.3409 0.1048 358.88))

(define-public tyrian
  (param (make-palette tyrian-oklch)))

(define-public persia-pink-oklch
  '(0.7404 0.1399 348.9))

(define-public persia-pink
  (param (make-palette persia-pink-oklch)))

(define-public naples-yellow-oklch
  '(0.9011 0.1449 97.97))

(define-public naples-yellow
  (param (make-palette naples-yellow-oklch)))

(define-public apple-green-oklch
  '(0.7214 0.1697 119.64))

(define-public apple-green
  (param (make-palette apple-green-oklch)))

(define-public mikado-yellow-oklch
  '(0.8538 0.1734 87.35))

(define-public mikado-yellow
  (param (make-palette mikado-yellow-oklch)))

(define-public bistre-oklch
  '(0.2732 0.0607 61.09))

(define-public bistre
  (param (make-palette bistre-oklch)))

(define-public black-bean-oklch
  '(0.2453 0.0769 40.07))

(define-public black-bean
  (param (make-palette black-bean-oklch)))

(define-public sienna-oklch
  '(0.4307 0.1478 35.91))

(define-public sienna
  (param (make-palette sienna-oklch)))

(define-public umber-oklch
  '(0.4106 0.0384 61.8))

(define-public umber
  (param (make-palette umber-oklch)))

(define-public beaver-oklch
  '(0.6651 0.0536 62.76))

(define-public beaver
  (param (make-palette beaver-oklch)))

(define-public coffee-oklch
  '(0.462 0.0615 63.5))

(define-public coffee
  (param (make-palette coffee-oklch)))

(define-public pale-dogwood-oklch
  '(0.8322 0.0512 42.95))

(define-public pale-dogwood
  (param (make-palette pale-dogwood-oklch)))

(define-public spiced-terracotta-oklch
  '(0.6277 0.1081 53.34))

(define-public spiced-terracotta
  (param (make-palette spiced-terracotta-oklch)))

(define-public orange-crayola-oklch
  '(0.7404 0.1444 57.26))

(define-public orange
  (param (make-palette orange-crayola-oklch)))

(define-public stone-oklch
  '(0.907 0.0013 286.37))

(define-public stone
  (param (make-palette stone-oklch
                       #:transformers (list (list 100 lighten-oklch 0.08)
                                            (list 300 lighten-oklch 0.04)
                                            (list 500 identity-oklch 0)
                                            (list 700 darken-oklch 0.05)
                                            (list 900 darken-oklch 0.1)))))

(define-public raisin-black-oklch
  '(0.2711 0.011 285.64))

(define-public raisin-black
  (param (make-palette raisin-black-oklch)))

(define-public asparagus-oklch
  '(0.6012 0.0882 137.17))

(define-public asparagus
  (param (make-palette asparagus-oklch)))

(define-public midnight-green-oklch
  '(0.4108 0.0614 214.25))

(define-public midnight-green
  (param (make-palette midnight-green-oklch)))

(define-public wine-oklch
  '(0.4284 0.0747 9.86))

(define-public wine
  (param (make-palette wine-oklch)))

(define-public van-dyke-oklch
  '(0.3297 0.0387 11.82))

(define-public van-dyke
  (param (make-palette van-dyke-oklch)))

(define-public prussian-blue-oklch
  '(0.3093 0.0627 254.14))

(define-public prussian-blue
  (param (make-palette prussian-blue-oklch)))

(define-public onyx-oklch
  '(0.3588 0.0044 247.95))

(define-public onyx
  (param (make-palette onyx-oklch)))

(define-public papaya-whip-oklch
  '(0.9622 0.0384 83.83))

(define-public papaya-whip
  (param (make-palette papaya-whip-oklch)))

(define-public floral-white-oklch
  '(0.9819 0.0164 91.55))

(define-public floral-white
  (param (make-palette floral-white-oklch)))

(define-public ferrari-red-oklch
  '(0.6399 0.2466 31.39))

(define-public ferrari-red
  (param (make-palette ferrari-red-oklch)))

(define-public palettes
  (param (list (cons 'apple-green
                     (apple-green))
               (cons 'ash-gray
                     (ash-gray))
               (cons 'asparagus
                     (asparagus))
               (cons 'beaver
                     (beaver))
               (cons 'bistre
                     (bistre))
               (cons 'black-bean
                     (black-bean))
               (cons 'black-olive
                     (black-olive))
               (cons 'buff
                     (buff))
               (cons 'cadet-gray
                     (cadet-gray))
               (cons 'cambridge-green
                     (cambridge-green))
               (cons 'castleton-green
                     (castleton-green))
               (cons 'charcoal
                     (charcoal))
               (cons 'china-rose
                     (china-rose))
               (cons 'china-violet
                     (china-violet))
               (cons 'claret
                     (claret))
               (cons 'coffee
                     (coffee))
               (cons 'dark-purple
                     (dark-purple))
               (cons 'ferrari-red
                     (ferrari-red))
               (cons 'floral-white
                     (floral-white))
               (cons 'glaucous
                     (glaucous))
               (cons 'iris
                     (iris))
               (cons 'jeans-blue
                     (jeans-blue))
               (cons 'lapis-lazuli
                     (lapis-lazuli))
               (cons 'light-coral
                     (light-coral))
               (cons 'mantis
                     (mantis))
               (cons 'melon
                     (melon))
               (cons 'midnight-green
                     (midnight-green))
               (cons 'mikado-yellow
                     (mikado-yellow))
               (cons 'moonstone
                     (moonstone))
               (cons 'naples-yellow
                     (naples-yellow))
               (cons 'onyx
                     (onyx))
               (cons 'orange
                     (orange))
               (cons 'pale-dogwood
                     (pale-dogwood))
               (cons 'papaya-whip
                     (papaya-whip))
               (cons 'persia-pink
                     (persia-pink))
               (cons 'pomp-and-power
                     (pomp-and-power))
               (cons 'prussian-blue
                     (prussian-blue))
               (cons 'raisin-black
                     (raisin-black))
               (cons 'redwood
                     (redwood))
               (cons 'russia-violet
                     (russia-violet))
               (cons 'sienna
                     (sienna))
               (cons 'spiced-terracotta
                     (spiced-terracotta))
               (cons 'stone
                     (stone))
               (cons 'tawny
                     (tawny))
               (cons 'tyrian
                     (tyrian))
               (cons 'umber
                     (umber))
               (cons 'van-dyke
                     (van-dyke))
               (cons 'white-smoke
                     (white-smoke))
               (cons 'wine
                     (wine)))))

