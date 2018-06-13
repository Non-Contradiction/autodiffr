Forward and Reverse Mode AD in autodiffr
================
Changcheng Li
2018/6/4

## Introduction

`autodiffr` is now a work-in-progress. You can install it by:

``` r
devtools::install_github("Non-Contradiction/autodiffr")
```

It’s also recommended to install the latest version of `JuliaCall` by:

``` r
devtools::install_github("Non-Contradiction/JuliaCall")
```

And after the installation is finished, just do the following steps,
note that the first time it will take some time, but the next time it
should be better.

``` r
library(autodiffr)
ad_setup()
```

    ## Julia version 0.6.3 at location /Applications/Julia-0.6.app/Contents/Resources/julia/bin will be used.

    ## Loading setup script for JuliaCall...

    ## Finish loading setup script for JuliaCall.

And we can use package `numDeriv` to compare with `autodiffr`.

``` r
require(numDeriv)
```

    ## Loading required package: numDeriv

    ## 
    ## Attaching package: 'numDeriv'

    ## The following objects are masked from 'package:autodiffr':
    ## 
    ##     grad, hessian, jacobian

## Direct wrapper functions of `ForwardDiff` and `ReverseDiff`

### Basic usage

In this section, we are using a function similar to Rosenbrock function
as an initial
example:

``` r
## Later on, I may export these functions maybe in an R environment including all testing functions.
## So users can get easy access to these functions for examples, testing and benchmarking purposes.
## But currently these functions are unexported in autodiffr
rosen1 <- autodiffr:::rosenbrock_1
# And there are other functions, which can be used to replace the rosen1 function in the following examples like
# rosen2 <- autodiffr:::rosenbrock_2
# rosen4 <- autodiffr:::rosenbrock_4
# ackley <- autodiffr:::ackley

rosen1
```

    ## function(x){
    ##     a <- 1
    ##     b <- 100 * a
    ##     result <- 0
    ##     for (i in 1:(length(x) - 1)) {
    ##         result <- result + (a - x[i])^2 + b*(x[i + 1] - x[i]^2)^2
    ##     }
    ##     result
    ## }
    ## <bytecode: 0x7f8d32545638>
    ## <environment: namespace:autodiffr>

``` r
# rosen2
# rosen4
# ackley

target <- rosen1
```

These functions receive a vector input and generates scalar output. So
`forward.grad` and `reverse.grad` can be used to calculate their
gradients and `forward.hessian` and `reverse.hessian` can be used to
calculate their hessians. Besides, it should be possible to calculate
the jacobian of the gradient function, which should be the same with the
hessian.

The basic usage is as follows:

``` r
X <- runif(5)
X
```

    ## [1] 0.12230726 0.81369512 0.45361742 0.26980547 0.04553986

