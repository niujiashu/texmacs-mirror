
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : adobe-fonts.scm
;; DESCRIPTION : setup TeX adobe postscript fonts
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license and comes WITHOUT
;; ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (fonts fonts-adobe))

(set-font-rules
  '(((avant-garde rm medium right $s $d) (adobe rpagk $s $d 0))
    ((avant-garde rm medium slanted $s $d) (adobe rpagko $s $d 0))
    ((avant-garde rm medium italic $s $d) (adobe rpagko $s $d 0))
    ((avant-garde rm bold right $s $d) (adobe rpagd $s $d 0))
    ((avant-garde rm bold slanted $s $d) (adobe rpagdo $s $d 0))
    ((avant-garde rm bold italic $s $d) (adobe rpagdo $s $d 0))

    ((bookman rm medium right $s $d) (adobe rpbkl $s $d 0))
    ((bookman rm medium slanted $s $d) (adobe rpbkli $s $d 0))
    ((bookman rm medium italic $s $d) (adobe rpbkli $s $d 0))
    ((bookman rm bold right $s $d) (adobe rpbkd $s $d 0))
    ((bookman rm bold slanted $s $d) (adobe rpbkdi $s $d 0))
    ((bookman rm bold italic $s $d) (adobe rpbkdi $s $d 0))
    ((bookman ss $series $shape $s $d) (avant-garde rm $series $shape $s $d))
    ((bookman tt $series $shape $s $d) (courier rm $series $shape $s $d))

    ((courier rm medium right $s $d) (adobe rpcrr $s $d 0))
    ((courier rm medium slanted $s $d) (adobe rpcrro $s $d 0))
    ((courier rm medium italic $s $d) (adobe rpcrro $s $d 0))
    ((courier rm bold right $s $d) (adobe rpcrb $s $d 0))
    ((courier rm bold slanted $s $d) (adobe rpcrbo $s $d 0))
    ((courier rm bold italic $s $d) (adobe rpcrbo $s $d 0))

    ((helvetica rm medium right $s $d) (adobe rphvr $s $d 0))
    ((helvetica rm medium slanted $s $d) (adobe rphvro $s $d 0))
    ((helvetica rm medium italic $s $d) (adobe rphvro $s $d 0))
    ((helvetica rm medium condensed $s $d) (adobe rphvrrn $s $d 0))
    ((helvetica rm medium slanted-condensed $s $d) (adobe rphvron $s $d 0))
    ((helvetica rm medium italic-condensed $s $d) (adobe rphvron $s $d 0))
    ((helvetica rm bold right $s $d) (adobe rphvb $s $d 0))
    ((helvetica rm bold slanted $s $d) (adobe rphvbo $s $d 0))
    ((helvetica rm bold italic $s $d) (adobe rphvbo $s $d 0))
    ((helvetica rm bold condensed $s $d) (adobe rphvbrn $s $d 0))
    ((helvetica rm bold slanted-condensed $s $d) (adobe rphvbon $s $d 0))
    ((helvetica rm bold italic-condensed $s $d) (adobe rphvbon $s $d 0))
    ((helvetica tt $series $shape $s $d) (courier rm $series $shape $s $d))

    ((new-century-schoolbook rm medium right $s $d) (adobe rpncr $s $d 0))
    ((new-century-schoolbook rm medium slanted $s $d) (adobe rpncri $s $d 0))
    ((new-century-schoolbook rm medium italic $s $d) (adobe rpncri $s $d 0))
    ((new-century-schoolbook rm bold right $s $d) (adobe rpncb $s $d 0))
    ((new-century-schoolbook rm bold slanted $s $d) (adobe rpncbi $s $d 0))
    ((new-century-schoolbook rm bold italic $s $d) (adobe rpncbi $s $d 0))

    ((palatino rm medium right $s $d) (adobe rpplr $s $d 0))
    ((palatino rm medium slanted $s $d) (adobe rpplro $s $d 0))
    ((palatino rm medium italic $s $d) (adobe rpplri $s $d 0))
    ((palatino rm medium italic-right $s $d) (adobe rpplru $s $d 0))
    ((palatino rm medium condensed $s $d) (adobe rpplrrn $s $d 0))
    ((palatino rm medium wide $s $d) (adobe rpplrre $s $d 0))
    ((palatino rm bold right $s $d) (adobe rpplb $s $d 0))
    ((palatino rm bold slanted $s $d) (adobe rpplbi $s $d 0))
    ((palatino rm bold italic $s $d) (adobe rpplbi $s $d 0))
    ((palatino rm bold italic-right $s $d) (adobe rpplbu $s $d 0))
    ((palatino ss $series $shape $s $d) (helvetica rm $series $shape $s $d))
    ((palatino tt $series $shape $s $d) (courier rm $series $shape $s $d))

    ((times rm medium right $s $d) (adobe rptmr $s $d 0))
    ((times rm medium slanted $s $d) (adobe rptmro $s $d 0))
    ((times rm medium italic $s $d) (adobe rptmri $s $d 0))
    ((times rm medium condensed $s $d) (adobe rptmrrn $s $d 0))
    ((times rm medium wide $s $d) (adobe rptmrre $s $d 0))
    ((times rm bold right $s $d) (adobe rptmb $s $d 0))
    ((times rm bold slanted $s $d) (adobe rptmbo $s $d 0))
    ((times rm bold italic $s $d) (adobe rptmbi $s $d 0))
    ((times ss $series $shape $s $d) (helvetica rm $series $shape $s $d))
    ((times tt $series $shape $s $d) (courier rm $series $shape $s $d))

    ((chancery rm $a $b $s $d) (adobe rpzcmi $s $d 0))
    ((chancellary rm $a $b $s $d) (adobe rpzcmi $s $d 0))
    ((dingbat rm $a $b $s $d) (adobe rpzdr $s $d 0))))


