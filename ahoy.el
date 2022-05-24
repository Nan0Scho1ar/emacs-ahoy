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
(require 'ansi-color)

(define-derived-mode ahoy-mode
  fundamental-mode "Ahoy"
  "Major mode for ahoy.")

(defun ahoy-build-control-sequence-regexp (regexps)
  "Build control sequence regexp from list of REGEXPS."
  (mapconcat (lambda (regexp)
               (concat "\\(?:" regexp "\\)"))
             regexps "\\|"))

(defvar ahoy-non-sgr-control-sequence-regexp
      (ahoy-build-control-sequence-regexp
       '(;; icon name escape sequences
         "\033\\][0-2];.*?\007"
         ;; non-SGR CSI escape sequences
         "\033\\[\\??[0-9;]*[^0-9;m]"
         ;; noop
         "\012\033\\[2K\033\\[1F"
         ;; tput sgr0
         "\033(B"
         ))
     "Regexps which matches non-SGR control sequences.")

(defun ahoy-filter-non-sgr-control-sequences-in-region (begin end)
  (save-excursion
    (goto-char begin)
    (while
        (re-search-forward ahoy-non-sgr-control-sequence-regexp end t)
      (replace-match ""))))

(defun ahoy-exec (cmd &optional args)
  "Run ahoy command CMD with arguments ARGS."
  (let ((buffer (get-buffer-create (format "* Ahoy %s *" cmd))))
    (when args (setq cmd (format "%s %s" cmd args)))
    (with-current-buffer buffer (erase-buffer) (ahoy-mode))
    (make-process :name "ahoy"
                  :buffer buffer
                  :command (list "bash" "-c" (format "TERM=xterm ahoy %s" cmd))
                  :noquery t
                  :sentinel (lambda (proc _event)
                              (when (memq (process-status proc) '(exit signal))
                                (with-current-buffer (process-buffer proc)
                                  (ansi-color-apply-on-region (point-min) (point-max))
                                  (ahoy-filter-non-sgr-control-sequences-in-region (point-min) (point-max)))
                                (pop-to-buffer (process-buffer proc)))))))

(defun ahoy-cmds ()
  "Run ahoy in the current directory and return a list of possible commands."
  (let ((cmd-str (shell-command-to-string "ahoy --generate-bash-completion")))
    (seq-filter (lambda (x) (not (equal x "init")))
                (split-string cmd-str "\n" t))))

(defun ahoy-select-cmd ()
  "Promp the user to choose a command."
  (completing-read "AHOY: " (ahoy-cmds)))

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
