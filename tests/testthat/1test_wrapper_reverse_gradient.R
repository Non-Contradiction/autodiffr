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

    r <- reverse.grad(f, list(a, b, c))
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]
    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    # with GradientConfig

    cfg <- reverse.grad.config(list(a, b, c))

    r <- reverse.grad(f, list(a, b, c), cfg)
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]

    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    # with GradientTape

    seeda <- matrix(runif(length(a)), dim(a))
    seedb <- matrix(runif(length(b)), dim(b))
    seedc <- matrix(runif(length(c)), dim(c))
    tp <- reverse.grad.tape(f, list(seeda, seedb, seedc))

    r <- reverse.grad(tp, list(a, b, c))
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]

    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    # with compiled GradientTape

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        r <- reverse.grad(ctp, list(a, b, c))
        ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]

        expect_equal(ga, test_a)
        expect_equal(gb, test_b)
        expect_equal(gc, test_c)
    }
}

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
