expect_deriv <- function(f, x, result, jf_str = NULL){
    testthat::expect_equal(forward.deriv(f, x), result)

    if (!is.null(jf_str)) {
        JuliaCall::julia_assign("x", x)
        command <- paste0("ForwardDiff.derivative(", jf_str, ", x)")
        testthat::expect_equal(forward.deriv(f, x),
                               JuliaCall::julia_eval(command))
    }
}

expect_grad <- function(f, x, result = NULL, julia_version = NULL, jf_str = NULL){
    testthat::expect_s3_class(forward.grad.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.grad.config(x), "JuliaObject")

    testthat::expect_equal(forward.grad(f, x), reverse.grad(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.grad(f, x), result)
    }

    if (!is.null(jf_str)) {
        JuliaCall::julia_assign("x", x)
        command <- paste0("ForwardDiff.gradient(", jf_str, ", x)")
        testthat::expect_equal(forward.grad(f, x),
                               JuliaCall::julia_eval(command))
    }
}

expect_hessian <- function(f, x, result = NULL, jf_str = NULL){
    testthat::expect_s3_class(forward.hessian.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.hessian.config(x), "JuliaObject")

    testthat::expect_equal(forward.hessian(f, x), reverse.hessian(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.hessian(f, x), result)
    }

    if (!is.null(jf_str)) {
        JuliaCall::julia_assign("x", x)
        command <- paste0("ForwardDiff.hessian(", jf_str, ", x)")
        testthat::expect_equal(forward.hessian(f, x),
                               JuliaCall::julia_eval(command))
    }
}

expect_jacobian <- function(f, x, result = NULL, jf_str = NULL){
    testthat::expect_s3_class(forward.jacobian.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.jacobian.config(x), "JuliaObject")

    testthat::expect_equal(forward.jacobian(f, x), reverse.jacobian(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.jacobian(f, x), result)
    }

    if (!is.null(jf_str)) {
        JuliaCall::julia_assign("x", x)
        command <- paste0("ForwardDiff.jacobian(", jf_str, ", x)")
        testthat::expect_equal(forward.jacobian(f, x),
                               JuliaCall::julia_eval(command))
    }
}

test_setup <- function(){
    ## The following two Julia packages are required for tests in ForwardDiff and ReverseDiff
    JuliaCall::julia_install_package_if_needed("Calculus")
    JuliaCall::julia_library("Calculus")
    JuliaCall::julia_install_package_if_needed("DiffTests")
    JuliaCall::julia_library("DiffTests")

    ## Adapted from test utility functions of ForwardDiff at
    ## <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/utils.jl>
    eval.parent(quote({
        ## convenient function in R corresponding to div in Julia
        div <- function(x, y) as.integer(x / y)
        set.seed(1)
        DEFAULT_CHUNK_THRESHOLD <- JuliaCall::julia_eval("ForwardDiff.DEFAULT_CHUNK_THRESHOLD")
        XLEN <- DEFAULT_CHUNK_THRESHOLD + 1
        YLEN <- div(DEFAULT_CHUNK_THRESHOLD, 2) + 1
        X <- runif(XLEN)
        Y <- runif(YLEN)
        CHUNK_SIZES <- c(1, div(DEFAULT_CHUNK_THRESHOLD, 3),
                         div(DEFAULT_CHUNK_THRESHOLD, 2), DEFAULT_CHUNK_THRESHOLD,
                         DEFAULT_CHUNK_THRESHOLD + 1)
        FINITEDIFF_ERROR <- 3e-5
    }))
}
