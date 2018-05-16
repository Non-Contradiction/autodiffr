context("Basic Tests for Wrapper Functions")

test_that("Basic tests for Config wrappers in ForwardDiff", {
    skip_on_cran()
    ad_setup()

    expect_s3_class(forward.grad.config(function(x)sum(x^2L), rep(0,5)), "JuliaObject")

    expect_s3_class(forward.hessian.config(function(x)sum(x^2L), rep(0,5)), "JuliaObject")

    expect_s3_class(forward.jacobian.config(function(x)x^2L, rep(0,5)), "JuliaObject")

})

test_that("Basic tests for Config wrappers in ReverseDiff", {
    skip_on_cran()
    ad_setup()

    expect_s3_class(reverse.grad.config(rep(0,5)), "JuliaObject")

    expect_s3_class(reverse.hessian.config(rep(0,5)), "JuliaObject")

    expect_s3_class(reverse.jacobian.config(rep(0,5)), "JuliaObject")

})

test_that("Results for ForwardDiff and ReverseDiff should match for basic functions", {
    skip_on_cran()
    ad_setup()

    expect_identical(
        forward.grad(function(x)sum(x^2L), rep(0,5)),
        reverse.grad(function(x)sum(x^2L), rep(0,5)))

    expect_identical(
        forward.hessian(function(x)sum(x^2L), rep(0,5)),
        reverse.hessian(function(x)sum(x^2L), rep(0,5)))

    expect_identical(
        forward.jacobian(function(x)x^2L, rep(0,5)),
        reverse.jacobian(function(x)x^2L, rep(0,5)))

})

test_that("Results for ForwardDiff for basic functions", {
    skip_on_cran()
    ad_setup()

    expect_identical(forward.deriv(function(x)x^2L, 0), 0)

    expect_identical(
        forward.grad(function(x)sum(x^2L), rep(0,5)),
        rep(0, 5))

    expect_identical(
        forward.hessian(function(x)sum(x^2L), rep(0,5)),
        2 * diag(5))

    expect_identical(
        forward.jacobian(function(x)x^2L, rep(0,5)),
        matrix(0, 5, 5))

})
