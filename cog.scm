;; Copyright (C) 2026 Tom Waddington
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; cog.scm - Forge package manifest for eval.hx
;;;
;;; Evaluates Steel code against the live editor engine via the `eval-string`
;;; builtin and routes results to a dedicated *hx-eval* scratch buffer.
;;;
;;; Installable with Steel's package manager:
;;;
;;;   forge pkg install --git https://github.com/waddie/eval.hx
;;;
;;; then, in ~/.config/helix/init.scm:
;;;
;;;   (require "eval.hx/eval.scm")

(define package-name 'eval.hx)
(define version "0.2.0")

;; repl-ui.hx: shared scratch-buffer, formatting, counter and selection
;; machinery (also used by nrepl.hx). Pure Scheme, no dylib.
(define dependencies
  '((#:name "repl-ui.hx"
     #:git-url
     "https://github.com/waddie/repl-ui.hx"
     #:sha
     "f274c26b23424929a38949c8e47fb2826e9eb2cb")))
