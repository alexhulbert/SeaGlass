;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       :completion
       company
       vertico

       :ui
       doom
       ;;doom-dashboard
       ;;doom-quit
       ;;(emoji +unicode)
       hl-todo
       modeline
       ophints
       (popup +defaults)
       ;;tabs
       treemacs
       unicode
       vc-gutter
       vi-tilde-fringe
       window-select
       workspaces

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates
       fold
       multiple-cursors

       :emacs
       dired
       electric
       ;;ibuffer
       undo
       vc

       :term

       :checkers
       syntax

       :tools
       debugger
       (eval +overlay)
       lookup
       lsp
       magit
       terraform

       :os
       tty

       :lang
       data
       elixir
       emacs-lisp
       (go +lsp)
       json
       javascript
       latex
       lua
       markdown
       nix
       org
       python
       rust
       scala
       sh
       solidity
       web
       yaml

       :email

       :app
       ;;everywhere

       :config
       (default +bindings +smartparens))

(when doom-debug-p
  (require 'benchmark-init)
  (add-hook 'doom-first-input-hook #'benchmark-init/deactivate))

(set-background-color "ARGBBB000000")
