;;; package --- Summary:
;; Config file for my Emacs distribution.
;;; Commentary:
;;
;;; Code:
;; -*- lexical-binding: t; -*-
;; Global keymaps
;; Make ESC be immediate
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Minimize setup
(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10)
(menu-bar-mode -1)
(setq visible-bell nil)

;;; Setup font
(defvar my-font-name)
(defvar my-font-size)
(defvar my-fontspec)

(setq my-font-name (cond
		    ((eq system-type 'darwin) "Iosevka Nerd Font")
		    (t "PragmataPro Mono Liga")))

(setq my-font-size (cond
		    (t 15)))

(setq my-fontspec (concat my-font-name "-" (number-to-string my-font-size)))
(add-to-list 'default-frame-alist `(font . ,my-fontspec))
(set-face-attribute 'default t :font my-font-name :height (* my-font-size 10))

;; Install use-package

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Plugins

;; Which-key

(use-package which-key
  :config (which-key-mode 1))

;; Ivy

(use-package ivy-prescient)

(use-package ivy
  :diminish
  :requires (ivy-prescient)
  :config
  (ivy-mode 1)
  (ivy-prescient-mode 1)
  (prescient-persist-mode 1))

;; Evil mode

(defvar evil-want-keybinding)
(defvar evil-want-integration)

(setq evil-want-keybinding nil)
(setq evil-want-integration t)

(use-package undo-tree
  :config (global-undo-tree-mode))

(use-package evil-leader)

(use-package evil
  :init
  :config
  (evil-mode 1)
  (evil-set-leader 'normal (kbd "SPC"))
  (evil-set-undo-system 'undo-tree)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1)
  (evil--add-to-alist
   'evil-surround-pairs-alist
   ?\( '("(" . ")")
   ?\[ '("[" . "]")
   ?\{ '("{" . "}")
   ?\) '("( " . " )")
   ?\] '("[ " . " ]")
   ?\} '("{ " . " }")))


;; Magit

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :init
  (setq auth-sources '("~/.authinfo"))
  :after magit)

(use-package diff-hl
  :config
  (global-diff-hl-mode))

;; Better keybinding

(use-package general
  :after (evil)
  :config (general-evil-setup))

;; Theming

(use-package telephone-line
  :config
  (telephone-line-mode 1))

;; (use-package gruvbox-theme
;;  :config (load-theme 'gruvbox-dark-hard t))

(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-woodland t))
;; Beancount

(straight-use-package '(beancount-mode :host github :repo "beancount/beancount-mode"))
(use-package no-littering)

(use-package nix-mode
  :mode "\\.nix\\'")

(add-to-list 'auto-mode-alist '("\\.beancount\\'" . beancount-mode))

;; YAML

(use-package yaml-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

;; JS/TS

(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :after tree-sitter)

(use-package typescript-mode
  :after (:all tree-sitter)
  :config
  (add-to-list 'tree-sitter-major-mode-language-alist '(typescriptreact-mode . tsx)))

(straight-use-package '(tsi :type git :host github :repo "orzechowskid/tsi.el"))
(straight-use-package '(tsx-mode :type git :host github :repo "orzechowskid/tsx-mode.el" :branch "emacs28"))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-mode))

;; Treemacs

(use-package treemacs
  :defer t)
(use-package treemacs-evil
  :after (treemacs evil))

;; Lua

(use-package lua-mode)

;; LSP

(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l")
  (setq lsp-beancount-langserver-executable "beancount-language-server")
  (setq lsp-beancount-journal-file "tx.beancount")
  (setq gc-cons-threshold 100000000)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  :hook ((lsp-mode . lsp-enable-which-key-integration)
	 (yaml-mode . lsp-deferred)
	 (lua-mode . lsp-deferred)
	 (javascript-mode . lsp-deferred)
	 (typescript-mode . lsp-deferred)
	 (python-mode . lsp-deferred)
	 (elixir-mode . lsp-deferred))
  :commands (lsp lsp-deferred)
  :config
  (defgroup lsp-ruff-lsp nil
    "LSP support for Python, using ruff-lsp's Python Language Server."
    :group 'lsp-mode
    :link '(url-link "https://github.com/charliermarsh/ruff-lsp"))

  (defcustom lsp-ruff-lsp-server-command '("ruff-lsp")
    "Command to start ruff-lsp."
    :risky t
    :type '(repeat string)
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-ruff-path ["ruff"]
    "Paths to ruff to try, in order."
    :risky t
    :type 'lsp-string-vector
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-ruff-args []
    "Arguments, passed to ruff."
    :risky t
    :type 'lsp-string-vector
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-log-level "error"
    "Tracing level."
    :type '(choice (const "debug")
		   (const "error")
		   (const "info")
		   (const "off")
		   (const "warn"))
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-python-path "python3"
    "Path to the Python interpreter."
    :risky t
    :type 'string
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-show-notifications "off"
    "When notifications are shown."
    :type '(choice (const "off")
		   (const "onError")
		   (const "onWarning")
		   (const "always"))
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-advertize-organize-imports t
    "Whether to report ability to handle source.organizeImports actions."
    :type 'boolean
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-advertize-fix-all t
    "Whether to report ability to handle source.fixAll actions."
    :type 'boolean
    :group 'lsp-ruff-lsp)

  (defcustom lsp-ruff-lsp-import-strategy "fromEnvironment"
    "Where ruff is imported from if lsp-ruff-lsp-ruff-path is not set."
    :type '(choice (const "fromEnvironment")
		   (const "useBundled"))
    :group 'lsp-ruff-lsp)

  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection
		     (lambda () lsp-ruff-lsp-server-command))
    :activation-fn (lsp-activate-on "python")
    :server-id 'ruff-lsp
    :priority -2
    :add-on? t
    :initialization-options
    (lambda ()
      (list :settings
	    (list :args lsp-ruff-lsp-ruff-args
		  :logLevel lsp-ruff-lsp-log-level
		  :path lsp-ruff-lsp-ruff-path
		  :interpreter (vector lsp-ruff-lsp-python-path)
		  :showNotifications lsp-ruff-lsp-show-notifications
		  :organizeImports (lsp-json-bool lsp-ruff-lsp-advertize-organize-imports)
		  :fixAll (lsp-json-bool lsp-ruff-lsp-advertize-fix-all)
		  :importStrategy lsp-ruff-lsp-import-strategy)))))

  (lsp-consistency-check lsp-ruff-lsp))

(use-package elixir-mode)

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :bind (:map yas-minor-mode-map
              ("C-c C-e" . yas-expand))
  
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (yas-global-mode 1)
  (setq yas-prompt-functions '(yas-dropdown-prompt
                               yas-ido-prompt
                               yas-completing-prompt)))

(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
(use-package dap-mode)

(use-package company
  :config
  (global-company-mode))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; Projectile

(use-package projectile
  :config
  (projectile-mode +1)
  (treemacs-project-follow-mode +1))

(use-package treemacs-projectile
  :after '(treemacs projectile))
(use-package counsel-projectile
  :after projectile)
(use-package ripgrep)
(use-package ag)

;; Terminal

(use-package vterm)
(use-package popper
  :bind (("C-`"   . popper-toggle-latest)
	 ("C-M-`"   . popper-cycle))
  :init
  (setq popper-reference-buffers
	'("\\*Messages\\*"
	  "Output\\*$"
	  "\\*Async Shell Command\\*"
	  "\\*vterm\\*"
	  "\\*poetry-shell\\*"
	  "\\*ripgrep-search\\*"
	  help-mode
	  compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))

;; Dashboard

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
  (setq dashboard-content-center t)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-items '((recents  . 5)
			  (bookmarks . 5)
			  (projects . 5)))
  (setq dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name))

;; Centaur Tabs

(use-package all-the-icons
  :if (display-graphic-p))

(use-package centaur-tabs
  :after all-the-icons
  :init
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-style "wave")
  (setq centaur-tabs-height 32)
  (defun centaur-tabs-hide-tab (x)
    "Do no to show buffer X in tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Current window is not dedicated window.
       (window-dedicated-p (selected-window))

       ;; Buffer name not match below blacklist.
       (string-prefix-p "*epc" name)
       (string-prefix-p "*helm" name)
       (string-prefix-p "*Helm" name)
       (string-prefix-p "*Compile-Log*" name)
       (string-prefix-p "*lsp" name)
       (string-prefix-p "*company" name)
       (string-prefix-p "*Flycheck" name)
       (string-prefix-p "*tramp" name)
       (string-prefix-p " *Mini" name)
       (string-prefix-p "*help" name)
       (string-prefix-p "*straight" name)
       (string-prefix-p " *temp" name)
       (string-prefix-p "*Help" name)
       (string-prefix-p "*mybuf" name)
       (string-prefix-p "*dashboard" name)

       ;; Is not magit buffer.
       (and (string-prefix-p "magit" name)
	    (not (file-name-extension name)))
       )))
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-group-by-projectile-project)
  :bind
  ("C-S-h" . centaur-tabs-backward)
  ("C-S-l" . centaur-tabs-forward)
  ("C-S-<left>" . centaur-tabs-backward)
  ("C-S-<right>" . centaur-tabs-forward))

;; Poetry

(use-package poetry
  :config
  (poetry-tracking-mode))

(use-package paren
  :straight (:type built-in)
  :custom
  (show-paren-when-point-inside-paren t)
  :custom-face
  (show-paren-match ((t (:background nil :weight bold :foreground "white"))))
  :hook
  (dashboard-after-initialize . show-paren-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package color-identifiers-mode
  :commands color-identifiers-mode)

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

(use-package sudo-edit)

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  (ligature-set-ligatures 'prog-mode
  			  '(
				"!=" "!==" "!=<"
				"#(" "#_" "#_(" "#{" "#>" "##" "#["
				"$>" "%=" "&%" "&&" "&+" "&-" "&/" "&=" "&&&"
				"(|" "*>" "++" "+++" "+=" "+>" "++="
				"--" "-<" "-<<" "-=" "->" "->>" "---" "-->" "-+-"
				"-\/" "-|>" "-<|" "->-" "-<-" "-|" "-||" "-|:"
				"- [v]" "- [x]" "- [-]"
				".=" "/=" "/==" "/-\\" "/-:" "/->"
				"/=>" "/-<" "/=<" "/=:" "//="
				":=" ":=>" ":-\\" ":|=" ":=/"
				":-/" ":-|" ":=|" ":|-" ":|="
				"<$>" "<*" "<*>" "<+>" "<-" "<<=" "<=" "<=>"
				"<>" "<|>" "<<-" "<|" "<=<" "<~" "<~~" "<<~"
				"<$" "<+" "<!>" "<@>" "<%>" "<^>" "<&>"
				"<?>" "<.>" "</>" "<\\>" "<\">" "<:>" "<~>" "<**>"
				"<<^" "<->" "<!--" "<--" "<~<" "<==>" "<|-"
				"<<|" "<||" "<-<" "<-->" "<==" "<<=="
				"<-\\" "<-/" "<=\\" "<=/"
				"=<<" "==" "===" "==>" "=>" "=~" "=>>"
				"=|" "=||" "=|:" "=/" "=/=" "=/<"
				">-" ">=" ">>-" ">>=" ">=>"
				">>^" ">>|" ">!=" ">->" ">==" ">/=" ">-|"
				">=|" ">-\\" ">=\\" ">-/" ">=/" ">λ="
				"?." "[[" "[|"
				"[BUG]" "[DEBUG]" "[ERR]"
				"[ERROR]" "[FAIL]" "[FATAL]" "[FIXME]"
				"[HACK]" "[INFO]" "[INFO ]" "[KO]"
				"[MARK]" "[NOTE]" "[OK]" "[PASS]"
				"[PASS ]" "[TODO]" "[TRACE]" "[VERBOSE]"
				"[WARN]" "[WARN ]" "[WARNING]"
				"]]" "\\==" "\\/-" "\\-/" "\\-:" "\\->"
				"\\=>" "\\-<" "\\=<" "\\=:"
				"_|_" "^=" "^<<" "^>>"
				"|)" "|=" "|>=" "|>" "|+|" "|->" "|-->" "|=>"
				"|==>" "|>-" "|<<" "||>" "|>>" "|-" "||-" "||="
				"|-:" "|=:" "|-<" "|=<" "|--<" "|==<" "|]"
				"~=" "~>" "~~>" "~>>"
				))
  (global-ligature-mode t))

;; Key binding

(general-nmap
  :prefix "SPC"
  "o" 'treemacs
  "t" 'vterm
  "p" 'counsel-projectile-switch-project
  "g" 'magit-status
  "e" '(:ignore t :which-key "emacs")
  "l" '(:ignore t :which-key "lsp"))

(general-nmap
  :prefix "SPC e"
  "c" 'calc)

(general-nmap
  :keymaps 'emacs-lisp-mode-map
  :prefix "SPC e"
  "x" 'eval-buffer)

(general-nmap
  "] q" '(flycheck-next-error 1 1)
  "[ q" '(flycheck-previous-error 1 1))

(general-nmap
  "C-h" 'evil-window-left
  "C-l" 'evil-window-right
  "C-j" 'evil-window-down
  "C-k" 'evil-window-up)

(general-imap
  "C-g" 'evil-normal-state
  "C-SPC" 'company-manual-begin)

(general-imap
  :keymaps 'company-mode-map
  "ESC" 'company-abort)

(general-nmap
  :prefix "SPC"
  "x" 'kill-current-buffer)

(general-vmap
  :prefix "SPC"
  "/" 'comment-line)

(general-nmap
  :prefix "SPC l"
  "p" 'poetry)

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(warning-suppress-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
