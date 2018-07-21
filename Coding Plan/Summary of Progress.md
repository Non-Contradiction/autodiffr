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

## May 19

* Adapt more tests in <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/GradientTest.jl>.
* Fix some small bugs and improve the debugging of the package.
* Identify three new issues using the new tests and debugging facility,
    - issue related to `ifelse`
    - issue related to `sapply`, `mapply` and etc.
    - issue related to things like `for (i in x)` when `x` is the input vector.
* Fix the issue found yesterday in `JuliaCall`, add the commented test back.
* Thinking and experimenting about ways to solve the three issues found today. Investigate deeply into the `sapply` and `mapply` issue and have tried many methods to solve it. Since every main function involved in `sapply` and `mapply` is either non-generic or internal-generic, and there seems no way to overload any needed method, the only viable method seems to define our own method, and there are advantages and disadvantages:
    - disadvantage: it is a new method and the users need to use it instead of `sapply` and `mapply` to make automatic differentiation working for their functions;
    - advantage: the new method is more clear, robust and not fragile;
    - advantage: the new method is quite efficient;
    - advantage: the new method is easy to use assume that the user is already familiar with `mapply`, in fact, the usage is the same to `mapply`.
* Use the aforementioned method to deal with the problem caused by `sapply` and `mapply` and add the related tests back.

## May 20

* After investigation, we can get around the issue caused by `for (i in x)` by using `for (i in as.list(x))` instead in the function that we want to apply automatic differentiation. Although there is some performance issue with the approach and is a little inconvenience, it should work.
* Use the aforementioned method to deal with the problem caused by `for (i in x)` and add the related test back.
* `ad_setup()` is not necessary any more, which is more convenient.
* Progress in adapting tests for Hessian for `ForwardDiff.jl` at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/HessianTest.jl>.
* Thinking about wrapping the mutating methods in `ForwardDiff.jl` and `ReverseDiff.jl` and doing some experiments about this.
* Thinking about adding `tag` argument for the Config methods to match the signature in `ForwardDiff.jl` and `ReverseDiff.jl`.
* More tests for the wrapper functions related to `Config` objects.

## May 21

* Yesterday I thought about adding `Tag` to the API. But after more thinking and investigation, it is unnecessary. The `Tag` type in `ForwardDiff.jl` is for checking perturbation confusion. Setting it manually doesn't have any benefit. After all, if users want to disable tag checking, they could use the check argument or let the function in config objects by nothing. Tests of `Tag` are useful in testing of `ForwardDiff.jl` internally, which is not the case for `autodiffr`. More discussions can be seen at github issue: <https://github.com/Non-Contradiction/autodiffr/issues/11>.
* Finish testing for wrapper functions for ForwardDiff Hessian.
* Adjust API of `config` functions, add `chunk_size` argument to replace `chunk` argument, as `chunk_size` is the only purpose for `Chunk` in `ForwardDiff.jl`. More discussions can be seen at <https://github.com/Non-Contradiction/autodiffr/issues/12>.
* Adjust API of `grad`, `jacobian` and `hessian` functions. Use `TRUE` or `FALSE` as `check` instead of `Val{true}()` or `Val{false}()`. The change could make the wrapper functions more idiomatic for R.
* Use wrapper functions wherever is possible, so users don't need to deal with functions from `JuliaCall` directly.
* Some small improvements for the package.
* Some tests fail because of some of internal generics are not implemented for `JuliaObject` in `JuliaCall`. Open the issue on `JuliaCall` at <https://github.com/Non-Contradiction/JuliaCall/issues/53>.
* Implement the `rep.JuliaObject` method in `JuliaCall`.
* Working on wrapper functions for ForwardDiff Jacobian. The hard-coded test pass because of the implementation of `rep.JuliaObject` in `JuliaCall`. The unpassed tests are temporarily commented out.

## May 22

