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
    test <- forward_hessian(f, x, forward_hessian_config(f, x, chunk_size = 1))
    testgrad <- forward_grad(f, x)
    testval <- f(x)

    print("....without HessianConfig")

    expect_equal(reverse_hessian(f, x), test)

    result <- HessianResult(x)
    reverse_hessian(f, x, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, testgrad)
    expect_equal(result$hessian, test)

    print("....with HessianConfig")

    cfg <- reverse_hessian_config(x)

    expect_equal(reverse_hessian(f, x, cfg), test)

    result <- HessianResult(x)
    cfg <- reverse_hessian_config(x, diffresult = result)
    reverse_hessian(f, x, cfg, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, testgrad)
    expect_equal(result$hessian, test)

    if (!use_tape) {
        print("..._tape is not tested.")
        return(0)
    }

    print("....with HessianTape")

    seedx <- rand(x)
    tp <- reverse_hessian_tape(f, seedx)

    ## additional check of is_tape function
    expect_true(autodiffr:::is_tape(tp))
    expect_equal(reverse_hessian(tp, x), test)

    result <- HessianResult(x)
    reverse_hessian(tp, x, diffresult = result)
    expect_equal(result$value, testval)
    expect_equal(result$grad, testgrad)
    expect_equal(result$hessian, test)

    if (!use_compiled_tape) {
        print("....Compiled tape is not tested.")
        return(0)
    }

    print("....with compiled HessianTape")

    if (length(tp$tape) <= 10000) { # otherwise compile time can be crazy
        ctp <- reverse_compile(tp)

        ## additional check of is_tape function
        expect_true(autodiffr:::is_tape(ctp))
        expect_equal(reverse_hessian(ctp, x), test)

        result <- HessianResult(x)
        reverse_hessian(ctp, x, diffresult = result)
        expect_equal(result$value, testval)
        expect_equal(result$grad, testgrad)
        expect_equal(result$hessian, test)
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

        print(paste0("VECTOR_TO_NUMBER_FUNCS ", n))

        test_unary_hessian(f, runif(5))
    }
})
