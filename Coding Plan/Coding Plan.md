# Coding Plan and Methods

The goal of this project is to make an `R` wrapper package `autodiffr` for `Julia` packages `ForwardDiff.jl` and `ReverseDiff.jl` to do automatic differentiation for native `R` functions
and some `Rcpp` functions.
The project will wrap the api for `ForwardDiff.jl` at <http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html>
and the api of `ReverseDiff.jl` at <http://www.juliadiff.org/ReverseDiff.jl/api/>.

The package `autodiffr` should provide an easy-to-use and well-documented user interface.
A good example is the package `numDeriv`, which is already widely used in optimization to provide derivative information like gradient by `numDeriv::grad`, hessian by `numDeriv::hessian` and jacobian by `numDeriv::jacobian`.
The usage of these three functions in `numDeriv` are consistent with each other,
so users can use the functions easily.
Another good example is the package [`optextras`]( https://CRAN.R-project.org/package=optextras), which provides a consistent and easy-to-use interface to apply and check derivatives for optimization.
The package `autodiffr` should provide an interface similar to other well-established packages to allow for easier usage, comparison and improvement of the tools.

The package `autodiffr` needs to use a `Julia` interface to wrap `ForwardDiff.jl` and `ReverseDiff.jl`.
There are two packages for calling `Julia` from `R` currently on `CRAN`: `XRJulia` and `JuliaCall`.
I'm the maintainer of `JuliaCall` and have also used `XRJulia` and developed a package `convexjlr` which could use either `XRJulia` and `JuliaCall` as an backend to communicate with `Julia`.
`JuliaCall` is an ideal choice for this project, because of the following reasons:
* `JuliaCall` embeds `Julia` in `R` and it has good performance to transfer data between `R` and `Julia`, which is inevitable in native `R` numerical applications like optimization.
* `JuliaCall` converts `R` and `Julia` objects of basic types like integers, float numbers, vectors, matrices and  dataframes automatically when needed, which is a very convenient feature.
* `JulliaCall` also handles other `Julia` types besides the basic type and converts them to `R6` wrapper objects `JuliaObject`.

One possible way to get automatic differentiation for the `R` functions through `Julia` packages is to overload  primitive functions for `JuliaObject` in `R` by corresponding `Julia` functions.
And the package `JuliaCall` already
overloads many `R` generic functions like math functions (like `sin`, `sqrt`, `log`, `exp`), operators (like `+`, `*`, `==`, `!`) and summary functions (like `max`, `min`, `sum`, `prod`).
As we can see from the test results in the last section,
automatic differentiation already works for some `R` functions.
But the current overloading scheme needs to be improved,
there are some generics not implemented like `rep`,
and some implementations of methods are not perfect, like the implementation of `max` and `min`.
So following the overloading method,
it is important to improve the overloading scheme in `JuliaCall`.
In the last section of the test results, it can also be seen the overloading approach work for `Rcpp` functions.
More results and discussions can be seen in the last section.

Since one of the most important goal of this project is to ensure the correctness of
automatic differentiation, so an extensive test set covering lots of possible usage
will be built during the project, including native `R` functions, `Julia` functions
through `JuliaCall`, `Rcpp` functions and the mix of these three kinds of functions.
Some original tests in `ForwardDiff.jl`
and `ReverseDiff.jl` need to be adopted to ensure the correctness of the wrapper.
And in the tests, the automatic differentiation results for a (mostly) same function
in `Julia`, `R`, and `Rcpp`
will be checked against each other,
and the automatic differential results will also be checked against the numerical
and symbolic differentiation results by packages like `numDeriv` and `Deriv` for correctness.
There should also be some benchmark tests, which checks the performance of the code
before/after a certain commit or pull request,
and compares the performance and accuracy with the numerical
and symbolic differentiation results by packages like `numDeriv` and `Deriv`.

## Timeline

* 1st phase (May 14 - June 10, 2018):
The result of the 1st phase should include a useable package which can do automatic differentiation of forward mode and reverse mode for some of the native `R` functions and `Rcpp` functions.
The CI test systems like travis CI and appveyor CI should be in place.
And the basic structure of the package need to be established, and in the package, there should be:
    * all of the wrapper functions needed for the api of `ForwardDiff.jl` and `ReverseDiff.jl` in the package although some functions may not work in this phase,
    * a basic user interface similar to other well-established packages like `numDeriv`,
    * documentation of user functions (even the not working ones) with explanation of the usage and examples,
    * an extensive test set as described before, and tests that don't pass at the moment can be temporarily commented out.

* 2nd phase (June 11 - July 8, 2018):
    * Implementation of wrappers in the api of `ForwardDiff.jl` and `ReverseDiff.jl` need to be finished.
    * User interface should be fixed (mostly) during this phase.
    * All user functions need to be well documented.
    * The issues in the test set from 1st phase should be fixed one by one.
    And new tests can be added to cover more functionalities of the package.
    It is also possible to add some complex integration test like applying AD on some functions resulted from AD.
    * There should be some benchmark tests as mentioned before, and some optimizations on performance can be carried out if possible.

* Final phase (July 9 - August 6, 2018):
    * All the basic objectives of the projects should be achieved at this phase.
    * If AD provided by the package is still not working for some corner cases,
    the cases that don't work should be documented and work-around methods need to be provided.
    * Performance improvements should be carried out if possible.
    * Prepare to submit the package to `CRAN`.
    * Create articles and blogs about the use of automatic differentiation in `R`, which demonstrates results of this project. We could also make comparison with packages using other methods to calculate derivative like `numDeriv` and `Deriv` on the accuracy and performance.

## Management of Coding Project

The project will be developed on Github.
It will have CI systems configured, both on travis CI for macos and linux, and appveyor CI
for windows.
The project will be test both  on the devel release and current release of `R` and the current release of `Julia`.

In the first phase, there will be lots of commits
which establish the basics of the project.
And the commit should be made quite frequently.
And an extensive test set will also be established in this phase as mentioned before.
Issues will be open for functions that don't work and tests that don't pass and they will be labeled according to seriousness and priority,
so it will be easy to tell the progress of the project.
In the second and third phases, basic functionalities of the project need to be able to work,
and issues with high-priority should be fixed.
Commit frequency will not be as high as in the first phase, but there should be still some comments on the Github issues which reflects the efforts to solve issues that are working on.
