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

    f <- autodiffr:::rosenbrock_1
    x <- c(0.1, 0.2, 0.3)
    v <- f(x)
    g <- c(-9.4, 15.6, 52.0)
    h <- matrix(c(-66.0, -40.0, 0.0,
                  -40.0, 130.0, -80.0,
                  0.0, -80.0, 200.0), 3, 3)

    for (c in 1:3) {

        print(paste0("  ...running hardcoded test with chunk size = ", c))

        JuliaCall::julia_assign("c", c)

        cfg <- forward.hessian.config(f, x, chunk = JuliaCall::julia_eval("ForwardDiff.Chunk{c}()"))

        expect_equal(h, forward.hessian(f, x, cfg))

        expect_equal(h, forward.hessian(f, x))
    }

    cfgx <- forward.hessian.config(sin, x)
    expect_error(forward.hessian(f, x, cfg = cfgx))
    expect_identical(forward.hessian(f, x, cfg = cfgx, check = JuliaCall::julia_call("Val{false}")),
                     forward.hessian(f,x))

})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    ########################
    # test vs. Calculus.jl #
    ########################

    for (i in 1:length(autodiffr:::VECTOR_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::VECTOR_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::VECTOR_TO_NUMBER_FUNCS)[i]
        v <- f(X)
        g <- forward.grad(f, X)
        h <- forward.hessian(f, X)
        expect_equal(h, JuliaCall::julia_call("Calculus.hessian", f, X), tolerance = 0.001)

        cfg0 <- forward.hessian.config(f, X)
        expect_equal(h, forward.hessian(f, X, cfg0))

        for (c in CHUNK_SIZES) {

            print(paste0("  ...testing ", n, " with chunk size = ", c))

            JuliaCall::julia_assign("c", c)

            cfg <- forward.hessian.config(f, X, chunk = JuliaCall::julia_eval("ForwardDiff.Chunk{c}()"))

            out <- forward.hessian(f, X, cfg)

            expect_equal(out, h)
        }
    }
})
