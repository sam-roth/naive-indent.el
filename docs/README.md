# Function

The `naive-indent` package provides a minor mode that indents text by
one tab stop upon pressing the tab key and dedents it by one tab stop
upon pressing shift-tab. This is useful for working with files for
which no minor mode is available.

# Installation

This package hasn't been published to a major package archive yet. To
add it to Emacs, add the following quoted list to your
`package-archives` list and install the `naive-indent` package:

```elisp
("naive-indent" . "https://sam-roth.github.io/naive-indent.el/archive/")
```

# Usage

Toggle the minor mode using `M-x naive-indent-minor-mode`. You can
also use the functions mapped by the major mode directly:

* **`(naive-indent-backtab)`**

  Shift the current line left by one tab stop.

* **`(naive-indent-tab)`**

  Shift the current line right by one tab stop.
