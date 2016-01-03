(def uniq ((o name))
  (if name
       (coerce (+ (coerce name 'string) "--" (rand-string 12)) 'sym)
       (coerce (rand-string 12) 'sym)))

(def bogus-has (g k)
  (isnt (g k) nil))

(def assert (x)
  (if x
       (prn "assertion ok")
       (do (prn "assertion fail")
           (quit 1))))

(wipe xhash-globals)

(= print-mapping
  (obj $assign--xVrP8JItk2Ot '$assign
       $begin--xVrP8JItk2Ot  '$begin
       $dyn--xVrP8JItk2Ot    '$dyn
       $fn--xVrP8JItk2Ot     '$fn
       $if--xVrP8JItk2Ot     '$if
       $quote--xVrP8JItk2Ot  '$quote))

(def xhash (x)
  (aif (and xhash-globals (is x xhash-globals))
        '$globals
       (isa x 'table)
        '<<table>>
       (print-mapping x)
        it
       (acons x)
        (cons (xhash (car x))
              (xhash (cdr x)))
        x))

(= source-dirs '("arc" "runtime-tests" "common-tests"))

(def default-arc-extension (file)
  (let file (coerce file 'string)
    (if (find #\. file)
         file
         (+ file ".arc"))))

(def sourcepath (name)
  (let name (string name)
    (aif (dir-exists name)
          (map [+ name "/" _] (dir name))
         (file-exists (default-arc-extension name))
          (list it)
         (some [file-exists (+ _ "/" (default-arc-extension name))]
               source-dirs)
          (list it)
          (err "source file not found:" name))))

(def loadf0 (f filename)
  (w/infile in filename
    (w/uniq eof
      (whiler x (read in eof) eof
        (f x)))))

(def loadf (f . files)
  (each file (flat (map sourcepath (flat files)))
    (prn file)
    (loadf0 f file)))

(def xload files
  (apply loadf eval files))

(xload '(p2
         extend-def
         iso-table
         iso-tagged
         test2
         parameterize0
         common-tests

         namespace
         prim-namespace
         ssyntax.arc
         ssyntax.t
         macro.arc
         macro.t
         implicit

         implicit-runtime))

(= xhash-globals ir)

(= starting-dyn
  `((,(rep ir!stdout) ,(stdout))
    (,(rep ir!stderr) ,(stderr))))

(def i-eval (x (o dyn starting-dyn))
  (let m
       (w/compile-options (obj globals           ir
                               xcompile-implicit t
                               xcompile-dyn      dyn)
         (macro-expand0 x nil))
    (let i (expand-implicit m)
      (let e `(let $dyn--xVrP8JItk2Ot ',dyn ,(unprimitive i))
        (eval e)))))

(test (i-eval `(,ir!+ 1 2)) 3)

(mac i-load files
  `(apply loadf [i-eval _] ',files))

(i-load
  global
  global.a
  set-global
  set-global.a
  quote
  quote.a
  assign
  assign.a
  fn
  fn.a
  if-3-clause
  if-3-clause.a

  ; Now we're more or less at the point where Arc 3.1's arc.arc starts
  ; off (aside from not having quasiquotation, complex function
  ; arguments, multi-clause if, ssyntax, the square bracket notation...)

  do
  do.a
  def
  cxr
  cxr.a
  predicates
  acons.a
  list
  list.a
  if-multi-clause
  if-multi-clause.a
  map1
  pair
  pair.a
  mac
  assert1
  with
  let

  ; Now let's implement enough of Arc so that we can get quasiquotation.
  ; (Some definitions such as rreduce got moved earlier since they were
  ; used by the quasiquotation code).

  ; This is the extended join that can produce dotted lists.

  join
  and
  and.a
  or
  or.a
  iso
  iso.a

  ; Now that we have iso, a simple test macro.

  test1

  ; Some tests that are easier to write with iso.

  ccc.t
  fn-dotted.t
  join.t
  join-dotted.t

  caris
  caris.t
  alist
  alist.t
  single
  single.t
  dotted
  dotted.t
  rreduce
  rreduce.t
  isa
  literal1
  literal.t
  literal-value
  literal-value.t

  ; Ah, quasiquotation

  qq/qq

  ; Now let's get enough of Arc loaded so that we can run the macro
  ; expander and the compiler.

  ; An implementation of bound that checks whether the named var is in
  ; globals.

  bound-global
  bound.t

  ; Extend referencing a global var to give an error if it isn't
  ; defined.

  global-check

  parameterize1
  parameter.t
  ccc-dyn.t

  w-uniq
  withs
  withs.t

  ; Function argument destructuring and optional arguments.

  complex-fn
  fn-complex.t
  fn-empty-body.t

  string-ref.t
  apply-string-ref.t

  ; More Arc functions used by the macro expander and compiler.

  writec
  p1
  arc2

  after.t

  compose-string-ref.t

  ; Full implementation of test which displays the source expression and
  ; resulting value.

  test2
  common-tests/compose.t
  common-tests/ssyntax-compose.t

  on-err.t
  p2

  ; Macro expander

  ssyntax
  ssyntax.t
  namespace
  prim-namespace
  macro
  macro.t

  ; Implicit level language
  implicit
  eval-i
  load)

(i-eval '(load 'arc/arc3
               'arc/iso-table
               'arc/iso-tagged
               'common-tests
               'runtime-tests
               'more-tests))
