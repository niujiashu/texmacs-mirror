
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : generic-edit.scm
;; DESCRIPTION : Generic editing routines
;; COPYRIGHT   : (C) 2001  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (generic generic-edit)
  (:use (utils library tree)
	(utils library cursor)
	(utils edit variants)
        (bibtex bib-complete)
	(source macro-search)))

(tm-define (generic-context? t) #t) ;; overridden in, e.g., graphics mode

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic cursor movements via the keyboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (kbd-horizontal t forwards?)
  (and-with p (tree-outer t)
    (kbd-horizontal p forwards?)))

(tm-define (kbd-vertical t downwards?)
  (and-with p (tree-outer t)
    (kbd-vertical p downwards?)))

(tm-define (kbd-extremal t forwards?)
  (and-with p (tree-outer t)
    (kbd-extremal p forwards?)))

(tm-define (kbd-incremental t downwards?)
  (and-with p (tree-outer t)
    (kbd-incremental p downwards?)))

(tm-define (kbd-horizontal t forwards?)
  (:require (tree-is-buffer? t))
  (with move (lambda () (if forwards? (go-right) (go-left)))
    (go-to-next-such-that move generic-context?)))

(tm-define (kbd-vertical t downwards?)
  (:require (tree-is-buffer? t))
  (with move (lambda () (if downwards? (go-down) (go-up)))
    (go-to-next-such-that move generic-context?)))

(tm-define (kbd-extremal t forwards?)
  (:require (tree-is-buffer? t))
  (with move (lambda () (if forwards? (go-end-line) (go-start-line)))
    (go-to-next-such-that move generic-context?)))

(tm-define (kbd-incremental t downwards?)
  (:require (tree-is-buffer? t))
  (with move (lambda () (if downwards? (go-page-down) (go-page-up)))
    (go-to-next-such-that move generic-context?)))