(set-font-rules
  '(((adobe mr medium $a $s $d)
     (math
      (adobe-math (tex cmr $s $d)
		  (tex cmmi $s $d)
		  (tex cmsy $s $d)
		  (tex msam $s $d)
		  (tex msbm $s $d)
		  (tex stmary $s $d)
		  (tex wasy $s $d)
		  (tex line $s $d)
		  (tex cmsy $s $d)
		  (tex eufm $s $d)
		  (tex bbm $s $d)
		  (tex cmbsy $s $d)
		  (virtual long $s $d)
		  (virtual negate $s $d)
		  (virtual misc $s $d)
		  (tex rptmri $s $d 0)
		  (tex rpsyr $s $d 0)
		  (tex rpsyro $s $d 0)
		  (tex rptmbi $s $d 0)
		  (tex rpsyr $s $d 0)
		  (tex rpsyro $s $d 0))
      (rubber (tex-rubber rubber-cmex cmex $s $d)
	      (tex-rubber rubber-stmary stmary $s $d)
	      (tex-rubber rubber-wasy wasy $s $d))
      (adobe rptmr $s $d 0)
      (adobe rptmr $s $d 0)))

    ((adobe mr bold $a $s $d)
     (math
      (adobe-math (tex cmbx $s $d)
		  (tex cmmib $s $d)
		  (tex cmbsy $s $d)
		  (tex msam $s $d)
		  (tex msbm $s $d)
		  (tex stmaryb $s $d)
		  (tex wasyb $s $d)
		  (tex lineb $s $d)
		  (tex cmbsy $s $d)
		  (tex eufb $s $d)
		  (tex bbmbx $s $d)
		  (tex cmbsy $s $d)
		  (virtual long $s $d)
		  (virtual negate $s $d)
		  (virtual misc $s $d)
		  (tex rptmbi $s $d 0)
		  (tex rpsyr $s $d 0)
		  (tex rpsyro $s $d 0)
		  (tex rptmbi $s $d 0)
		  (tex rpsyr $s $d 0)
		  (tex rpsyro $s $d 0))
      (rubber (tex-rubber rubber-cmex cmexb $s $d)
	      (tex-rubber rubber-stmary stmaryb $s $d)
	      (tex-rubber rubber-wasy wasyb $s $d))
      (adobe rptmb $s $d 0)
      (adobe rptmb $s $d 0)))))