``` r
forward.grad(target, X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
reverse.grad(target, X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
forward.jacobian(function(x) forward.grad(target, x), X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
reverse.jacobian(function(x) reverse.grad(target, x), X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
forward.hessian(target, X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
reverse.hessian(target, X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

And we can compare the results with `numDeriv`:

``` r
numDeriv::grad(target, X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
numDeriv::jacobian(function(x) numDeriv::grad(target, x), X)
```

    ##               [,1]       [,2]          [,3]      [,4]      [,5]
    ## [1,] -3.055206e+02  -48.92286  7.377095e-06    0.0000    0.0000
    ## [2,] -4.892286e+01  815.07288 -3.254779e+02    0.0000    0.0000
    ## [3,]  7.376238e-06 -325.47792  3.410001e+02 -181.4465    0.0000
    ## [4,]  0.000000e+00    0.00000 -1.814465e+02  271.1371 -107.9249
    ## [5,]  0.000000e+00    0.00000  0.000000e+00 -107.9249  199.9899

``` r
numDeriv::hessian(target, X)
```

    ##               [,1]          [,2]          [,3]          [,4]          [,5]
    ## [1,] -3.055272e+02 -4.892290e+01  2.368475e-09 -1.773064e-14 -1.219648e-13
    ## [2,] -4.892290e+01  8.150727e+02 -3.254780e+02  3.003082e-10  3.239381e-12
    ## [3,]  2.368475e-09 -3.254780e+02  3.410003e+02 -1.814470e+02  4.398050e-14
    ## [4,] -1.773064e-14  3.003082e-10 -1.814470e+02  2.711380e+02 -1.079222e+02
    ## [5,] -1.219648e-13  3.239381e-12  4.398050e-14 -1.079222e+02  2.000000e+02

We can see the result is similar, and results from `autodiffr` should be
more accurate.

### Advance usage

#### Use of config object

If gradient or hessian of the same target function need to be caculated
repeatedly on inputs of the same shape, like input vectors of same
length or input matrices with the same number of rows and columns, then
users can caculate config objects before to improve the performance:

``` r
cfg <- forward.grad.config(target, X)
forward.grad(target, X, cfg = cfg)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
cfg <- reverse.grad.config(X)
reverse.grad(target, X, cfg = cfg)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
cfg <- forward.hessian.config(target, X)
forward.hessian(target, X, cfg = cfg)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
cfg <- reverse.hessian.config(X)
reverse.hessian(target, X, cfg = cfg)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

And users can also choose a chunk size when using config objects for
forward mode automatic differentiation, choosing appropriate sample size
can improve performance further.

``` r
cfg1 <- forward.grad.config(target, X, chunk_size = 1)
forward.grad(target, X, cfg = cfg1)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
cfg1 <- forward.hessian.config(target, X, chunk_size = 1)
forward.hessian(target, X, cfg = cfg1)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

#### Use of tape object in reverse mode automatic differentiation

In reverse mode automatic differentiation, if the target function are
defined without any branching, like `if`, `ifelse`, `while` and etc,
then it is possible to use `tape` to further improve performance:

``` r
tp <- reverse.grad.tape(target, X)
reverse.grad(tp, X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
tp <- reverse.hessian.tape(target, X)
reverse.hessian(tp, X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

## User interface functions provided by `autodiffr`

`autodiffr` provides a set of user interface functions to deal with the
usage of forward and reverse mode automatic differentiation.

### Basic usage

If users want to caculate the gradient, hessian or jacobian directly:

``` r
autodiffr::grad(target, X, mode = "forward")
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
autodiffr::grad(target, X, mode = "reverse")
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
autodiffr::hessian(target, X, mode = "forward")
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
autodiffr::hessian(target, X, mode = "reverse")
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

It’s easy to have a gradient, hessian, or jacobian function just by
ommiting the `x` argument:

``` r
autodiffr::grad(target, mode = "forward")(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
autodiffr::grad(target, mode = "reverse")(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
autodiffr::hessian(target, mode = "forward")(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
autodiffr::hessian(target, mode = "reverse")(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

### Advanced usage

If users want to have a gradient, hessian, or jacobian function
specalised for inputs of the fixed shape (like length of the input
vector or numbers of rows and columns of the input matrix), then it is
possible to have an optimized function by providing `xsize`
argument:

``` r
g1 <- autodiffr::grad(target, mode = "forward", xsize = runif(length(X)))
g1(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
g2 <- autodiffr::grad(target, mode = "reverse", xsize = runif(length(X)))
g2(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
h1 <- autodiffr::hessian(target, mode = "forward", xsize = runif(length(X)))
h1(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
h2 <- autodiffr::hessian(target, mode = "reverse", xsize = runif(length(X)))
h2(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

Beyond the `xsize` argument, users can also provide `chunk_size` for
forward mode automatic differentiation. From `?ForwardDiff` users can
see instrustions on how to choose chunk size. And users can use
`use_tape` for reverse mode automatic differentiation, which may
increase the performance of gradient, hessian or jacobian functions a
lot.

``` r
g1 <- autodiffr::grad(target, mode = "forward", xsize = runif(length(X)), chunk_size = 1)
g1(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
g2 <- autodiffr::grad(target, mode = "reverse", xsize = runif(length(X)), use_tape = TRUE)
g2(X)
```

    ## [1] -40.831873 227.231018 -54.408495  14.288386  -5.451027

``` r
h1 <- autodiffr::hessian(target, mode = "forward", xsize = runif(length(X)), chunk_size = 1)
h1(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

``` r
h2 <- autodiffr::hessian(target, mode = "reverse", xsize = runif(length(X)), use_tape = TRUE)
h2(X)
```

    ##           [,1]      [,2]      [,3]      [,4]      [,5]
    ## [1,] -305.5272  -48.9229    0.0000    0.0000    0.0000
    ## [2,]  -48.9229  815.0727 -325.4780    0.0000    0.0000
    ## [3,]    0.0000 -325.4780  341.0003 -181.4470    0.0000
    ## [4,]    0.0000    0.0000 -181.4470  271.1380 -107.9222
    ## [5,]    0.0000    0.0000    0.0000 -107.9222  200.0000

But please note that if the target function are defined with branching,
like `if`, `ifelse`, `while` and etc, then `use_tape` may give incorrect
results, like the following example.

``` r
f <- function(x){
    if (x[1] > 1.5) {
        sum(x^2)
    }
    else {
        sum(x^3)
    }
}

gF <- autodiffr::grad(f, mode = "forward", xsize = rep(2,3), chunk_size = 1)

gR <- autodiffr::grad(f, mode = "reverse", xsize = rep(2,3), use_tape = TRUE)

gF(rep(1,3)) ## correct result
```

    ## [1] 3 3 3

``` r
gR(rep(1,3)) ## wrong result
```

    ## [1] 2 2 2