* Refine the implementation of `rep.JuliaObject` in `JuliaCall`.
* Important bug fix for assign of `JuliaObject` in `JuliaCall`.
* New experimental `assign!` to match behavior for assign in R and use it for `JuliaObject` in `JuliaCall`.
* Experimental `JuliaPlain` idea to alleviate the problem that R dispatches only on the first argument, make `ifelse` possible to work for `JuliaObject` in `JuliaCall`.
* Identify some issue in `ForwardDiff.jl`, create an issue and pull request to fix it.
* Temporarily incorporate the above fix in `autodiffr` before the fix merged into `ForwardDiff.jl`.
* Add the test on `ifelse` back which becomes possible due to the changes above.

## May 23

* More thinking on the `ifelse` issue and other related ones. Doing experimentation about this. And thinking about implementation in `JuliaCall`.
* Fix some issues in `JuliaCall`.

## May 24

* Some optimization for `JuliaCall`.
* Thinking and doing experimentations about wrapping mutating related APIs of `ForwardDiff.jl`.
* Migrating more tests from `ForwardDiff.jl`.

## May 25

* Thinking about the `diag` issue with `autodiffr` and `JuliaCall`.
* Have `diag` related methods implemented in `JuliaCall`, i.e., `is.matrix.JuliaObject`, `is.array.JuliaObject`, `dim.JuliaObject`. Have tests for the new functionalities in `JuliaCall`.
* Implement `diagm` to supplement the `diag` methods from `JuliaCall`. It turns out very difficult to implement `diag` for `JuliaObject` vectors. `diagm` is a clear name for this functionality.
* Finish adapting tests for Jacobian for `ForwardDiff.jl` at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/JacobianTest.jl>.
* Have tests to check the implementation of testing functions in `DiffTests.R`.

## May 26

* Thinking about APIs related to `DiffResults` at <https://github.com/JuliaDiff/DiffResults.jl> which can save the differentiation results and can get the differentiation results of multiple orders simultaneously.

## May 27

* Clean up the `ReverseDiff` API to use the wrapper functions.
* Remove the tape arguments in the wrapper functions of Config APIs of `ReverseDiff`. As I understand, it doesn't make a big difference, and it also doesn't appear in documentations, examples and tests.
* After consideration, decide to wrap `AbstractTape` APIs of `ReverseDiff` at <http://www.juliadiff.org/ReverseDiff.jl/api/#the-abstracttape-api>.
* Initial implementation and documentation of `AbstractTape` APIs of `ReverseDiff`.
* Incorporate the `AbstractTape`-related methods into current APIs of `ReverseDiff`.
* Make corresponding adjustments for documentation of APIs.
* Simplify codes related to `ad_setup()` a little bit.

## May 28

* Use `NULL` for `cfg` arguments in the APIs of `reverse.grad`, `reverse.jacobiann` and `reverse.hessian`. This can improve the performance of the functions a little, since the `Config` object is not needed in the `AbstractTape`-related methods.
* APIs of `ReverseDiff` can deal with functions with multiple arguments. Use idea of `positionize` to turn idiomatic R functions with named arguments into functions with positional arguments which `ReverseDiff` is easy to deal with. Related to issue #15.
* Incorporate the idea of `positionize` to deal with functions of multiple arguments into all `ReverseDiff` APIs step by step.
* Correct some bugs in `AbstractTape`-related methods.
* Adapting tests of `ReverseDiff` gradient from <https://github.com/JuliaDiff/ReverseDiff.jl/blob/master/test/api/GradientTests.jl>.
* Identify some issues related to generics on `JuliaObject`, namely, `%*%`, `determinant` and `as.vector`.
* Since `%*%` is only S4 generic but not S3 generic, it is difficult to overload this method for `JuliaObject`. Temporarily define `%x%` method to deal with this problem. And incorporate the method into tests.

## May 29

* Finish implementation of tests for Hessian and Jacobian of `ReverseDiff`.
* Try to make tests pass.
* Identify various issues with `matrix` function.

## May 30

* Trying to make tests pass.
* Thinking about wrapping `DiffResults` related APIs.

## June 2

* Use `%m%` instead of `%x%` as `%x%` already means Kronecker product in R.
* Identify issues of multiplication between matrix and vector.
* Trying to make tests pass.
* Introduce function `zeros` and `ones` to deal with the problem of creating certain type
  of `Julia` matrices.
