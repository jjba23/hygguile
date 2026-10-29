;; hygguile - cozy and professional user-interfaces for everyone
;;
;; SPDX-License-Identifier: MIT
;; Copyright © Josep Bigorra <jjbigorra@gmail.com>

(define-module (hygguile components table)
  #:use-module (hygguile abstraction)
  #:use-module (srfi srfi-1)
  #:use-module (web uri)
  #:use-module (hygguile components feedback)
  #:export (table caption
                  thead
                  tbody
                  tfoot
                  tr
                  th
                  td
                  sort-href
                  parse-sort
                  table-column
                  sortable-table))

(define (align-classes align numeric)
  "Return the text-align and tabular-figure utility classes for a table cell.

A numeric cell with no explicit alignment is right-aligned, which is what
columns of figures want; passing @code{#:align} overrides that.

@table @var
@item align
A symbol, one of @code{'left}, @code{'right}, @code{'center} or @code{#f}.
@item numeric
A boolean adding @code{tabular-nums}, so columns of figures line up.
@end table"
  (append (cond
            ((eq? 'right align)
             '(text-right))
            ((eq? 'center align)
             '(text-center))
            ((eq? 'left align)
             '(text-left))
            ((and numeric
                  (not align))
             '(text-right))
            (else '()))
          (if numeric
              '(tabular-nums)
              '())))

(define (cell-classes classes align numeric nowrap)
  "Return the sorted class list shared by @code{th} and @code{td} cells.

@table @var
@item classes
List of symbols representing the caller-supplied cell classes.
@item align
A symbol passed on to @code{align-classes}.
@item numeric
A boolean passed on to @code{align-classes}.
@item nowrap
A boolean adding @code{whitespace-nowrap}, useful for narrow headers.
@end table"
  (mk-class (append classes
                    (align-classes align numeric)
                    (if nowrap
                        '(whitespace-nowrap)
                        '()))))

(define* (caption-node content
                       #:key (position 'top)
                       (classes '(py-2 px-3
                                       text-left
                                       text-sm
                                       font-light
                                       text-onyx-300
                                       dark:text-stone-500)))
  "Build the S-expression of an HTML @code{<caption>} element.

This is the shared implementation behind the exported @code{caption}
component and the @code{#:caption} key argument of @code{table}.

@table @var
@item content
The caption text string or inline nodes.
@item position
A symbol placing the caption above or below the table.
@item classes
List of symbols representing typography CSS classes.
@end table"
  `((caption (@ (class ,(mk-class (append classes
                                          (if (eq? 'bottom position)
                                              '(caption-bottom)
                                              '(caption-top))))))
             ,content)))

(define* (caption content
                  #:key (position 'top)
                  (classes '(py-2 px-3
                                  text-left
                                  text-sm
                                  font-light
                                  text-onyx-300
                                  dark:text-stone-500)))
  "Create an HTML @code{<caption>} naming a data table.

A caption is the accessible name of the table: assistive technology
announces it when the table is reached, so it is worth writing even when
a nearby heading says almost the same thing.

@table @var
@item content
The caption text string or inline nodes.
@item position
A symbol placing the caption above (@code{'top}, the default) or below
(@code{'bottom}) the table, purely through the @code{caption-side} property.
@item classes
List of symbols representing typography CSS classes.
@end table

@example
(caption \"Quarterly revenue\")
@end example"
  (caption-node content
                #:position position
                #:classes classes))

(define* (table content
                #:key (caption #f)
                (caption-position 'top)
                (caption-classes '(py-2 px-3
                                        text-left
                                        text-sm
                                        font-light
                                        text-onyx-300
                                        dark:text-stone-500))
                (scroll #t)
                (scroll-label #f)
                (table-attributes '())
                (container-attributes '())
                (table-classes '(w-full min-w-full border-collapse text-left))
                (container-classes '(my-4 w-full max-w-full overflow-x-auto)))
  "Create a semantic HTML @code{<table>} for tabular data.

Rows are built from @code{thead}, @code{tbody}, @code{tfoot},
@code{tr}, @code{th} and @code{td} nodes, so every piece of the table
keeps its native meaning: browsers, screen readers and crawlers all
understand the relationship between headers and cells without any
scripting.

Wide tables are a common source of horizontal page overflow on phones.
By default the table is therefore wrapped in a scrollable region that
carries @code{role=\"region\"} and an accessible name, and that is
reachable with @code{tabindex}, so keyboard users can scroll it too.
Pass @code{#:scroll #f} when you would rather handle the overflow
yourself.

@table @var
@item content
The row groups making up the table, typically a @code{thead},
a @code{tbody} and an optional @code{tfoot}.
@item caption
An optional caption rendered as the table's own @code{caption} element.
@item caption-position
A symbol placing that caption @code{'top} (default) or @code{'bottom}.
@item caption-classes
List of symbols representing caption typography CSS classes.
@item scroll
A boolean wrapping the table in an accessible horizontally scrollable region.
@item scroll-label
An optional accessible name for that region; it defaults to a string caption.
@item table-attributes
Extra attributes for the @code{<table>} itself, as pairs.
@item container-attributes
Extra attributes for the scroll region, as pairs.
@item table-classes
List of symbols representing the table layout CSS classes.
@item container-classes
List of symbols representing the scroll container CSS classes.
@end table

@example
(table (list (thead (list (tr (list (th \"Plan\" #:scope 'col)
                                   (th \"Price\" #:scope 'col #:numeric #t)))))
             (tbody (list (tr (list (td \"Cozy\")
                                    (td \"9\" #:numeric #t))))))
       #:caption \"Plans\")
@end example"
  (let* ((caption-element (if caption
                              (caption-node caption
                                            #:position caption-position
                                            #:classes caption-classes)
                              '()))
         (accessible-name (cond
                            ((and scroll-label
                                  (string? scroll-label))
                             scroll-label)
                            ((string? caption)
                             caption)
                            (else "Table")))
         (table-node `((table (@ ,@table-attributes
                                   (class ,(mk-class table-classes)))
                              ,@caption-element
                              ,content))))
    (if scroll
        `((div (@ ,@container-attributes
                  (role "region")
                  (tabindex "0")
                  (aria-label ,accessible-name)
                  (class ,(mk-class container-classes)))
               ,@table-node)) table-node)))

(define* (thead rows
                #:key (classes '(bg-stone-500/25 dark:bg-onyx-500/25)))
  "Create an HTML @code{<thead>} row group holding the column headers.

@table @var
@item rows
A list of @code{tr} rows built from @code{th} cells.
@item classes
List of symbols representing the header group CSS classes.
@end table

@example
(thead (list (tr (list (th \"Name\" #:scope 'col)))))
@end example"
  `((thead (@ (class ,(mk-class classes)))
           ,@rows)))

(define* (tbody rows
                #:key (classes '()))
  "Create an HTML @code{<tbody>} row group holding the data rows.

@table @var
@item rows
A list of @code{tr} rows built from @code{td} cells.
@item classes
List of symbols representing the body group CSS classes.
@end table

@example
(tbody (list (tr (list (td \"Ada Lovelace\")))))
@end example"
  `((tbody (@ ,@(attr-when (not (null? classes))
                           'class
                           (mk-class classes)))
           ,@rows)))

(define* (tfoot rows
                #:key (classes '(bg-stone-500/25 dark:bg-onyx-500/25
                                                 font-medium)))
  "Create an HTML @code{<tfoot>} row group for summaries and totals.

@table @var
@item rows
A list of @code{tr} rows, usually a single row of totals.
@item classes
List of symbols representing the footer group CSS classes.
@end table

@example
(tfoot (list (tr (list (th \"Total\" #:scope 'row)
                       (td \"42\" #:numeric #t)))))
@end example"
  `((tfoot (@ (class ,(mk-class classes)))
           ,@rows)))

(define* (tr cells
             #:key (classes '()))
  "Create an HTML table row (@code{<tr>}) from a list of cells.

@table @var
@item cells
A list of @code{th} or @code{td} cells.
@item classes
List of symbols representing optional row CSS classes.
@end table

@example
(tr (list (td \"Cozy\") (td \"9\" #:numeric #t)))
@end example"
  `((tr (@ ,@(attr-when (not (null? classes))
                        'class
                        (mk-class classes)))
        ,@cells)))

(define* (th content
             #:key (scope 'col)
             (align #f)
             (numeric #f)
             (nowrap #f)
             (colspan #f)
             (aria-sort #f)
             (resizable? #f)
             (classes '(px-3 py-2
                             align-top
                             font-medium
                             border-b-2
                             border-stone-500/50
                             dark:border-onyx-100/50
                             text-onyx-300
                             dark:text-stone-300)))
  "Create an HTML @code{<th>} header cell.

Every header is given an explicit @code{scope} by default, which lets
assistive technology tie the header to the column or row it describes
without guessing.

@table @var
@item content
The header text string or inline nodes.
@item scope
A symbol, one of @code{'col} (default), @code{'row}, @code{'colgroup} or @code{'rowgroup}.
@item align
A symbol, one of @code{'left}, @code{'right} or @code{'center}.
By default a header inherits the table's alignment.
@item numeric
A boolean enabling tabular figures and, unless @var{align} says
otherwise, right-aligning the header.
@item nowrap
A boolean preventing the header from wrapping.
@item colspan
A number of columns this cell spans.
@item aria-sort
A symbol or string from @code{ascending}, @code{descending} or @code{none}.
Set by @code{sortable-table} to announce the order a sortable column is in;
@code{none} marks a column that can be sorted but is not.
@item resizable?
Whether the header cell carries a column-resize handle (an enhancement).
@item classes
List of symbols representing the header cell CSS classes.
@end table

@example
(th \"Price\" #:align 'right #:numeric #t)
@end example"
  `((th (@ (scope ,(symbol->string scope))
           ,@(attr-when colspan
                        'colspan
                        (format #f "~a" colspan))
           ,@(attr-when aria-sort
                        'aria-sort
                        (if (symbol? aria-sort)
                            (symbol->string aria-sort) aria-sort))
           (class ,(cell-classes classes align numeric nowrap)))
        ,content
        ,@(if resizable?
              (list `(span (@ (class "hg-column-resizer")
                              (data-hg-column-resizer "")
                              (aria-hidden "true"))))
              '()))))

(define* (td content
             #:key (align #f)
             (numeric #f)
             (nowrap #f)
             (colspan #f)
             (classes '(px-3 py-2
                             align-top
                             border-b-2
                             border-stone-500/50
                             dark:border-onyx-100/50
                             text-onyx-500
                             dark:text-stone-300)))
  "Create an HTML @code{<td>} data cell.

@table @var
@item content
The cell text string or inline nodes.
@item align
A symbol, one of @code{'left}, @code{'right} or @code{'center}.
By default a cell inherits the table's alignment.
@item numeric
A boolean enabling tabular figures and, unless @var{align} says
otherwise, right-aligning the cell, so columns of numbers line up digit
by digit.
@item nowrap
A boolean preventing the cell from wrapping.
@item colspan
A number of columns this cell spans, which is what a totals row and an
empty state need.
@item classes
List of symbols representing the data cell CSS classes.
@end table

@example
(td \"1 204\" #:numeric #t)
@end example"
  `((td (@ ,@(attr-when colspan
                        'colspan
                        (format #f "~a" colspan))
           (class ,(cell-classes classes align numeric nowrap)))
        ,content)))

;; ===== Server-driven sorting =====
;;
;; The order of a table belongs to the server, and the URL is where a server
;; gets it. A sortable header cell is therefore an ordinary link: clicking it
;; navigates to the same page with the two names below set to the column and
;; the direction, the server reads them, and renders the rows in the order it
;; was asked for. Nothing has to run in the browser, so the table sorts with
;; JavaScript disabled, a reload reproduces the order, and a shared or
;; bookmarked link opens on the same view.

;; The two names the order travels under. Every page has query parameters of
;; its own, and `sort' and `dir' are a common enough pair for an application
;; to be using for something else entirely, so the table's state is prefixed
;; with the library's name instead of claiming a bare one.
(define sort-key-param
  "hygguile-table-sort")

(define sort-direction-param
  "hygguile-table-dir")

;; They are replaced rather than carried over when a link is built, since a
;; link is asking for a new order: leaving the old pair in place would put
;; two contradictory orders in one URL, and a server reading the first one
;; would ignore the click.
(define sort-state-params
  (list sort-key-param sort-direction-param))

(define (param-string value)
  "Return a query parameter name or value as a string, whatever it was written as."
  (cond
    ((string? value)
     value)
    ((symbol? value)
     (symbol->string value))
    (else (format #f "~a" value))))

(define (query-ref params name)
  "Return the value of @var{name} in a decoded query, or @code{#f}.

Accepts an association list such as @code{((\"filter\" . \"active\"))} or the
SXML-flavoured @code{((filter active))}, so it can be handed the query as
the framework or the caller happens to hold it."
  (let ((hit (find (lambda (entry)
                     (and (pair? entry)
                          (equal? name
                                  (param-string (car entry))))) params)))
    (and hit
         (let ((value (cdr hit)))
           (if (pair? value)
               (car value) value)))))

(define* (sort-href #:key (path #f)
                    (params '())
                    (drop-params '("page"))
                    (sort #f)
                    (direction 'asc))
  "Build the URL asking the server to order a table by @var{sort} in @var{direction}.

The link a header cell carries is the whole sorting state: the server
reads it back on the next request, and a reload or a shared link
reproduces the same order without any scripting. The order itself travels
in @code{hygguile-table-sort} and @code{hygguile-table-dir}, prefixed so
that a page's own @code{sort} or @code{dir} parameter is never mistaken
for the table's state. Every value is URL-encoded, and the parameters
named in @var{drop-params} are left out, because they describe a
position in the order that is being replaced: keeping @code{page=4}
while the sort changes would show an arbitrary slice of the new order.
Sorting therefore starts at the first page.

An order already present in @var{params} is replaced, not repeated, so
the whole query such a page received can be handed straight back in
without the link contradicting itself. Parameters of the page's own are
carried over untouched, however they are named: a page whose @code{sort}
means something else keeps it.

With no @var{path} the href is a bare query, such as
@code{?hygguile-table-sort=seats&hygguile-table-dir=desc}, which the
browser resolves against the page's own path. That is what a table route
wants, since one route renders the page and handles the sort.

@table @var
@item path
An optional path to prefix the query with, such as @code{\"/plans\"}.
@item params
An association list of other query parameters to carry over, such as
@code{'((\"filter\" . \"active\"))}. Symbol names and non-string values
are converted.
@item drop-params
Names removed from @var{params} first. Defaults to @code{\"page\"}.
@item sort
The key of the column to order by, as a symbol or a string. @code{#f}
asks for the natural order instead, which is how a \"stop sorting\" link
is built.
@item direction
@code{'asc} (the default) or @code{'desc}.
@end table

@example
(sort-href #:params '((\"page\" . \"4\"))
           #:sort 'seats #:direction 'desc)
;; => \"?hygguile-table-sort=seats&hygguile-table-dir=desc\"
@end example"
  (let* ((dropped (append (map param-string drop-params) sort-state-params))
         (kept (filter (lambda (pair)
                         (not (member (param-string (car pair)) dropped)))
                       params))
         (pairs (append (map (lambda (pair)
                               (cons (param-string (car pair))
                                     (param-string (cdr pair)))) kept)
                        (if sort
                            (list (cons sort-key-param
                                        (param-string sort))
                                  (cons sort-direction-param
                                        (param-string direction)))
                            '())))
         (query (string-join (map (lambda (pair)
                                    (format #f "~a=~a"
                                            (uri-encode (car pair))
                                            (uri-encode (cdr pair)))) pairs)
                             "&")))
    (cond
      ((null? pairs)
       (if path
           (format #f "~a" path) "?"))
      (path (format #f "~a?~a" path query))
      (else (format #f "?~a" query)))))

(define (direction-symbol value)
  "Return @code{'asc} or @code{'desc} for a direction, or @code{#f} for anything else."
  (cond
    ((eq? 'asc value)
     'asc)
    ((eq? 'desc value)
     'desc)
    ((string? value)
     (cond
       ((string-ci=? "asc" value)
        'asc)
       ((string-ci=? "desc" value)
        'desc)
       (else #f)))
    (else #f)))

(define (column-sort-key column)
  "Return the sort key of a column descriptor, or @code{#f} when it has none.

A column may be a @code{table-column} descriptor or a bare key, so a table
that only needs keys can be written as @code{' (name seats)}."
  (cond
    ((null? column)
     #f)
    ((pair? column)
     (let ((hit (assq 'key column)))
       (and hit
            (cdr hit))))
    (else column)))

(define (column-field column field default)
  "Read @var{field} out of a column descriptor, falling back to @var{default}."
  (let ((hit (and (pair? column)
                  (assq field column))))
    (if hit
        (cdr hit) default)))

(define (column-active? column active)
  "True when @var{column} is the column the current request is ordered by."
  (let ((key (column-sort-key column)))
    (and key active
         (equal? (param-string key)
                 (param-string (column-sort-key active))))))

(define (next-sort-direction column active direction default-direction)
  "Return the direction a click on @var{column} should ask the server for next.

Clicking the column the table is already ordered by reverses it; clicking
any other column starts that column in its own direction, or the table's
when it declares none."
  (if (column-active? column active)
      (if (eq? 'desc direction)
          'asc
          'desc)
      (let ((explicit (column-field column
                                    'default-direction #f)))
        (cond
          ((eq? 'asc explicit)
           'asc)
          ((eq? 'desc explicit)
           'desc)
          (else default-direction)))))

(define* (table-column #:key label
                       (key #f)
                       (numeric #f)
                       (sortable #t)
                       (default-direction #f)
                       (align #f)
                       (nowrap #f))
  "Describe one column of a @code{sortable-table}.

@table @var
@item label
The text shown in the header cell. When omitted, the sort key is used.
@item key
The sort key this column is ordered by, and the value that travels in the
URL as @code{?hygguile-table-sort=}. Symbols are conventional. A column
without a key is
rendered but not sortable, which is what a column of row actions wants.
@item numeric
A boolean right-aligning the column and letting its digits line up.
@item sortable
A boolean; @code{#f} renders a plain header cell even when a key is given.
@item default-direction
The direction the first click on this column asks for, @code{'asc} or
@code{'desc}. Defaults to the table's own @code{#:default-direction}.
@item align
A symbol, one of @code{'left}, @code{'right} or @code{'center}, overriding
the numeric default.
@item nowrap
A boolean preventing this column's cells from wrapping.
@end table

@example
(table-column #:key 'seats #:label \"Seats\" #:numeric #t)
@end example"
  (list (cons 'label label)
        (cons 'key key)
        (cons 'numeric numeric)
        (cons 'sortable sortable)
        (cons 'default-direction default-direction)
        (cons 'align align)
        (cons 'nowrap nowrap)))

(define* (parse-sort params
                     #:key (columns '())
                     (default-direction 'asc))
  "Read the requested sort state out of a decoded query.

This is the other half of @code{sortable-table}: the component writes the
order into the URL, and this reads it back on the following request, so a
route only has to hand over the query it decoded. Only the two prefixed
names are read, so a @code{sort} or a @code{dir} belonging to the page's
own query is left to the page.

A key no column declares is reported as no sort at all rather than passed
through, so a hand-edited, stale or truncated link falls back to the
natural order instead of reaching the query layer. The key that comes back
is the column's own, not the string from the URL, so it can be compared
with @code{eq?} and handed straight back to @code{sortable-table}.

@table @var
@item params
The decoded query, an association list such as
@code{'((\"hygguile-table-sort\" . \"seats\"))}; symbol names and
@code{(name value)} pairs are accepted too.
@item columns
The column descriptors given to @code{sortable-table}, or a plain list of
sort keys.
@item default-direction
The direction used when the URL asks for none. Defaults to @code{'asc}.
@end table

Returns a two-element list, @code{(key direction)}, where @code{key} is
@code{#f} when the request asks for the natural order.

@example
(parse-sort '((\"hygguile-table-sort\" . \"seats\")
              (\"hygguile-table-dir\" . \"desc\"))
            #:columns (list (table-column #:key 'seats #:label \"Seats\")))
;; => (seats desc)
@end example"
  (let ((requested (query-ref params sort-key-param))
        (keys (filter identity
                      (map column-sort-key columns))))
    (list (and requested
               (find (lambda (key)
                       (equal? (param-string key)
                               (param-string requested))) keys))
          (or (direction-symbol (query-ref params sort-direction-param))
              default-direction))))

(define (header-text label key)
  "Return the text a header cell shows: its label, or its key, always as a string.

A key is a symbol, and SXML content has to be a string or a node: a bare
symbol would be dropped by the serializer, which is how a column with no
label ends up with an empty header."
  (let ((text (if label label key)))
    (cond
      ((string? text)
       text)
      ((symbol? text)
       (symbol->string text))
      (else (format #f "~a" text)))))

(define* (sort-link label
                    key
                    #:key (path #f)
                    (params '())
                    (drop-params '("page"))
                    active
                    (direction 'asc)
                    (next-direction 'asc))
  "Build the link a sortable header cell carries.

The link is the header's whole interactive area, so its box fills the cell
and the padding that used to sit on the cell sits on the link instead. The
arrow beside the label shows the order the column is in -- @var{direction},
up or down -- and is replaced by a dimmed double arrow when the column is
not the one ordering the table (@var{active}). The arrow is decorative,
because the state is already in the cell's @code{aria-sort}, so it is
hidden from assistive technology; the link's @code{title} says what a click
would do next, which is @var{next-direction}.

The link names its own ink -- the page's link colours, one per theme --
because a bare @code{<a>} would fall back to the browser's default blue,
which is off-palette and unreadable on a dark surface."
  (let ((href (sort-href #:path path
                         #:params params
                         #:drop-params drop-params
                         #:sort key
                         #:direction next-direction)))
    `((a (@ (href ,href)
            (title ,(if (eq? 'asc next-direction) "Sort ascending"
                        "Sort descending"))
            ;; the ink is the page's link ink rather than the header cell's:
            ;; a bare <a> would otherwise fall back to the browser's default
            ;; blue, which is off-palette and unreadable on the dark theme
            (class ,(mk-class '(block cursor-pointer
                                      select-none
                                      px-3
                                      py-2
                                      no-underline
                                      hover:underline
                                      text-jeans-blue-500
                                      dark:text-moonstone-300
                                      hover:text-jeans-blue-900
                                      dark:hover:text-moonstone-100
                                      transition-colors
                                      duration-150
                                      focus-visible:outline-2
                                      focus-visible:outline-offset-2
                                      outline-jeans-blue-500))))
         ,(header-text label key)
         (span (@ (aria-hidden "true")
                  (class ,(mk-class (append '(ml-1)
                                            (if active
                                                '()
                                                '(opacity-60))))))
               ,(if active
                    (if (eq? 'desc direction) "↓" "↑") "↕"))))))

(define* (sortable-header-cell column
                               active
                               direction
                               default-direction
                               path
                               params
                               drop-params
                               #:key (classes '(p-0 align-top
                                                    font-medium
                                                    border-b-2
                                                    border-stone-500/50
                                                    dark:border-onyx-100/50
                                                    text-onyx-300
                                                    dark:text-stone-300))
                               (resizable? #f))
  "Build one header cell: a plain @code{th}, or one wrapping a sort link."
  (let ((key (column-sort-key column))
        (numeric (column-field column
                               'numeric #f))
        (align (column-field column
                             'align #f))
        (nowrap (column-field column
                              'nowrap #f)))
    (if (not (and key
                  (column-field column
                                'sortable #t)))
        (th (header-text (column-field column
                                       'label #f) key)
            #:scope 'col
            #:numeric numeric
            #:align align
            #:nowrap nowrap
            #:resizable? resizable?)
        (let ((is-active (column-active? column active)))
          (th (sort-link (column-field column
                                       'label #f)
                         key
                         #:path path
                         #:params params
                         #:drop-params drop-params
                         #:active is-active
                         #:direction (if is-active direction default-direction)
                         #:next-direction (next-sort-direction column active
                                           direction default-direction))
              #:scope 'col
              #:numeric numeric
              #:align align
              #:nowrap nowrap
              #:aria-sort (cond
                            ((not is-active)
                             "none")
                            ((eq? 'desc direction)
                             "descending")
                            (else "ascending"))
              #:classes classes
              #:resizable? resizable?)))))

(define* (sortable-table #:key columns
                         (rows '())
                         (sort #f)
                         (direction 'asc)
                         (path #f)
                         (params '())
                         (drop-params '("page"))
                         (default-direction 'asc)
                         (caption #f)
                         (caption-position 'top)
                         (caption-classes '(py-2 px-3
                                                 text-left
                                                 text-sm
                                                 font-light
                                                 text-onyx-300
                                                 dark:text-stone-500))
                         (scroll #t)
                         (scroll-label #f)
                         (table-classes '(w-full min-w-full border-collapse
                                                 text-left))
                         (container-classes '(my-4 w-full max-w-full
                                                   overflow-x-auto))
                         (head-classes '(bg-stone-500/25 dark:bg-onyx-500/25))
                         (header-classes '(p-0 align-top
                                               font-medium
                                               border-b-2
                                               border-stone-500/50
                                               dark:border-onyx-100/50
                                               text-onyx-300
                                               dark:text-stone-300))
                         (cell-classes '(px-3 py-2
                                              align-top
                                              border-b-2
                                              border-stone-500/50
                                              dark:border-onyx-100/50
                                              text-onyx-500
                                              dark:text-stone-300))
                         (row-classes '())
                         (empty-message "Nothing to show yet")
                         (empty #f)
                         (sticky-header? #f)
                         (selectable? #f)
                         (select-name "selected")
                         (row-keys '())
                         (resizable? #f)
                         (density 'comfortable)
                         (zebra? #f)
                         (loading? #f)
                         (loading-rows 4)
                         (error #f)
                         (retry #f))
  "Create a data table whose column order lives in the URL.

Each sortable header cell is a link to the same page carrying
@code{hygguile-table-sort} and @code{hygguile-table-dir}, and the cell
announces the state it is in through @code{aria-sort}. Nothing runs in
the browser: clicking a header is an ordinary navigation, so the table
sorts with JavaScript disabled, a reload reproduces the order, and a
shared link opens on the same view. The server reads the order back with
@code{parse-sort}.

Clicking the column the table is already ordered by reverses it; clicking
another starts that column in its own direction. The other query
parameters travel along, except those in @var{drop-params}, so a filter
survives a sort while a page number does not.

@table @var
@item columns
A list of @code{table-column} descriptors, or of bare sort keys.
@item rows
A list of rows, each a list of cell contents matching the columns by
position. A short row simply leaves its trailing cells empty.
@item sort
The key of the column currently ordered, or @code{#f} for the natural
order. A key no column declares is ignored.
@item direction
The current direction, @code{'asc} (the default) or @code{'desc}.
@item path
The path the links point at, when it differs from the page that renders
them. By default they are bare queries, which keep the current path.
@item params
Other query parameters to carry over, as for @code{sort-href}.
@item drop-params
Parameters removed when the sort changes. Defaults to @code{\"page\"}.
@item default-direction
The direction a column starts in when it declares none.
@item caption
An optional caption rendered as the table's own @code{caption} element.
@item caption-position
A symbol placing that caption @code{'top} (default) or @code{'bottom}.
@item caption-classes
List of symbols representing caption typography CSS classes.
@item scroll
A boolean wrapping the table in an accessible horizontally scrollable region.
@item scroll-label
An optional accessible name for that region; it defaults to a string caption.
@item table-classes
List of symbols representing the table layout CSS classes.
@item container-classes
List of symbols representing the scroll container CSS classes.
@item head-classes
List of symbols representing the header row group CSS classes.
@item header-classes
List of symbols representing a sortable header cell. The cell's padding
moves to the link, so the link covers the whole cell.
@item cell-classes
List of symbols representing the data cell CSS classes.
@item row-classes
List of symbols representing each body row's CSS classes.
@item empty-message
What a table with no rows says, spanning every column.
@end table

A totals row or any other bespoke footer is the one thing this component
leaves out: reach for @code{table} with @code{tfoot}, and for
@code{sort-href} plus @code{th #:aria-sort} to build the header the same
way by hand.

@example
(sortable-table #:columns (list (table-column #:key 'plan #:label \"Plan\")
                                (table-column #:key 'seats #:label \"Seats\"
                                              #:numeric #t))
                #:rows (list (list \"Cozy\" \"3\"))
                #:sort 'seats #:direction 'desc
                #:caption \"Plans\")
@end example"
  (cond
    ((and error retry)
     (list (error-state #:title "The table could not load"
                        #:body error
                        #:retry retry)))
    (error
     (list (error-state #:title "The table could not load"
                        #:body error)))
    (loading?
     (list (skeleton-table #:rows loading-rows
                           #:columns (max 1 (length columns)))))
    (else
     (let* ((active (and sort
                         (find (lambda (column)
                                 (let ((key (column-sort-key column)))
                                   (and key
                                        (equal? (param-string key)
                                                (param-string sort))))) columns)))
            (span-count (if selectable? 1 0))
            (selection-header
             (if selectable?
                 (list (th (list `(input (@ (type "checkbox")
                                            (data-hg-select-all "")
                                            (aria-label "Select all rows")
                                            (class "hg-checkbox"))))
                            #:scope 'col
                            #:classes '(px-3 py-2 w-10)))
                 '()))
            (header-row (append selection-header
                                (map (lambda (column)
                                       (sortable-header-cell column
                                                             active
                                                             direction
                                                             default-direction
                                                             path
                                                             params
                                                             drop-params
                                                             #:classes header-classes
                                                             #:resizable? resizable?))
                                     columns)))
            (selection-cell (lambda (row-index)
                              (let ((key (if (< row-index (length row-keys))
                                             (list-ref row-keys row-index)
                                             (number->string (+ row-index 1)))))
                                (td (list `(input (@ (type "checkbox")
                                                     (name ,select-name)
                                                     (value ,(format #f "~a" key))
                                                     (aria-label ,(format #f
                                                                          "Select row ~a"
                                                                          key))
                                                     (class "hg-checkbox"))))
                                    #:classes '(px-3 py-2 w-10)))))
            (body-rows (if (null? rows)
                           (list (tr (list (td (or empty empty-message)
                                               #:colspan (max 1
                                                              (+ span-count
                                                                 (length columns)))
                                               #:align 'center
                                               #:classes '(px-3 py-6 text-center
                                                           font-light
                                                           text-onyx-300
                                                           dark:text-stone-500)))))
                           (map (lambda (row row-index)
                                  (let ((cells (map (lambda (column index)
                                                      (td (if (< index
                                                                 (length row))
                                                              (list-ref row index) "")
                                                          #:numeric (column-field column
                                                                                  'numeric
                                                                                  #f)
                                                          #:align (column-field column
                                                                                'align #f)
                                                          #:nowrap (column-field column
                                                                                 'nowrap
                                                                                 #f)
                                                          #:classes cell-classes)) columns
                                                    (iota (length columns)))))
                                    (tr (append (if selectable?
                                                    (list (selection-cell row-index))
                                                    '())
                                                cells)
                                        #:classes (append row-classes
                                                          (if (and zebra?
                                                                   (odd? row-index))
                                                              '(hg-row-odd)
                                                              '())))))
                                rows (iota (length rows)))))
            (head (thead (list (tr header-row))
                         #:classes (append head-classes
                                           (if sticky-header?
                                               '(hg-sticky-header)
                                               '()))))
            (table-attrs (if resizable?
                             (list (cons 'data-hg-resizable ""))
                             '()))
            (container-attrs (if (eq? 'compact density)
                                 (list (cons 'data-density "compact"))
                                 '()))
            (container-classes* (append container-classes
                                        (if (eq? 'compact density)
                                            '(hg-density-compact)
                                            '()))))
       (table (list head (tbody body-rows))
              #:caption caption
              #:caption-position caption-position
              #:caption-classes caption-classes
              #:scroll scroll
              #:scroll-label scroll-label
              #:table-attributes table-attrs
              #:table-classes table-classes
              #:container-attributes container-attrs
              #:container-classes container-classes*)))))
