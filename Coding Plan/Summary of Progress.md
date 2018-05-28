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

# May 27

* Clean up the `ReverseDiff` API to use the wrapper functions.
* Remove the tape arguments in the wrapper functions of Config APIs of `ReverseDiff`. As I understand, it doesn't make a big difference, and it also doesn't appear in documentations, examples and tests.
* After consideration, decide to wrap `AbstractTape` APIs of `ReverseDiff` at <http://www.juliadiff.org/ReverseDiff.jl/api/#the-abstracttape-api>.
* Initial implementation and documentation of `AbstractTape` APIs of `ReverseDiff`.
* Incorporate the `AbstractTape`-related methods into current APIs of `ReverseDiff`.
* Make corresponding adjustments for documentation of APIs.
* Simplify codes related to `ad_setup()` a little bit.
