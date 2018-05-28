## The file is adapted from the gradient test for ForwardDiff.jl
## at <https://github.com/JuliaDiff/ForwardDiff.jl/blob/master/test/GradientTest.jl>

context("Test Wrapper Functions for ReverseDiff Gradient")

COMPILED_TAPE_LIMIT <- 5000

test_unary_gradient <- function(f, x){
    test <- forward.grad(f, x)

    # without GradientConfig

    expect_equal(reverse.grad(f, x), test)

    # with GradientConfig

    cfg <- reverse.grad.config(x)

    expect_equal(reverse.grad(f, x, cfg), test)

    # with GradientTape

    seedx <- matrix(runif(length(x)), dim(x))
    tp <- reverse.grad.tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse.grad(tp, x), test)

    # with compiled GradientTape

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(ctp))
        expect_equal(reverse.grad(ctp, x), test)
    }
}

test_ternary_gradient <- function(f, a, b, c){
    test_val <- f(a, b, c)
    test_a <- forward.grad(function(x) f(x, b, c), a)
    test_b <- forward.grad(function(x) f(a, x, c), b)
    test_c <- forward.grad(function(x) f(a, b, x), c)

    # without GradientConfig

    ga, gb, gc = ReverseDiff.gradient(f, (a, b, c))
    test_approx(∇a, test_a)
    test_approx(∇b, test_b)
    test_approx(∇c, test_c)

    ∇a, ∇b, ∇c = map(similar, (a, b, c))
    ReverseDiff.gradient!((∇a, ∇b, ∇c), f, (a, b, c))
    test_approx(∇a, test_a)
    test_approx(∇b, test_b)
    test_approx(∇c, test_c)

    ∇a, ∇b, ∇c = map(DiffResults.GradientResult, (a, b, c))
    ReverseDiff.gradient!((∇a, ∇b, ∇c), f, (a, b, c))
    test_approx(DiffResults.value(∇a), test_val)
    test_approx(DiffResults.value(∇b), test_val)
    test_approx(DiffResults.value(∇c), test_val)
    test_approx(DiffResults.gradient(∇a), test_a)
    test_approx(DiffResults.gradient(∇b), test_b)
    test_approx(DiffResults.gradient(∇c), test_c)
}

# with GradientConfig

cfg = ReverseDiff.GradientConfig((a, b, c))

∇a, ∇b, ∇c = ReverseDiff.gradient(f, (a, b, c), cfg)
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(similar, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), f, (a, b, c), cfg)
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(DiffResults.GradientResult, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), f, (a, b, c), cfg)
test_approx(DiffResults.value(∇a), test_val)
test_approx(DiffResults.value(∇b), test_val)
test_approx(DiffResults.value(∇c), test_val)
test_approx(DiffResults.gradient(∇a), test_a)
test_approx(DiffResults.gradient(∇b), test_b)
test_approx(DiffResults.gradient(∇c), test_c)

# with GradientTape

tp = ReverseDiff.GradientTape(f, (rand(size(a)), rand(size(b)), rand(size(c))))

∇a, ∇b, ∇c = ReverseDiff.gradient!(tp, (a, b, c))
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(similar, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), tp, (a, b, c))
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(DiffResults.GradientResult, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), tp, (a, b, c))
test_approx(DiffResults.value(∇a), test_val)
test_approx(DiffResults.value(∇b), test_val)
test_approx(DiffResults.value(∇c), test_val)
test_approx(DiffResults.gradient(∇a), test_a)
test_approx(DiffResults.gradient(∇b), test_b)
test_approx(DiffResults.gradient(∇c), test_c)

# with compiled GradientTape

if length(tp.tape) <= COMPILED_TAPE_LIMIT # otherwise compile time can be crazy
ctp = ReverseDiff.compile(tp)

∇a, ∇b, ∇c = ReverseDiff.gradient!(ctp, (a, b, c))
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(similar, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), ctp, (a, b, c))
test_approx(∇a, test_a)
test_approx(∇b, test_b)
test_approx(∇c, test_c)

∇a, ∇b, ∇c = map(DiffResults.GradientResult, (a, b, c))
ReverseDiff.gradient!((∇a, ∇b, ∇c), ctp, (a, b, c))
test_approx(DiffResults.value(∇a), test_val)
test_approx(DiffResults.value(∇b), test_val)
test_approx(DiffResults.value(∇c), test_val)
test_approx(DiffResults.gradient(∇a), test_a)
test_approx(DiffResults.gradient(∇b), test_b)
test_approx(DiffResults.gradient(∇c), test_c)
end
end

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

    expect_equal(g, forward.grad(f, x))
    cfg0 <- forward.grad.config(f, x)
    expect_equal(g, forward.grad(f, x, cfg0))

    for (c in 1:3) {

        print(paste0("  ...running hardcoded test with chunk size = ", c))

        cfg <- forward.grad.config(f, x, chunk_size = c)

        expect_equal(g, forward.grad(f, x, cfg))
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

    for (i in 1:length(autodiffr:::VECTOR_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::VECTOR_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::VECTOR_TO_NUMBER_FUNCS)[i]
        v <- f(X)
        g <- forward.grad(f, X)
        expect_equal(g, JuliaCall::julia_call("Calculus.derivative", f, X))

        cfg0 <- forward.grad.config(f, X)
        expect_equal(g, forward.grad(f, X, cfg = cfg0))

        for (c in CHUNK_SIZES) {

            print(paste0("  ...testing ", n, " with chunk size = ", c))

            cfg <- forward.grad.config(f, X, chunk_size = c)

            expect_equal(g, forward.grad(f, X, cfg))
        }
    }
})
