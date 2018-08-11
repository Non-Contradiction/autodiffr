Automatic Differentiation in R by autodiffr
================
Changcheng Li, John Nash, Hans Werner Borchers
2018/8/10

Package `autodiffr` provides an R wrapper for Julia packages
[`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl) and
[`ReverseDiff.jl`](https://github.com/JuliaDiff/ReverseDiff.jl) through
R package [`JuliaCall`](https://github.com/Non-Contradiction/JuliaCall)
to do **automatic differentiation** for native R functions. This
vignette will walk you through several examples in using `autodiffr`.

## Basic usage

When loading the library `autodiffr` it is still necessary to create a
process running Julia, to connect to it, to check whether all needed
Julia packages are installed resp. to install them in case they are
missing. All this is done by the `ad_setup` function. If everything is
in place, it will finish in short time, otherwise it may take several
minutes (the first time it is called).

    library(autodiffr)
    
    ad_setup()
    ## Julia version 0.6.4 at location [...]/julia/bin will be used.
    ## Loading setup script for JuliaCall...
    Finish loading setup script for JuliaCall.
    INFO: Precompiling module DiffResults.
    INFO: Precompiling module ForwardDiff.
    INFO: Precompiling module ReverseDiff.

The first time `ad_setup()` is called on your system, these three Julia
modules / packages are being precompiled, later on this will not happen
again, except when the julia packages get installed anew (e.g., a new
version has appeared). Please note that `ad_setup` is required whenever
you load the `autodiffr` package into R. And if Julia is not in the
path, then `autodiffr` may fail to locate Julia. In this case, use
`ad_setup(JULIA_HOME = "the file folder contains the julia binary")`.

Now automatic differentiation is ready to get applied. `autodiffr` has
`ad_grad`, `ad_jacobian` and `ad_hessian` to calculate gradient,
jacobian and hessian, and has `makeGradFunc`, `makeJacobianFunc` and
`makeHessianFunc` to create gradient, jacobian and hessian functions
respectively. We can see the basic usage below:

``` r
## Define a target function with vector input and scalar output
f <- function(x) sum(x^2L)

## Calculate gradient of f at [2,3] by
ad_grad(f, c(2, 3)) ## deriv(f, c(2, 3))
#> [1] 4 6

## Get a gradient function g
g <- makeGradFunc(f)

## Evaluate the gradient function g at [2,3]
g(c(2, 3))
#> [1] 4 6

## Calculate hessian of f at [2,3] by
ad_hessian(f, c(2, 3))
#>      [,1] [,2]
#> [1,]    2    0
#> [2,]    0    2

## Get a hessian function h
h <- makeHessianFunc(f)

## Evaluate the hessian function h at [2,3]
h(c(2, 3))
#>      [,1] [,2]
#> [1,]    2    0
#> [2,]    0    2

## Define a target function with vector input and vector output
f <- function(x) x^2

## Calculate jacobian of f at [2,3] by
ad_jacobian(f, c(2, 3))
#>      [,1] [,2]
#> [1,]    4    0
#> [2,]    0    6

## Get a jacobian function j
j <- makeJacobianFunc(f)

## Evaluate the gradient function j at [2,3]
j(c(2, 3))
#>      [,1] [,2]
#> [1,]    4    0
#> [2,]    0    6
```

## What to do if autodiffr cannot handle your function?

`autodiffr` works by ultilizing R’s S3 object system: most of R
functions are just compositions of many small operations like `+` and
`-`, and these small operations can be dispatched by the S3 object
system to Julia, which finishes the real work of automatic
differentiation behind the scence. This mechanism can work for many R
functions, but it also means that `autodiffr` has same limitations just
as R’s S3 object system. For example, `autodiffr` can’t handle R’s
internal C code or some external C and Fortran code. In this section, we
will talk about how to detect to deal with such problems. We will first
talk about the common issues in the next subsection, and then we will
see a little example, finally we will show how to use a helper function
`ad_variant` provided by `autodiffr` to deal with these common problems
at the same time.

### Basic R functions that have problems with autodiffr

This is a list of the most common basic R functions that have problems
with `autodiffr`:

  - `colSums`, `colMeans`, `rowSums`, `rowMeans`: These common functions
    are all implemented in R’s internal C code. And `autodiffr` provides
    helper functions `cSums`, `cMeans`, `rSums` and `rMeans` to
    substitute them. Example error message is like “Error in colSums(…)
    : ‘x’ must be numeric”.
  - `%*%`: this function can’t be handled with R’s S3 system, so
    `autodiffr` provides `%m%` to use instead. Example error message is
    like “Error in x %\*% y : requires numeric/complex matrix/vector
    arguments“.
  - `crossprod`, `tcrossprod`: these functions are also implemented in
    R’s internal C code, users may use `t(x) %m% y` or `x %m% t(y)`
    instead, or find some other more effective alternatives. Example
    error message is like “Error in crossprod(x, y) : requires
    numeric/complex matrix/vector arguments”.
  - `diag`: it will also invoke R’s internal C code when using `diag` on
    a vector to create a diagonal matrix and `autodiffr` provides helper
    functions `diagm` for the same purpose. Example error message is
    like “Error in diag(x) : long vectors not supported yet:
    ../../../../R-3.5.1/src/main/array.c:2178”.
  - `mapply`, `sapply`, `apply`: `autodiffr` provides a helpful function
    *map*, which can be used similarly to *mapply*.
  - `matrix`: it’s problematic to use `matrix` to reshape vectors into
    matrices with `autodiffr`, use R’s `array` instead or use the helper
    function `julia_array` from `autodiffr`. Example error message is
    like “Error in matrix(x, : ‘data’ must be of a vector type, was
    ‘environment’”. \*`[<-`: if you ever want to do something like
    `x[i] <- a` or `x[i, j] <- a`, when `x` is a vector or matrix
    involved in the differentiation process, then it’s likely that you
    hit this problem: “Error in x\[i\] \<- y : incompatible types (from
    environment to double) in subassignment type fix”. To deal with this
    problem, maybe you need to do `x <- julia_array(x)` first.

### A little example to demonstrate issues

Let us first define a makeup function to show some of the aforementioned
issues:

``` r
fun <- function(x) {
    if (length(x) != 4L) stop("'x' must be a vector of 4 elements.")
    y <- rep(0, 4)
    y[1] <- x[1]; y[2] <- x[2]^2
    y[3] <- x[3]; y[4] <- x[4]^3
    y <- matrix(y, 2, 2)
    det(y)
}
```

If we directly use `autodiffr` to deal with `fun`, we will have:

``` r
x0 <- c(1.2, 1.4, 1.6, 1.8)

try(ad_grad(fun, x0))

## from the error message
## Error in y[1] <- x[1] : 
##  incompatible types (from environment to double) in subassignment type fix
## and the error list in the previous subsection, we can know the problem is from assignment, 
## and we can come up with the solution which deal with the issue:

fun1 <- function(x) {
    if (length(x) != 4L) stop("'x' must be a vector of 4 elements.")
    y <- julia_array(rep(0, 4)) 
    ## we need to use julia_array to wrap the vector
    ## or we can do y <- julia_array(0, 4) which is more elegant.
    y[1] <- x[1]; y[2] <- x[2]^2
    y[3] <- x[3]; y[4] <- x[4]^3
    y <- matrix(y, 2, 2)
    det(y)
}

print(try(ad_grad(fun1, x0)))
#> [1] "Error : Error happens in Julia.\nREvalError: \n"
#> attr(,"class")
#> [1] "try-error"
#> attr(,"condition")
#> <simpleError: Error happens in Julia.
#> REvalError: >

## and then we have another error, 
## from the error message 
## Error in matrix(y, 2, 2) : 
##   'data' must be of a vector type, was 'environment'
## and the error list in the previous subsection, we can know the problem is from 
## using matrix to reshape the vector y, 
## and we can come up with the solution which deal with the issue:

fun2 <- function(x) {
    if (length(x) != 4L) stop("'x' must be a vector of 4 elements.")
    ## we need to use julia_array to wrap the vector
    ## or we can do y <- julia_array(0, 4) which is more elegant.
    y <- julia_array(rep(0, 4)) 
    y[1] <- x[1]; y[2] <- x[2]^2
    y[3] <- x[3]; y[4] <- x[4]^3
    ## we need to use array to reshape the vector,
    ## or we can do y <- julia_array(y, 2, 2).
    y <- array(y, c(2, 2))
    det(y)
}

## This time we will have the correct solution
ad_grad(fun2, x0)
#> [1]  5.832 -4.480 -1.960 11.664

## and we can use numeric approximation to check our result:
numDeriv::grad(fun2, x0)
#> [1]  5.832 -4.480 -1.960 11.664
```

### Use `ad_variant` to deal with these issues “automatically”

The above process is a little tedious. Helpfully, `autodiffr` provides a
helper function `ad_variant` to deal with these problems simutaneously.
And the usage is quite simple and self-explanotory:

``` r
funvariant <- ad_variant(fun)
#> ad_variant will try to wrap your function in a special environment, which redefines some R functions to be compatible with autodiffr. Please use it with care.

ad_grad(funvariant, x0)
#> [1]  5.832 -4.480 -1.960 11.664

funvariant1 <- ad_variant(fun, checkArgs = x0)
#> ad_variant will try to wrap your function in a special environment, which redefines some R functions to be compatible with autodiffr. Please use it with care.
#> Start checking...
#> assignment in arrays has been replaced to be compatible with arrays in Julia.
#> matrix has been replaced with array.
#> New function gives the same result as the original function at the given arguments. Still need to use it with care.
#> Checking finished.

ad_grad(funvariant1, x0)
#> [1]  5.832 -4.480 -1.960 11.664
```

## A more complex example: Chebyquad function

This problem was given prominence in the optimization literature by
Fletcher (1965).

First let us have our Chebyquad function. Note that this is for the
**vector** x. This function is taken from the package
[`funconstrain`](https://github.com/jlmelville/funconstrain).

``` r
cyq.f <- function (par) 
{
    n <- length(par)
    if (n < 1) {
        stop("Chebyquad: n must be positive")
    }
    y <- 2 * par - 1
    t0 <- rep(1, n)
    t1 <- y
    ti <- t1
    fsum <- 0
    for (i in 1:n) {
        if (i > 1) {
            ti <- 2 * y * t1 - t0
            t0 <- t1
            t1 <- ti
        }
        fi <- sum(ti)/n
        if (i%%2 == 0) {
            fi <- fi + 1/(i * i - 1)
        }
        fsum <- fsum + fi * fi
    }
    fsum
}
```

Let us choose a single value for the number of parameters, and for
illustration use \(n = 10\).

``` r
## cyq.setup
n <- 10
x<-1:n
x<-x/(n+1.0) # Initial value suggested by Fletcher
```

For safety, let us check the function and a numerical approximation to
the gradient.

``` r
require(numDeriv)
#> Loading required package: numDeriv
cat("Initial parameters:")
#> Initial parameters:
x
#>  [1] 0.09090909 0.18181818 0.27272727 0.36363636 0.45454545 0.54545455
#>  [7] 0.63636364 0.72727273 0.81818182 0.90909091
cat("Initial value of the function is ",cyq.f(x),"\n")
#> Initial value of the function is  0.03376327
gn <- numDeriv::grad(cyq.f, x) # using numDeriv
cat("Approximation to gradient at initial point:")
#> Approximation to gradient at initial point:
gn
#>  [1]  0.7446191 -0.4248347  0.3221248 -0.0246995 -0.2126736  0.2126736
#>  [7]  0.0246995 -0.3221248  0.4248347 -0.7446191
```

And then we can use `autodiffr` to get the gradient:

``` r
cyq.ag <- makeGradFunc(cyq.f) # Need autodiffr:: specified for knitr
cat("Gradient at x")
#> Gradient at x
cyq.ag(x)
#>  [1]  0.7446191 -0.4248347  0.3221248 -0.0246995 -0.2126736  0.2126736
#>  [7]  0.0246995 -0.3221248  0.4248347 -0.7446191
```

And we can see that the result is very similar, which means that
`autodiffr` gives the correct result.

### Create optimized gradient/jacobian/hessian functions with autodiffr

`autodiffr` also provides some ways to generate a more optimized version
of gradient/jacobian/hessian functions. See `?autodifffunc`.

Here we will give a simple example for one possible way (and maybe the
most effective one) to generate optimized gradient function by `use_tape
= TRUE` using the Chebyquad
function:

``` r
cyq.ag_with_tape <- makeGradFunc(cyq.f, x = runif(length(x)), use_tape = TRUE)

cyq.ag_with_tape(x)
#>  [1]  0.7446191 -0.4248347  0.3221248 -0.0246995 -0.2126736  0.2126736
#>  [7]  0.0246995 -0.3221248  0.4248347 -0.7446191
```

From the documentation: `use_tape` is whether or not to use tape for
reverse mode automatic differentiation. Note that although use\_tape can
greatly improve the performance sometime, it can only calculate the
derivatives w.r.t a certain branching, so it may not give the correct
result for functions containing things like if. And this parameter is
only effective when mode = “reverse”.

**Important** And also pay attention that for the optimization to have
any effect, `x` must be given and must have the same shape of the
potential input(s).

And we can see that the optimized gradient function also gives the
correct result.

And then we can use package `microbenchmark` to check the effect of
`use_tape` and also compare it with the numeric approximation from
`numDeriv`.

``` r
require(microbenchmark)
#> Loading required package: microbenchmark

cat("cyq.f timing:\n")
#> cyq.f timing:
tcyq.f <- microbenchmark(cyq.f(x))
tcyq.f
#> Unit: microseconds
#>      expr    min      lq     mean median     uq    max neval
#>  cyq.f(x) 13.049 13.4505 14.34149 13.793 14.237 49.492   100

tcyq.ag <- microbenchmark(cyq.ag(x), unit="us" )

tcyq.ag
#> Unit: microseconds
#>       expr      min       lq     mean   median      uq      max neval
#>  cyq.ag(x) 6732.641 7387.361 9566.946 8249.006 10046.3 37423.42   100

tcyq.ag_with_tape <- microbenchmark(cyq.ag_with_tape(x), unit="us" )

tcyq.ag_with_tape
#> Unit: microseconds
#>                 expr    min      lq     mean  median      uq     max neval
#>  cyq.ag_with_tape(x) 154.09 156.065 178.1127 157.494 162.701 605.363   100

tcyq.ng <- microbenchmark(numDeriv::grad(cyq.f, x), unit="us" )

tcyq.ng
#> Unit: microseconds
#>                      expr      min       lq     mean   median       uq
#>  numDeriv::grad(cyq.f, x) 1957.673 2167.925 2851.527 2552.967 3307.834
#>       max neval
#>  6314.212   100
```

From the time comparison, we can see that the `use_tape` is very
effective and the optimized gradient function performs much better than
the numeric approximation provided by `numDeriv` in this case.

## Bibliography

<div id="refs" class="references">

<div id="ref-Fletcher65">

Fletcher, R. 1965. “Function Minimization Without Calculating
Derivatives – a Review.” *Computer Journal* 8:33–41.

</div>

</div>
