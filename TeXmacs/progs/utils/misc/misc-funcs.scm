
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : misc-funcs.scm
;; DESCRIPTION : important miscellaneous subroutines
;; COPYRIGHT   : (C) 2001  Joris van der Hoeven
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (utils misc misc-funcs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subtrees and path rounding
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (tm-start p)
  (:type (-> path path))
  (:synopsis "Round cursor position @p to below.")
  (cursor-start (the-root) p))

(tm-define (tm-end p)
  (:type (-> path path))
  (:synopsis "Round cursor position @p to above.")
  (cursor-end (the-root) p))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment related
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (test-default? . vals)
  (if (null? vals)
      #t
      (and (not (init-has? (car vals)))
	   (apply test-default? (cdr vals)))))

(tm-define (init-default . args)
  (:check-mark "*" test-default?)
  (for-each init-default-one args))

(tm-define (test-init? var val)
  (== (get-init-tree var) (string->tree val)))

(tm-property (init-env var val)
  (:check-mark "*" test-init?))

(tm-define (test-env? var val)
  (== (get-env var) val))

(tm-property (make-with var val)
  (:check-mark "o" test-env?))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Debugging
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (not-implemented s)
  (set-message "Error: not yet implemented" s))

(tm-define (tm-debug)
  (:type (-> void))
  (:synopsis "For debugging purposes.")
  (display* (tree->stree (the-root)) "\n"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (texmacs-version-release* t)
  (texmacs-version-release (tree->string t)))

(tm-define (real-math-font? fn)
  (or (== fn "roman") (== fn "concrete")))

(tm-define (real-math-family? fn)
  (or (== fn "mr") (== fn "ms") (== fn "mt")))

(tm-define (replace-start-forward what by)
  (replace-start what by #t))

(tm-define (with-active-buffer-sub name cmd)
  (let ((old (get-name-buffer)))
    (switch-to-active-buffer name)
    (eval cmd)
    (switch-to-active-buffer old)))

(tm-define-macro (with-active-buffer . l)
  (with-active-buffer-sub (car l) (cons 'begin (cdr l))))

(tm-define (inside-which l)
  (with r (tm-inside-which l)
    (if (== r "") #f (string->symbol r))))

(tm-define-macro (delayed . body)
  `(exec-delayed (lambda () ,@body)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; For actions which need to operate on specific markup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define the-action-path '(-1))
(tm-define (set-action-path p) (set! the-action-path p))
(tm-define (has-action-path?) (!= the-action-path '(-1)))
(tm-define (get-action-path) the-action-path)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; For compatibility with the old "interactive" texmacs built-in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-define (interactive . args)
  (let ((fun (last args)))
    (if (not (procedure? fun))
        (apply tm-interactive (rcons (but-last args) (eval fun)))
        (apply tm-interactive args))))
