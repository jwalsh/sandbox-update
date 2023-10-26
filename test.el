;; Add some repos
(sandbox-update-repo-add "sandbox-update.el")
(sandbox-update-repo-add "emacs-ai-utils")
(sandbox-update-repo-add "feedback.el")
(sandbox-update-repo-add "org-mode-journal-capture-templates")
(sandbox-update-repo-add "chatgpt-shell")
(sandbox-update-repo-add "socratic-ai.el")
(sandbox-update-repo-add "whisper.el")
(sandbox-update-repo-add "copilot.el")

;; Remove repo
(sandbox-update-repo-remove "chatgpt-shell")

;; List repos
(sandbox-update-repos-list)

;; Clear repos
(sandbox-update-repos-clear)

;; Update repos
(sandbox-update-repos-update)
