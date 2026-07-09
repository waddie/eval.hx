# eval.hx

Evaluates Steel code against the live editor engine (via the `eval-string`
builtin) and routes results to a dedicated `*hx-eval*` scratch buffer, in the
style of [nrepl.hx](https://github.com/waddie/nrepl.hx).

Evaluation is synchronous and runs on the editor’s own engine, so evaluated
code can call any `helix/*` function and see prior definitions.

Note that evaluated code shares the global namespace and can shadow bindings.

## Demo

![An asciinema recording of evaluating code with the results in the eval.hx
buffer](https://github.com/waddie/eval.hx/blob/main/images/demo.gif?raw=true)

## Commands

- `:hx-eval-selection` - Evaluate the primary selection.
- `:hx-eval-buffer` - Evaluate the entire buffer.
- `:hx-eval-multiple-selections` - Evaluate every selection in sequence.
- `:hx-eval-prompt` - Prompt for an expression and evaluate it.

Results are appended to the `*hx-eval*` buffer in REPL format: a `repl:N:>`
prompt, the value, or a commented error block.

## Install

```sh
forge pkg install --git https://github.com/waddie/eval.hx
```

Then, in `~/.config/helix/init.scm`:

```scheme
(require "eval.hx/eval.scm")
```

See `keybindings-example.scm` for a sample keymap (bound under `space E`).

## Licence

GNU AGPL v3 or later. See LICENSE.md.
