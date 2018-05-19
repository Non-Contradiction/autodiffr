## Community Bonding

* Setting up the repo.
* Build the skeleton of the package.
* Basic functions, documentations and tests.
* Setting up Travis and Appveyor.
* Write README and build github pages.
* Fix an important bug in `JuliaCall` which breaks `autodiffr` and is caused by changes in `Julia` upstream.

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

* Start to adapting functions in `DiffTests.jl`.

## May 18

* Finish adapting functions in `DiffTests.jl` currently. Note that the mutating related functions in `DiffTests.jl` are not adapted.
* Add test utility functions to check the results from R wrappers with the results from `Julia`. Apply the change in testing of automatic differentiation of rosenbrock function.
* Considering adapting tests from `ForwardDiff.jl` and `ReverseDiff.jl`.
* Make changes in `JuliaCall` to facilitate the development of `autodiffr`.
* Tests for `forward.deriv` based on <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/DerivativeTest.jl>. Found an issue caused by `JuliaCall`. The problematic test will be commented out until the issue is fixed in `JuliaCall`.
* Some tests for `forward.grad` based on <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/GradientTest.jl>. 
