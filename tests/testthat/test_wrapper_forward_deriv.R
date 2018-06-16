## The file is adapted from the derivative test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/DerivativeTest.jl>

########################
# test vs. Calculus.jl #
########################

context("Test Wrapper Functions for ForwardDiff Deriv")

test_that("test on NUMBER_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    x <- 1

    funcs <- TESTING_FUNCS$NUMBER_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        v <- f(x)
        d <- forward.deriv(f, x)
        expect_equal(d, JuliaCall::julia_call("Calculus.derivative", f, x))
    }
})

test_that("test on NUMBER_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    x <- 1

    funcs <- TESTING_FUNCS$NUMBER_TO_ARRAY_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        v <- f(x)
        d <- forward.deriv(f, x)
        expect_equal(d, JuliaCall::julia_call("Calculus.derivative", f, x))
    }
})
