;;; init.el --- Summary
;;; Some ruby packages

;;; Commentary:

;;; Code:

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/"))
      use-package-always-ensure t)

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(setq package-list '(better-defaults
                     solarized-theme
                     ruby-electric
                     inf-ruby
                     ruby-test-mode
                     flycheck))

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'better-defaults)

(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'ruby-mode)

(load-theme 'solarized-dark t)

(global-linum-mode)
(column-number-mode)

(require 'ruby-electric)
(add-hook 'ruby-mode-hook 'ruby-electric-mode)

(add-hook 'compilation-finish-functions
          (lambda (buf strg)
            (switch-to-buffer-other-window "*compilation")
            (read-only-mode)
            (got-char (point-max))
            (local-set-key (kbd "q")
                           (lambda () (interactive) (quit-restore-window)))))

(add-hook 'after-init-hook #'global-flycheck-mode)

(provide 'init)
;;; init.el ends here
