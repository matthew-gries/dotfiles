(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
  ;; and `package-pinned-packages`. Most users will not need or want to do this.
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  )
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(conda-anaconda-home "~/anaconda3/")
 '(custom-safe-themes
   (quote
    ("d1af5ef9b24d25f50f00d455bd51c1d586ede1949c5d2863bef763c60ddf703a" default)))
 '(package-selected-packages
   (quote
    (company-irony irony-eldoc irony auctex flycheck-rust evil-magit pyvenv jedi eglot counsel company-lsp magit rust-mode evil-collection avy flycheck company all-the-icons neotree dashboard airline-themes powerline projectile which-key atom-one-dark-theme evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Evil mode
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(setq evil-want-C-u-scroll t)

(require 'evil)
(when (require 'evil-collection nil t)
  (evil-collection-init))
(evil-mode 1)
(evil-set-initial-state 'neotree-mode 'emacs)
(evil-set-initial-state 'dashboard-mode 'emacs)
(evil-set-initial-state 'dired-mode 'emacs)
(evil-set-initial-state 'shell-mode 'emacs)

(setq evil-magit-state 'normal)
(setq evil-magit-use-y-for-yank nil)
(require 'evil-magit)

;; General quality of life extensions
(which-key-mode)
(projectile-mode +1)
(ivy-mode 1)
(setq projectile-completion-system 'ivy)
(require 'powerline)
(require 'airline-themes)
(require 'page-break-lines)
(turn-on-page-break-lines-mode)
(add-to-list 'load-path "~/.emacs.d/elpa/page-break-lines/page-break-lines-20200305.244.el")
(require 'dashboard)
(dashboard-setup-startup-hook)
(require 'neotree)
(require 'all-the-icons)

;; code completion engine
(require 'company)
(setq company-idle-delay nil)
(setq company-minimum-prefix-length 3)
(setq company-show-numbers t)
(setq company-tooltip-limit 20)
(setq company-dabbrev-downcase nil)
(add-hook 'after-init-hook 'global-company-mode)
;;(global-company-mode t)
(require 'company-lsp)
(setq compnay-lsp-enable-snippet t)
(push 'company-lsp company-backends)
(require 'lsp-mode)
(require 'rust-mode)
;;(add-hook 'c-mode-hook #'lsp)
;;(add-hook 'c++-mode-hook #'lsp)
(add-hook 'rust-mode-hook #'lsp)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

; irony mode
(require 'company-irony)
(add-to-list 'company-backends 'company-irony)
(require 'irony)
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(require 'irony-eldoc)
(add-hook 'irony-mode-hook #'irony-eldoc)

(setenv "WORKON_HOME" "~/anaconda3/envs")
(pyvenv-mode 1)

(load "~/.emacs.d/config.el")
