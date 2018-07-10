## The file is adapted from the gradient test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/GradientTest.jl>

context("Test Wrapper Functions for ForwardDiff Gradient")

test_that("test on rosenbrock function", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    ##################
    # hardcoded test #
    ##################

    f <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS$rosenbrock_1
    x <- c(0.1, 0.2, 0.3)
    v <- f(x)
    g <- c(-9.4, 15.6, 52.0)

    expect_equal(g, forward.grad(f, x))
    cfg0 <- forward.grad.config(f, x)
    expect_equal(g, forward.grad(f, x, cfg0))

    for (c in 1:3) {

        print(paste0("  ...running hardcoded test with chunk size = ", c))

        cfg <- forward.grad.config(f, x, chunk_size = c)

        expect_equal(g, forward.grad(f, x, cfg))

        out <- GradientResult(x)
        forward.grad(f, x, cfg, diffresult = out)
        expect_equal(out$value, v)
        expect_equal(out$grad, g)

        out <- GradientResult(x)
        forward.grad(f, x, diffresult = out)
        expect_equal(out$value, v)
        expect_equal(out$grad, g)
    }

    cfgx <- forward.grad.config(sin, x)
    expect_error(forward.grad(f, x, cfg = cfgx))
    expect_identical(forward.grad(f, x, cfg = cfgx, check = FALSE),
                     forward.grad(f,x))

})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    ########################
    # test vs. Calculus.jl #
    ########################

    funcs <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        v <- f(X)
        g <- forward.grad(f, X)
        expect_equal(g, JuliaCall::julia_call("Calculus.derivative", f, X))

        cfg0 <- forward.grad.config(f, X)
        expect_equal(g, forward.grad(f, X, cfg = cfg0))

        for (c in CHUNK_SIZES) {

            print(paste0("  ...testing ", n, " with chunk size = ", c))

            cfg <- forward.grad.config(f, X, chunk_size = c)

            expect_equal(g, forward.grad(f, X, cfg))

            out <- GradientResult(X)
            forward.grad(f, X, cfg, diffresult = out)
            expect_equal(out$value, v)
            expect_equal(out$grad, g)
        }
    }
})
