
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : server-tmfs.scm
;; DESCRIPTION : Remote file system, server side
;; COPYRIGHT   : (C) 2013  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(texmacs-module (server server-tmfs)
  (:use (server server-resource)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Repository
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define repo (url-concretize "$TEXMACS_HOME_PATH/server"))
(define repo-seed-val (+ (* 4294967296 (abs (texmacs-time)))))
(define repo-seed (seed->random-state repo-seed-val))

(define (repository-add-into dir name)
  (when (not (url-exists? dir))
    (system-mkdir dir))
  (with rdir (string-append dir "/_")
    (if (not (url-exists? rdir))
        (begin
          (system-mkdir rdir)
          (string-append rdir "/" name))
        (with sub (number->string (random 10 repo-seed))
          (repository-add-into (string-append dir "/" sub) name)))))

(define (repository-add rid suffix)
  (let* ((name (if (== suffix "") rid (string-append rid "." suffix)))
         (full (repository-add-into repo name))
         (tail (substring full (+ (string-length repo) 1)
                               (string-length full))))
    (resource-set rid "location" (list tail))
    (resource-set name "rid" (list rid))
    name))

(define (repository-get rid)
  (with l (resource-get rid "location")
    (and (pair? l) (string-append repo "/" (car l)))))

(define (repository-rid name)
  (with l (resource-get name "rid")
    (and (pair? l) (car l))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remote file manipulations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(tm-service (remote-file-create suffix)
  (with uid (server-get-user envelope)
    (if (not uid) (server-error envelope "Error: not logged in")
        (let* ((rid (resource-create "Nameless remote file" "file" uid))
               (name (repository-add rid suffix)))
          (server-return envelope name)))))

(tm-service (remote-file-load rname)
  (let* ((uid (server-get-user envelope))
         (rid (repository-rid (tmfs-cdr rname)))
         (fname (repository-get rid)))
    (cond ((not uid) ;; FIXME: anonymous access
           (server-error envelope "Error: not logged in"))
          ((not (resource-allow? rid uid "readable"))
           (server-error envelope "Error: read access denied"))
          ((not (url-exists? fname))
           (server-error envelope "Created new file"))
          (else
            (with props (resource-get-all-decoded rid)
              (if (url-exists? fname)
                  (let* ((tm (string-load fname))
                         (doc (convert tm "texmacs-document" "texmacs-stree")))
                    (server-return envelope (list doc props)))
                  (server-return envelope (list #f props))))))))

(tm-service (remote-file-save rname doc)
  (let* ((uid (server-get-user envelope))
         (rid (repository-rid (tmfs-cdr rname)))
         (fname (repository-get rid))
         (tm (convert doc "texmacs-stree" "texmacs-document")))
    (cond ((not uid)
           (server-error envelope "Error: not logged in"))
          ((not (resource-allow? rid uid "writable"))
           (server-error envelope "Error: write access denied"))
          (else
            (with props (resource-get-all-decoded rid)
              (string-save tm fname)
              (server-return envelope (list doc props)))))))

(tm-service (remote-set-properties rname props)
  (let* ((uid (server-get-user envelope))
         (rid (repository-rid (tmfs-cdr rname))))
    (cond ((not uid)
           (server-error envelope "Error: not logged in"))
          ((not (resource-allow? rid uid "owner"))
           (server-error envelope "Error: administrative access denied"))
          (else
            (resource-set-all-encoded rid props)
            (with new-props (resource-get-all-decoded rid)
              (server-return envelope new-props))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Remote directories
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (generic-document doc)
  `(document
     (TeXmacs ,(texmacs-version))
     (style (tuple "generic"))
     (body ,doc)))

(define (decode-key-value s)
  (with i (string-index s #\=)
    (if (not i) (list "error" "error")
        (list (substring s 0 i) (substring s (+ i 1) (string-length s))))))

(define (dir-line server rid)
  (let* ((name (resource-get-first rid "name" "?"))
         (tail (url->string (url-tail (repository-get rid))))
         (full (string-append "tmfs://remote-file/" server "/" tail))
         (hlink `(hlink ,name ,full)))
    hlink))

(define (dir-page server rids)
  (generic-document `(document (subsection* "File list")
                               ,@(map (cut dir-line server <>) rids))))

(define (filter-read-access rids uid)
  (cond ((null? rids) rids)
        ((resource-allow? (car rids) uid "readable")
         (cons (car rids) (filter-read-access (cdr rids) uid)))
        (else (filter-read-access (cdr rids) uid))))

(tm-service (remote-dir-load name)
  (with uid (server-get-user envelope)
    (if (not uid) (server-error envelope "Error: not logged in")
        (let* ((server (car (tmfs->list name)))
               (pairs (rcons (cdr (tmfs->list name)) "type=file"))
               (query (map decode-key-value pairs))
               (matches (resource-search query))
               (filtered (filter-read-access matches uid)))
          (server-return envelope (dir-page server filtered))))))
