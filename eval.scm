;; Copyright (C) 2026 Tom Waddington
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; eval.hx - A self-driving Steel REPL for Helix
;;;
;;; Evaluates Steel code against the live editor engine (via the `eval-string`
;;; builtin) and routes results to a dedicated *hx-eval* scratch buffer, in the
;;; style of nrepl.hx. Unlike a network REPL, evaluation is synchronous and runs
;;; on the editor's own engine, so evaluated code can call any helix/* function
;;; and see prior definitions.
;;;
;;; Usage:
;;;   :hx-eval-selection            - Evaluate the primary selection
;;;   :hx-eval-buffer               - Evaluate the entire buffer
;;;   :hx-eval-multiple-selections  - Evaluate every selection in sequence
;;;   :hx-eval-prompt               - Prompt for an expression and evaluate it
;;;
;;; All results are appended to the *hx-eval* buffer in REPL format
;;; (repl:N:> prompt, value, or a commented error block).

(require-builtin helix/components)
(require (prefix-in helix. "helix/commands.scm"))
(require "helix/misc.scm")

;; Shared REPL machinery
(require "repl-ui.hx/helix-context.scm")
(require "repl-ui.hx/buffer.scm")
(require "repl-ui.hx/format.scm")
(require "repl-ui.hx/counter.scm")
(require "repl-ui.hx/selection.scm")

;; Local evaluator
(require "cogs/eval/evaluate.scm")

(provide hx-eval-selection
  hx-eval-buffer
  hx-eval-multiple-selections
  hx-eval-prompt)

;;;; Configuration ;;;;

;; Comment prefix for Steel/Scheme, used when commenting error detail.
(define comment-prefix ";")

;; Split orientation for the output buffer ('vsplit or 'hsplit).
(define orientation 'vsplit)

;;;; State ;;;;

;; The *hx-eval* output buffer handle (updated as it is created/recreated).
;; Language is forced to scheme regardless of the source buffer's language.
(define *buffer*
  (box (make-repl-buffer "*hx-eval*" orientation "; hx-eval buffer\n" "scheme")))

;; Per-session eval counter for repl:N:> numbering.
(define *counter* (make-eval-counter))

;;;; Formatting ;;;;

;; Steel prompt line: repl:N:> <code> (mirrors the Janet adapter's numbering).
(define (format-prompt-steel ns code eval-number)
  (if eval-number
    (string-append "repl:" (number->string eval-number) ":> " code "\n")
    (string-append "repl:> " code "\n")))

;;;; Evaluation ;;;;

;; Ensure the output buffer exists, evaluate code, append the formatted result.
;; Fully synchronous: eval-string returns directly on the main thread.
(define (eval-and-append code)
  (let ([ctx (make-helix-context)])
    (repl-buffer:ensure
      (unbox *buffer*)
      ctx
      (lambda (rb)
        (set-box! *buffer* rb)
        (let* ([n (eval-counter-next! *counter*)]
               [result (evaluate code)]
               [formatted (format-result-common code
                           result
                           format-prompt-steel
                           take-first-line
                           comment-prefix
                           #t
                           n)])
          (set-box! *buffer* (repl-buffer:append (unbox *buffer*) formatted ctx)))
        ;; Return void so Helix does not echo the command's return value.
        (if #f #f)))))

;;;; Commands ;;;;

;;@doc
;; Evaluate the current selection (primary cursor)
(define (hx-eval-selection)
  (let ([sel (selection:primary)])
    (if (not sel)
      (helix.echo "hx-eval: No text selected")
      (eval-and-append (hash-get sel 'code)))))

;;@doc
;; Evaluate the entire buffer
(define (hx-eval-buffer)
  (let ([buf (selection:buffer)])
    (if (not buf)
      (helix.echo "hx-eval: Buffer is empty")
      (eval-and-append (hash-get buf 'code)))))

;;@doc
;; Evaluate all selections in sequence
(define (hx-eval-multiple-selections)
  (let ([ranges (selection:ranges)])
    (if (null? ranges)
      (helix.echo "hx-eval: No selections")
      (let loop ([remaining ranges] [count 0])
        (if (null? remaining)
          (helix.echo (string-append "hx-eval: Evaluated "
                       (number->string count)
                       (if (= count 1) " selection" " selections")))
          (let ([code (hash-get (car remaining) 'code)])
            (if (string=? code "")
              ;; Skip empty/whitespace-only selection
              (loop (cdr remaining) count)
              (begin
                (eval-and-append code)
                (loop (cdr remaining) (+ count 1))))))))))

;;@doc
;; Prompt for an expression and evaluate it
(define (hx-eval-prompt)
  (push-component!
    (prompt "eval:"
      (lambda (code)
        (let ([trimmed (trim code)])
          (when (not (string=? trimmed ""))
            (eval-and-append trimmed)))))))
