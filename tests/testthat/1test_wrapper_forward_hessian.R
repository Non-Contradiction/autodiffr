## The file is adapted from the hessian test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/HessianTest.jl>

context("Test Wrapper Functions for ForwardDiff Hessian")

for c in (1, 2, 3), tag in (nothing, Tag((f,gradient), eltype(x)))
println("  ...running hardcoded test with chunk size = $c and tag = $tag")
cfg = ForwardDiff.HessianConfig(f, x, ForwardDiff.Chunk{c}(), tag)
resultcfg = ForwardDiff.HessianConfig(f, DiffResults.HessianResult(x), x, ForwardDiff.Chunk{c}(), tag)

@test eltype(resultcfg) == eltype(cfg)

@test isapprox(h, ForwardDiff.hessian(f, x))
@test isapprox(h, ForwardDiff.hessian(f, x, cfg))

out = similar(x, 3, 3)
ForwardDiff.hessian!(out, f, x)
@test isapprox(out, h)

out = similar(x, 3, 3)
ForwardDiff.hessian!(out, f, x, cfg)
@test isapprox(out, h)

out = DiffResults.HessianResult(x)
ForwardDiff.hessian!(out, f, x)
@test isapprox(DiffResults.value(out), v)
@test isapprox(DiffResults.gradient(out), g)
@test isapprox(DiffResults.hessian(out), h)

out = DiffResults.HessianResult(x)
ForwardDiff.hessian!(out, f, x, resultcfg)
@test isapprox(DiffResults.value(out), v)
@test isapprox(DiffResults.gradient(out), g)
@test isapprox(DiffResults.hessian(out), h)
end
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

    for (i in 1:length(autodiffr:::VECTOR_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::VECTOR_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::VECTOR_TO_NUMBER_FUNCS)[i]
        v <- f(X)
        g <- forward.grad(f, X)
        expect_equal(g, JuliaCall::julia_call("Calculus.derivative", f, X))

        for (c in CHUNK_SIZES) {
            for (tag in list(JuliaCall::julia_eval("nothing", need_return = "Julia"),
                             JuliaCall::julia_call("ForwardDiff.Tag",
                                                   f, JuliaCall::julia_eval("Float64")))) {

                print(paste0("  ...testing ", n, " with chunk size = ", c, " and tag = ", tag))

                JuliaCall::julia_assign("c", c)
                cfg <- JuliaCall::julia_call("ForwardDiff.GradientConfig",
                                             f, X,
                                             JuliaCall::julia_eval("ForwardDiff.Chunk{c}()"),
                                             tag)

                expect_equal(g, forward.grad(f, X, cfg))
            }
        }
    }
})
