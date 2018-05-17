## Community Bonding

* Setting up the repo.
* Build the skeleton of the package.
* Basic functions, documentations and tests.
* Setting up Travis and Appveyor.
* Write README and build github pages.

## May 14

* Begin working on the implementations for some of the wrapper functions of `ForwardDiff.jl` and `ReverseDiff.jl`.
* Due to the fact that `Julia` function can mutate the  content of its arguments which is typically not true for `R` functions, the mutating functions in `ForwardDiff.jl` and `ReverseDiff.jl` are temporarily not wrapped.
* Some thinking on the interface design.

## May 15

* Exportations and documentations for the wrapper functions of `ForwardDiff.jl` and `ReverseDiff.jl`.
* Correct bugs in the implementation of the wrapper functions. Now all the functions should work as expected.

## May 16

* Create some utility functions to create tests.
* Add tests of rosenbrock function and lambertW function.

## May 17

* Study about the tests of `ForwardDiff.jl` and `ReverseDiff.jl`, prepare to adopt some of the tests for `autodiffr`. Related resources are
  * <https://github.com/JuliaDiff/DiffTests.jl/blob/master/src/DiffTests.jl>
  * <https://github.com/JuliaDiff/ForwardDiff.jl/tree/master/test>
  * <https://github.com/JuliaDiff/ReverseDiff.jl/tree/master/test>
