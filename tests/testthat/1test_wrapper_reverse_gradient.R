## The file is adapted from the gradient test for ReverseDiff.jl
## at <https://github.com/JuliaDiff/ReverseDiff.jl/blob/master/test/api/GradientTests.jl>

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

test_that("test on MATRIX_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    for (i in 1:length(autodiffr:::MATRIX_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::MATRIX_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::MATRIX_TO_NUMBER_FUNCS)[i]

        print(paste0("MATRIX_TO_NUMBER_FUNCS ", n))

        test_unary_gradient(f, matrix(runif(25), 5, 5))
    }
})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    for (i in 1:length(autodiffr:::VECTOR_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::VECTOR_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::VECTOR_TO_NUMBER_FUNCS)[i]

        print(paste0("VECTOR_TO_NUMBER_FUNCS ", n))

        test_unary_gradient(f, runif(5))
    }
})

test_that("test on TERNARY_MATRIX_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    for (i in 1:length(autodiffr:::TERNARY_MATRIX_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::TERNARY_MATRIX_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::TERNARY_MATRIX_TO_NUMBER_FUNCS)[i]

        print(paste0("TERNARY_MATRIX_TO_NUMBER_FUNCS ", n))

        test_ternary_gradient(f, matrix(runif(25), 5, 5), matrix(runif(25), 5, 5), matrix(runif(25), 5, 5))
    }
})
