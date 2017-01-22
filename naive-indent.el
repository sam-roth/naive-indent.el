;;; naive-indent.el --- Mode-unaware indentation functions

;; Copyright (C) 2017 Sam Roth

;; Author: Sam Roth
;; Version: 0.1

;;; Commentary:
;; This package provides mode-unaware indentation functions and a
;; minor mode that supplies keybindings to them.

(require 'cl)

;;; Code:

(defun naive-indent--indent (indent-func)
  "Indent a line naively using an indent-rigidly-* family \
function INDENT-FUNC."
  (let ((zero-line-flag (eq (point-at-bol) (point-at-eol))))
    (save-excursion
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

    (when zero-line-flag
      (end-of-line))))

(defun naive-indent-backtab ()
  "Backtab naively."
  (interactive)
  (naive-indent--indent 'indent-rigidly-left-to-tab-stop))

(defun naive-indent-tab ()
  "Tab naively."
  (interactive)
  (naive-indent--indent 'indent-rigidly-right-to-tab-stop))

(define-minor-mode naive-indent-minor-mode
  "Minor mode with traditional mode-unaware tab key behavior"
  :lighter "NaiveIndent"
  :keymap '(("\t" . naive-indent-tab)
            ([backtab] . naive-indent-backtab)))

(when (require 'evil nil 'noerror)
  (evil-make-overriding-map naive-indent-minor-mode-map 'insert)
  (add-hook 'naive-indent-minor-mode-hook #'evil-normalize-keymaps))

(provide 'naive-indent)

;;; naive-indent.el ends here
