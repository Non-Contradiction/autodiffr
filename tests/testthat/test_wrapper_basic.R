context("Basic Tests for Wrapper Functions")

test_that("Basic tests for Config wrappers in ForwardDiff", {
    skip_on_cran()
    ad_setup()

    expect_s3_class(forward_grad_config(function(x)sum(x^2L), rep(0,5)), "JuliaObject")

    expect_s3_class(forward_hessian_config(function(x)sum(x^2L), rep(0,5)), "JuliaObject")

    expect_s3_class(forward_jacobian_config(function(x)x^2L, rep(0,5)), "JuliaObject")

})

test_that("Basic tests for Config wrappers in ReverseDiff", {
    skip_on_cran()
    ad_setup()

    expect_s3_class(reverse_grad_config(rep(0,5)), "JuliaObject")

    expect_s3_class(reverse_hessian_config(rep(0,5)), "JuliaObject")

    expect_s3_class(reverse_jacobian_config(rep(0,5)), "JuliaObject")

})

test_that("Results for ForwardDiff and ReverseDiff should match for basic functions", {
    skip_on_cran()
    ad_setup()

    expect_identical(
        forward_grad(function(x)sum(x^2L), rep(0,5)),
        reverse_grad(function(x)sum(x^2L), rep(0,5)))

    expect_identical(
        forward_hessian(function(x)sum(x^2L), rep(0,5)),
        reverse_hessian(function(x)sum(x^2L), rep(0,5)))

    expect_identical(
        forward_jacobian(function(x)x^2L, rep(0,5)),
        reverse_jacobian(function(x)x^2L, rep(0,5)))

})

test_that("Results for ForwardDiff for basic functions", {
    skip_on_cran()
    ad_setup()

    expect_identical(forward_deriv(function(x)x^2L, 0), 0)

    expect_identical(
        forward_grad(function(x)sum(x^2L), rep(0,5)),
        rep(0, 5))

    expect_identical(
        forward_hessian(function(x)sum(x^2L), rep(0,5)),
        2 * diag(5))

    expect_identical(
        forward_jacobian(function(x)x^2L, rep(0,5)),
        matrix(0, 5, 5))

})
