;; Copyright (C) 2026 Tom Waddington
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU Affero General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;;; evaluate.scm - Evaluate Steel against the live engine
;;;
;;; Wraps the Steel `eval-string` builtin, which evaluates a string in the
;;; plugin's global environment against the running editor. Code sees every
;;; helix/* binding and any prior `define`s, so state persists across calls
;;; (the REPL behaviour). It also means evaluated code shares the plugin's
;;; global namespace and can shadow bindings.
;;;
;;; Commands run on the Helix main thread, so no hx.with-context marshalling is
;;; needed here.

(provide evaluate)

;; Extract a readable message from a raised value. error-object-message throws
;; on non-error values, so fall back to a generic string representation.
(define (error->string err)
  (with-handler (lambda (_) (to-string err))
    (error-object-message err)))

;; Render an evaluated value for the REPL buffer. Void (e.g. from `define`)
;; yields #f so no value line is shown; strings are quoted so they are
;; distinguishable from symbols/output.
(define (value->display v)
  (cond
    [(void? v) #f]
    [(string? v) (string-append "\"" v "\"")]
    [else (to-string v)]))

;;@doc
;; Evaluate a string of Steel code against the live engine.
;;
;; Returns a result hash compatible with repl-ui.hx's format-result-common:
;;   success -> 'value (string or #f for void), 'output '(), 'error #f
;;   failure -> 'value #f, 'error <msg>, 'ex <msg>
(define (evaluate code)
  (with-handler
    (lambda (err)
      (let ([msg (error->string err)])
        (hash 'value #f 'output '() 'error msg 'ex msg 'ns #f)))
    (let ([result (eval-string code)])
      (hash 'value (value->display result) 'output '() 'error #f 'ns #f))))
