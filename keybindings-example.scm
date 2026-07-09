(keymap (global)
  (normal (space (E
                  (b ":hx-eval-buffer")
                  (m ":hx-eval-multiple-selections")
                  (p ":hx-eval-prompt")
                  (s ":hx-eval-selection")))
    (S-A-ret ":hx-eval-selection"))
  (select (space (E
                  (b ":hx-eval-buffer")
                  (m ":hx-eval-multiple-selections")
                  (p ":hx-eval-prompt")
                  (s ":hx-eval-selection")))
    (S-A-ret ":hx-eval-selection")))
