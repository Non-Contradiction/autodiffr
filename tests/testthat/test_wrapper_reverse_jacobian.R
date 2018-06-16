## The file is adapted from the jacobian test for ReverseDiff.jl
## at <https://github.com/JuliaDiff/ReverseDiff.jl/blob/master/test/api/JacobianTests.jl>

context("Test Wrapper Functions for ReverseDiff Jacobian")

COMPILED_TAPE_LIMIT <- 5000

rand <- function(x){
    if (length(dim(x)) == 2) seedx <- matrix(runif(length(x)), dim(x))
    else seedx <- runif(length(x))
    seedx
}

test_unary_jacobian <- function(f, x, use_compiled_tape = FALSE){
    test_val <- f(x)
    test <- forward.jacobian(f, x)

    print("....without JacobianConfig")

    expect_equal(reverse.jacobian(f, x), test)

    print("....with JacobianConfig")

    cfg <- reverse.jacobian.config(x)

    expect_equal(reverse.jacobian(f, x, cfg), test)

    print("....with GradientTape")

    seedx <- rand(x)
    tp <- reverse.jacobian.tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse.jacobian(tp, x), test)

    if (!use_compiled_tape) {
        print("....Compiled tape is not tested.")
        return(0)
    }

    print("....with compiled GradientTape")

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(ctp))
        expect_equal(reverse.jacobian(ctp, x), test)
    }
}

test_binary_jacobian <- function(f, a, b, use_compiled_tape = FALSE){
    test_val <- f(a, b)
    test_a <- forward.jacobian(function(x) f(x, b), a)
    test_b <- forward.jacobian(function(x) f(a, x), b)

    print("....without JacobianConfig")

    r <- reverse.jacobian(f, list(a, b))
    Ja <- r[[1]]; Jb <- r[[2]]
    expect_equal(Ja, test_a)
    expect_equal(Jb, test_b)

    print("....with JacobianConfig")

    cfg <- reverse.jacobian.config(list(a, b))

    r <- reverse.jacobian(f, list(a, b), cfg)
    Ja <- r[[1]]; Jb <- r[[2]]

    expect_equal(Ja, test_a)
    expect_equal(Jb, test_b)

    print("....with JacobianTape")

    seeda <- rand(a)
    seedb <- rand(b)
    tp <- reverse.jacobian.tape(f, list(seeda, seedb))

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))

    r <- reverse.jacobian(tp, list(a, b))
    Ja <- r[[1]]; Jb <- r[[2]]

    expect_equal(Ja, test_a)
    expect_equal(Jb, test_b)

    if (!use_compiled_tape) {
        print("....Compiled tape is not tested.")
        return(0)
    }

    print("....with compiled JacobianTape")

    if (length(tp$tape) <= COMPILED_TAPE_LIMIT) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(tp))

        r <- reverse.jacobian(ctp, list(a, b))
        Ja <- r[[1]]; Jb <- r[[2]]

        expect_equal(Ja, test_a)
        expect_equal(Jb, test_b)
    }
}

test_that("test on ARRAY_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$ARRAY_TO_ARRAY_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("ARRAY_TO_ARRAY_FUNCS ", n))

        test_unary_jacobian(f, matrix(runif(9), 3, 3))
    }
})

test_that("test on MATRIX_TO_MATRIX_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$MATRIX_TO_MATRIX_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("MATRIX_TO_MATRIX_FUNCS ", n))

        test_unary_jacobian(f, matrix(runif(9), 3, 3))
    }
})

test_that("test on BINARY_MATRIX_TO_MATRIX_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$BINARY_MATRIX_TO_MATRIX_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]

        print(paste0("BINARY_MATRIX_TO_MATRIX_FUNCS ", n))

        test_binary_jacobian(f, matrix(runif(9), 3, 3), matrix(runif(9), 3, 3))
    }
})

test_that("test on nested jacobians", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    fs <- c(autodiffr:::ARRAY_TO_ARRAY_FUNCS, autodiffr:::MATRIX_TO_MATRIX_FUNCS)
    for (i in 1:length(fs)) {
        f <- fs[[i]]
        n <- names(fs)[i]

        print(paste0("ARRAY_TO_ARRAY_FUNCS + MATRIX_TO_MATRIX_FUNCS ", n))

        x <- matrix(runif(9), 3, 3)
        test <- forward.jacobian(function(y) forward.jacobian(f, y), x)

        print("....without JacobianTape")

        J <- reverse.jacobian(function(y) reverse.jacobian(f, y), x)
        expect_equal(J, test)

        print("....with JacobianTape")

        tp <- reverse.jacobian.tape(function(y) reverse.jacobian(f, y), rand(x))
        J <- reverse.jacobian(tp, x)
        expect_equal(J, test)
    }


    for (i in 1:length(autodiffr:::BINARY_MATRIX_TO_MATRIX_FUNCS)) {
        f <- autodiffr:::BINARY_MATRIX_TO_MATRIX_FUNCS[[i]]
        n <- names(autodiffr:::BINARY_MATRIX_TO_MATRIX_FUNCS)[i]

        print(paste0("BINARY_MATRIX_TO_MATRIX_FUNCS ", n))

        a <- matrix(runif(9), 3, 3)
        b <- matrix(runif(9), 3, 3)
        test_val <- f(a, b)
        test_a <- forward.jacobian(function(y) forward.jacobian(function(x) f(x, b), y), a)
        test_b <- forward.jacobian(function(y) forward.jacobian(function(x) f(a, x), y), b)

        print("....without JacobianTape")

        Ja <- reverse.jacobian(function(y) reverse.jacobian(function(x) f(x, b), y), a)
        Jb <- reverse.jacobian(function(y) reverse.jacobian(function(x) f(a, x), y), b)
        expect_equal(Ja, test_a)
        expect_equal(Jb, test_b)

        print("....with JacobianTape")

        ra <- reverse.jacobian.tape(function(y) reverse.jacobian(function(x) f(x, b), y), rand(a))
        rb <- reverse.jacobian.tape(function(y) reverse.jacobian(function(x) f(a, x), y), rand(b))
        Ja <- reverse.jacobian(ra, a)
        Jb <- reverse.jacobian(rb, b)
        expect_equal(Ja, test_a)
        expect_equal(Jb, test_b)

        # The below will fail until support for the Jacobian of
        # functions with multiple output arrays is implemented

        # Ja, Jb = ReverseDiff.jacobian((x, y) -> ReverseDiff.jacobian(f, (x, y)), (a, b))
        # test_approx(Ja test_a)
        # test_approx(Jb test_b)
    }
})
