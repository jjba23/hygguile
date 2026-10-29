;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

;; The small panels the showcase builds its sections out of.

(define-module (showcase specimens)
  #:use-module (hygguile hygguile)
  #:export (showcase-specimen showcase-type-row showcase-email-control))

(define* (showcase-specimen title content
                            #:key (classes '()))
  "A small labelled panel used to show one primitive on the showcase."
  `((div (@ (class ,(mk-class (append '(rounded-xl border-2
                                                   border-stone-500/25
                                                   dark:border-onyx-100/25
                                                   bg-stone-100/50
                                                   dark:bg-onyx-900/50
                                                   p-5
                                                   flex
                                                   flex-col
                                                   gap-4) classes))))
         ;; the label is a heading a reader reads before the specimen, not a
         ;; caption under it: at small it was set at 8px, which is decoration
         ;; rather than text, so it carries body size and keeps its letter
         ;; case for the contrast of a label
         (h4 (@ (class ,(mk-class '(text-md font-semibold uppercase
                                            tracking-wide text-onyx-300
                                            dark:text-stone-300))))
             ,title)
         ,@content)))

(define (showcase-type-row caption content)
  "One line of the type specimen: the classes it shows, then the text itself."
  `((div (@ (class ,(mk-class '(flex flex-col gap-1))))
         ;; the class list a specimen is annotated with is read by the same
         ;; eyes that read the specimen, so it is set at body-adjacent size
         ;; rather than as a whisper of 8px
         (span (@ (class ,(mk-class '(font-mono text-sm text-onyx-300
                                                dark:text-stone-500))))
               ,caption)
         ,content)))

(define (showcase-email-control w)
  `((input (@ ,@(field-control-attributes w)
              (type "email")
              (class ,(mk-class '(p-3 w-full
                                      rounded-xl
                                      border-2
                                      border-stone-700
                                      dark:border-onyx-100
                                      bg-stone-300/75
                                      dark:bg-onyx-700/75
                                      text-onyx-500
                                      dark:text-stone-300)))))))
