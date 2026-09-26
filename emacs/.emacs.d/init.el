;; -*- lexical-binding: t; -*-
(use-package emacs
  :custom
  ((custom-file "~/.emacs.d/emacs-custom.el")               ;; Define a localização do arquivo com opções customizadas
   (backup-directory-alist '(("." . "~/.emacs.d/backup/"))) ;; Define a localização dos backups
   (global-display-line-numbers-mode t)                     ;; Ativa a numeração global
   (display-line-numbers-type 'visual)                      ;; Ativa a numeração relativa
   (indent-tabs-mode nil)                                   ;; Good riddance, Tabs
   (tab-width 4) ;;Tab = 4 espaços
   (xref-search-program 'ripgrep)
   (tab-always-indent 'complete)
   (inhibit-startup-message t)
   (ring-bell-function #'ignore)
   (ansi-color-for-compilation-mode t))
  :config
  ;; Adiciona o MELPA à lista de pacotes possíveis
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  ;; Para não poluir a configuração com ensures desnecessários
  (require 'use-package-ensure)
  (setq use-package-always-ensure t)
  ;; Inicia o Emacs com tela cheia
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
  ;; Carrega arquivo de configurações
  (load custom-file)
  (dolist (mode '(eshell-mode-hook dired-mode-hook pdf-view-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))
  ;; Pra conseguir abrir PDFs grandes
  (setq large-file-warning-threshold 100000000)
  ;; Ajustes de codificação quando estiver usando Windows
  (pcase system-type
    (windows-nt
     (prefer-coding-system 'utf-8)
     (set-default-coding-systems 'utf-8)
     (set-terminal-coding-system 'utf-8)
     (set-keyboard-coding-system 'utf-8)
     (setq-default default-process-coding-system '(utf-8 . cp1252))
     ;; Tooling no Windows
     (dolist (path '("C:/Users/jose/Portable/msys64/usr/bin/"
                     "C:/Users/jose/Portable/fd"
                     "C:/Users/jose/Portable/rg"
                     "~/Portable/Git/bin"
                     "~/Repos"))
       (add-to-list 'exec-path (expand-file-name path)))
     (setenv "PATH" (mapconcat #'identity exec-path path-separator))))
  ;; Configurações de cores no compile-mode
  (add-hook 'compilation-filter-hook #'ansi-color-compilation-filter))

(setq-default sysTypeSpecific  system-type)
(cond 
;; If type is "gnu/linux", override to "wsl/linux" if it's WSL.
((eq sysTypeSpecific 'gnu/linux)  
(when (string-match "Linux.*Microsoft.*Linux" 
                    (shell-command-to-string "uname -a"))

    (setq-default sysTypeSpecific "wsl/linux") ;; for later use.
    (setq
    cmdExeBin"/mnt/c/Windows/System32/cmd.exe"
    cmdExeArgs '("/c" "start" "") )
    (setq
    browse-url-generic-program  cmdExeBin
    browse-url-generic-args     cmdExeArgs
    browse-url-browser-function 'browse-url-generic)
    )))

(use-package bookmark
  :config
  (bookmark-store "Configurações" `((filename . ,(expand-file-name "~/.emacs.d/jclmntn_emacs.org")) (position . 1)) nil)
  (bookmark-store "Repositórios" `((filename . ,(expand-file-name "~/Repos/")) (position . 1)) nil)
  (bookmark-store "Notas" `((filename . ,(expand-file-name "~/Repos/Notes/")) (position . 1)) nil)
  (bookmark-save))

(use-package general
  :config
  (general-create-definer jclmntn/leader-keys
                          :keymaps '(normal insert visual emacs)
                          :prefix "SPC"
                          :global-prefix "C-SPC"))

(jclmntn/leader-keys
  ;; "d"   '(dbtel-menu :which-key)
  "s"   '(jclmntn/toggle-speedbar-window :which-key)
  "ca"  '(eglot-code-actions :which-key)
  "cr"  '(eglot-rename :which-key)
  "cf"  '(eglot-format :which-key)
  "RET" '(consult-bookmark :which-key)
  "/"   '(consult-ripgrep :which-key)
  "."   '(consult-fd :which-key)
  "i"   '(consult-imenu :which-key)
  "f"   '(consult-flymake :which-key)
  "oc"  '(org-capture :which-key)
  "oa"  '(org-agenda :which-key)
  "nn"  '(denote :which-key)
  "nr"  '(denote-rename-file :which-key)
  "nl"  '(denote-link :which-key)
  "nj"  '(denote-journal-new-or-existing-entry :which-key)
  "nsl" '(denote-sequence-link :which-key)
  "nsf" '(denote-sequence-find :which-key)
  "nss" '(denote-sequence :which-key)
  "nf"  '(consult-notes :which-key)
  "nb"  '(denote-backlinks :which-key)
  "nwo" '(citar-open :which-key)
  "nwn" '(citar-open-notes :which-key)
  "nwx" '(citar-denote-nocite :which-key))

(defun jclmntn/my-bind-layout-marks (alist evil-fn prefix)
  (dolist (item alist)
    (let* ((key (car item))
           (val (cdr item))
           (sym-name (format "my-layout-%s-%c" prefix val))
           (sym (intern sym-name)))
      (defalias sym `(lambda ()
                      (interactive)
                      (funcall ',evil-fn ,val)))
      (define-key evil-normal-state-map (kbd key) sym))))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-i-jump t)
  :hook
  ;; Preciso fazer isso pra corrigir o problema de completion.
  (completion-in-region-mode . evil-normalize-keymaps)
  :config
  (evil-mode 1)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-undo-system 'undo-redo)
  ;; No emacs 31, o minibuffer fica doidão!! Candidato a PR.
  (evil-set-initial-state 'minibuffer-mode 'emacs)
  (evil-set-initial-state 'completion-list-mode 'emacs)
  (evil-make-overriding-map completion-in-region-mode-map)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "C-.") nil)
  (define-key evil-normal-state-map (kbd "M-.") nil)
  (setq alist-mark-set '(("À" . ?A) ("È" . ?E) ("Ì" . ?I) ("Ò" . ?O) ("Ù" . ?U) ("à" . ?a)
                         ("è" . ?e) ("ò" . ?o) ("ù" . ?u) ("Ǘ" . ?V) ("ǘ" . ?v) ("?" . ?N)
                         ("?" . ?n) ("?" . ?W) ("?" . ?w) ("?" . ?Y) ("?" . ?y)))
  (setq alist-line-set '(("Á" . ?A) ("É" . ?E) ("Í" . ?I) ("Ó" . ?O) ("Ú" . ?U) ("Ý" . ?y)
                         ("á" . ?a) ("é" . ?e) ("í" . ?i) ("ó" . ?o) ("ú" . ?u) ("ý" . ?y)
                         ("N" . ?N) ("n" . ?n) ("Ǘ" . ?V) ("ǘ" . ?v) ("Ẃ" . ?W) ("ẃ" . ?w)))
  (setq alist-reg-set '(("Ä" . ?A) ("Ë" . ?E) ("Ï" . ?O) ("Ö" . ?U) ("Ü" . ?U) ("ä" . ?a)
                        ("ë" . ?e) ("ï" . ?i) ("ö" . ?o) ("ü" . ?u) ("ÿ" . ?y) ("Ÿ" . ?Y)
                        ("Ḧ" . ?H) ("ḧ" . ?h) ("Ẅ" . ?W) ("ẅ" . ?w) ("ẗ" . ?t)))
  (jclmntn/my-bind-layout-marks alist-mark-set #'evil-goto-mark "mark")
  (jclmntn/my-bind-layout-marks alist-line-set #'evil-goto-line "line")
  (jclmntn/my-bind-layout-marks alist-reg-set #'evil-use-register "reg"))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init)
  (evil-collection-eshell-setup)
  (evil-collection-eat-setup))

;; (with-eval-after-load 'evil-collection
;;   (evil-collection-define-key 'normal 'minibuffer-local-map
;;     (kbd "<escape>") 'abort-minibuffers
;;     (kbd "gg")       'minibuffer-beginning-of-buffer
;;     (kbd "j")        'next-line-or-history-element
;;     (kbd "k")        'previous-line-or-history-element
;;     (kbd "gj")       'next-matching-history-element
;;     (kbd "gk")       'previous-matching-history-element
;;     (kbd "C-u")      'minibuffer-complete-history
;;     (kbd "C-d")      'minibuffer-complete-defaults)

;;   (evil-collection-define-key 'insert 'minibuffer-local-map
;;     (kbd "C-n")      'next-line-or-history-element
;;     (kbd "C-p")      'previous-line-or-history-element))

(use-package evil-surround
  :after evil
  :ensure t
  :config
  (global-evil-surround-mode 1))

  (use-package ediff
    :ensure nil
    :custom
    ((ediff-split-window-function 'split-window-horizontally)
     (ediff-window-setup-function 'ediff-setup-windows-plain)))

(use-package dired
  :ensure nil
  :custom
  ((dired-kill-when-opening-new-dired-buffer t)
   (dired-dwim-target t)))

(use-package vundo)

(use-package wgrep)

  (use-package speedbar
    :ensure nil
    :custom ((speedbar-prefer-window t)
             (speedbar-window-dedicated-window t)))

(defun jclmntn/toggle-speedbar-window ()
  (interactive)
  (if (string-equal (buffer-name) " SPEEDBAR")
      (speedbar-window)
    (speedbar-get-focus)))

(defun jclmntn/elfeed-entry-to-bibtex ()
  "A simple function to export elfeed entry metadata into bibtex format, killing its result into the kill ring."
  (interactive)
  (let*
      ((entry (elfeed-search-selected :entry))
       (title (elfeed-entry-title entry))
       (link (elfeed-entry-link entry))
       (year (format-time-string "%Y" (seconds-to-time (elfeed-entry-date entry))))
       (authors-raw (elfeed-meta entry :authors))
       (first-author (plist-get (car authors-raw) :name))
       (first-author-last-name (car (last (split-string first-author))))
       (authors
        (if authors-raw
            (mapconcat (lambda (author) (plist-get author :name)) authors-raw ", ")
          "Unknown Authors"))
       (bibtex-entry (format
              "@misc{%s%s, author = {%s}, title = {%s}, year = {%s}, url = {%s}}"
              first-author-last-name year authors title year link)))
    (kill-new bibtex-entry)
    (message bibtex-entry)))
(use-package elfeed
  :custom ((elfeed-feeds '(("https://www.tandfonline.com/feed/rss/cjas20" journal stats)
                           ("https://hdsr.mitpress.mit.edu/rss.xml" blog data)
                           ("https://rss.sciencedirect.com/publication/science/01482963" journal business stats)
                           ("http://feeds.harvardbusiness.org/harvardbusiness/" blog business)
                           ("https://www.insurancejournal.com/rss/news" news insurance)
                           ("https://www.nexojornal.com.br/rss.xml" news brazil)
                           ("https://www.counting-stuff.com/rss" blog stats)
                           ("https://blog.miguelgrinberg.com/feed" blog python)
                           ("https://davidvujic.blogspot.com/feeds/posts/default" blog python agile)
                           ("https://grouplens.org/feed/" blog computing)
                           ("https://protesilaos.com/master.xml" blog philosophy emacs)))))

(use-package pinentry
  :config (pinentry-start))

  (use-package hl-todo
    :vc (:url "https://github.com/tarsius/hl-todo" :rev :newest)
    :hook ((prog-mode . hl-todo-mode)
           (yaml-mode . hl-todo-mode))
    :config
    (setq hl-todo-keyword-faces
           '(("TODO"   . "#FF0000")
             ("FIXME"  . "#FF0000"))))

(load-theme 'modus-operandi)

(set-face-attribute 'default nil :font "IosevkaTerm" :height 140)
(set-face-attribute 'fixed-pitch nil :font "IosevkaTerm" :height 140)
(set-face-attribute 'variable-pitch nil :font "IosevkaTerm" :height 140 :weight 'regular)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(set-fringe-mode '(20 . 0))

(use-package nerd-icons
  :custom (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  ;; :after vertico
  :config
  (nerd-icons-completion-mode)
  (with-eval-after-load 'marginalia
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)))

(use-package nerd-icons-ibuffer
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package pulsar
  :bind
  ( :map global-map
    ("C-x l" . pulsar-pulse-line) ; overrides `count-lines-page'
    ("C-x L" . pulsar-highlight-permanently-dwim)) ; or use `pulsar-highlight-temporarily-dwim'
  :init
  (pulsar-global-mode 1)
  :config
  (setq pulsar-delay 0.055)
  (setq pulsar-iterations 5)
  (setq pulsar-face 'pulsar-green)
  (setq pulsar-region-face 'pulsar-yellow)
  (setq pulsar-highlight-face 'pulsar-magenta))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-vcs-max-length 30))

(use-package racket-mode
  :mode (("\\.scm\\'" . racket-mode))
  :config
  (add-to-list 'display-buffer-alist
               '(
                 "\\*Racket REPL"
                 (display-buffer-reuse-mode-window
                  display-buffer-below-selected)
                 (window-height . 10)
                 (dedicated . t))))

(use-package just-mode)

(use-package ox-pandoc)

(use-package eat
  :config (eat-eshell-mode))

;; Pensei em incluir isso, mas não dá certo.
;; (defun jclmntn/completion-ret-or-first ()
;;   "RET no minibuffer, imitando o vertico:
;; 1. Se houver um candidato selecionado no buffer de completions
;;    (por navegação com setas via `minibuffer-visible-completions'),
;;    confirma esse candidato.
;; 2. Senão, se o texto digitado já for uma opção válida, confirma
;;    como está.
;; 3. Senão, se houver candidatos disponíveis, pula para o primeiro
;;    e confirma.
;; 4. Senão, aceita o texto digitado como está (ex: nomes novos)."
;;   (interactive)
;;   (cond
;;    ((and (fboundp 'minibuffer-choose-completion-if-selected)
;;          (minibuffer-choose-completion-if-selected)))
;;    ((test-completion (minibuffer-contents)
;;                       minibuffer-completion-table
;;                       minibuffer-completion-predicate)
;;     (exit-minibuffer))
;;    ((completion-all-sorted-completions)
;;     (minibuffer-force-complete-and-exit))
;;    (t
;;     (exit-minibuffer))))

(defun prot-minibuffer-completions-tweak-style ()
  "Tweak the style of the Completions buffer."
  (setq-local mode-line-format nil)
  (setq-local cursor-in-non-selected-windows nil)
  (when (and completions-header-format
             (not (string-blank-p completions-header-format)))
    (setq-local display-line-numbers-offset -1))
  (display-line-numbers-mode 1))

(use-package minibuffer
  :ensure nil
  :hook (completion-list-mode . (lambda () (setq truncate-lines t))) ;; Para fazer com que as completions fiquem sempre na mesma linha.
  :bind
  (:map completion-list-mode-map
        ("RET" . choose-completion))
  ;;   :map minibuffer-local-completion-map
  ;;     ([remap minibuffer-complete-and-exit] . jclmntn/completion-ret-or-first)
  :custom
  ((completion-show-help nil)
   (completion-show-inline-help t)
   (completions-detailed t)
   (completions-format 'one-column)
   (completions-max-height 12)
   (completions-max-annotation-limit 30)
   (completions-sort 'historical)
   (completions-header-format (propertize "%s possible completions:\n" 'face 'shadow))
   (completions-group t)
   (completion-auto-help 'always)
   (completion-auto-select t)
   (completion-tab-width 1)
   (completion-eager-display t)
   (completion-eager-update t)
   (minibuffer-visible-completions 'up-down)
   (minibuffer-completion-auto-choose t))
  :config
  (define-key completion-in-region-mode-map (kbd "RET") #'choose-completion)
  (advice-add 'exit-minibuffer :around
              (lambda (orig-fn &rest args)
                (if (not (minibufferp))
                    (call-interactively #'choose-completion)
                  (apply orig-fn args)))))

(use-package embark
  :bind (
         ("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h b" . embark-bindings))
  :custom
  ((prefix-help-command #'embark-prefix-help-command))
  )

(use-package embark-consult
  :after embark
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package consult
  :bind
  (("C-s" . consult-line)
   ("C-x b" . consult-buffer)))

;; Em algum momento considerei isso para sempre selecionar a primeira opção, mas isso acaba estragando tudo.
;; (:map consult-narrow-map
;;          ([remap exit-minibuffer] . minibuffer-force-complete-and-exit))

(use-package consult-imenu
  :after consult
  :ensure nil)

(use-package consult-notes
  :commands (consult-notes consult-notes-search-in-all-notes)
  :config
  (consult-notes-org-headings-mode)
  (consult-notes-denote-mode)
  (when (locate-library "denote")
    (consult-notes-denote-mode))
  :custom
  ((consult-notes-file-dir-sources '(("Denote" ?d "~/Repos/Notes/denote-notes/")))
   (consult-notes-denote-title-width 50)))

(use-package jinx
  :if (eq system-type 'gnu/linux)
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-language))
  :custom
  (jinx-languages "pt_BR en_US")
  :config
  (with-eval-after-load 'embark
  (keymap-set jinx-repeat-map "RET" 'jinx-correct)
  (embark-define-overlay-target jinx category (eq %p 'jinx-overlay))
  (add-to-list 'embark-default-action-overrides '(jinx . jinx-correct))
  (add-to-list 'embark-target-finders 'embark-target-jinx-at-point)
  (add-to-list 'embark-keymap-alist '(jinx jinx-repeat-map embark-general-map))
  (add-to-list 'embark-repeat-actions #'jinx-next)
  (add-to-list 'embark-repeat-actions #'jinx-previous)
  (add-to-list 'embark-target-injection-hooks (list #'jinx-correct #'embark--ignore-target))))

;; (use-package ispell
;;   :custom
;;   (ispell-alternate-dictionary (expand-file-name "pt_BR_words.txt" user-emacs-directory)))

(use-package marginalia
  ;; :after vertico
  :init (marginalia-mode)
  :custom (marginalia-align-offset -10))

(use-package eca
  :vc (:url "https://github.com/editor-code-assistant/eca-emacs" :rev :newest))

(use-package magit
  :custom
  (magit-display-buffer-action #'magit-display-buffer-same-window-except-diff-v1))

(with-eval-after-load 'magit
  (add-hook 'magit-log-wash-summary-hook
            #'hl-todo-search-and-highlight t)
  (add-hook 'magit-revision-wash-message-hook
            #'hl-todo-search-and-highlight t))

;; Não está funcionando atualmente, preciso entender o porquê.
;; Abri um PR no Forge.
(use-package forge
  :after magit)

(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))

;; Pra forçar a codificação do comando git.
;; Engraçado que isso tenha dado certo, significa que por alguma razão o git tem outra codificação mesmo no WSL.
(setq-default process-coding-system-alist (cons '("git" . (utf-8 . utf-8)) process-coding-system-alist))

(use-package vc-hooks
  :ensure nil
  :custom (vc-follow-symlinks t))

(use-package yasnippet
  :config
  (setq yas-snippet-dirs '("~/Repos/Notes/Snippets/"))
  (yas-global-mode 1))

(use-package hideshow
  :ensure nil
  :hook (prog-mode . hs-minor-mode))

(defun jclmntn/rass-uvtool-command ()
      (let ((uv-tool-command '("uv" "tool" "run" "--from" "rassumfrassum" "rass"))
           (rass-separator '("--"))
           (ty-server-command '("ty" "server"))
           (ruff-server-command '("ruff" "server"))
           (pylsp-server-command '("pylsp")))
        (apply #'append 
               (list
                uv-tool-command
                rass-separator
                ty-server-command
                rass-separator
                ruff-server-command
                rass-separator
                pylsp-server-command))))

(use-package cape)
    ;; :custom
    ;; (cape-dict-file (expand-file-name "pt_BR_words.txt" user-emacs-directory))
    ;; )
(use-package yasnippet-capf :after cape)

(defun jclmntn/eglot-capf-with-yasnippet ()
  (setq-local completion-at-point-functions
              (list 
	       (cape-capf-super
		#'eglot-completion-at-point
		#'yasnippet-capf))))

(use-package eglot
  :hook (eglot-managed-mode . jclmntn/eglot-capf-with-yasnippet)
  :config
  (add-to-list 'eglot-server-programs '(python-mode . jclmntn/rass-uvtool-command))
  (add-to-list 'eglot-server-programs '(python-ts-mode . jclmntn/rass-uvtool-command)))

(use-package eldoc-box
  :hook (eglot-managed-mode . eldoc-box-hover-at-point-mode))

(use-package rainbow-delimiters
             :hook (prog-mode . rainbow-delimiters-mode))

(defun jclmntn/python-dynamic-shell-args (&rest _args)
  "Dynamically set python shell args based on pyproject.toml"
  (let ((pyproject-file (locate-dominating-file default-directory "pyproject.toml")))
    (when pyproject-file
      (let ((args (with-temp-buffer
                    (insert-file-contents (expand-file-name "pyproject.toml" pyproject-file))
                    (goto-char (point-min))
                    (cond
                     ((re-search-forward "kedro" nil t) "run kedro ipython --simple-prompt -i")
                     ((progn (goto-char (point-min)) (re-search-forward "ipython" nil t)) "run ipython")
                     (t "run python -i")))))
        (setq-local python-shell-interpreter-args args)
        (message "Python args set to: %s" args)))))

(use-package python
  :mode (("\\.py\\'" . python-ts-mode))
  :hook ((python-ts-mode . display-fill-column-indicator-mode)
         (python-ts-mode . jclmntn/python-dynamic-shell-args)
         (python-ts-mode . jclmntn/python-dynamic-shell-args))
  :custom ((python-shell-interpreter "uv")
           (python-shell-interpreter-args "run python -i")
           (python-indent-offset 4)
           (python-indent-def-block-scale 1)
           (python-shell-prompt-detect-enabled nil))
  :config
  (advice-add 'run-python :before #'jclmntn/python-dynamic-shell-args))

(use-package project
  :custom
  ((project-mode-line t)
   (project-vc-extra-root-markers '("pyproject.toml"))))

(use-package completion-preview
  :ensure nil
  :demand t
  :custom (completion-preview-minimum-symbol-length 1)
  :bind
  ( :map completion-preview-active-mode-map
    ("M-i" . completion-preview-insert-word)
    ("M-n" . completion-preview-next-candidate)
    ("M-p" . completion-preview-prev-candidate)
    ("M-<return>" . completion-preview-insert)
    ;; Mostra candidatos
    ("<tab>" . completion-preview-complete))
  :config
  (push 'org-self-insert-command completion-preview-commands)
  (global-completion-preview-mode 1))

(defun jclmntn/ejc-maybe-add-limit (args)
  "Inject LIMIT 200 into SELECT queries that do not already specify a limit."
  (let* ((sql (car args))
         (upper (when sql (upcase (string-trim sql)))))
    (if (and upper
             (or (string-match-p "\\`SELECT\\b" upper)
                 (string-match-p "\\`WITH\\b" upper))
             (not (string-match-p "\\bLIMIT\\b" upper)))
        (cons (concat (string-trim-right sql) "\nLIMIT 200") (cdr args))
      args)))

(defun jclmntn/ejc-sql-connected-hook ()
  (ejc-set-fetch-size 99)         ; Limit for the number of records to output.
  (ejc-set-max-rows 99)           ; Limit for the number of records in ResultSet.
  (ejc-set-show-too-many-rows-message t) ; Set output 'Too many rows' message.
  (ejc-set-column-width-limit nil) ; Limit for outputing the number of chars per column.
  (ejc-set-use-unicode t)         ; Use unicode symbols for grid borders.
  )

(use-package ejc-sql
  :hook (ejc-sql-connected . jclmntn/ejc-sql-connected-hook)
  :custom
  (ejc-nrepl-timeout nil)
  (ejc-show-result-bottom t)
  :config
  (setq nrepl-sync-request-timeout nil)
  (require 'ejc-completion-common)
  (advice-add 'ejc-eval-user-sql :filter-args #'jclmntn/ejc-maybe-add-limit)
  (ejc-create-connection
   "BigQuery"
   :dependencies [[com.simba.googlebigquery/googlebigquery-jdbc42 "1.6.3.1004"]
                  [com.google.cloud/google-cloud-bigquerystorage "3.9.3"]
                  [com.google.apis/google-api-services-bigquery "v2-rev20240919-2.0.0"]
                  [com.google.auth/google-auth-library-oauth2-http "1.28.0"]]
   :classname "com.simba.googlebigquery.jdbc.Driver"
   :connection-uri (concat "jdbc:bigquery://https://www.googleapis.com/bigquery/v2:443"
                           ";ProjectId=azos-data-analytics"
                           ";OAuthType=0"
                           ";OAuthServiceAcctEmail=azos-feature-store@azos-data-analytics.iam.gserviceaccount.com"
                           ";OAuthPvtKeyPath=" (expand-file-name "~/.config/gcloud/feature-store.json")))

    (let* ((auth (car (auth-source-search :host "postgres-dis")))
         (user (plist-get auth :user))
         (subname (plist-get auth :subname))
         (password (let ((secret (plist-get auth :secret)))
                     (if (functionp secret) (funcall secret) secret))))
    (ejc-create-connection
     "PostgreSQLDis"
     :dependencies [[org.postgresql/postgresql "42.7.3"]]
     :classpath (concat "~/.m2/repository/org.postgresql/postgresql/42.7.3/"
                        "postgresql-42.7.3.jar")
     :subprotocol "postgresql"
     :subname subname
     :user user
     :password password)))

(use-package
  notmuch
  :commands (notmuch notmuch-search)
  :bind ("C-c m" . notmuch)
  :custom
  ((notmuch-search-oldest-first nil)
  '(("jclmntn@gmail.com" . "jclmntn@gmail.com/Sent +sent -unread")
    ("grancade@gmail.com" . "jclmntn@gmail.com/Sent +sent -unread"))))

(defun jclmntn/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode)
  (add-hook 'completion-at-point-functions (cape-capf-super #'yasnippet-capf) nil t))
  ;; (add-hook 'completion-at-point-functions #'cape-dict nil t)

(defun jclmntn/babel-ansi ()
  (when-let ((beg (org-babel-where-is-src-block-result nil nil)))
    (save-excursion
      (goto-char beg)
      (when (looking-at org-babel-result-regexp)
        (let ((end (org-babel-result-end))
              (ansi-color-context-region nil))
          (ansi-color-apply-on-region beg end))))))

(defun jclmntn/org-capture-templates ()
  "Return custom org-capture templates list."
  '(("i" "Idea" entry
     (file+olp "~/Repos/Notes/Tasks.org" "Caixa de Entrada") 
     "* IDEA %?\n%U\n %a\n %i"
     :empty-lines 1)
    ("l" "Log" entry
     (file+olp denote-journal-path-to-new-or-existing-entry "Logs")
     "* %U %?\n%i\n%a"
     :kill-buffer t
     :empty-lines 1)
    ("p" "Project Task" entry
     (file+headline org-default-notes-file "Inbox")
     "* IDEA %?\n Created: %U\n Link: %a")))

(use-package denote
  :hook (dired-mode . denote-dired-mode)
  :custom ((denote-templates '((journal . "* Logs"))))
  :config
  (setq denote-directory (expand-file-name "~/Repos/Notes/denote-notes"))
  (denote-rename-buffer-mode 1))

(use-package denote-sequence)

(use-package denote-journal
  :custom ((denote-journal-directory
            (expand-file-name "journal" denote-directory))
           (denote-journal-title-format 'day-date-month-year)))

(use-package citar
  :after org
  :demand t
  :custom
  (citar-open-always-create-notes nil)
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  :config
  (require 'citar-org)
  (setq citar-bibliography (file-expand-wildcards "~/Repos/Notes/bib/*.bib"))
  :bind (:map org-mode-map ("C-c b" . #'org-cite-insert))
  :hook (org-mode . (lambda ()
                      (require 'citar-capf)
                      (citar-capf-setup))))

(use-package citar-embark
  :after citar embark
  :no-require
  :config (citar-embark-mode)) 

(use-package citar-denote
  :demand t ;; Ensure minor mode loads
  :after (:any citar denote)
  :custom
  ;; Package defaults
  (citar-denote-file-type 'org)
  (citar-denote-keyword "bib")
  (citar-denote-subdir "bib")
  (citar-denote-template nil)
  (citar-denote-title-format "author-year-title")
  (citar-denote-title-format-andstr "and")
  (citar-denote-title-format-authors 1)
  :init
  (citar-denote-mode))

  (use-package ebib
    :custom (ebib-default-directory "~/Repos/Notes/bib/"))

  (use-package ebib-biblio
    :ensure nil
    :after (ebib biblio)
    :bind (:map ebib-index-mode-map
                ("B" . ebib-biblio-import-doi)
                :map biblio-selection-mode-map
                ("e" . ebib-biblio-selection-import)))

(use-package biblio)

(use-package biblio-openlibrary
  :vc (:url "https://github.com/fabcontigiani/biblio-openlibrary"
       :rev :newest)
  :after biblio
  :demand t)

(use-package pdf-tools
  :config (pdf-loader-install))

(use-package org
  :hook
  (org-mode . jclmntn/org-mode-setup)
  (org-babel-after-execute . jclmntn/babel-ansi)
  :custom 
  ((org-todo-keywords
    '((sequence "TODO(t!)" "PROJ(j)" "NEXT(n)" "IDEA(i)" "|" "DONE(d!)" "KILL(k!)")))
   (org-agenda-files '("~/Repos/Notes/Tasks.org"))
   (org-log-into-drawer t)
   (org-log-done 'time)
   (org-agenda-window-setup 'only-window)
   (org-agenda-restore-windows-after-quit t)
   (org-src-window-setup 'plain)
   (org-src-preserve-indentation t)
   (org-confirm-babel-evaluate nil)
   (org-plantuml-jar-path "~/.config/plantuml/plantuml-mit-1.2025.9.jar")
   (org-latex-src-block-backend 'engraved)
   (org-latex-pdf-process
    '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
      "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
      "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
   (org-cite-csl-link-cites nil)
   (org-cite-csl-nocitelinks-backends '(ascii md gfm))
   (org-refile-targets '(("~/Repos/Notes/Tasks.org" :maxlevel . 3)))
   (org-imenu-depth 3))
  :config
  (setq org-capture-templates (jclmntn/org-capture-templates))
  (add-to-list 'org-src-lang-modes '("planuml" . plantuml))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (emacs-lisp . t)
     (python . t)
     (plantuml . t)
     (eshell . t)))
  (defun org--get-display-dpi ()
    "Hardcode display DPI to bypass PGTK/Wayland arithmetic overflow bug."
    200.0))

(use-package org-transclusion :after org)

(use-package org-modern
  :config
  (global-org-modern-mode))

(use-package org-noter)

(require 'org-habit)

(defun jclmntn/short-hledger-amount ()
  "Target an amount at point of the form hledger-amount-value-regex"
  (save-excursion
    (let* ((line-start (line-beginning-position))
           (line-end (line-end-position))
           (str (buffer-substring-no-properties line-start line-end))
           (match (string-match (concat hledger-currency-string " ?" hledger-amount-value-regex) str))
           (buffer-match-start (+ line-start (match-beginning 0)))
           (buffer-match-end (+ line-start (match-end 0))))
      (save-match-data
        (when (and (derived-mode-p 'hledger-mode) match)
          `(hledger-amount
            ,(format "%s" (match-string 0 str))
            ,buffer-match-start . ,buffer-match-end))))))

(defun hledger-completion-accounts ()
  (when-let ((bounds (and (boundp 'hledger-accounts-cache)
                          (bounds-of-thing-at-point 'symbol))))
    (list (car bounds) (point) hledger-accounts-cache)))

(defun jclmntn/hledger-imenu ()
    (setq-local imenu-create-index-function #'imenu-default-create-index-function)
    (setq-local imenu-generic-expression '(("Dates" "\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)" 1))))

(defun jclmntn/hledger-align-currency ()
  (save-excursion
    (save-restriction
      (widen)
      (align-regexp (point-min) (point-max) "\\(\\s-*\\)R\\$" 1 1 nil))))

(use-package hledger-mode
  :mode "\\.journal\\'"
  :custom
  ((hledger-jfile "~/Repos/hlfinances/2026.journal") ;; Sempre atualizar para o mais recente.
   (hledger-currency-string " R$")
   (hledger-year-of-birth 1995)
   (hledger-reporting-day 1)
   (hledger-ratios-liquid-asset-accounts "assets:bank assets:wallet assets:caixinha")
   (hledger-ratios-essential-expense-accounts "expenses:food expenses:groceries expenses:energy expenses:water expenses:streaming expenses:internet expenses:cellphone expenses:telephone"))
  :hook
  ((hledger-mode . (lambda ()
                     (add-hook 'completion-at-point-functions 'hledger-completion-accounts)))
   (hledger-mode . jclmntn/hledger-imenu)
   (hledger-mode . (lambda () (add-hook 'before-save-hook #'jclmntn/hledger-align-currency))))
  :config
  (with-eval-after-load 'embark
    (add-to-list 'embark-target-finders 'jclmntn/short-hledger-amount)
    (add-to-list 'embark-keymap-alist '(hledger-amount hledger-amount-keymap))
  (defvar-keymap hledger-amount-keymap
    :doc "Keymap for 'hledger-amount'"
    :parent embark-general-map
    "RET" #'hledger-edit-amount)))
