;;; naive-indent.el --- Mode-unaware indentation functions

;; Copyright (C) 2017 Sam Roth

;; Author: Sam Roth
;; Version: 0.2

;;; Commentary:
;; This package provides mode-unaware indentation functions and a
;; minor mode that supplies keybindings to them.

(require 'cl)

;;; Code:

(eval-when-compile
  (when (or (< emacs-major-version 25)
            (and (= emacs-major-version 25) (< emacs-minor-version 1)))
    (defmacro save-mark-and-excursion (&rest body)
      `(save-excursion ,@body))))

(defun naive-indent--indent (indent-func)
  "Indent a line naively using an indent-rigidly-* family \
function INDENT-FUNC."
  (let ((line-start-flag (eq (point-at-bol) (point))))
    (save-mark-and-excursion
      (beginning-of-line)

      (let ((empty-line-flag (looking-at-p "^\\s-*$"))
            (empty-line-marker "#"))     ; arbitrary dummy character
        ;; The indent-rigidly-* functions don't work on lines with
        ;; only whitespace characters. To work around this, insert a
        ;; dummy character on whitespace-only lines.
        (when empty-line-flag
          (end-of-line)
          (insert empty-line-marker))

        (apply indent-func (point-at-bol) (point-at-eol) nil)

        (when empty-line-flag
          (end-of-line)
          (backward-char 1)
          (cl-assert (looking-at-p empty-line-marker))
          (delete-char 1))))

    (when line-start-flag
      (back-to-indentation))))

(defmacro naive-indent--define-tabbing-fn (name doc indent-func)
  `(defun ,name (&optional beg end)
     ,doc
     (interactive
      (if (use-region-p)
          (list (region-beginning) (region-end))
        nil))
     (if beg
         (save-mark-and-excursion
           (,indent-func beg end))
       (naive-indent--indent #',indent-func))
     (setq deactivate-mark nil)))

(naive-indent--define-tabbing-fn
 naive-indent-backtab
 "Backtab naively. Shift the line left by one tab stop."
 indent-rigidly-left-to-tab-stop)

(naive-indent--define-tabbing-fn
 naive-indent-tab
 "Tab naively. Shift the line right by one tab stop."
 indent-rigidly-right-to-tab-stop)

(define-minor-mode naive-indent-minor-mode
  "Minor mode with the mode-unaware tab key behavior similar to \
that found in most text editors."
  :lighter "NaiveIndent"
  :keymap '(("\t" . naive-indent-tab)
            ([backtab] . naive-indent-backtab)))

(when (require 'evil nil 'noerror)
  ;; Ensure minor mode keybindings take place of evil-mode's defaults
  ;; since not doing this would defeat the entire purpose of this
  ;; mode.
  (dolist (mode '(insert visual))
    (evil-make-overriding-map naive-indent-minor-mode-map mode))
  (add-hook 'naive-indent-minor-mode-hook #'evil-normalize-keymaps))

(provide 'naive-indent)

;;; naive-indent.el ends here
