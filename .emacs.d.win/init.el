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
    (use-package company-irony irony-eldoc irony auctex flycheck-rust evil-magit pyvenv jedi eglot counsel company-lsp magit rust-mode evil-collection avy flycheck company all-the-icons neotree dashboard airline-themes powerline projectile which-key atom-one-dark-theme evil))))
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

;; Evil-Magit
(use-package evil-magit
  :init
  (setq evil-magit-state 'normal)
  (setq evil-magit-use-y-for-yank nil))


;; General quality of life extensions
(which-key-mode)
(projectile-mode +1)
(ivy-mode 1)
(setq projectile-completion-system 'ivy)

(use-package page-break-lines
  :config
  (page-break-lines-mode)
  (add-to-list 'load-path "~/.emacs.d/elpa/page-break-lines/page-break-lines-20200305.244.el"))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

(use-package neotree)
(use-package all-the-icons)

;; code completion engine
(use-package company
  :config
  (setq company-idle-delay nil)
  (setq company-minimum-prefix-length 3)
  (setq company-show-numbers t)
  (setq company-tooltip-limit 20)
  (setq company-dabbrev-downcase nil)
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-lsp
  :config
  (setq compnay-lsp-enable-snippet t)
  (push 'company-lsp company-backends))

(use-package lsp-mode)
(use-package rust-mode)

(add-hook 'rust-mode-hook #'lsp)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

; irony mode
(use-package company-irony
  :config
  (add-to-list 'company-backends 'company-irony))

(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(use-package irony
  :config
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))

(use-package irony-eldoc
  :config
  (add-hook 'irony-mode-hook #'irony-eldoc))

;;(setenv "WORKON_HOME" "~/anaconda3/envs")
;;(pyvenv-mode 1)

;; CONFIGURATION STUFF

;; themes, fonts, general editor settings
(load-theme 'gruvbox t)
(set-frame-font "Consolas 12" nil t)
;;(load-theme 'airline-gruvbox-dark t)
;;(menu-bar-mode 0)
(tool-bar-mode 0)
(set-scroll-bar-mode nil)
(toggle-truncate-lines)
(global-display-line-numbers-mode)
(electric-pair-mode 1)
(setq make-backup-files nil)

;; custom keybindings
(global-set-key [f8] 'neotree-toggle)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(add-hook 'neotree-mode-hook
	    (lambda ()
	    (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
	    (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-quick-look)
	    (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
	    (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)
	    (define-key evil-normal-state-local-map (kbd "g") 'neotree-refresh)
	    (define-key evil-normal-state-local-map (kbd "n") 'neotree-next-line)
	    (define-key evil-normal-state-local-map (kbd "p") 'neotree-previous-line)
	    (define-key evil-normal-state-local-map (kbd "A") 'neotree-stretch-toggle)
	    (define-key evil-normal-state-local-map (kbd "H") 'neotree-hidden-file-toggle)))

(global-set-key (kbd "C-:") 'avy-goto-char)
(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "M-g w") 'avy-goto-word-1)
(global-set-key (kbd "M-g e") 'avy-goto-word-0)

(global-set-key (kbd "C-;") 'company-complete-common)

;; dashboard settings
(setq dashboard-banner-logo-title "Uh oh, stinky...")
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))
(setq dashboard-startup-banner 3)
(setq dashboard-center-content t)
; daemon specific
(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))

(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

;; language mode hooks and settings
(add-hook 'after-init-hook #'global-flycheck-mode)
;;(with-eval-after-load 'rust-mode
;;  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(defun my-c-mode-hook ()
  (setq c-default-style "linux")
  (setq c-basic-offset 4))

(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)
(add-hook 'rust-mode-hook
          (lambda () (setq indent-tabs-mode nil)))

(setq-default indent-tabs-mode nil)
(setq tab-width 4)

;; windows specific settings
(setq default-directory "C:/Users/Matthew")
(setq use-file-dialog nil)
(setq use-dialog-box nil)
(setq-default buffer-file-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
; daemon specific stuff
(if (daemonp)
    (add-hook 'after-make-frame-functions
	(lambda (frame)
	  (select-frame frame)
	  (load-theme 'gruvbox t)
	  (set-frame-font "Consolas 12" nil t))))
;; Make startup faster by reducing the frequency of garbage
;; collection.  The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; The rest of the init file.

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
