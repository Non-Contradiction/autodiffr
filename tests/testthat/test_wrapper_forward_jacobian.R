## The file is adapted from the hessian test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/JacobianTest.jl>

context("Test Wrapper Functions for ForwardDiff Jacobian")

test_that("hardcoded test", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    #############################
    #      hardcoded test       #
    #############################

    f <- function(x){
        ## Need to do this to allow automatic differentiation
        y <- rep(x[1], 4)
        y[1] <- x[1] * x[2]
        y[1] <- y[1] * sin(x[3]^2)
        y[2] <- y[1] + x[3]
        y[3] <- y[1] / y[2]
        y[4] <- x[3]
        y
    }
    x <- c(1, 2, 3)
    v <- f(x)
    j <- t(matrix(c(0.8242369704835132, 0.4121184852417566, -10.933563142616123,
                    0.8242369704835132, 0.4121184852417566, -9.933563142616123,
                    0.169076696546684,  0.084538348273342,  -2.299173530851733,
                    0.0,                0.0,                1.0), 3, 4))

    for (c in 1:3) {

        print(paste0("  ...running hardcoded test with chunk size = ", c))

        cfg <- forward.jacobian.config(f, x, chunk_size = c)

        expect_equal(j, forward.jacobian(f, x, cfg))

        expect_equal(j, forward.jacobian(f, x))

        out <- JacobianResult(rep(0, 4), rep(0, 3))
        forward.jacobian(f, x, cfg, diffresult = out)
        expect_equal(out$value, v)
        expect_equal(out$jacobian), j)
    }

    cfgx <- forward.jacobian.config(sin, x)
    expect_error(forward.jacobian(f, x, cfg = cfgx))
    expect_identical(forward.jacobian(f, x, cfg = cfgx, check = FALSE),
                     forward.jacobian(f,x))

})

test_that("test on ARRAY_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    ########################
    # test vs. Calculus.jl #
    ########################

    funcs <- TESTING_FUNCS$ARRAY_TO_ARRAY_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        v <- f(X)
        j <- forward.jacobian(f, X)

        JuliaCall::julia_assign("_f", f)
        JuliaCall::julia_assign("_X", X)
        expect_equal(j, JuliaCall::julia_eval("Calculus.jacobian(x -> vec(_f(x)), _X, :forward)"),
                     tolerance = 0.001)

        cfg0 <- forward.jacobian.config(f, X)
        expect_equal(j, forward.jacobian(f, X, cfg0))

        for (c in CHUNK_SIZES) {

            print(paste0("  ...testing ", n, " with chunk size = ", c))

            cfg <- forward.jacobian.config(f, X, chunk_size = c)

            out <- forward.jacobian(f, X, cfg)

            expect_equal(out, j)

            out <- JacobianResult(X, v)
            forward.jacobian(f, X, cfg, diffresult = out)
            expect_equal(out$value, v)
            expect_equal(out$jacobian, j)
        }
    }
})
