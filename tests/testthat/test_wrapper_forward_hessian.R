## The file is adapted from the hessian test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/HessianTest.jl>

context("Test Wrapper Functions for ForwardDiff Hessian")

test_that("test on rosenbrock function", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    #############################
    # rosenbrock hardcoded test #
    #############################

    f <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS$rosenbrock_1
    x <- c(0.1, 0.2, 0.3)
    v <- f(x)
    g <- c(-9.4, 15.6, 52.0)
    h <- matrix(c(-66.0, -40.0, 0.0,
                  -40.0, 130.0, -80.0,
                  0.0, -80.0, 200.0), 3, 3)

    for (c in 1:3) {

        print(paste0("  ...running hardcoded test with chunk size = ", c))

        cfg <- forward.hessian.config(f, x, chunk_size = c)
        resultcfg <- forward.hessian.config(f, x, chunk_size = c, diffresult = HessianResult(x))

        expect_equal(h, forward.hessian(f, x, cfg))

        expect_equal(h, forward.hessian(f, x))

        out <- HessianResult(x)
        forward.hessian(f, x, diffresult = out)
        expect_equal(out$value, v)
        expect_equal(out$grad, g)
        expect_equal(out$hessian, h)

        out <- HessianResult(x)
        forward.hessian(f, x, resultcfg, diffresult = out)
        expect_equal(out$value, v)
        expect_equal(out$grad, g)
        expect_equal(out$hessian, h)
    }

    cfgx <- forward.hessian.config(sin, x)
    expect_error(forward.hessian(f, x, cfg = cfgx))
    expect_identical(forward.hessian(f, x, cfg = cfgx, check = FALSE),
                     forward.hessian(f,x))

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
        h <- forward.hessian(f, X)
        expect_equal(h, JuliaCall::julia_call("Calculus.hessian", f, X), tolerance = 0.001)

        cfg0 <- forward.hessian.config(f, X)
        expect_equal(h, forward.hessian(f, X, cfg0))

        for (c in CHUNK_SIZES) {

            print(paste0("  ...testing ", n, " with chunk size = ", c))

            cfg <- forward.hessian.config(f, X, chunk_size = c)
            resultcfg <- forward.hessian.config(f, X, chunk_size = c, diffresult = HessianResult(X))

            out <- forward.hessian(f, X, cfg)

            expect_equal(out, h)

            out <- HessianResult(X)
            forward.hessian(f, X, resultcfg, diffresult = out)
            expect_equal(out$value, v)
            expect_equal(out$grad, g)
            expect_equal(out$hessian, h)
        }
    }
})
