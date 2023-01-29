;;  -*- lexical-binding: t; -*-

(defvar mrds--roam-root-directory nil "the root directory of roam")
(defvar mrds--db-cache-path nil "path for storing the db files")
(defvar mrds--roam-current-directory nil "hold the value when switching to a new directory")

(defun mrds/show-current-roam-directory ()
  (interactive)
  (message mrds--roam-current-directory))


(defun mrds/roam-switch-db (path)
  "roam switch db.
  if path is a directory path, db name is the last hierarchical directory name.
  if path is a file path, db name is the file name."
  (let* ((directory path)
         (name (file-name-nondirectory path))
         (cache-path (string-trim-left  (expand-file-name path) (expand-file-name (concat mrds--roam-root-directory "/"))))
         (db (concat mrds--db-cache-path "/" cache-path ".db")))
    (setq org-roam-directory  directory)
    (setq org-roam-db-location db)
    (setq mrds--roam-current-directory directory)
    (org-roam-db-sync)))


(defun mrds/roam-switch-directory()
  (interactive)
  (let* ((ldir  (cl-remove-if-not (lambda (x) (and (file-directory-p x)
                                                   (not (member (file-name-nondirectory x) '("." ".." ".DS_Store" ".git" ".gitignore"))) (not (cl-search "/.git/" x))))
                                  (directory-files-recursively mrds--roam-root-directory "" t )))
         (lrdir (push mrds--roam-root-directory ldir))
         (name (completing-read "select a roam db: " (mapcar (lambda (x)
                                                               (if (string= x mrds--roam-root-directory)
                                                                   "/"
                                                                 (string-trim-left  (expand-file-name x) (expand-file-name (concat mrds--roam-root-directory "/"))))) lrdir))))
    (mrds/roam-switch-db (concat mrds--roam-root-directory "/" name))
    name))


(define-minor-mode mrds-mode
  "Toggles global mrds-mode."
  :init-value nil
  :global t
  :group 'mrds
  :lighter " mrds"
  :keymap (make-sparse-keymap))

(provide 'mrds-mode)