(tm-define (kbd-left)
  (kbd-horizontal (focus-tree) #f))
(tm-define (kbd-right)
  (kbd-horizontal (focus-tree) #t))
(tm-define (kbd-up)
  (kbd-vertical (focus-tree) #f))
(tm-define (kbd-down)
  (kbd-vertical (focus-tree) #t))
(tm-define (kbd-start-line)
  (kbd-extremal (focus-tree) #f))
(tm-define (kbd-end-line)
  (kbd-extremal (focus-tree) #t))
(tm-define (kbd-page-up)
  (kbd-incremental (focus-tree) #f))
(tm-define (kbd-page-down)
  (kbd-incremental (focus-tree) #t))

(tm-define (kbd-select r)
  (select-from-shift-keyboard)
  (r)
  (select-from-cursor))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic editing via the keyboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (insert-return) (insert-raw-return))

(tm-define (kbd-space-bar t shift?)
  (and-with p (tree-outer t)
    (kbd-space-bar p shift?)))

(tm-define (kbd-enter t shift?)
  (and-with p (tree-outer t)
    (kbd-enter p shift?)))

(tm-define (kbd-control-enter t shift?)
  (and-with p (tree-outer t)
    (kbd-control-enter p shift?)))

(tm-define (kbd-alternate-enter t shift?)
  (and-with p (tree-outer t)
    (kbd-alternate-enter p shift?)))

(tm-define (kbd-remove t forwards?)
  (and-with p (tree-outer t)
    (kbd-remove p forwards?)))

(tm-define (kbd-variant t forwards?)
  (and-with p (tree-outer t)
    (kbd-variant p forwards?)))

(tm-define (kbd-space-bar t shift?)
  (:require (tree-is-buffer? t))
  (insert " "))

(tm-define (kbd-enter t shift?)
  (:require (tree-is-buffer? t))
  (insert-return))

(tm-define (kbd-control-enter t shift?)
  (:require (tree-is-buffer? t))
  (noop))

(tm-define (kbd-alternate-enter t shift?)
  (:require (tree-is-buffer? t))
  (noop))

(tm-define (kbd-remove t forwards?)
  (:require (tree-is-buffer? t))
  (remove-text forwards?))

(tm-define (kbd-remove t forwards?)
  (:require (and (tree-is-buffer? t) (with-any-selection?)))
  (clipboard-cut "nowhere")
  (clipboard-clear "nowhere"))

(tm-define (kbd-variant t forwards?)
  (:require (tree-is-buffer? t))
  (if (and (not (complete-try?)) forwards?)
      (with sh (kbd-system-rewrite (kbd-find-inv-binding '(kbd-alternate-tab)))
        (set-message `(concat "Use " ,sh " in order to insert a tab")
                     "tab"))))

(tm-define (kbd-variant t forwards?)
  (:require (and (tree-in? t '(label reference pageref)) (cursor-inside? t)))
  (if (complete-try?) (noop)))

(tm-define (bib-cite-context? t)
  (and (tree-in? t '(cite nocite cite-detail))
       (cursor-inside? t)
       (or (not (tree-is? t 'cite-detail))
           (== (tree-index (tree-down t)) 0))))

(tm-define (kbd-variant t forwards?)
  (:require (and (not (supports-db?)) (bib-cite-context? t)))
  (with u (current-bib-file #t)
    (with ttxt (tree-ref t (cADr (cursor-path)))
      (if (or (url-none? u) (not ttxt))
          (set-message "No completions" "You must add a bibliography file")
          (custom-complete (tm->tree (citekey-completions u ttxt)))))))

(tm-define (kbd-alternate-variant t forwards?)
  (and-with p (tree-outer t)
    (kbd-alternate-variant p forwards?)))

(tm-define (kbd-alternate-variant t forwards?)
  (:require (tree-is-buffer? t))
  (make-htab "5mm"))

(tm-define (kbd-space)
  (kbd-space-bar (focus-tree) #f))
(tm-define (kbd-shift-space)
  (kbd-space-bar (focus-tree) #t))
(tm-define (kbd-return)
  (kbd-enter (focus-tree) #f))
(tm-define (kbd-shift-return)
  (kbd-enter (focus-tree) #t))
(tm-define (kbd-control-return)
  (kbd-control-enter (focus-tree) #f))
(tm-define (kbd-shift-control-return)
  (kbd-control-enter (focus-tree) #t))
(tm-define (kbd-alternate-return)
  (kbd-alternate-enter (focus-tree) #f))
(tm-define (kbd-shift-alternate-return)
  (kbd-alternate-enter (focus-tree) #t))
(tm-define (kbd-backspace)
  (kbd-remove (focus-tree) #f))
(tm-define (kbd-delete)
  (kbd-remove (focus-tree) #t))
(tm-define (kbd-tab)
  (kbd-variant (focus-tree) #t))
(tm-define (kbd-shift-tab)
  (kbd-variant (focus-tree) #f))
(tm-define (kbd-alternate-tab)
  (kbd-alternate-variant (focus-tree) #t))
(tm-define (kbd-shift-alternate-tab)
  (kbd-alternate-variant (focus-tree) #f))

(tm-define (notify-activated t) (noop))
(tm-define (notify-disactivated t) (noop))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Basic predicates
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (simple-tags)
  '(concat document tformat table row cell shown hidden))

(tm-define (complex-context? t)
  (and (nleaf? t)
       (nin? (tree-label t) (simple-tags))))

(tm-define (simple-context? t)
  (or (leaf? t)
      (and (tree-in? t (simple-tags))
           (simple-context? (tree-down t)))))

(tm-define (document-context? t)
  (tree-is? t 'document))

(tm-define (table-markup-context? t)
  (or (tree-in? t '(table tformat))
      (and (== (tree-arity t) 1)
           (or (tree-in? (tree-ref t 0) '(table tformat))
               (and (tm-func? (tree-ref t 0) 'document 1)
                    (tree-in? (tree-ref t 0 0) '(table tformat)))))))

(tm-define (structured-horizontal? t)
  (or (tree-is-dynamic? t)
      (table-markup-context? t)))

(tm-define (structured-vertical? t)
  (or (tree-in? t '(tree))
      (table-markup-context? t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tree traversal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (traverse-horizontal t forwards?)
  (if forwards? (go-to-next-word) (go-to-previous-word)))

(tm-define (traverse-vertical t downwards?)
  (and-with p (tree-outer t)
    (traverse-vertical p downwards?)))

(tm-define (traverse-vertical t downwards?)
  (:require (document-context? t))
  (with move (if downwards? go-to-next-tag go-to-previous-tag)
    (move 'document)))

(define (find-similar-upwards t l)
  (cond ((in? (tree-label t) l) t)
        ((and (not (tree-is-buffer? t)) (tree-up t))
         (find-similar-upwards (tree-up t) l))
        (else #f)))

(define-macro (with-focus-in l . body)
  `(begin
     ,@body
     (selection-cancel)
     (and-with t (find-similar-upwards (focus-tree) ,l)
       (tree-focus t))))

(tm-define (traverse-incremental t forwards?)
  (let* ((l (similar-to (tree-label t)))
         (fun (if forwards? go-to-next-tag go-to-previous-tag)))
    (with-focus-in l (fun l))))

(tm-define (traverse-extremal t forwards?)
  (let* ((l (similar-to (tree-label t)))
         (fun (if forwards? go-to-next-tag go-to-previous-tag))
         (inc (lambda () (fun l))))
    (with-focus-in l
      (go-to-repeat inc)
      (structured-inner-extremal t forwards?))))

(tm-define (traverse-previous)
  (traverse-incremental (focus-tree) #f))
(tm-define (traverse-next)
  (traverse-incremental (focus-tree) #t))
(tm-define (traverse-first)
  (traverse-extremal (focus-tree) #f))
(tm-define (traverse-last)
  (traverse-extremal (focus-tree) #t))
(tm-define (traverse-left)
  (traverse-horizontal (focus-tree) #f))
(tm-define (traverse-right)
  (traverse-horizontal (focus-tree) #t))
(tm-define (traverse-up)
  (traverse-vertical (focus-tree) #f))
(tm-define (traverse-down)
  (traverse-vertical (focus-tree) #t))
(tm-define (traverse-previous-section-title)
  (go-to-previous-tag (similar-to 'section)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Structured insert and remove
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (structured-insert-horizontal t forwards?)
  (and-with p (tree-outer t)
    (structured-insert-horizontal p forwards?)))

(tm-define (structured-insert-vertical t downwards?)
  (and-with p (tree-outer t)
    (structured-insert-vertical p downwards?)))

(tm-define (structured-remove-horizontal t forwards?)
  (and-with p (tree-outer t)
    (structured-remove-horizontal p forwards?)))

(tm-define (structured-remove-vertical t downwards?)
  (and-with p (tree-outer t)
    (structured-remove-vertical p downwards?)))

(tm-define (structured-insert-horizontal t forwards?)
  (:require (structured-horizontal? t))
  (when (tree->path t :down)
    (insert-argument-at (tree->path t :down) forwards?)))

(tm-define (structured-remove-horizontal t forwards?)
  (:require (structured-horizontal? t))
  (when (tree->path t :down)
    (remove-argument-at (tree->path t :down) forwards?)))

(tm-define (structured-insert-extremal t forwards?)
  (structured-extremal t forwards?)
  (structured-insert-horizontal t forwards?))

(tm-define (structured-insert-incremental t downwards?)
  (structured-incremental t downwards?)
  (structured-insert-vertical t downwards?))

(tm-define (structured-insert-left)
  (structured-insert-horizontal (focus-tree) #f))
(tm-define (structured-insert-right)
  (structured-insert-horizontal (focus-tree) #t))
(tm-define (structured-remove-left)
  (structured-remove-horizontal (focus-tree) #f))
(tm-define (structured-remove-right)
  (structured-remove-horizontal (focus-tree) #t))
(tm-define (structured-insert-up)
  (structured-insert-vertical (focus-tree) #f))
(tm-define (structured-insert-down)
  (structured-insert-vertical (focus-tree) #t))
(tm-define (structured-remove-up)
  (structured-remove-vertical (focus-tree) #f))
(tm-define (structured-remove-down)
  (structured-remove-vertical (focus-tree) #t))
(tm-define (structured-insert-start)
  (structured-insert-extremal (focus-tree) #f))
(tm-define (structured-insert-end)
  (structured-insert-extremal (focus-tree) #t))
(tm-define (structured-insert-top)
  (structured-insert-incremental (focus-tree) #f))
(tm-define (structured-insert-bottom)
  (structured-insert-incremental (focus-tree) #t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Structured movements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (structured-horizontal t forwards?)
  (and-with p (tree-outer t)
    (structured-horizontal p forwards?)))

(tm-define (structured-horizontal t forwards?)
  (:require (structured-horizontal? t))
  (with-focus-after t
    (with move (if forwards? path-next-argument path-previous-argument)
      (with p (move (root-tree) (tree->path (tree-down t)))
        (if (nnull? p) (go-to p))))))

(tm-define (structured-vertical t downwards?)
  (and-with p (tree-outer t)
    (structured-vertical p downwards?)))

(tm-define (structured-inner-extremal t forwards?)
  (and-with p (tree-outer t)
    (structured-inner-extremal p forwards?)))

(tm-define (structured-inner-extremal t forwards?)
  (:require (structured-horizontal? t))
  (with-focus-after t
    (tree-go-to t :down (if forwards? :end :start))))

(tm-define (structured-extremal t forwards?)
  (go-to-repeat (lambda () (structured-horizontal t forwards?)))
  (structured-inner-extremal t forwards?))

(tm-define (structured-incremental t downwards?)
  (go-to-repeat (lambda () (structured-vertical t downwards?)))
  (structured-inner-extremal t downwards?))

(tm-define (structured-exit t forwards?)
  (when (complex-context? t)
    (tree-go-to t (if forwards? :end :start))))

(tm-define (structured-left)
  (structured-horizontal (focus-tree) #f))
(tm-define (structured-right)
  (structured-horizontal (focus-tree) #t))
(tm-define (structured-up)
  (structured-vertical (focus-tree) #f))
(tm-define (structured-down)
  (structured-vertical (focus-tree) #t))
(tm-define (structured-start)
  (structured-extremal (focus-tree) #f))
(tm-define (structured-end)
  (structured-extremal (focus-tree) #t))
(tm-define (structured-top)
  (structured-incremental (focus-tree) #f))
(tm-define (structured-bottom)
  (structured-incremental (focus-tree) #t))
(tm-define (structured-exit-left)
  (structured-exit (focus-tree) #f))
(tm-define (structured-exit-right)
  (structured-exit (focus-tree) #t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Multi-purpose alignment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (geometry-speed t down?)
  (and-with p (tree-outer t)
    (geometry-speed p down?)))

(tm-define (geometry-variant t forwards?)
  (and-with p (tree-outer t)
    (geometry-variant p forwards?)))

(tm-define (geometry-default t)
  (and-with p (tree-outer t)
    (geometry-default p)))

(tm-define (geometry-horizontal t forwards?)
  (and-with p (tree-outer t)
    (geometry-horizontal p forwards?)))

(tm-define (geometry-vertical t down?)
  (and-with p (tree-outer t)
    (geometry-vertical p down?)))

(tm-define (geometry-extremal t forwards?)
  (and-with p (tree-outer t)
    (geometry-extremal p forwards?)))

(tm-define (geometry-incremental t down?)
  (and-with p (tree-outer t)
    (geometry-incremental p down?)))

(tm-define (geometry-slower)
  (geometry-speed (focus-tree) #f))
(tm-define (geometry-faster)
  (geometry-speed (focus-tree) #t))
(tm-define (geometry-circulate forwards?)
  (geometry-variant (focus-tree) forwards?))
(tm-define (geometry-reset)
  (geometry-default (focus-tree)))
(tm-define (geometry-left)
  (geometry-horizontal (focus-tree) #f))
(tm-define (geometry-right)
  (geometry-horizontal (focus-tree) #t))
(tm-define (geometry-up)
  (geometry-vertical (focus-tree) #f))
(tm-define (geometry-down)
  (geometry-vertical (focus-tree) #t))
(tm-define (geometry-start)
  (geometry-extremal (focus-tree) #f))
(tm-define (geometry-end)
  (geometry-extremal (focus-tree) #t))
(tm-define (geometry-top)
  (geometry-incremental (focus-tree) #f))
(tm-define (geometry-bottom)
  (geometry-incremental (focus-tree) #t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tree editing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (structured-insert-horizontal t forwards?)
  (:require (tree-is? t 'tree))
  (if (== (tree-down-index t) 0) (set! t (tree-up t)))
  (if (== (tm-car t) 'tree)
      (with pos (tree-down-index t)
        (if forwards? (set! pos (1+ pos)))
        (tree-insert! t pos '(""))
        (tree-go-to t pos 0))))

(tm-define (structured-remove-horizontal t forwards?)
  (:require (tree-is? t 'tree))
  (if (== (tree-down-index t) 0) (set! t (tree-up t)))
  (if (== (tm-car t) 'tree)
      (with pos (tree-down-index t)
        (cond (forwards?
               (tree-remove! t pos 1)
               (if (== pos (tree-arity t))
                   (tree-go-to t :end)
                   (tree-go-to t pos :start)))
              ((== pos 1) (tree-go-to t 0 :end))
              (else (tree-remove! t (- pos 1) 1))))))

(tm-define (structured-insert-vertical t downwards?)
  (:require (tree-is? t 'tree))
  (if downwards?
      (if (== (tree-down-index t) 0)
          (with pos (tree-arity t)
            (tree-insert! t pos '(""))
            (tree-go-to t pos 0))
          (begin
            (set! t (tree-down t))
            (tree-set! t `(tree ,t ""))
            (tree-go-to t 1 0)))
      (begin
        (if (!= (tree-down-index t) 0) (set! t (tree-down t)))
        (tree-set! t `(tree "" ,t))
        (tree-go-to t 0 0))))

(define (branch-active t)
  (with i (tree-down-index t)
    (if (and (= i 0) (tree-is? t :up 'tree))
        (tree-up t)
        t)))

(define (branch-go-to . l)
  (apply tree-go-to l)
  (if (tree-is? (cursor-tree) 'tree)
      (with last (cAr l)
        (if (nin? last '(:start :end)) (set! last :start))
        (tree-go-to (cursor-tree) 0 last))))

(tm-define (structured-horizontal t* forwards?)
  (:require (tree-is? t* 'tree))
  (let* ((t (branch-active t*))
         (i (tree-down-index t)))
    (cond ((and (not forwards?) (> i 1))
           (branch-go-to t (- i 1) :end))
          ((and forwards? (!= i 0) (< i (- (tree-arity t) 1)))
           (branch-go-to t (+ i 1) :start)))))

(tm-define (structured-vertical t* downwards?)
  (:require (tree-is? t* 'tree))
  (let* ((t (branch-active t*))
         (i (tree-down-index t)))
    (cond ((and (not downwards?) (!= i 0))
           (tree-go-to t 0 :end))
          ((and downwards? (== (tree-down-index t*) 0))
           (branch-go-to t* (quotient (tree-arity t*) 2) :start)))))

(tm-define (structured-extremal t* forwards?)
  (:require (tree-is? t* 'tree))
  (let* ((t (branch-active t*))
         (i (tree-down-index t)))
    (cond ((not forwards?)
           (branch-go-to t 1 :start))
          (forwards?
           (branch-go-to t :last :end)))))
  
(tm-define (structured-incremental t downwards?)
  (:require (tree-is? t 'tree))
  (go-to-repeat (if downwards? structured-down structured-up)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra editing functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (kill-paragraph)
  (selection-set-start)
  (go-end-paragraph)
  (selection-set-end)
  (clipboard-cut "primary"))

(tm-define (yank-paragraph)
  (selection-set-start)
  (go-end-paragraph)
  (selection-set-end)
  (clipboard-copy "primary"))

(tm-define (select-all)
  (tree-select (buffer-tree)))

(tm-define (go-to-line n . opt-from)
  (if (nnull? opt-from) (cursor-history-add (car opt-from)))
  (with-innermost t 'document
    (tree-go-to t n 0)))

(tm-define (go-to-column c . opt-from)
  (if (nnull? opt-from) (cursor-history-add (car opt-from)))
  (with-innermost t 'document
    (with p (tree-cursor-path t)
      (tree-go-to t (cADr p) c))))

(tm-define (select-word w t col)
  (:synopsis "Selects word @w in tree @t, more or less around column @col.")
  (let* ((st (tree->string t))
         (pos (- col (string-length w)))
         (beg (string-contains st w (max 0 pos)))) ; returns index of w in st
    (if beg
        (with p (tree->path t)
          (go-to (rcons p beg))
          (selection-set-start)
          (go-to (rcons p (+ beg (string-length w))))
          (selection-set-end)))
    beg))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Standard environment parameters for primitives
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (standard-parameters l)
  (:require (== l "action"))
  (list "locus-color"))

(tm-define (standard-parameters l)
  (:require (== l "locus"))
  (list "locus-color" "visited-color"))

(tm-define (standard-parameters l)
  (:require (== l "ornament"))
  (list "ornament-shape" "ornament-title-style" "ornament-border"
	"ornament-hpadding" "ornament-vpadding"
	"ornament-color" "ornament-extra-color"
	"ornament-sunny-color" "ornament-shadow-color"))

(tm-define (standard-parameters l)
  (:require (in? l '("reference" "pageref" "label" "tag")))
  (list))

(tm-define (search-parameters l)
  (:require (in? (if (string? l) l (symbol->string l))
                 '("reference" "pageref" "hlink")))
  (standard-parameters "locus"))

(tm-define (parameter-choice-list l)
  (:require (== l "ornament-shape"))
  (list "classic" "rounded" "angular" "cartoon"
        ;;"ring"
        ))

(tm-define (parameter-choice-list l)
  (:require (== l "ornament-title-style"))
  (list "classic"
        "top left" "top center" "top right"
        "bottom left" "bottom center" "bottom right"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inserting various kinds of content
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (label-insert t)
  (and-with p (tree-outer t)
    (label-insert p)))

(tm-define (label-insert t)
  (:require (tree-is-buffer? t))
  (make 'label))

(tm-define (make-label)
  (label-insert (focus-tree)))

(tm-define (make-specific s)
  (if (or (== s "texmacs") (in-source?))
      (insert-go-to `(specific ,s "") '(1 0))
      (insert-go-to `(inactive (specific ,s "")) '(0 1 0))))

(define (url->delta-unix u)
  (if (url-rooted? u) (set! u (url-delta (current-buffer) u)))
  (url->unix u))

(tm-define (make-include u)
  (insert `(include ,(url->delta-unix u))))

(tm-define (make-inline-image l)
  (apply make-image (cons* (url->delta-unix (car l)) #f (cdr l))))

(tm-define (make-link-image l)
  (apply make-image (cons* (url->delta-unix (car l)) #t (cdr l))))

(tm-define (make-graphics-over-selection)
  (if (selection-active-any?)
  (with selection (selection-tree)
    (clipboard-cut "graphics background")
    (insert-go-to `(draw-over ,selection (graphics)) '(1 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Thumbnails facility
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (thumbnail-suffixes)
  (list->url
    (map url-wildcard
         '("*.gif" "*.jpg" "*.jpeg" "*.JPG" "*.JPEG" "*.png" "*.PNG"))))

(define (fill-row l nr)
  (cond ((= nr 0) '())
        ((nnull? l) (cons (car l) (fill-row (cdr l) (- nr 1))))
        (else (cons "" (fill-row l (- nr 1))))))

(define (make-rows l nr)
  (if (> (length l) nr)
      (cons (list-head l nr) (make-rows (list-tail l nr) nr))
      (list (fill-row l nr))))

(define (make-thumbnails-sub l)
  (define (mapper x)
    `(image ,(url->delta-unix x) "0.22par" "" "" ""))
  (let* ((l1 (map mapper l))
         (l2 (make-rows l1 4))
         (l3 (map (lambda (r) `(row ,@(map (lambda (c) `(cell ,c)) r))) l2)))
    (insert `(tabular* (tformat (twith "table-width" "1par")
                                (twith "table-hyphen" "yes")
                                (table ,@l3))))))

(tm-define (make-thumbnails)
  (:interactive #t)
  (user-url "Picture directory" "directory" 
   (lambda (dir) 
     (let* ((find (url-append dir (thumbnail-suffixes)))
                  (files (url->list (url-expand (url-complete find "r"))))
                  (base (buffer-master))
                  (rel-files (map (lambda (x) (url-delta base x)) files)))
           (if (nnull? rel-files) (make-thumbnails-sub rel-files))))))
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Routines for floats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (make-marginal-note)
  (:synopsis "Insert a marginal note.")
  (wrap-selection-small
    (insert-go-to `(inactive (marginal-note "normal" "c" "")) '(0 2 0))))

(tm-define (test-marginal-note-hpos? hp)
  (and-with t (tree-innermost 'marginal-note #t)
    (tm-equal? (tree-ref t 0) hp)))
(tm-define (set-marginal-note-hpos hp)
  (:synopsis "Set the horizontal position of the marginal note to @hp.")
  (:check-mark "v" test-marginal-note-hpos?)
  (and-with t (tree-innermost 'marginal-note #t)
    (tree-set t 0 hp)))

(tm-define (test-marginal-note-valign? va)
  (and-with t (tree-innermost 'marginal-note #t)
    (tm-equal? (tree-ref t 1) va)))
(tm-define (set-marginal-note-valign va)
  (:synopsis "Set the vertical alignment of the marginal note to @va.")
  (:check-mark "v" test-marginal-note-valign?)
  (and-with t (tree-innermost 'marginal-note #t)
    (tree-set t 1 va)))

(tm-define (make-insertion s)
  (:synopsis "Make an insertion of type @s.")
  (with pos (if (== s "float") "tbh" "")
    (insert-go-to (list 'float s pos (list 'document ""))
                  (list 2 0 0))))

(tm-define (insertion-positioning what flag)
  (:synopsis "Allow/disallow the position @what for innermost float.")
  (with-innermost t 'float
    (let ((op (if flag string-union string-minus))
          (st (tree-ref t 1)))
      (tree-set! st (op (tree->string st) what)))))

(define (test-insertion-positioning? what)
  (with-innermost t 'float
    (with c (string-ref what 0)
      (char-in-string? c (tree->string (tree-ref t 1))))))

(define (not-test-insertion-positioning? s)
  (not (test-insertion-positioning? s)))

(tm-define (toggle-insertion-positioning what)
  (:check-mark "v" test-insertion-positioning?)
  (insertion-positioning what (not-test-insertion-positioning? what)))

(tm-define (toggle-insertion-positioning-not s)
  (:check-mark "v" not-test-insertion-positioning?)
  (toggle-insertion-positioning s))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Balloons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (balloon-context? t)
  (tree-in? t (balloon-tag-list)))

(define (integer-floor x)
  (inexact->exact (floor x)))

(tm-define (display-balloon body balloon halign valign extents)
  (:secure #t)
  (with (x1 y1 x2 y2) (tree-bounding-rectangle body)
    (let* ((zf (get-window-zoom-factor))
           (sf (/ 5.0 zf))
           (balloon* `(with "magnification" ,(number->string zf) ,balloon))
           (w (widget-texmacs-output balloon* '(style "generic")))
           (ww (integer-floor (/ (tree->number (tree-ref extents 0)) sf)))
           (wh (integer-floor (/ (tree->number (tree-ref extents 1)) sf)))
           (ha (tree->stree halign))
           (va (tree->stree valign))
           (x (cond ((== ha "Left") (- (- x1 ww) (* 3 256)))
                    ((== ha "left") x1)
                    ((== ha "center") (quotient (+ x1 x2 (- ww)) 2))
                    ((== ha "right") (- (- x2 ww) (* 3 256)))
                    ((== ha "Right") x2)
                    (else x1)))
           (y (cond ((== va "Bottom") (- y1 (* 5 256)))
                    ((== va "bottom") (+ y1 wh))
                    ((== va "center") (quotient (+ y1 y2 wh) 2))
                    ((== va "top") y2)
                    ((== va "Top") (+ y2 wh (* 5 256)))
                    (else (- y1 (* 5 256))))))
      ;;(display* "size= " (widget-size w) "\n")
      (show-balloon w x y))))

(tm-define (display-balloon* body balloon halign valign extents)
  (:secure #t)
  (with (mx my) (get-mouse-position)
    (let* ((zf (get-window-zoom-factor))
           (sf (/ 5.0 zf))
           (balloon* `(with "magnification" ,(number->string zf) ,balloon))
           (w (widget-texmacs-output balloon* '(style "generic")))
           (ww (integer-floor (/ (tree->number (tree-ref extents 0)) sf)))
           (wh (integer-floor (/ (tree->number (tree-ref extents 1)) sf)))
           (ha (tree->stree halign))
           (va (tree->stree valign))
           (x (cond ((in? ha (list "Left" "left")) (- (- mx ww) (* 3 256)))
                    ((== ha "center") (+ (- mx (quotient ww 2)) (* 5 256)))
                    ((in? ha (list "right" "Right")) (+ mx (* 10 256)))
                    (else (+ mx (* 3 256)))))
           (y (cond ((in? va (list "Bottom" "bottom")) (- my (* 16 256)))
                    ((== va "center") (- (+ my (quotient wh 2)) (* 8 256)))
                    ((in? va (list "top" "Top")) (+ my wh (* 5 256)))
                    (else (- my (* 5 256))))))
      (show-balloon w x y))))

(tm-define (make-balloon)
  (:synopsis "Insert a balloon.")
  (wrap-selection-small
    (insert-go-to `(inactive (mouse-over-balloon "" "" "left" "Bottom"))
                  '(0 0 0))))

(tm-define (test-balloon-halign? ha)
  (and-with t (tree-innermost balloon-context? #t)
    (tm-equal? (tree-ref t 2) ha)))
(tm-define (set-balloon-halign ha)
  (:synopsis "Set the horizontal alignment of the marginal note to @ha.")
  (:check-mark "v" test-balloon-halign?)
  (and-with t (tree-innermost balloon-context? #t)
    (tree-set t 2 ha)))

(tm-define (test-balloon-valign? va)
  (and-with t (tree-innermost balloon-context? #t)
    (tm-equal? (tree-ref t 3) va)))
(tm-define (set-balloon-valign va)
  (:synopsis "Set the vertical alignment of the marginal note to @va.")
  (:check-mark "v" test-balloon-valign?)
  (and-with t (tree-innermost balloon-context? #t)
    (tree-set t 3 va)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sound and video
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (make-sound u)
  (if (not (url-none? u))
      (insert `(sound ,(url->delta-unix u)))))

(tm-define (make-animation u)
  (interactive
      (lambda (w h len rep)
        (if (== rep "no") (set! rep "false"))
        (insert `(video ,(url->delta-unix u) ,w ,h ,len ,rep)))
    "Width" "Height" "Length" "Repeat?"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Search, replace, spell and tab-completion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (key-press-command key)
  ;; FIXME: this routine should do exactly the same as key-press,
  ;; without modification of the internal state and without executing
  ;; the actual shortcut. It should rather return a command which
  ;; does all this, or #f
  (and-with p (kbd-find-key-binding key)
    (car p)))

(tm-define (keyboard-press key time)
  (:mode search-mode?)
  (with cmd (key-press-command (string-append "search " key))
    (cond (cmd (cmd))
          ((key-press-search key) (noop))
          (else (key-press key)))))

(tm-define (search-next)
  (key-press-search "next"))

(tm-define (search-previous)
  (key-press-search "previous"))

(tm-define (keyboard-press key time)
  (:mode replace-mode?)
  (with cmd (key-press-command (string-append "replace " key))
    (cond (cmd (cmd))
          ((key-press-replace key) (noop))
          (else (key-press key)))))

(tm-define (keyboard-press key time)
  (:mode spell-mode?)
  (with cmd (key-press-command (string-append "spell " key))
    (cond (cmd (cmd))
          ((key-press-spell key) (noop))
          (else (key-press key)))))

(tm-define (keyboard-press key time)
  (:mode complete-mode?)
  (with cmd (key-press-command (string-append "complete " key))
    (cond (cmd (cmd))
          ((key-press-complete key) (noop))
          (else (key-press key)))))

(tm-define (keyboard-press key time)
  (:mode remote-control-mode?)
  ;;(display* "Press " key "\n")
  (if (ahash-ref remote-control-remap key)
      (begin
        ;;(display* "Remap " (ahash-ref remote-control-remap key) "\n")
        (key-press (ahash-ref remote-control-remap key)))
      (key-press key)))
