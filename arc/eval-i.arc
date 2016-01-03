(def eval (x (o into globals))
  (ar-eval
    (unprimitive
      (expand-implicit
        (macro-expand x into)))))
