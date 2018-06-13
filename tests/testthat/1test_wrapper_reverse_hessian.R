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

    print("....without HessianConfig")

    expect_equal(reverse.hessian(f, x), test)

    print("....with HessianConfig")

    cfg <- reverse.hessian.config(x)

    expect_equal(reverse.hessian(f, x, cfg), test)

    if (!use_tape) {
        print("....Tape is not tested.")
        return(0)
    }

    print("....with HessianTape")

    seedx <- rand(x)
    tp <- reverse.hessian.tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse.hessian(tp, x), test)

    if (!use_compiled_tape) {
        print("....Compiled tape is not tested.")
        return(0)
    }

    print("....with compiled HessianTape")

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

    for (i in 1:length(autodiffr:::MATRIX_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::MATRIX_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::MATRIX_TO_NUMBER_FUNCS)[i]

        print(paste0("MATRIX_TO_NUMBER_FUNCS ", n))

        test_unary_hessian(f, matrix(runif(25), 5, 5), use_tape = (i > 2))
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

        test_unary_hessian(f, runif(5))
    }
})
