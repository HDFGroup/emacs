;;; hdfql.el --- A minor mode for HDFql

;; Copyright (C) 2021 The HDF Group

;; Author: Gerd Heber <gheber@hdfgroup.org>
;; Maintainer: Gerd Heber <gheber@hdfgroup.org>
;; Created: 24 Dec 2021
;; Modified: 30 Dec 2021
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: hdf5 hdfql
;; URL: https://github.com/HDFGroup/emacs

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; A minor mode for HDFql (https://www.hdfql.com/)
;;
;; Please see README.md from the same repository for documentation.

;;; Code:

;; We assume that `HDFqlCLI` is found in `PATH` and that `libHDFql.so` is
;; found in `LD_LIBRARY_PATH`.

(defun org-babel-execute:hdfql (body params)
  "Execute a block of HDFql code with org-babel."
  (message "executing HDFql source code block")
  (org-babel-eval
   (format "HDFqlCLI --no-status --execute=\"%s\"" body) ""))

(push '("hdfql" . hdfql) org-src-lang-modes)

(add-to-list 'org-structure-template-alist '("hq" . "src hdfql"))

(defvar hdf5-keywords-re
  (concat
   "\\b"
   (regexp-opt
    (list
     "attribute"
     "chunked" "compact"
     "dataset" "dense" "directory" "dimension"
     "early" "external link"
     "file" "fill"
     "group"
     "incremental"
     "late" "library bounds" "link"
     "no fill"
     "order indexed" "order tracked"
     "soft link"
     "unlimited" "userblock size"
     ))
   "\\b"))

(defvar hdf5-type-keywords-re
  (concat
   "\\b"
   (regexp-opt
    (list
     "ascii"
     "big endian"
     "compound"
     "enumeration"
     "little endian"
     "native"
     "offset"
     "opaque"
     "size"
     "tag"
     "utf8"
     ))
   "\\b"))

(defvar hdfql-keywords-re
  (concat
   "\\b"
   (regexp-opt
    (list
     "alter" "atomic"
     "close"
     "debug" "default" "disable"
     "enable"
     "flush"
     "hdf5"
     "hdfql"
     "mpi"
     "plugin path" "prefix"
     "rename"
     "thread" "to" "truncate"
     "use"
     "version"
     ))
   "\\b"))

(defun hdfql-font-lock-add-keywords ()
  "Augment the sql mode font-lock keywords for HDFql"
  (if (fboundp 'font-lock-add-keywords)
      (progn
	    (font-lock-add-keywords
	     'sql-mode `((,hdf5-keywords-re . font-lock-function-name-face)))
	    (font-lock-add-keywords
	     'sql-mode `((,hdf5-type-keywords-re . font-lock-type-face)))
	    (font-lock-add-keywords
	     'sql-mode `((,hdfql-keywords-re . font-lock-keyword-face)))
	)))

(add-hook 'sql-mode-hook
          '(lambda ()
	         (hdfql-font-lock-add-keywords)
             (setq font-lock-keywords-case-fold-search t)
	         (font-lock-mode t)))

(defun hdfql-mode (&optional arg)
  "En/disable HDFql mode"
  (interactive "P")

  (set (make-variable-buffer-local 'hdfql-mode)
       (if (null arg) (not hdfql-mode)
	     (> (prefix-numeric-value arg) 0)))

  (sql-mode))
