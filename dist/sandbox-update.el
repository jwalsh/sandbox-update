;;; sandbox-update.el --- Update git sandboxes -*- lexical-binding: t -*-

;; Copyright (C) 2023 Jason Walsh

;; Author: Jason Walsh <j@wal.sh>
;; Version: 0.1
;; Keywords: tools vc
;; Package-Requires: ((emacs "25.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Functions for updating git sandboxes.

;;; Code:

(defgroup sandbox-update nil
  "Customization for sandbox update."
  :group 'tools)

;; Customization values

(defcustom sandbox-update-cache-dir "~/.cache/sandbox-update/"
  "Directory to store sandbox update cache files."
  :type 'directory
  :group 'sandbox-update)

(defcustom sandbox-update-sandbox-dir "~/sandbox/"
  "Base directory for sandbox repositories."
  :type 'directory
  :group 'sandbox-update)

;; Variable definitions

(defvar sandbox-update-repos nil
  "List of repositories for sandbox update.")

;; Function definitions  

(defun sandbox-update-repo-add (location)
  "Add repository at LOCATION to `sandbox-update-repos'.
LOCATION can be a path or a URL."
  (let ((repo (if (string-prefix-p "http" location)
                  (file-name-nondirectory 
                   (url-filename (url-generic-parse-url location)))
                location)))
    
    (unless (file-exists-p sandbox-update-sandbox-dir)
      (warn "Sandbox directory %s does not exist" sandbox-update-sandbox-dir)
      (make-directory sandbox-update-sandbox-dir t))

    (unless (file-exists-p sandbox-update-cache-dir)
      (warn "Cache directory %s does not exist" sandbox-update-cache-dir)
      (make-directory sandbox-update-cache-dir t))
      
    (let ((repo-path (expand-file-name repo sandbox-update-sandbox-dir)))
      (unless (file-exists-p repo-path)
        (warn "Repository %s does not exist" repo-path))
        
      ;; Add if found  
      (when (file-exists-p repo-path)
        (message "Adding %s to sandbox update repos" repo-path)
        (unless (member repo sandbox-update-repos)
          (add-to-list 'sandbox-update-repos repo-path))))))

(defun sandbox-update-repo-remove (repo)
  "Remove REPO from `sandbox-update-repos'."
  (setq sandbox-update-repos
        (delete repo sandbox-update-repos)))

(defun sandbox-update-repos-clear ()
  "Clear `sandbox-update-repos'."
  (interactive)
  (setq sandbox-update-repos nil))

(defun sandbox-update-repos-list ()
  "Display list of repositories for sandbox update."
  (message "Sandbox update repos: %S" sandbox-update-repos))

(defun sandbox-update-repos-update ()
  "Update all repositories in `sandbox-update-repos'."
  (dolist (repo sandbox-update-repos)
    (let* ((cache-dir (expand-file-name sandbox-update-cache-dir))
           (cache-path (expand-file-name repo cache-dir))
           (last-update-file (expand-file-name "last-updated" cache-path))
           (now (current-time))
           (origin (with-temp-buffer 
                     (let ((default-directory repo))
                       (shell-command "git remote get-url origin")
                       (buffer-string)))))
      (unless (file-exists-p cache-path)
        (make-directory cache-path t))

      (let* (last-updated)
	(with-temp-buffer
	  (insert-file-contents last-update-file)
	  (setq last-updated (buffer-string)))
	(message "Last updated: %s" last-updated))
      (if (or (not (file-exists-p last-update-file))
              (time-less-p 
               (nth 5 (file-attributes last-update-file))
               now))
          (progn
            (message "Updating %s from %s" repo origin)
            (shell-command (format "cd %s && git pull" repo))
            (with-temp-file last-update-file
              (insert (format-time-string "%Y-%m-%d %T" now))))))))

(provide 'sandbox-update)

;;; sandbox-update.el ends here
