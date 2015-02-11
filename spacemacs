;; -*- mode: emacs-lisp -*-                                       (0.43.0)
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

;; Configuration Layers
;; --------------------

(setq-default
 ;; List of additional paths where to look for configuration layers.
 ;; Paths must have a trailing slash (ie. `~/.mycontribs/')
 dotspacemacs-configuration-layer-path '()
 ;; List of configuration layers to load.
 dotspacemacs-configuration-layers '(themes-megapack
                                     haskell clojure scala ruby javascript
                                     git zoo)
 ;; A list of packages and/or extensions that will not be install and loaded.
 dotspacemacs-excluded-packages '()
)

;; Settings
;; --------

(setq-default
 ;; Specify the startup banner. If the value is an integer then the
 ;; banner with the corresponding index is used, if the value is `random'
 ;; then the banner is chosen randomly among the available banners, if
 ;; the value is nil then no banner is displayed.
 dotspacemacs-startup-banner '999
 ;; Default theme applied at startup
 dotspacemacs-themes '(zenburn)
 ;; The leader key
 dotspacemacs-leader-key "SPC"
 ;; Major mode leader key is a shortcut key which is the equivalent of
 ;; pressing `<leader> m`
 dotspacemacs-major-mode-leader-key ","
 ;; The command key used for Evil commands (ex-commands) and
 ;; Emacs commands (M-x).
 ;; By default the command key is `:' so ex-commands are executed like in Vim
 ;; with `:' and Emacs commands are executed with `<leader> :'.
 dotspacemacs-command-key ":"
 ;; Guide-key delay in seconds. The Guide-key is the popup buffer listing
 ;; the commands bound to the current keystrokes.
 dotspacemacs-guide-key-delay 0.4
 ;; If non nil the frame is fullscreen when Emacs starts up (Emacs 24.4+ only).
 dotspacemacs-fullscreen-at-startup nil
 ;; If non nil the frame is maximized when Emacs starts up (Emacs 24.4+ only).
 ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
 dotspacemacs-maximized-at-startup nil
 ;; A value from the range (0..100), in increasing opacity, which describes the
 ;; transparency level of a frame when it's active or selected. Transparency can
 ;; be toggled through `toggle-transparency'.
 dotspacemacs-active-transparency 90
 ;; A value from the range (0..100), in increasing opacity, which describes the
 ;; transparency level of a frame when it's inactive or deselected. Transparency
 ;; can be toggled through `toggle-transparency'.
 dotspacemacs-inactive-transparency 90
 ;; If non nil unicode symbols are displayed in the mode line (e.g. for lighters)
 dotspacemacs-mode-line-unicode-symbols nil
 ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth scrolling
 ;; overrides the default behavior of Emacs which recenters the point when
 ;; it reaches the top or bottom of the screen
 dotspacemacs-smooth-scrolling t
 ;; If non nil pressing 'jk' in insert state, ido or helm will activate the
 ;; evil leader.
 dotspacemacs-feature-toggle-leader-on-jk nil
 ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
 dotspacemacs-smartparens-strict-mode t
 ;; If non nil advises quit functions to keep server open when quitting.
 dotspacemacs-persistent-server nil
 ;; The default package repository used if no explicit repository has been
 ;; specified with an installed package.

 ;; Not used for now.
 dotspacemacs-default-package-repository nil
 )
;; Initialization Hooks
;; --------------------

(defun dotspacemacs/init ()
  "User initialization for Spacemacs. This function is called at the very
 startup."
  ;; using evil-escape-key-sequence to jk... I'm going to wait
  ;; for the first issue I have with this to change it
  (setq-default evil-escape-key-sequence (kbd "jk"))
  ;; I _do not_ like this feature at all
  (setq-default evil-search-highlight-persist nil)
  (setq-default clocker-enable-on-initialize t)
  (setq-default clocker-issue-format-regex "lp-[[:digit:]]+"))

(defun dotspacemacs/config ()
  "This is were you can ultimately override default Spacemacs configuration.
This function is called at the very end of Spacemacs initialization."
  ;; (global-whitespace-mode 1)
  (golden-ratio-mode 1)
  (clocker-mode 1)
  (global-evil-search-highlight-persist -1)
  (ido-vertical-mode -1))

;; Custom variables
;; ----------------

;; Do not write anything in this section. This is where Emacs will
;; auto-generate custom variable definitions.
