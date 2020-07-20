(set-frame-font "Iosevka 12" nil t)
(load-theme 'gruvbox t)
(tool-bar-mode 0)
(set-scroll-bar-mode nil)
(global-display-line-numbers-mode)
(toggle-truncate-lines)
;;(setq inhibit-startup-message t)
(setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
(add-to-list 'default-frame-alist '(font . "Iosevka 12"))
(setq-default visible-bell t)
(setq use-file-dialog nil)
(setq use-dialog-box nil)
(setq-default buffer-file-coding-system 'utf-8-unix)
;; utf-8 settings
(set-terminal-coding-system 'utf-8)
(set-language-environment 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Windows performance tweaks
;;
(when (boundp 'w32-pipe-read-delay)
  (setq w32-pipe-read-delay 0))
;; Set the buffer size to 64K on Windows (from the original 4K)
(when (boundp 'w32-pipe-buffer-size)
  (setq irony-server-w32-pipe-buffer-size (* 64 1024)))

;; compile command set to F9
(global-set-key (kbd "<f9>") #'compile)

(global-set-key (kbd "<C-f9>")
                (lambda () (interactive)
                  (save-buffer)
                  (recompile)                
                  ))


;; function to run bash
(defun run-bash ()
      (interactive)
      (let ((shell-file-name "C:\\Program Files\\Git\\bin\\bash.exe"))
            (shell "*bash*")))

;; function to run cmd
(defun run-cmdexe ()
      (interactive)
      (let ((shell-file-name "cmd.exe"))
            (shell "*cmd.exe*")))

;; function to run powershell
(defun run-powershell ()
  "Run powershell"
  (interactive)
  (async-shell-command "c:/windows/system32/WindowsPowerShell/v1.0/powershell.exe -Command -"
               nil
               nil))
