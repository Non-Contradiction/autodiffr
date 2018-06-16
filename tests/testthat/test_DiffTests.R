context("Test Function Implementations in DiffTests")

test_that("test on NUMBER_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    x <- 1

    funcs <- TESTING_FUNCS$NUMBER_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        expect_equal(f(x),
                     JuliaCall::julia_call(paste0("DiffTests.", n), x))
    }
})

test_that("test on NUMBER_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    x <- 1

    funcs <- TESTING_FUNCS$NUMBER_TO_ARRAY_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        expect_equal(f(x),
                     JuliaCall::julia_call(paste0("DiffTests.", n), x))
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
        print(paste0("  ...testing ", n))
        expect_equal(f(X),
                     JuliaCall::julia_call(paste0("DiffTests.", n), X))
    }
})

test_that("test on ARRAY_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$ARRAY_TO_ARRAY_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        if (n == "-") next()
        print(paste0("  ...testing ", n))
        expect_equal(f(X),
                     JuliaCall::julia_call(paste0("DiffTests.", n), X))

    }
})

rand <- function(x){
    if (length(dim(x)) == 2) seedx <- matrix(runif(length(x)), dim(x))
    else seedx <- runif(length(x))
    seedx
}

test_that("test on TERNARY_MATRIX_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$TERNARY_MATRIX_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        x <- matrix(1, 5, 5)
        a <- rand(x)
        b <- rand(x)
        c <- rand(x)
        expect_equal(f(a, b, c),
                     JuliaCall::julia_call(paste0("DiffTests.", n), a, b, c))

    }
})

test_that("test on MATRIX_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    funcs <- TESTING_FUNCS$MATRIX_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        x <- matrix(1, 5, 5)
        a <- rand(x)

        if (n != "det") {
            expect_equal(f(a),
                         JuliaCall::julia_call(paste0("DiffTests.", n), a))
        }
        if (n == "det") {
            expect_equal(f(a),
                         JuliaCall::julia_call(n, a))
        }
    }
})
