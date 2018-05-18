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

    testthat::expect_identical(forward.grad(f, x), reverse.grad(f, x))

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

    testthat::expect_identical(forward.hessian(f, x), reverse.hessian(f, x))

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

    testthat::expect_identical(forward.jacobian(f, x), reverse.jacobian(f, x))

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
