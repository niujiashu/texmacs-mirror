
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : generic-menu.scm
;; DESCRIPTION : default focus menu
;; COPYRIGHT   : (C) 2010  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (generic generic-menu)
  (:use (utils edit variants)
	(generic generic-edit)
	(generic format-edit)
	(generic format-geometry-edit)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (variant-set t v)
  (tree-assign-node t v))

(define (variant-set-keep-numbering t v)
  (if (and (symbol-numbered? v) (symbol-unnumbered? (tree-label t)))
      (variant-set t (symbol-append v '*))
      (variant-set t v)))

(define (tag-menu-name l)
  (if (symbol-unnumbered? l)
      (tag-menu-name (symbol-drop-right l 1))
      (upcase-first (symbol->string l))))

(define (variant-menu-item v)
  (list (tag-menu-name v)
	(lambda () (variant-set-keep-numbering (focus-tree) v))))

(tm-define (variant-menu-items t)
  (with variants (variants-of (tree-label t))
    (map variant-menu-item variants)))

(tm-define (check-number? t)
  (tree-in? t (numbered-tag-list)))

(tm-define (number-toggle t)
  (when (numbered-context? t)
    (if (tree-in? t (numbered-tag-list))
	(variant-set t (symbol-append (tree-label t) '*))
	(variant-set t (symbol-drop-right (tree-label t) 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Adding and removing children
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (structured-horizontal? t)
  (or (tree-is-dynamic? t)
      (and-with c (tree-down t)
	(tree-in? c '(table tformat)))))

(tm-define (structured-vertical? t)
  (or (tree-in? t '(tree))
      (and-with c (tree-down t)
	(tree-in? c '(table tformat)))))

(tm-define (focus-can-insert)
  (with t (focus-tree)
    (< (tree-arity t) (tree-maximal-arity t))))

(tm-define (focus-can-remove)
  (with t (focus-tree)
    (> (tree-arity t) (tree-minimal-arity t))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Special handles for images
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (string-input-handle t i w)
  (if (tree-atomic? (tree-ref t i))
      (menu-dynamic
	(input (when answer (tree-set (focus-tree) i answer)) "string"
	       (list (tree->string (tree-ref t i))) w))
      (menu-dynamic
	(group "[n.a.]"))))

(tm-menu (image-handles t)
  (glue #f #f 3 0)
  (mini #t (group "File:"))
  (dynamic (string-input-handle t 0 "0.5w"))
  (glue #f #f 3 0)
  (mini #t (group "Width:"))
  (dynamic (string-input-handle t 1 "3em"))
  (glue #f #f 3 0)
  (mini #t (group "Height:"))
  (dynamic (string-input-handle t 2 "3em")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The main Focus menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; FIXME: when recovering focus-tree,
;; double check that focus-tree still has the required form

(tm-menu (standard-focus-menu t)
  (-> (eval (tag-menu-name (tree-label t)))
      (dynamic (variant-menu-items t)))
  (assuming (numbered-context? t)
    ;; FIXME: itemize, enumerate, eqnarray*
    ((check "Numbered" "v" (check-number? (focus-tree)))
     (number-toggle (focus-tree))))
  (assuming (toggle-context? t)
    ((check "Unfolded" "v" (toggle-second-context? (focus-tree)))
     (toggle-toggle (focus-tree))))
  ("Describe" (set-message "Not yet implemented" ""))
  ("Delete" (remove-structure-upwards))
  
  ---
  ("Previous similar" (traverse-previous))
  ("Next similar" (traverse-next))
  ("First similar" (traverse-first))
  ("Last similar" (traverse-last))
  ("Exit left" (structured-exit-left))
  ("Exit right" (structured-exit-right))
  
  (assuming (or (structured-horizontal? t) (structured-vertical? t))
    ---)
  (assuming (structured-vertical? t)
    ("Insert above" (structured-insert-up)))
  (assuming (structured-horizontal? t)
    (when (focus-can-insert)
      ("Insert argument before" (structured-insert #f))))
  (assuming (structured-horizontal? t)
    (when (focus-can-insert)
      ("Insert argument after" (structured-insert #t))))
  (assuming (structured-vertical? t)
    ("Insert below" (structured-insert-down)))
  (assuming (structured-vertical? t)
    ("Remove upwards" (structured-remove-up)))
  (assuming (structured-horizontal? t)
    (when (focus-can-remove)
      ("Remove argument before" (structured-remove #f))))
  (assuming (structured-horizontal? t)
    (when (focus-can-remove)
      ("Remove argument after" (structured-remove #t))))
  (assuming (structured-vertical? t)
    ("Remove downwards" (structured-remove-down))))

(tm-menu (focus-menu)
  (dynamic (standard-focus-menu (focus-tree))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The main focus icons bar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-menu (focus-variant-icons t)
  (mini #t
    (=> (balloon (eval (tag-menu-name (tree-label t))) "Structured variant")
	(dynamic (variant-menu-items t))))
  (assuming (numbered-context? t)
    ;; FIXME: itemize, enumerate, eqnarray*
    ((check (balloon (icon "tm_numbered.xpm") "Toggle numbering") "v"
	    (check-number? (focus-tree)))
     (number-toggle (focus-tree))))
  (assuming (toggle-context? t)
    ((check (balloon (icon "tm_unfold.xpm") "Fold / Unfold") "v"
	    (toggle-second-context? (focus-tree)))
     (toggle-toggle (focus-tree))))
  ((balloon (icon "tm_focus_help.xpm") "Describe tag")
   (set-message "Not yet implemented" ""))
  ((balloon (icon "tm_focus_delete.xpm") "Remove tag")
   (remove-structure-upwards)))

(tm-menu (focus-move-icons t)
  ((balloon (icon "tm_similar_first.xpm") "Go to first similar tag")
   (traverse-first))
  ((balloon (icon "tm_similar_previous.xpm") "Go to previous similar tag")
   (traverse-previous))
  ((balloon (icon "tm_exit_left.xpm") "Exit tag on the left")
   (structured-exit-left))
  ((balloon (icon "tm_exit_right.xpm") "Exit tag on the right")
   (structured-exit-right))
  ((balloon (icon "tm_similar_next.xpm") "Go to next similar tag")
   (traverse-next))
  ((balloon (icon "tm_similar_last.xpm") "Go to last similar tag")
   (traverse-last)))

(tm-menu (focus-insert-icons t)
  (assuming (structured-vertical? t)
    ((balloon (icon "tm_insert_up.xpm") "Structured insert above")
     (structured-insert-up)))
  (assuming (structured-horizontal? t)
    (when (focus-can-insert)
      ((balloon (icon "tm_insert_left.xpm") "Structured insert at the left")
       (structured-insert #f))))
  (assuming (structured-horizontal? t)
    (when (focus-can-insert)
      ((balloon (icon "tm_insert_right.xpm") "Structured insert at the right")
       (structured-insert #t))))
  (assuming (structured-vertical? t)
    ((balloon (icon "tm_insert_down.xpm") "Structured insert below")
     (structured-insert-down)))
  (assuming (structured-vertical? t)
    ((balloon (icon "tm_delete_up.xpm") "Structured remove upwards")
     (structured-remove-up)))
  (assuming (structured-horizontal? t)
    (when (focus-can-remove)
      ((balloon (icon "tm_delete_left.xpm") "Structured remove leftwards")
       (structured-remove #f))))
  (assuming (structured-horizontal? t)
    (when (focus-can-remove)
      ((balloon (icon "tm_delete_right.xpm") "Structured remove rightwards")
       (structured-remove #t))))
  (assuming (structured-vertical? t)
    ((balloon (icon "tm_delete_down.xpm") "Structured remove downwards")
     (structured-remove-down))))

(tm-menu (standard-focus-icons t)
  (minibar (dynamic (focus-variant-icons t)))
  (glue #f #f 5 0)
  (minibar (dynamic (focus-move-icons t)))
  (assuming (or (structured-horizontal? t) (structured-vertical? t))
    (glue #f #f 5 0)
    (minibar (dynamic (focus-insert-icons t))))
  (assuming (tree-is? t 'image)
    (dynamic (image-handles t)))
  (glue #f #f 5 0))

(tm-menu (texmacs-focus-icons)
  (dynamic (standard-focus-icons (focus-tree))))
