
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : bib-kbd.scm
;; DESCRIPTION : keyboard shortcuts for editing bibliographic databases
;; COPYRIGHT   : (C) 2015  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (database bib-kbd)
  (:use (database bib-menu)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completing bibliographic references
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (kbd-variant t forwards?)
  (:require (and (supports-db?) (bib-cite-context? t)))
  (with u (tree-down t)
    (and-with key (and (tree-atomic? u) (tree->string u))
      (with-database (bib-database)
        (with completions (sort (index-get-name-completions key) string<=?)
          (if (null? completions)
              (set-message "No completions" "complete bibliographic reference")
              (with cs (cons key (map (cut string-drop <> (string-length key))
                                      completions))
                (custom-complete (tm->tree `(tuple ,@cs))))))))))

(tm-define (kbd-alternate-variant t forwards?)
  (:require (and (supports-db?) (bib-cite-context? t)))
  (and-with u (tree-down t)
    (open-bib-chooser
     (lambda (key)
       (when (and (tree->path u)
		  (tree-in? (tree-up u) '(cite nocite cite-detail)))
	 (tree-set! u key))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Entering names
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(kbd-map
  (:mode in-bib-names?)
  ("space a n d space" (make-name-sep))
  ("," (make-name-sep))
  (", var" ",")
  ("S-F5" (make-name-von))
  ("S-F7" (make-name-jr)))
