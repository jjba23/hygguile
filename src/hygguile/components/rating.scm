;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components rating)
  #:use-module (ice-9 format)
  #:use-module (srfi srfi-1)
  #:use-module (hygguile abstraction)
  #:use-module (hygguile components field)
  #:export (rating))

;; ===== A star rating =====
;;
;; A rating is a group of native radios and nothing else. Each radio is one
;; star, so the browser gives the group a single value, the arrow keys move
;; between the stars, the choice is announced as "3 of 5", and a form that
;; sends no script still sends the answer. The stars a reader sees are drawn
;; by the stylesheet from the radios that are checked, which is why this
;; component ships no script at all.
;;
;; The shell is the same four questions every field answers -- what is this
;; called, how is it described, is it wrong, is it required -- so it borrows
;; `field-wiring' from the field module rather than answering them again.
;; What it does not borrow is `form-field', because a group of controls is
;; named by a `<legend>', not by a `<label for>': a label points at one
;; control, and a rating is several.

(define rating-label-classes
  '(text-lg font-light text-onyx-100 dark:text-stone-300 font-sans))

(define rating-help-classes
  '(text-sm font-light text-onyx-300 dark:text-stone-500))

(define rating-error-classes
  '(text-sm font-medium text-redwood-700 dark:text-light-coral-100))

(define rating-valid-classes
  '(text-sm font-medium text-asparagus-900 dark:text-asparagus-300))

(define* (field-note id classes text #:key (role #f))
  "Render the paragraph a field shows under its control.

The role decides which of the two message styles the paragraph wears, and
so which glyph the stylesheet puts in front of it: an error is announced
(@var{role} is @code{\"alert\"}) as well as shown, which is what makes a
server-rendered error reach a reader who is not looking at the group."
  `((p (@ (id ,id)
          ,@(if role
                (list (cons 'role role))
                '())
          (class ,(mk-class (append classes
                                    (cond
                                      ((equal? role "alert")
                                       '(hg-error-message))
                                      ((equal? role "status")
                                       '(hg-success-message))
                                      (else '()))))))
       ,text)))

(define (star-input star-id
                    name
                    n
                    chosen
                    required
                    disabled)
  "Render one star's radio: the control behind a rating."
  `(input (@ (type "radio")
             (id ,star-id)
             (name ,(format #f "~a" name))
             (value ,(format #f "~a" n))
             (class "hg-rating-input")
             ,@(if (= n chosen)
                   '((checked ""))
                   '())
             ,@(if required
                   '((required ""))
                   '())
             ,@(if disabled
                   '((disabled ""))
                   '()))))

(define (star-label star-id spoken)
  "Render one star's label, whose glyph the stylesheet draws.

The label says nothing on screen -- the glyph is the star -- and says
everything to a screen reader, which hears \"3 of 5\" for this one choice.
That is why the words are in the markup and the star is not."
  `(label (@ (for ,star-id)
             (class "hg-rating-label")
             (title ,spoken))
          (span (@ (class "sr-only"))
                ,spoken)))

(define (static-star n chosen)
  "Render one star of a score that cannot be changed: real text, not a glyph."
  `(span (@ (aria-hidden "true")
            (class ,(if (<= n chosen) "hg-star hg-star-on"
                        "hg-star hg-star-off")))
         ,(if (<= n chosen) "★" "☆")))

(define* (rating #:key label
                 name
                 (id #f)
                 (value 0)
                 (max 5)
                 (required #f)
                 (disabled #f)
                 (readonly #f)
                 (help-text #f)
                 (error #f)
                 (valid #f)
                 (classes '(my-2 flex flex-col gap-1))
                 (label-css rating-label-classes)
                 (help-classes rating-help-classes)
                 (error-css rating-error-classes)
                 (valid-css rating-valid-classes))
  "Render a star rating: a group of native radios, or a static score.

In its default (interactive) form the rating is a real radio group, so it
works with scripting off and is navigated the way every other choice in a
form is: one tab stop, then the arrow keys. Each star carries a spoken name
-- \"3 of 5\" -- and the group is named by its `<legend>`, which is what a
screen reader announces rather than the stars themselves.

With @var{readonly} the rating is a single image with an accessible name
(\"4 out of 5\"): the stars are then what a page shows about a score it does
not let anyone change, such as an average review score.

@table @var
@item label
The name of the group, rendered as a `<legend>`.
@item name
The form field name; the value submitted is the number of stars chosen.
@item id
An explicit identifier for the group; defaults to @var{name}.
@item value
The number of stars that start filled. Defaults to @code{0}.
@item max
How many stars there are. Defaults to @code{5}.
@item required
Whether a rating has to be given.
@item disabled
Whether the group is disabled.
@item readonly
Show the score without letting it be changed.
@item help-text
Optional helper copy, linked with @code{aria-describedby}.
@item error
Optional validation message, announced with @code{role=\"alert\"}.
@item valid
@code{#t} to mark the rating as answered, or a string to say so in words.
@item classes
Classes for the field wrapper.
@item label-css
Classes for the legend.
@item help-classes
Classes for the helper copy.
@item error-css
Classes for the error message.
@item valid-css
Classes for the success message.
@end table

@example
(rating #:label \"How was your stay?\" #:name \"score\" #:value 4)
(rating #:label \"Average score\" #:name \"average\" #:value 4 #:readonly #t)
@end example"
  (let* ((stars (if (and (number? max)
                         (> max 0)) max 5))
         ;; `max' is this procedure's own keyword, so the chosen number of
         ;; stars cannot be clamped with the core procedure of that name
         (chosen (let ((given (if (number? value) value 0)))
                   (cond
                     ((< given 0)
                      0)
                     ((> given stars)
                      stars)
                     (else given))))
         (wiring (field-wiring #:name name
                               #:id id
                               #:help-text help-text
                               #:error error
                               #:required required))
         (group-id (field-id wiring))
         (help-id (field-help-id wiring))
         (error-id (field-error-id wiring))
         (described-by (field-described-by wiring))
         (numbers (iota stars 1))
         (star-id (lambda (n)
                    (format #f "~a-star-~a" group-id n)))
         (spoken (lambda (n)
                   (format #f "~a of ~a" n stars)))
         (interactive (append-map (lambda (n)
                                    (list (star-input (star-id n)
                                                      name
                                                      n
                                                      chosen
                                                      required
                                                      disabled)
                                          (star-label (star-id n)
                                                      (spoken n)))) numbers))
         (score (if readonly
                    (list `(span (@ (class "hg-rating-static")
                                    (role "img")
                                    (aria-label ,(format #f "~a out of ~a"
                                                         chosen stars)))
                                 ,@(map (lambda (n)
                                          (static-star n chosen)) numbers)))
                    '()))
                  ;; each star's radio is followed by its own label: that is what lets
                  ;; the stylesheet fill the stars below the chosen one by emptying the
                  ;; ones that follow it, and what puts a focus ring on the star a
                  ;; reader has tabbed to
                  (state-classes (cond
                                   (error '(hg-field-invalid))
                                   (valid '(hg-field-valid))
                                   (else '())))
                  (success (and valid
                                (not error)
                                (if (string? valid) valid #f)))
                  (body (if readonly
                            score
                            interactive)))
             `((div (@ (class ,(mk-class (append classes
                                                 (cons 'hg-rating-field state-classes)))))
           (fieldset (@ (class "hg-rating-group")
                        ,@(if described-by
                              (list (cons 'aria-describedby described-by))
                              '())
                        ,@(if required
                              '((aria-required "true"))
                              '())
                        ,@(if error
                              '((aria-invalid "true"))
                              '()))
                     (legend (@ (class ,(mk-class label-css)))
                             ,label
                             ,@(if required
                                   (list `(span (@ (aria-hidden "true")
                                                   (class ,(mk-class '(text-redwood-700
                                                                       dark:text-light-coral-100))))
                                                " *")
                                         `(span (@ (class "sr-only"))
                                                " (required)"))
                                   '()))
                     (div (@ (class "hg-rating"))
                          ,@body))
                      ,@(if error
                            (field-note error-id error-css error #:role "alert")
                            '())
                      ,@(if success
                            (field-note (format #f "~a-valid" group-id)
                                        valid-css success #:role "status")
                            '())
                      ,@(if help-text
                            (field-note help-id help-classes help-text)
                            '())))))
