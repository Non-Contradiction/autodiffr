
<!-- README.md is generated from README.Rmd. Please edit that file -->

# autodiffr for Automatic Differentiation in R through Julia

[![Travis-CI Build
Status](https://travis-ci.org/Non-Contradiction/autodiffr.svg?branch=master)](https://travis-ci.org/Non-Contradiction/autodiffr)
<!--
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/Non-Contradiction/JuliaCall?branch=master&svg=true)](https://ci.appveyor.com/project/Non-Contradiction/JuliaCall)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/JuliaCall)](https://cran.r-project.org/package=JuliaCall)
[![](https://cranlogs.r-pkg.org/badges/JuliaCall)](https://cran.r-project.org/package=JuliaCall)
[![](https://cranlogs.r-pkg.org/badges/grand-total/JuliaCall)](https://cran.r-project.org/package=JuliaCall)
-->

Package `autodiffr` provides an R interface to `Julia`, which is a
high-level, high-performance dynamic programming language for numerical
computing, see <https://julialang.org/> for more information. Below is
an image for [Mandelbrot
set](https://en.wikipedia.org/wiki/Mandelbrot_set). JuliaCall brings
**more than 100 times speedup** of the calculation\! See
<https://github.com/Non-Contradiction/JuliaCall/tree/master/example/mandelbrot>
for more information.

## Installation

Pakcage `autodiffr` is not on CRAN yet. You can get the development
version of `autodiffr` by

``` r
devtools::install_github("Non-Contradiction/autodiffr")
```

It’s recommended at this stage to also use the development version of
`JuliaCall` by

``` r
devtools::install_github("Non-Contradiction/JuliaCall")
```

## Basic Usage

``` r
library(autodiffr)

## Do initial setup

ad_setup()
#> Julia version 0.6.2 at location /Applications/Julia-0.6.app/Contents/Resources/julia/bin will be used.
#> Julia initiation...
#> Finish Julia initiation.
#> Loading setup script for JuliaCall...
#> Finish loading setup script for JuliaCall.

## If you want to use a julia at a specific location, you could do the following:
## ad_setup(JULIA_HOME = "the folder that contains julia binary"), 
## or you can set JULIA_HOME in command line environment or use `options(...)`

f <- function(x) sum(x^2L)

grad(f, c(2, 3))
#> [1] 4 6

g <- grad(f)

g(c(2, 3))
#> [1] 4 6
```

## Trouble Shooting and Way to Get Help

### Julia is not found

Make sure the `Julia` installation is correct. `autodiffr` is able to
find `Julia` on PATH, and there are three ways for `autodiffr` to find
`Julia` not on PATH.

  - Use `ad_setup(JULIA_HOME = "the folder that contains julia binary")`
  - Use `options(JULIA_HOME = "the folder that contains julia binary")`
  - Set `JULIA_HOME` in command line environment.

### How to Get Help

  - The GitHub Pages for this repository host the documentation for the
    development version of `autodiffr`:
    <https://non-contradiction.github.io/autodiffr/>.

  - And you are more than welcome to contact me about `JuliaCall` at
    <lch34677@gmail.com> or <cxl508@psu.edu>.

## Suggestion and Issue Reporting

`autodiffr` is under active development now. Any suggestion or issue
reporting is welcome\! You may report it using the link:
<https://github.com/Non-Contradiction/autodiffr/issues/new>. Or email me
at <lch34677@gmail.com> or <cxl508@psu.edu>.