* Introduce function `Jmatrix` to deal with the reshaping problem of `JuliaObject`.
* Introduce `cSums`, `cMeans`, `rSums`, `rMeans` to deal with the problem of `colSums`,
  `colMeans`, `rowSums` and `rowMeans` for `JuliaObject`.
* Try to support multiple index for `JuliaObject` in `JuliaCall`, which is related to `autodiffr`.

## June 3

* Implementation of `determinant`, `mean` and `solve` generics for `JuliaObject` in `JuliaCall`.
* Implementation of `c.JuliaObject` because of a new problem identified in `det`.
* Trying to make tests pass.
* Because of one issue in implementation of `det` for `JuliaObject`. Omit the tests
  of tape-related `ReverseDiff` methods with `det`.
* Make all the tests in Gradient and Hessian tests of `ReverseDiff` pass.
* Some tests in Jacobian tests of `ReverseDiff` can also pass.
* Implementation of `t.JuliaObject` in `JuliaCall`.
* Implementation of more testing functions in `DiffTests.R`.
* Add more tests back.

## June 4

* Identify problems in the new implemented `c.JuliaObject` and fix it.
* Fix small issues in `autodiffr`.
* Make all tests works, except the `solve` one in `ReverseDiff` Jacobian testing currently.
* Try to reduce testing time.
* Summarize all the new defined functions in `autodiffr` in an `autodiffr` issue:
  <https://github.com/Non-Contradiction/autodiffr/issues/18>.
* Investigate into the issue again and find out that `array` can be used instead of
  `matrix` and is more friendly to generics.
* Implementation of more generics for `JuliaObject` in `JuliaCall`,
  `as.vector`, `dim<-`, and `aperm`.
* Use `array` instead of `Jmatrix`.

## June 5 - June 13

* Initial implementation of interface functions. Currently `grad`, `jacobian` and `hessian` are in place,
  but `deriv` is not.
  and the function signature is `grad(func, x = NULL, mode = c("forward", "reverse"), xsize = x,
  chunk_size = NULL, use_tape = FALSE, compiled = FALSE, ...)`.
  May need to make `grad` also working for the scalar case and alias of `deriv`?
* Basic examples in Rmd document in the example folder.
* Basic shiny apps to compare automatic differentiation methods and numerical methods.
* Fix many small issues in `autodiffr`.

## June 14 - June 22

* Make `autodiffr` interface functions more robust to things like length-1 vectors and 1x1 matrices.
  The interface functions can now treat scalars as length-1 vectors and 1x1 matrices as scalar if necessary.
* Use reverse mode as default since it seems to be more performant and can deal with
  all the things that forward mode can deal with.
* Let `deriv` to be as same as `grad`.
* Implement multi-argument handling in forward mode.
* Refactor tests and various improvements.
* Have more robust way to locate libjulia in `JuliaCall`, which deals with potential setup problem with
  `autodiffr` on linux.
* Have tests for interface functions and fix many small issues.
* Fix issues related to handling of multi-argument functions.
* Fix many small issues in `autodiffr`.

## June 23 - July 1

* Experimentation in `JuliaCall` about using `Rcpp` with `JuliaCall`.
* Experimentation in `autodiffr` about
    - tool to make suggestion for normal R functions to be suitable for AD,
    - automatic adaptation tool,
    - some debugging tools.
* Have a simple interface in `Rcpp` to get access to `JuliaCall`.
* Bug fixes and performance improvements for the `Rcpp` interface of `JuliaCall`.
* Have a simple `Rcpp` example in `autodiffr`.

## July 2

* Bug correction in `JuliaCall` for `as.vector.JuliaObject`.
* Prepare new release for `JuliaCall` on `CRAN`.
* Have the experimented `ad.variant` function exported in `JuliaCall` which is
  an automatic adaptation tool for normal R functions to be more suitable for AD.
* Identify problems of AD caused by `as.numeric` (equivalent to `as.double`).

## July 3

