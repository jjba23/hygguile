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

(define-module (hygguile hss colors)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-13)
  #:use-module (ice-9 string-fun)
  #:use-module (hygguile hss dsl)
  #:export (default-palettes))

(define redwood-oklch
  '(0.5591 0.1288 31.7))

(define redwood
  (make-parameter (make-palette redwood-oklch)))

(define melon-oklch
  '(0.7664 0.0661 30.56))

(define melon
  (make-parameter (make-palette melon-oklch)))

(define charcoal-oklch
  '(0.3798 0.0343 266.95))

(define charcoal
  (make-parameter (make-palette charcoal-oklch)))

(define glaucous-oklch
  '(0.5653 0.0696 251.18))

(define glaucous
  (make-parameter (make-palette glaucous-oklch)))

(define cambridge-green-oklch
  '(0.6443 0.0467 168.05))

(define cambridge-green
  (make-parameter (make-palette cambridge-green-oklch)))

(define iris-oklch
  '(0.4929 0.161 279.98))

(define iris
  (make-parameter (make-palette iris-oklch)))

(define mantis-oklch
  '(0.7048 0.1321 144.02))

(define mantis
  (make-parameter (make-palette mantis-oklch)))

(define china-rose-oklch
  '(0.6023 0.1041 7.06))

(define china-rose
  (make-parameter (make-palette china-rose-oklch)))

(define china-violet-oklch
  '(0.5161 0.0609 310.77))

(define china-violet
  (make-parameter (make-palette china-violet-oklch)))

(define light-coral-oklch
  '(0.6751 0.152 20.02))

(define light-coral
  (make-parameter (make-palette light-coral-oklch)))

(define jeans-blue-oklch
  '(0.452 0.0712 256.28))

(define jeans-blue
  (make-parameter (make-palette jeans-blue-oklch)))

(define buff-oklch
  '(0.7871 0.0895 49.68))

(define buff
  (make-parameter (make-palette buff-oklch)))

(define tawny-oklch
  '(0.6183 0.1557 45.26))

(define tawny
  (make-parameter (make-palette tawny-oklch)))

(define moonstone-oklch
  '(0.6609 0.0708 213.97))

(define moonstone
  (make-parameter (make-palette moonstone-oklch)))

(define claret-oklch
  '(0.4111 0.1625 5.42))

(define claret
  (make-parameter (make-palette claret-oklch)))

(define castleton-green-oklch
  '(0.3771 0.0754 167.02))

(define castleton-green
  (make-parameter (make-palette castleton-green-oklch)))

(define lapis-lazuli-oklch
  '(0.4595 0.0968 251.94))

(define lapis-lazuli
  (make-parameter (make-palette lapis-lazuli-oklch)))

(define cadet-gray-oklch
  '(0.654 0.0185 225.33))

(define cadet-gray
  (make-parameter (make-palette cadet-gray-oklch)))

(define ash-gray-oklch
  '(0.8342 0.0248 196.69))

(define ash-gray
  (make-parameter (make-palette ash-gray-oklch)))

(define dark-purple-oklch
  '(0.3022 0.0506 0.51))

(define dark-purple
  (make-parameter (make-palette dark-purple-oklch)))

(define pomp-and-power-oklch
  '(0.5818 0.0719 310.07))

(define pomp-and-power
  (make-parameter (make-palette pomp-and-power-oklch)))

(define black-olive-oklch
  '(0.4087 0.0176 128.95))

(define black-olive
  (make-parameter (make-palette black-olive-oklch)))

(define white-smoke-oklch
  '(0.9702 0 0))

(define white-smoke
  (make-parameter (make-palette white-smoke-oklch)))

(define russia-violet-oklch
  '(0.3016 0.1166 317.88))

(define russia-violet
  (make-parameter (make-palette russia-violet-oklch)))

(define tyrian-oklch
  '(0.3409 0.1048 358.88))

(define tyrian
  (make-parameter (make-palette tyrian-oklch)))

(define persia-pink-oklch
  '(0.7404 0.1399 348.9))

(define persia-pink
  (make-parameter (make-palette persia-pink-oklch)))

(define naples-yellow-oklch
  '(0.9011 0.1449 97.97))

(define naples-yellow
  (make-parameter (make-palette naples-yellow-oklch)))

(define apple-green-oklch
  '(0.7214 0.1697 119.64))

(define apple-green
  (make-parameter (make-palette apple-green-oklch)))

(define mikado-yellow-oklch
  '(0.8538 0.1734 87.35))

(define mikado-yellow
  (make-parameter (make-palette mikado-yellow-oklch)))

(define bistre-oklch
  '(0.2732 0.0607 61.09))

(define bistre
  (make-parameter (make-palette bistre-oklch)))

(define black-bean-oklch
  '(0.2453 0.0769 40.07))

(define black-bean
  (make-parameter (make-palette black-bean-oklch)))

(define sienna-oklch
  '(0.4307 0.1478 35.91))

(define sienna
  (make-parameter (make-palette sienna-oklch)))

(define umber-oklch
  '(0.4106 0.0384 61.8))

(define umber
  (make-parameter (make-palette umber-oklch)))

(define beaver-oklch
  '(0.6651 0.0536 62.76))

(define beaver
  (make-parameter (make-palette beaver-oklch)))

(define coffee-oklch
  '(0.462 0.0615 63.5))

(define coffee
  (make-parameter (make-palette coffee-oklch)))

(define pale-dogwood-oklch
  '(0.8322 0.0512 42.95))

(define pale-dogwood
  (make-parameter (make-palette pale-dogwood-oklch)))

(define spiced-terracotta-oklch
  '(0.6277 0.1081 53.34))

(define spiced-terracotta
  (make-parameter (make-palette spiced-terracotta-oklch)))

(define orange-crayola-oklch
  '(0.7404 0.1444 57.26))

(define orange
  (make-parameter (make-palette orange-crayola-oklch)))

(define stone-oklch
  '(0.907 0.0013 286.37))

(define stone
  (make-parameter (make-palette stone-oklch
                                #:transformers (list (list 100 lighten-oklch
                                                           0.08)
                                                     (list 300 lighten-oklch
                                                           0.04)
                                                     (list 500 identity-oklch
                                                           0)
                                                     (list 700 darken-oklch
                                                           0.05)
                                                     (list 900 darken-oklch
                                                           0.1)))))

(define raisin-black-oklch
  '(0.2711 0.011 285.64))

(define raisin-black
  (make-parameter (make-palette raisin-black-oklch)))

(define asparagus-oklch
  '(0.6012 0.0882 137.17))

(define asparagus
  (make-parameter (make-palette asparagus-oklch)))

(define midnight-green-oklch
  '(0.4108 0.0614 214.25))

(define midnight-green
  (make-parameter (make-palette midnight-green-oklch)))

(define wine-oklch
  '(0.4284 0.0747 9.86))

(define wine
  (make-parameter (make-palette wine-oklch)))

(define van-dyke-oklch
  '(0.3297 0.0387 11.82))

(define van-dyke
  (make-parameter (make-palette van-dyke-oklch)))

(define prussian-blue-oklch
  '(0.3093 0.0627 254.14))

(define prussian-blue
  (make-parameter (make-palette prussian-blue-oklch)))

(define onyx-oklch
  '(0.3588 0.0044 247.95))

(define onyx
  (make-parameter (make-palette onyx-oklch)))

(define papaya-whip-oklch
  '(0.9622 0.0384 83.83))

(define papaya-whip
  (make-parameter (make-palette papaya-whip-oklch)))

(define floral-white-oklch
  '(0.9819 0.0164 91.55))

(define floral-white
  (make-parameter (make-palette floral-white-oklch)))

(define ferrari-red-oklch
  '(0.6399 0.2466 31.39))

(define ferrari-red
  (make-parameter (make-palette ferrari-red-oklch)))

(define default-palettes
  (make-parameter (list (cons 'apple-green
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

