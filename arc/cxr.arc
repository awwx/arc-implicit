(def caar   (xs) (car (car xs)))
(def cadr   (xs) (car (cdr xs)))
(def cdar   (xs) (cdr (car xs)))
(def cddr   (xs) (cdr (cdr xs)))
(def cadar  (xs) (car (cdar xs)))
(def cddar  (xs) (cdr (cdar xs)))
(def caddar (xs) (car (cddar xs)))
