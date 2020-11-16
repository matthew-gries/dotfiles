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
   '("d1af5ef9b24d25f50f00d455bd51c1d586ede1949c5d2863bef763c60ddf703a" default))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(racer yasnippet-snippets elpy company-jedi yapfify py-yapf company-racer use-package jdee cargo slime flymake-racket racket-mode flycheck-haskell lsp-haskell haskell-mode yasnippet company-irony irony-eldoc irony auctex flycheck-rust evil-magit pyvenv jedi eglot counsel company-lsp magit rust-mode evil-collection avy flycheck company all-the-icons neotree dashboard airline-themes powerline projectile which-key atom-one-dark-theme evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  (add-to-list 'load-path "<path where use-package is installed>")
  (require 'use-package))

;; Evil mode

(use-package evil
  :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-want-C-u-scroll t)
    :config
    (when (require 'evil-collection nil t)
    (evil-collection-init))
    (evil-mode 1)
    (evil-set-initial-state 'neotree-mode 'emacs)
    (evil-set-initial-state 'dashboard-mode 'emacs)
    (evil-set-initial-state 'dired-mode 'emacs)
    (evil-set-initial-state 'shell-mode 'emacs))

 (use-package evil-magit
   :init
   (setq evil-magit-state 'normal)
   (setq evil-magit-use-y-for-yank nil))

(defun neotree-evil-hook ()
  ;;; Neotree evil settings
  (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
  (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-quick-look)
  (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
  (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)
  (define-key evil-normal-state-local-map (kbd "g") 'neotree-refresh)
  (define-key evil-normal-state-local-map (kbd "n") 'neotree-next-line)
  (define-key evil-normal-state-local-map (kbd "p") 'neotree-previous-line)
  (define-key evil-normal-state-local-map (kbd "A") 'neotree-stretch-toggle)
  (define-key evil-normal-state-local-map (kbd "H") 'neotree-hidden-file-toggle))


;; General quality of life extensions
(use-package which-key
  :config
  (which-key-mode))

(use-package ivy
  :config
  (ivy-mode 1))

(use-package projectile
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package airline-themes)
(use-package powerline
  :init
  (load-theme 'airline-gruvbox-dark t))

(use-package page-break-lines
  :config
  (page-break-lines-mode))

(use-package all-the-icons)

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Uh oh, stinky...")
  (setq dashboard-items '((recents  . 5)
                          (bookmarks . 5)
                          (projects . 5)
                          (agenda . 5)
                          (registers . 5)))
  (setq dashboard-startup-banner 3)
  (setq dashboard-center-content t))

(use-package neotree
  :hook
  (neotree-mode . neotree-evil-hook)
  :bind
  ([f8] . neotree-toggle)
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

(use-package avy
  :bind
  ("C-:" . avy-goto-char)
  ("C-'" . avy-goto-char-2)
  ("M-g f" . avy-goto-line)
  ("M-g w" . avy-goto-word-1)
  ("M-g e" . avy-goto-word-0))

;; Language settings
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Rust mode stuff
(use-package rust-mode)
(add-hook 'rust-mode-hook
          (lambda () (setq indent-tabs-mode nil)))


;; flycheck and linting
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))

(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'rust-mode-hook #'flycheck-rust-setup)

(use-package company
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :config
  (setq company-idle-delay nil)
  (setq company-minimum-prefix-length 3)
  (setq company-show-numbers t)
  (setq company-tooltip-limit 20)
  :bind
  ("C-;" . company-complete-common))

 
(use-package racer
  :ensure t
  :init
  (setq racer-rust-src-path
    (concat (string-trim
            (shell-command-to-string "rustc --print sysroot"))
            "/lib/rustlib/src/rust/library"))
  :bind
  ("<f8>" . racer-describe))

(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'company-mode)

;;(setenv "WORKON_HOME" "~/anaconda3/envs")
;;(pyvenv-mode 1)
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

;; themes, fonts, general editor settings
(set-frame-font "Source Code Pro 12" nil t)
(load-theme 'gruvbox t)
(menu-bar-mode 0)
(tool-bar-mode 0)
(set-scroll-bar-mode nil)
(toggle-truncate-lines)
(global-display-line-numbers-mode)
(electric-pair-mode 1)
(setq make-backup-files nil)

;; custom keybindings

(defun my-indent-region (N)
  (interactive "p")
  (if (use-region-p)
      (progn (indent-rigidly (region-beginning) (region-end) (* N 4))
             (setq deactivate-mark nil))
    (self-insert-command N)))

(defun my-unindent-region (N)
  (interactive "p")
  (if (use-region-p)
      (progn (indent-rigidly (region-beginning) (region-end) (* N -4))
             (setq deactivate-mark nil))
    (self-insert-command N)))

(global-set-key (kbd "C->") 'my-indent-region)
(global-set-key (kbd "C-<") 'my-unindent-region)
(global-set-key (kbd "<f9>") 'compile)

;; language mode hooks and settings
(defun my-c-mode-hook ()
  (setq c-default-style "linux")
  (setq c-basic-offset 4))

(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

;; indentation
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default tab-always-indent t)

;; misc.
(setq max-lisp-eval-depth 10000)
(setq max-specpdl-size 13000)
