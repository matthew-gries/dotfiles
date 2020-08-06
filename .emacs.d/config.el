;; themes, fonts, general editor settings
(set-frame-font "Source Code Pro 12" nil t)
(load-theme 'gruvbox t)
(load-theme 'airline-gruvbox-dark t)
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

;; dashboard settings
(setq dashboard-banner-logo-title "Uh oh, stinky...")
(setq dashboard-items '((recents  . 5)
                        (bookmarks . 5)
                        (projects . 5)
                        (agenda . 5)
                        (registers . 5)))
(setq dashboard-startup-banner 3)
(setq dashboard-center-content t)
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

(setq c-default-style "linux")
(setq c-basic-offset 4)

