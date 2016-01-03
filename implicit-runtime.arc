(def implicit-apply (f args)
  (if (isa f 'fn)
       (apply f args)
      (isa f 'param)
       (alref (car args) (rep f))
       (apply f (cdr args))))

(def implicit-call (f . args)
  (implicit-apply f args))

(= ir (table))

(def drop-dyn (f)
  (fn (dyn . args)
    (apply f args)))

(= ir!t 't)

(def list* args
  (if (no args)
       nil
      (no (cdr args))
       (car args)
       (cons (car args) (apply list* (cdr args)))))

(test (list*)            nil)
(test (list* 1 2)        '(1 . 2))
(test (list* 1 2 '(3 4)) '(1 2 3 4))

(mac named-fn (name parms . body)
  `(,namefn ',name (fn ,parms ,@body)))

(= ir!apply
  (named-fn dyn-apply (dyn f . args)
    (implicit-apply f (cons dyn (apply list* args)))))

(= ir!get-dyn
  (named-fn get-dyn (dyn) dyn))

(test (ir!apply 'foobar ir!get-dyn) 'foobar)

(= ir!parameter
  (named-fn dyn-parameter (dyn (o name))
    (annotate 'param (uniq name))))

(= ir!ar-parameterize
  (named-fn dyn-ar-parameterize (dyn param val thunk)
    (unless (isa param 'param)
      (err "not a parameter:" param))
    (thunk (cons (list (rep param) val) dyn))))

(= ir!ccc
  (named-fn dyn-ccc (dyn dyn-f)
    (ccc (fn (c)
           (dyn-f dyn (fn (dyn2 v)
                        (c v)))))))

(= ir!protect
  (named-fn dyn-protect (dyn during after)
    (protect
      (fn ()
        (during dyn))
      (fn ()
        (after dyn)))))

(= ir!ar-eval
  (fn (dyn expr)
    (eval `((fn ($dyn--xVrP8JItk2Ot) ,expr) ',dyn))))

(= ir!stdout (ir!parameter nil 'stdout))
(= ir!stderr (ir!parameter nil 'stderr))

(= ir!call-w/stdout
  (named-fn dyn-call-w/stdout (dyn port thunk)
    (ir!ar-parameterize dyn ir!stdout port thunk)))

(= ir!call-w/stderr
  (named-fn dyn-call-w/stderr (dyn port thunk)
    (ir!ar-parameterize dyn ir!stderr port thunk)))

(let port (outstring)
  (ir!call-w/stdout nil port
    (fn (dyn)
      (disp "xyzzy" (implicit-call ir!stdout dyn))))
  (test (inside port) "xyzzy"))

(= ir!atomic-invoke
  (named-fn dyn-atomic-invoke (dyn thunk)
    (atomic-invoke (fn () (thunk dyn)))))

(= ir!on-err
  (named-fn dyn-on-err (dyn errfn f)
    (on-err (fn (c) (errfn dyn c))
            (fn () (f dyn)))))

(= ir!implicit-call implicit-call)

(= ir!maptable
  (named-fn dyn-maptable (dyn f table)
    (maptable (fn (key val)
                (f dyn key val))
              table)))

(each (name f)
      `((ar-disp          ,disp)
        (ar-readb         ,readb)
        (ar-string-append ,+)
        (ar-write         ,write)
        (ar-writec        ,writec)
        (ar-<2            ,<)
        (ar->2            ,>)
        (annotate         ,annotate)
        (assert           ,assert)
        (car              ,car)
        (cdr              ,cdr)
        (close            ,close)
        (coerce           ,coerce)
        (cons             ,cons)
        (details          ,details)
        (dir              ,dir)
        (dir-exists       ,dir-exists)
        (err              ,err)
        (has              ,bogus-has)
        (infile           ,infile)
        (is               ,is)
        (len              ,len)
        (mod              ,mod)
        (namefn           ,namefn)
        (newstring        ,newstring)
        (outfile          ,outfile)
        (quit             ,quit)
        (rep              ,rep)
        (scar             ,scar)
        (sread            ,sread)
        (sref             ,(fn (x k v) (sref x v k)))
        (ssexpand         ,ssexpand)
        (is-ssyntax       ,is-ssyntax)
        (table            ,table)
        (tagged           ,tagged)
        (type             ,type)
        (uniq             ,uniq)
        (xhash            ,xhash)
        (+                ,+)
        (-                ,-)
        (*                ,*)
        (/                ,/))
  (= ir.name
     (namefn
       (coerce (+ "dyn-" (coerce name 'string)) 'sym)
       (drop-dyn f))))

(test (ir!+ nil 1 2 3) 6)

(test (ir!apply nil ir!+ 1 2 '(3)) 6)
