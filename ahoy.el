;;; ahoy.el --- Run ahoy commands from your editor -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Nan0Scho1ar
;;
;; Author: Nan0Scho1ar <scorch267@gmail.com>
;; Maintainer: Nan0Scho1ar <scorch267@gmail.com>
;; Created: May 24, 2022
;; Modified: May 24, 2022
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/nan0scho1ar/ahoy
;; Package-Requires: ((emacs "25.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;; Run ahoy commands fron within Emacs.
;;
;;; Code:

(defun ahoy-cmds ()
  "Run ahoy in the current directory and return a list of possible commands."
  (let ((cmd-str (shell-command-to-string "ahoy --generate-bash-completion")))
    (seq-filter (lambda (x) (not (equal x "init")))
                (split-string cmd-str "\n" t))))

(defun ahoy-select-cmd ()
  "Promp the user to choose a command."
  (completing-read "AHOY: " (ahoy-cmds)))

(defun ahoy-exec (cmd &optional args)
  "Run ahoy command CMD with arguments ARGS."
  (shell-command (format "ahoy %s %s" cmd args)))

(defun ahoy ()
  "Promp the user to choose a command then run it."
  (interactive)
  (ahoy-exec (ahoy-select-cmd)))

(defun ahoy-help ()
  "Promp the user to choose a command then return it's help text."
  (interactive)
  (ahoy-exec "--help" (ahoy-select-cmd)))

(defun ahoy-run-with-args ()
  "Promp the user to choose a command then run it."
  (interactive)
  (ahoy-exec (ahoy-select-cmd) (read-string "ARGS: ")))

(provide 'ahoy)
;;; ahoy.el ends here
