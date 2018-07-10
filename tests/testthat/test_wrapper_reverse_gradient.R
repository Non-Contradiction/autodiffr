## The file is adapted from the gradient test for ReverseDiff.jl
## at <https://github.com/JuliaDiff/ReverseDiff.jl/blob/master/test/api/GradientTests.jl>

context("Test Wrapper Functions for ReverseDiff Gradient")

COMPILED_TAPE_LIMIT <- 5000

rand <- function(x){
    if (length(dim(x)) == 2) seedx <- matrix(runif(length(x)), dim(x))
    else seedx <- runif(length(x))
    seedx
}

test_unary_gradient <- function(f, x, use_tape = TRUE){
    test <- forward.grad(f, x)
    testval <- f(x)

    print("....without GradientConfig")

    expect_equal(reverse.grad(f, x), test)

    result <- GradientResult(x)
    reverse.grad(f, x, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, test)

    print("....with GradientConfig")

    cfg <- reverse.grad.config(x)

    expect_equal(reverse.grad(f, x, cfg), test)

    result <- GradientResult(x)
    reverse.grad(f, x, cfg, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, test)

    if (!use_tape) {
        print("....Tape-related methods are not tested...")
        return(0)
    }

    print("....with GradientTape")

    seedx <- rand(x)
    tp <- reverse.grad.tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse.grad(tp, x), test)

    result <- GradientResult(x)
    reverse.grad(tp, x, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, test)

    print("....with compiled GradientTape")

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(ctp))
        expect_equal(reverse.grad(ctp, x), test)

        result <- GradientResult(x)
        reverse.grad(ctp, x, diffresult = result)
        expect_equal(result$value, testval)
        expect_equal(result$grad, test)
    }
}

test_ternary_gradient <- function(f, a, b, c){
    test_val <- f(a, b, c)
    test_a <- forward.grad(function(x) f(x, b, c), a)
    test_b <- forward.grad(function(x) f(a, x, c), b)
    test_c <- forward.grad(function(x) f(a, b, x), c)

    print("....without GradientConfig")

    r <- reverse.grad(f, list(a, b, c))
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]
    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    print("....with GradientConfig")

    cfg <- reverse.grad.config(list(a, b, c))

    r <- reverse.grad(f, list(a, b, c), cfg)
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]

    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    print("....with GradientTape")

    seeda <- rand(a)
    seedb <- rand(b)
    seedc <- rand(c)
    tp <- reverse.grad.tape(f, list(seeda, seedb, seedc))

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))

    r <- reverse.grad(tp, list(a, b, c))
    ga <- r[[1]]; gb <- r[[2]]; gc <- r[[3]]

    expect_equal(ga, test_a)
    expect_equal(gb, test_b)
    expect_equal(gc, test_c)

    print("....with compiled GradientTape")

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(tp))

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

    funcs <- TESTING_FUNCS$MATRIX_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("MATRIX_TO_NUMBER_FUNCS ", n))

        test_unary_gradient(f, matrix(runif(25), 5, 5), use_tape = (i > 2))
    }
})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("VECTOR_TO_NUMBER_FUNCS ", n))

        test_unary_gradient(f, runif(5))
    }
})

test_that("test on TERNARY_MATRIX_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$TERNARY_MATRIX_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("TERNARY_MATRIX_TO_NUMBER_FUNCS ", n))

        test_ternary_gradient(f, matrix(runif(25), 5, 5), matrix(runif(25), 5, 5), matrix(runif(25), 5, 5))
    }
})
