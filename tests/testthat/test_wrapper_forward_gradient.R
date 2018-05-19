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

    f <- autodiffr:::rosenbrock_1
    x <- c(0.1, 0.2, 0.3)
    v <- f(x)
    g <- c(-9.4, 15.6, 52.0)

    for (c in 1:3) {
        for (tag in list(JuliaCall::julia_eval("nothing", need_return = "Julia"),
                         JuliaCall::julia_call("ForwardDiff.Tag",
                                               f, JuliaCall::julia_eval("Float64")))) {

            print(paste0("  ...running hardcoded test with chunk size = ", c, " and tag = ", tag))

            JuliaCall::julia_assign("c", c)
            cfg <- JuliaCall::julia_call("ForwardDiff.GradientConfig",
                                         f, x,
                                         JuliaCall::julia_eval("ForwardDiff.Chunk{c}()"),
                                         tag)

            expect_equal(g, forward.grad(f, x, cfg))
            expect_equal(g, forward.grad(f, x))
        }
    }

    cfgx <- forward.grad.config(sin, x)
    expect_error(forward.grad(f, x, cfg = cfgx))
    expect_identical(forward.grad(f, x, cfg = cfgx, check = JuliaCall::julia_call("Val{false}")),
                     forward.grad(f,x))

})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    ########################
    # test vs. Calculus.jl #
    ########################

    for (f in autodiffr:::VECTOR_TO_NUMBER_FUNCS) {
        v <- f(X)
        g <- forward.grad(f, X)
        expect_equal(g, JuliaCall::julia_call("Calculus.derivative", f, X))

        for (c in CHUNK_SIZES) {
            for (tag in list(JuliaCall::julia_eval("nothing", need_return = "Julia"),
                             JuliaCall::julia_call("ForwardDiff.Tag",
                                                   f, JuliaCall::julia_eval("Float64")))) {
                JuliaCall::julia_assign("c", c)
                cfg <- JuliaCall::julia_call("ForwardDiff.GradientConfig",
                                             f, x,
                                             JuliaCall::julia_eval("ForwardDiff.Chunk{c}()"),
                                             tag)

                expect_equal(g, forward.grad(f, x, cfg))
            }
        }
    }
})