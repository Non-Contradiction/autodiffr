context("Test Function Implementations in DiffTests")

test_that("test on NUMBER_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    x <- 1

    for (i in 1:length(autodiffr:::NUMBER_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::NUMBER_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::NUMBER_TO_NUMBER_FUNCS)[i]
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

    for (i in 1:length(autodiffr:::NUMBER_TO_ARRAY_FUNCS)) {
        f <- autodiffr:::NUMBER_TO_ARRAY_FUNCS[[i]]
        n <- names(autodiffr:::NUMBER_TO_ARRAY_FUNCS)[i]
        print(paste0("  ...testing ", n))
        expect_equal(f(x),
                     JuliaCall::julia_call(paste0("DiffTests.", n), x))
    }
})

test_that("test on VECTOR_TO_NUMBER_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    for (i in 1:length(autodiffr:::VECTOR_TO_NUMBER_FUNCS)) {
        f <- autodiffr:::VECTOR_TO_NUMBER_FUNCS[[i]]
        n <- names(autodiffr:::VECTOR_TO_NUMBER_FUNCS)[i]
        print(paste0("  ...testing ", n))
        expect_equal(f(X),
                     JuliaCall::julia_call(paste0("DiffTests.", n), X))
    }
})

test_that("test on ARRAY_TO_ARRAY_FUNCS", {
    skip_on_cran()
    ad_setup()
    autodiffr:::test_setup()

    for (i in 1:length(autodiffr:::ARRAY_TO_ARRAY_FUNCS)) {
        f <- autodiffr:::ARRAY_TO_ARRAY_FUNCS[[i]]
        n <- names(autodiffr:::ARRAY_TO_ARRAY_FUNCS)[i]
        print(paste0("  ...testing ", n))
        expect_equal(f(X),
                     JuliaCall::julia_call(paste0("DiffTests.", n), X))

    }
})
