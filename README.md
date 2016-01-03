# Arc Implicit

Demo of implementing dynamically scoped variables using a hidden
<code>dyn</code> parameter passed to every function.

Quite slow as it runs on top of a compatibility layer on top of
Arc<sub>3.1</sub> with no attempt at optimization, but sufficient to
run tests.

    racket -f run.scm