* Fix bugs in `as.double.JuliaObject` in `JuliaCall`.
* Identify an issue in Julia package `ReverseDiff.jl` caused by `Base.float`
  at <https://github.com/JuliaDiff/ReverseDiff.jl/issues/107>.
* Incorporate a temporary incomplete fix into `autodiffr` for problems with `as.double`.

## July 4

* Add helpful error information in `JuliaCall` to help users setup `autodiffr`.
* Prepare new release for `JuliaCall`.

## July 5

* New release of `JuliaCall` on `CRAN`.
* Have `autodiffr` depending on the new release of `JuliaCall`.
* Start working on wrapping APIS related to `DiffResults`.

## July 6

* Thoroughly refactor of wrapper functions of `ReverseDiff` and `ForwardDiff`.
* Incorporate the API of `DiffResults` into wrapper functions of `ReverseDiff` and `ForwardDiff`.

## July 7

* Finish the basic implementation and documentation of wrappers of `DiffResults`-related APIs.
* Update README and Github page.

## July 8

* Finish tests for wrappers of `DiffResults`-related APIs.
* Add `y` argument in `JacobianResult` to deal with the case that output doesn't have same shape with `x`.
* Correct some small bugs in `DiffResults`-related APIs.

## July 9

* Have functions to extract derivative information from `DiffResult`.
* Prepare to separate functions to calculate derivatives and make derivative functions in user interface functions.

## July 10

* Investigate into the performance problem in `autodiffr`.
* Improve performance in wrapper functions of `ReverseDiff`.

## July 11

* Improve the overhead of user interface functions in `JuliaCall`.
* Investigate into overhead problem in `JuliaCall`, have several plans to improve performance further.

## July 12

* Undo the yesterday's performance improvement in `JuliaCall` because it is at the flexibility's expense.
* Refactor the user interface functions in `autodiffr` into two groups, XX and makeXXFunc.
  The intention of using functions will be more clear.
  The documentation of the functions and arguments is also more clear.
* Incorporate some ideas of improving performance in `JuliaCall` into `autodiffr` first.
  Have a `debug` argument which can be turned off to allow computations to be more performant.
* Some small performance optimizations in `autodiffr`.

## July 13

* Experiment ways to reduce overhead in `JuliaCall` interface.

## July 14

* Experiment ways to reduce overhead in `JuliaCall` interface.
* Reduce some overhead in `DiffResults`-related wrapper functions.

## July 15

* Reduce overhead in `JuliaCall` interface.

## July 16

* Reduce overhead further in `JuliaCall` interface.
* Adjust `autodiffr` to be compatible with `JuliaCall` in development.
* Use the optimized version of `JuliaCall` in `autodiffr` to see the performance improvement.
  The improvement is obvious when the dominant part is overhead,
  as in the case of unoptimized gradient functions (where the overhead may occur multiple times),
  or in the case of very fast calculations.
  But in some other cases it is not that obvious.

## July 17

* Reduce overhead in `JuliaCall` interface.
* Reduce overhead in `JuliaCall` for `rcopy` and `sexp` of `JuliaObject`,
  which is another important source of overhead in `autodiffr`.
* Use the optimized version of `JuliaCall` in `autodiffr` to see the performance improvement.

## July 18

* Some small performance improvements in `JuliaCall`.

## July 19

* Experiments on further performance improvement in `JuliaCall`.
* Identify problem in `a[i,]` style index for `JuliaObject` in `JuliaCall`.
* Identify problem in `max` and similar generics for `JuliaObject` in `JuliaCall`.
* Identify some issues in `ad.variant` in `autodiffr`.
* Try to fix the problems identified in `JuliaCall` and `autodiffr`.

## July 20

* Experiments on further performance improvement in `JuliaCall`.
* Some small bug fixes in `JuliaCall`.

## July 21

* Another relatively big performance improvement in `JuliaCall`.
* Now there is still room for performance optimization in `JuliaCall`, but it would be quite limited.
  So the performance improvement work in `JuliaCall` in this phase is finished quite satisfactorily.
  After more bug fixing, `JuliaCall` should have another release
  and `autodiffr` needs to depend on the new version of `JuliaCall`.
