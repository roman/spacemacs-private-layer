(defvar zoo-packages
  '(evil-visual-mark-mode
    clocker
    nix-mode
    navorski
    confluence
    whitespace
    helm-c-yasnippet

    ;; clojure
    paredit
    evil-paredit
    cider
    flycheck-clojure
    flycheck-pos-tip

    ensime
    w3m
    haskell-mode
    org))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/-get-hook-funcs (hook)
  (delq nil (mapcar
             (lambda (e) (if (symbolp e) e))
             hook)))

(defun zoo/-get-hook-funcs-names (hook)
  (mapcar 'symbol-name
          (zoo/-get-hook-funcs
           (if (symbolp hook)
               (symbol-value hook)
             hook))))

(defun zoo/-get-all-hooks ()
  (let (hlist (list))
    (mapatoms (lambda (a)
                (if (and (not (null (string-match ".*-hook"
                                                  (symbol-name a))))
                         (not (functionp a)))
                    (add-to-list 'hlist a))))
        hlist))

(defun zoo/remove-from-hook (hook fname &optional local)
  (interactive
   (let ((hook (intern (ido-completing-read
                        "Which hook? "
                        (mapcar #'symbol-name (zoo/-get-all-hooks))))))
     (list hook
           (ido-completing-read "Which? " (zoo/-get-hook-funcs-names hook)))))
  (remove-hook hook
               (if (stringp fname)
                   (intern fname)
                 fname)
               local))

(defun zoo/remove-after-save-hook (fname)
  (interactive (list (ido-completing-read
                      "Which? "
                      (zoo/-get-hook-funcs-names after-save-hook))))
    (zoo/remove-from-hook 'after-save-hook fname t))

(defun zoo/add-after-save-hook (fname)
  (interactive "aWhich function: ")
    (add-hook 'after-save-hook fname t t))

(evil-define-key 'normal php-mode-map
  (kbd "<SPC>mr") 'start-wordpress)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/navorski-terminal-line-mode ()
  (interactive)
  (when (term-in-char-mode)
    (term-line-mode)
    (linum-mode 1))
  (when (evil-emacs-state-p)
    (evil-normal-state)))

(defun zoo/navorski-terminal-char-mode ()
  (interactive)
  (when (evil-normal-state-p)
    (evil-emacs-state))
  (when (term-in-line-mode)
    (term-char-mode)
    (linum-mode 0)))

(defun zoo/navorski-terminal-toggle-mode ()
  (interactive)
  (cond
   ;; on char mode
   ((term-in-char-mode)
    (progn
      (term-line-mode)
      (linum-mode 1)))

   ;; on line mode
   ((term-in-line-mode)
    (progn
      (term-char-mode)
      (evil-emacs-state)
      (linum-mode 0)))

   ;; else
   (t nil)))

(defun zoo/set-navorski-keybidings ()
  (evil-local-set-key
   'emacs
   (kbd "<f7> n") 'zoo/navorski-terminal-line-mode)
  (evil-local-set-key
   'normal
   (kbd "<f7> e") 'zoo/navorski-terminal-char-mode))

(defun zoo/init-navorski ()
  (use-package navorski
    :config
    (progn
      (setq-default multi-term-program (or (getenv "SHELL")
                                           "/bin/sh"))
      (evil-set-initial-state 'term-mode 'emacs)
      (evil-leader/set-key "]" 'nav/term)
      (add-hook 'term-mode-hook 'zoo/set-navorski-keybidings))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defadvice spacemacs/mode-line-prepare-left (around compile)
          (setq ad-return-value (clocker-add-clock-in-to-mode-line ad-do-it)))

(defun zoo/init-clocker ()
  (use-package powerline
    :config
    (progn
      (ad-activate 'spacemacs/mode-line-prepare-left)
      (evil-leader/set-key "tC" 'clocker-mode)
      (clocker-mode 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; shamelessly stolen from
;; http://beatofthegeek.com/2014/02/my-setup-for-using-emacs-as-web-browser.html

(defun zoo/reddit (reddit)
  "Opens the REDDIT in w3m-new-session"
  (interactive (list
                (read-string "Enter the reddit (default: haskell): " nil nil "haskell" nil)))
  (browse-url (format "http://m.reddit.com/r/%s" reddit)))


(defun zoo/hoogle (term)
  "Opens hoogle search in w3m-new-session"
  (interactive (list
                (read-string "Enter the hoogle term: ")))
  (browse-url (format "http://www.haskell.org/hoogle/?hoogle=%s" term)))

;; When I want to enter the web address all by hand
(defun zoo/w3m-open-site (site)
  "Opens site in new w3m session with 'http://' appended"
  (interactive
   (list (read-string "Enter website address (default: google.com):" nil nil "google.com" nil )))
  (w3m-goto-url-new-session
      (concat "http://" site)))

(defun zoo/init-w3m ()
  (use-package w3m
    :init
    (progn
      (setq-default browse-url-browser-function 'w3m-goto-url-new-session)
      (setq-default w3m-user-agent "Mozilla/5.0 (Linux; U; Android 2.3.3; zh-tw; HTC_Pyramid Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533."))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/init-whitespace ()
  (use-package whitespace
    :init
    (progn
      (setq-default indent-tabs-mode nil)
      (setq-default whitespace-style
                    '(face tabs trailing newline empty
                           space-before-tab space-after-tab))
      (add-hook 'after-save-hook 'whitespace-cleanup))
    :config
    (progn
      (global-whitespace-mode 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/toogle-evil-visual-mark-mode ()
  "Toogle evil-visual-mark-mode on and off"
  (interactive)
  (if (symbol-value evil-visual-mark-mode)
      (progn (evil-visual-mark-mode -1))
    (evil-visual-mark-mode 1)))

(defun zoo/init-evil-visual-mark-mode ()
  (use-package evil
    :config
    (use-package evil-visual-mark-mode
      :init (setq evil-visual-mark-exclude-marks '("^" "[" "]"))
      :config (progn
                (evil-visual-mark-mode 1)
                (evil-leader/set-key "tv" 'zoo/toogle-evil-visual-mark-mode)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/init-evil-paredit ())

(defun zoo/flycheck-clojure-after-hook ()
  (flycheck-mode 1)
  (flycheck-clojure-setup))

(defun zoo/init-flycheck-clojure ()
  (use-package clojure-mode
    :config
    (progn
      (setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages)
      (add-hook 'clojure-mode-hook 'zoo/clojure-after-hook))))

(defun zoo/clojure-after-hook ()
  (paredit-mode 1)
  (evil-paredit-mode 1)
  (smartparens-mode -1))

(defun zoo/cider-switch-and-load ()
  (interactive)
  (let* ((repl-buffer (cider-current-repl-buffer))
         (repl-ns (and repl-buffer (with-current-buffer repl-buffer
                                     cider-buffer-ns)))
         (buffer-ns (cider-current-ns)))
    (when (not (string= repl-buffer buffer-ns))
      (cider-repl-set-ns buffer-ns))
    (cider-load-file (buffer-file-name))
    (cider-switch-to-repl-buffer)))

(defun zoo/cider-load-and-test ()
  (interactive)
  (cider-load-file (buffer-file-name))
  (cider-test-run-test))

(defun zoo/init-cider ()
  (use-package cider
    :config
    (progn
      (evil-leader/set-key-for-mode 'clojure-mode
        "ml" 'zoo/cider-switch-and-load
        "m," 'zoo/cider-load-and-test
        "mi" 'cider-inspect
        "mq" 'cider-quit
        "msc" 'cider-connect)
      (setq cider-repl-pop-to-buffer-on-connect t)
      (add-hook 'cider-repl-mode-hook 'zoo/clojure-after-hook))))

(defun zoo/init-clojure-mode ()
  (use-package clojure-mode
    :config
    (progn
      (setq flycheck-display-errors-function #'flycheck-pos-tip-error-messages)
      (add-hook 'clojure-mode-hook 'zoo/clojure-after-hook))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/ensime-load-file ()
  (interactive)
  (ensime-inf-load-file (buffer-file-name)))

(defun zoo/init-ensime ()
  (use-package ensime
    :defer t
    :config
    (progn
      (evil-leader/set-key-for-mode 'scala-mode
        "mz"  'ensime-inf-switch
        "ml"  'zoo/ensime-load-file
        "mer" 'ensime-inf-eval-region
        "meb" 'ensime-inf-eval-buffer
        "mj"  'ensime))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/parent-dir (dir)
  "Returns the parent directory path of given directory path."
  (if (or (not dir)
          (string-equal dir "/"))
      nil
    (file-name-directory
          (directory-file-name dir))))

(defun zoo/locate-dominating-file (glob &optional start-dir)
  "Similar to the original one, although this one accepts globs.

If start directory is not specified, starts in `default-directory`."
  (let* ((dir (or start-dir default-directory))
         (file-found (directory-files dir
                                      nil
                                      (eshell-glob-regexp glob))))
    (cond
     (file-found (concat dir (car file-found)))
     ((not (or (string= dir "/")
               (string= dir "~/")))
      (zoo/locate-dominating-file glob
                                  (zoo/parent-dir dir)))
     (t nil))))

(defun zoo/haskell-find-cabal-dir ()
  "Returns the directory path where the *.cabal file is."
  (zoo/parent-dir (zoo/locate-dominating-file "*.cabal")))

(defun zoo/haskell-find-cabal-sandbox-dir ()
  "Returns the directory path where the .cabal-sandbox folder is."
  (zoo/locate-dominating-file ".cabal-sandbox"))

(defun zoo/haskell-find-cabal-sandbox-package-db ()
  (interactive)
  (let* ((cabal-sandbox-dirname (zoo/haskell-find-cabal-sandbox-dir))
         (package-db (and cabal-sandbox-dirname
                          (car
                           (directory-files
                            cabal-sandbox-dirname t (eshell-glob-regexp "*-packages.conf.d"))))))
    package-db))

(defun zoo/haskell-switch-to-ghci (&optional no-reload)
  "Pops the ghci buffer, in case it is already there asks to reload it."
  (interactive)

  ;; restart ghci?
  (when (not no-reload)
    (let ((buffer (get-buffer "*haskell*")))
      (when (and buffer
                 (y-or-n-p "Do you want to reload ghci? "))
        (set-process-query-on-exit-flag (get-buffer-process buffer) nil)
        (kill-buffer buffer))))

  ;; setup "cabal-dev ghci" in case we are using cabal-dev
  ;; setup special ghci in case we are using cabal sandbox
  (let* ((cabal-sandbox-dir (zoo/haskell-find-cabal-sandbox-dir))
         (default-directory (or cabal-sandbox-dir
                                default-directory))
         (haskell-program-name (or (and cabal-sandbox-dir
                                        (format "ghci \"-package-db\" \"%s\""
                                                (zoo/haskell-find-cabal-sandbox-package-db)))
                                   haskell-program-name)))
    (message "excute: %s" haskell-program-name)
    (switch-to-haskell)))

(defun zoo/inferior-haskell-reload-file ()
  (interactive)
  (zoo/inferior-haskell-load-file 'reload))

(defun zoo/inferior-haskell-load-file (&optional reload)
  "Pass the current buffer's file to the inferior haskell process.
If prefix arg \\[universal-argument] is given, just reload the previous file."
  (interactive "P")
  ;; Save first, so we're sure that `buffer-file-name' is non-nil afterward.
  (save-buffer)
  (let ((buf (current-buffer))
        (file buffer-file-name)
        (proc (inferior-haskell-process)))
    (if file
        (with-current-buffer (process-buffer proc)
          (compilation-forget-errors)
          (let ((parsing-end (marker-position (process-mark proc)))
                root)
            (inferior-haskell-send-command
             proc (if reload ":reload"
                    (concat ":load \""
                            ;; Espace the backslashes that may occur in file names.
                            (replace-regexp-in-string "[\\\"]" "\\\\\&" file)
                            "\"")))
            ;; Move the parsing-end marker *after* sending the command so
            ;; that it doesn't point just to the insertion point.
            ;; Otherwise insertion may move the marker (if done with
            ;; insert-before-markers) and we'd then miss some errors.
            (if (boundp 'compilation-parsing-end)
                (if (markerp compilation-parsing-end)
                    (set-marker compilation-parsing-end parsing-end)
                  (setq compilation-parsing-end parsing-end))))
          (with-selected-window (display-buffer (current-buffer) nil 'visible)
            (goto-char (point-max)))
          ;; Use compilation-auto-jump-to-first-error if available.
          ;; (if (and (boundp 'compilation-auto-jump-to-first-error)
          ;;          compilation-auto-jump-to-first-error
          ;;          (boundp 'compilation-auto-jump-to-next))
          ;;     (setq compilation-auto-jump-to-next t)
          (when inferior-haskell-wait-and-jump
            (inferior-haskell-wait-for-prompt proc)
            (ignore-errors                  ;Don't beep if there were no errors.
              (next-error))))
      (error "No file associated with buffer"))))

(defun zoo/init-haskell-mode ()
  (use-package haskell-mode
    :config
    (progn
      (evil-leader/set-key-for-mode 'haskell-mode
        "mj" 'zoo/haskell-switch-to-ghci
        "ml" 'zoo/inferior-haskell-load-file
        "mr" 'zoo/inferior-haskell-reload-file))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/init-confluence ()
  (use-package confluence
    :defer t
    :init
    (progn
      (setf confluence-url "https://wiki.unbounce.com/confluence/rpc/xmlrpc"))
    :config
    (progn
      ;; maybe include keybindings on org-mode ?
      )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun zoo/init-org ()
  (use-package org
    :defer t
    :config
    (progn
      (setq org-hide-leading-stars t)
      (setq org-show-following-heading t)
      (setq org-show-hierarchy-above t)

      ;; ctrl-a/e will respect org-mode entries
      ;; jump to the start of the headline
      (setq org-special-ctrl-a/e t)

      ;; respect tags when killing line on a heading
      (setq org-special-ctrl-k t)
      (setq org-return-follows-link t)

      ;; Save the clock and entry when I close emacs
      (setq org-clock-persist t)

      ;; Check a clock that was left behind open when
      ;; starting emacs
      (org-clock-persistence-insinuate)

      ;; Store at least 35 clocks in memory
      (setq org-clock-history-length 35)

      ;; When clocking in, change the status of the item to
      ;; STARTED
      (setq org-clock-in-switch-to-state "STARTED")

      ;; Have a special :CLOCK: drawer for clocks
      (setq org-clock-into-drawer "CLOCK")

      ;; Don't register clocks with zero-time length
      (setq org-clock-out-remove-zero-time-clocks t)

      ;; Stop clock when a task gets to state DONE.
      (setq org-clock-out-when-done t)

      ;; Resolve open-clocks if iddle more than 30 minutes
      (setq org-clock-idle-time 30)

      ;; Activate single letter commands at the beginning of
      ;; a headline
      (setq org-use-speed-commands t)


      ;; when changing the item to DONE, Don't add anything
      (setq org-log-done nil)

      ;; Add all notes and timestamps to the LOGBOOK drawer
      (setq org-log-into-drawer "LOGBOOK")

      ;; When task is refilled, rescheduled or redeadline add
      ;; a timestamp to the task
      (setq org-log-refile 'time)
      (setq org-log-reschedule 'time)
      (setq org-log-redeadline 'time)


      (setq org-log-note-headings
            '((done .  "CLOSING NOTE %t")
              (state . "State %-12s from %-12S %t")
              (note .  "Note taken on %t")
              (reschedule .  "Rescheduled from %S on %t")
              (delschedule .  "Not scheduled, was %S on %t")
              (redeadline .  "New deadline from %S on %t")
              (deldeadline .  "Removed deadline, was %S on %t")
              (refile . "Refiled from %s to %S on %t")
              (clock-out . "")))

      (setq org-done-keywords
            '("DONE" "CANCELLED"))

      ;; Avoid adding a blank line after doing alt-return on an entry.
      (setq org-blank-before-new-entry '((heading . auto)
                                         (plain-list-item . auto)))

      ;; When hitting alt-return on a header, please create a new one without
      ;; messing up the one I'm standing on.
      (setq org-insert-heading-respect-content t)

      ;; Avoid adding a blank line after doing alt-return on an entry.
      (setq org-blank-before-new-entry
            '((heading . auto)
              (plain-list-item . auto)))

      ;; When hitting alt-return on a header, please create a new one without
      ;; messing up the one I'm standing on.
      (setq org-insert-heading-respect-content t)

      ;; Avoid setting entries as DONE when there are still sub-entries
      ;; that are not DONE.
      (setq org-enforce-todo-dependencies t)

      ;; Allow to iterate easily between todo-keywords using meta->/meta-<
      (setq org-use-fast-todo-selection t)
      (setq org-treat-S-cursor-todo-selection-as-state-change nil)

      ;; States that a todo can have
      (setq org-todo-keywords
            '((sequence "TODO(t)" "TODAY(y!)" "|" "STARTED(s!)" "|" "PAUSED(p!)"
                        "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "SOMEDAY(S!)" "OPEN(O@)" "|" "CANCELLED(c@/!)")))


      ;; Pretty styling for the different keywords of a TODO item
      (setq org-todo-keyword-faces
            '(("TODO" :foreground "red" :weight bold)
              ("TODAY" :foreground "color-27" :weight bold)
              ("STARTED" :foreground "color-27" :weight bold)
              ("PAUSED" :foreground "gold" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("SOMEDAY" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)))


      ;; BABEL supported languages
      (setq org-babel-load-languages
            '((clojure . t)
              (emacs-lisp . t)))

      (defun zoo/org-mode-ask-effort ()
        (unless (org-entry-get (point) "Effort")
          (let ((effort
                 (completing-read
                  "Effort: "
                  (org-entry-get-multivalued-property (point) "Effort"))))
            (unless (equal effort "")
              (org-set-property "Effort" effort)))))

      (defun zoo/org-current-timestamp ()
        (let ((fmt (concat
                    "[" (substring (cdr org-time-stamp-formats) 1 -1) "]")))
          (format-time-string fmt)))

      (defun zoo/org-current-clock-id ()
        "Get the id of the current item being clocked."
        (save-window-excursion
          (save-excursion
            (org-clock-goto)
            (org-id-get-create))))

      (defun zoo/org-insert-heading-hook ()
        (interactive)
        ;; Create an ID for the current item
        (org-id-get-create)
        (org-set-property "ADDED"
                          (zoo/org-current-timestamp))
        (if (zoo/org-clocking-p)
            ;; ^ If a clock is active, add a reference to the task
            ;; that is clocked in
            (org-set-property "CLOCK-WHEN-ADDED"
                              (zoo/org-current-clock-id))))

      (defun zoo/org-is-last-task-started-p ()
        (interactive)
        (save-window-excursion
          (org-clock-goto)
          (let ((state (org-get-todo-state)))
            (string= state "STARTED"))))

      (defun zoo/org-clock-in-last ()
        (interactive)
        (if (zoo/org-is-last-task-started-p)
            (org-clock-in-last)
          (message "ignoring org-clock-in-last")))

      (defun zoo/org-mode-hook ()
        ;; hate this crap
        (evil-org-mode -1))

      (add-hook 'org-insert-heading-hook
                'zoo/org-insert-heading-hook)

      (add-hook 'org-clock-in-prepare-hook
                'zoo/org-mode-ask-effort)

      (add-hook 'org-mode-hook
                'zoo/org-mode-hook)

      (global-set-key (kbd "<f8> i") 'org-clock-in)
      (global-set-key (kbd "<f8> o") 'org-clock-out)
      (global-set-key (kbd "<f8> l") 'zoo/org-clock-in-last)
      (global-set-key (kbd "<f8> -") 'org-clock-goto)
      )))
