expect_deriv <- function(f, x, result){
    testthat::expect_equal(forward.deriv(f, x), result)
}

expect_grad <- function(f, x, result = NULL){
    testthat::expect_s3_class(forward.grad.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.grad.config(x), "JuliaObject")

    testthat::expect_identical(forward.grad(f, x), reverse.grad(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.grad(f, x), result)
    }
}

expect_hessian <- function(f, x, result = NULL){
    testthat::expect_s3_class(forward.hessian.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.hessian.config(x), "JuliaObject")

    testthat::expect_identical(forward.hessian(f, x), reverse.hessian(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.hessian(f, x), result)
    }
}

expect_jacobian <- function(f, x, result = NULL){
    testthat::expect_s3_class(forward.jacobian.config(f, x), "JuliaObject")

    testthat::expect_s3_class(reverse.jacobian.config(x), "JuliaObject")

    testthat::expect_identical(forward.jacobian(f, x), reverse.jacobian(f, x))

    if (!is.null(result)) {
        testthat::expect_equal(forward.jacobian(f, x), result)
    }
}
