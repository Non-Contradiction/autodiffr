## The file is adapted from the hessian test for ReverseDiff.jl
## at <https://github.com/JuliaDiff/ReverseDiff.jl/blob/master/test/api/HessianTests.jl>

context("Test Wrapper Functions for ReverseDiff Hessian")

COMPILED_TAPE_LIMIT <- 5000

rand <- function(x){
    if (length(dim(x)) == 2) seedx <- matrix(runif(length(x)), dim(x))
    else seedx <- runif(length(x))
    seedx
}

test_unary_hessian <- function(f, x, use_tape = TRUE, use_compiled_tape = FALSE){
    test <- forward.hessian(f, x, forward.hessian.config(f, x, chunk_size = 1))

    cat("....without HessianConfig")

    expect_equal(reverse.hessian(f, x), test)

    cat("....with HessianConfig")

    cfg <- reverse.hessian.config(x)

    expect_equal(reverse.hessian(f, x, cfg), test)

    if (!use_tape) {
        cat("....Tape is not tested.")
        return(0)
    }

    cat("....with HessianTape")

    seedx <- rand(x)
    tp <- reverse.hessian.tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse.hessian(tp, x), test)

    if (!use_compiled_tape) {
        cat("....Compiled tape is not tested.")
        return(0)
    }

    cat("....with compiled HessianTape")

    if (length(tp$tape) <= 10000) { # otherwise compile time can be crazy
        ctp <- reverse.compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(ctp))
        expect_equal(reverse.hessian(ctp, x), test)
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

        cat(paste0("MATRIX_TO_NUMBER_FUNCS ", n))

        test_unary_hessian(f, matrix(runif(9), 3, 3), use_tape = (i > 2))
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

        cat(paste0("VECTOR_TO_NUMBER_FUNCS ", n))

        test_unary_hessian(f, runif(5))
    }
})
