
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : init-maxima.scm
;; DESCRIPTION : Initialize maxima plugin
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven, 2005  Andrey Grozin
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (maxima-input)
  (:use (texmacs plugin plugin-convert)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Specific conversion routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (maxima-input-var-row r)
  (if (not (null? r))
      (begin
	(display ", ")
	(plugin-input (car r))
	(maxima-input-var-row (cdr r)))))

(define (maxima-input-row r)
  (display "[")
  (plugin-input (car r))
  (maxima-input-var-row (cdr r))
  (display "]"))

(define (maxima-input-var-rows t)
  (if (not (null? t))
      (begin
	(display ", ")
	(maxima-input-row (car t))
	(maxima-input-var-rows (cdr t)))))

(define (maxima-input-rows t)
  (display "matrix(")
  (maxima-input-row (car t))
  (maxima-input-var-rows (cdr t))
  (display ")"))

(define (maxima-input-descend-last args)
  (if (null? (cdr args))
      (plugin-input (car args))
      (maxima-input-descend-last (cdr args))))

(define (maxima-input-det args)
  (display "determinant(")
  (maxima-input-descend-last args)
  (display ")"))

(define (maxima-input-binom args)
  (display "binomial(")
  (plugin-input (car args))
  (display ",")
  (plugin-input (cadr args))
  (display ")"))

(define (maxima-input-sqrt args)
  (if (= (length args) 1)
      (begin
        (display "sqrt(")
        (plugin-input (car args))
        (display ")"))
      (begin
        (display "(")
        (plugin-input (car args))
        (display ")^(1/(")
        (plugin-input (cadr args))
        (display "))"))))

(define (maxima-input-sum args)
  (if (not (null? args))
      (if (not (null? (cdr args)))
          (begin ;; both lower and upper index
            (display "tmsum(")
            (plugin-input (car args))
            (display ",")
            (plugin-input (cadr args))
            (display ","))
          (begin ;; lower index only
            (display "tmlsum(")
            (plugin-input (car args))
            (display ",")))
      (display "tmsum(")))

(define (maxima-input-prod args)
  (if (not (null? args))
      (begin
        (display "tmprod(")
        (plugin-input (car args))
        (if (not (null? (cdr args)))
            (begin
              (display ",")
              (plugin-input (cadr args))))
        (display ","))
      (display "tmprod(")))

(define (maxima-input-int args)
  (if (not (null? args))
      (begin
        (display "tmint(")
        (plugin-input (car args))
        (if (not (null? (cdr args)))
            (begin
              (display ",")
              (plugin-input (cadr args))))
        (display ","))
      (display "integrate(")))

(define (maxima-input-big args)
  (let ((op (car args)))
       (cond
         ((== op ".") (display ")"))
         ((== op "sum")  (maxima-input-sum (cdr args)))
         ((== op "prod") (maxima-input-prod (cdr args)))
         ((== op "int")  (maxima-input-int (cdr args)))
         (else (display op) (display "(")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(plugin-input-converters maxima
  (rows maxima-input-rows)
  (det maxima-input-det)
  (sqrt maxima-input-sqrt)
  (big maxima-input-big)
  (binom maxima-input-binom)

  ("<infty>"      "inf")
  ("<emptyset>"   "[]")
  ("<mathd>"      ",")
  ("<mathi>"      "%i")
  ("<mathe>"      "%e")
  ("<in>"         "=")

  ("<alpha>"      "alpha")
  ("<beta>"       "beta")
  ("<gamma>"      "%gamma")
  ("<delta>"      "delta")
  ("<epsilon>"    "epsilon")
  ("<varepsilon>" "epsilon")
  ("<zeta>"       "zeta")
  ("<eta>"        "eta")
  ("<theta>"      "theta")
  ("<vartheta>"   "theta")
  ("<iota>"       "iota")
  ("<kappa>"      "kappa")
  ("<lambda>"     "lambda")
  ("<mu>"         "mu")
  ("<nu>"         "nu")
  ("<xi>"         "xi")
  ("<pi>"         "%pi")
  ("<rho>"        "rho")
  ("<varrho>"     "rho")
  ("<sigma>"      "sigma")
  ("<varsigma>"   "sigma")
  ("<tau>"        "tau")
  ("<upsilon>"    "upsilon")
  ("<phi>"        "phi")
  ("<varphi>"     "phi")
  ("<chi>"        "chi")
  ("<psi>"        "psi")
  ("<omega>"      "omega")
  ("<Gamma>"      "gamma")
  ("<Delta>"      "Delta")
  ("<Theta>"      "Theta")
  ("<Lambda>"     "Lambda")
  ("<Xi>"         "Xi")
  ("<Pi>"         "Pi")
  ("<Sigma>"      "Sigma")
  ("<Upsilon>"    "Upsilon")
  ("<Phi>"        "Phi")
  ("<Psi>"        "Psi")
  ("<Omega>"      "Omega")
)
