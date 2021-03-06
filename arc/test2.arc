(mac catcherr (expr)
  `(on-err (fn (c) (list 'err (details c)))
           (fn () ,expr)))

(mac test (x expected)
  (w/uniq (actual expect)
    `(with (,actual (catcherr ,x) ,expect ,expected)
       (if (iso ,actual ,expected)

            (do (disp "OK ")
                (write ',x)
              (disp " => ")
              (write (xhash ,actual))
              (disp "\n"))

            (do (disp "FAIL ")
                (write ',x)
              (disp " => ")
              (disp "\n")
              (write (xhash ,actual))
              (disp " NOT")
              (disp "\n")
              (write (xhash ,expect))
              (disp "\n")
              (quit 1))))))

(mac testx (pattern . tests)
  `(do ,@(map (fn ((x expected))
                `(test (let _ ,x ,pattern) ,expected))
              (pair tests))))
