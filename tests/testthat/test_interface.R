context("Test on User Interface Functions")

test_that("test of grad", {
    skip_on_cran()
    ad_setup()

    X <- runif(5)

    funcs <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        test <- ad_grad(f, X)
        for (mode in c("reverse", "forward")) {
            expect_equal(test, ad_grad(f, X, mode = mode))
        }
    }
})

test_that("test of hessian", {
    skip_on_cran()
    ad_setup()

    X <- runif(5)

    funcs <- TESTING_FUNCS$VECTOR_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        test <- ad_hessian(f, X)
        for (mode in c("reverse", "forward")) {
            expect_equal(test, ad_hessian(f, X, mode = mode))
        }
    }
})

# test_that("test of jacobian", {
#     skip_on_cran()
#     ad_setup()
#
#     X <- matrix(runif(9), 3, 3)
#
#     funcs <- TESTING_FUNCS$ARRAY_TO_ARRAY_FUNCS
#
#     for (i in 1:length(funcs)) {
#         f <- funcs[[i]]
#         n <- names(funcs)[i]
#         print(paste0("  ...testing ", n))
#         test <- ad_jacobian(f, X)
#         for (mode in c("reverse", "forward")) {
#                         expect_equal(test, ad_jacobian(f, X, mode = mode))
#         }
#     }
# })

test_that("test on scalar2scalar function", {
    skip_on_cran()
    ad_setup()

    X <- runif(1)

    funcs <- TESTING_FUNCS$NUMBER_TO_NUMBER_FUNCS

    for (i in 1:length(funcs)) {
        f <- funcs[[i]]
        n <- names(funcs)[i]
        print(paste0("  ...testing ", n))
        test <- ad_grad(f, X)
        for (mode in c("reverse", "forward")) {
            print(paste0("  ......mode ", mode))

            expect_equal(test, ad_grad(f, X, mode = mode))
            expect_equal(test, ad_jacobian(f, X, mode = mode)[1])
        }
    }
})

test_that("test on multi-argument function", {
    skip_on_cran()
    ad_setup()

    f <- function(a = 1, b = 2, c = 3){
        a + 2 * b ^ 2 + 3 * c ^ 3
    }

    ans0 <- function(a = 1, b = 2, c = 3){
        r <- list()
        if (!missing(a)) {
            r$a <- 1
        }
        if (!missing(b)) {
            r$b <- 4 * b
        }
        if (!missing(c)) {
            r$c <- 9 * c
        }
        r
    }

    ans <- function(r0){
        if (!is.list(r0)) {
            r1 <- ans0(r0)
            names(r1) <- names(r0)
            as.double(r1)
        }
        else {
            r1 <- do.call(ans0, r0)
            names(r1) <- names(r0)
            r1
        }
    }

    for (X in list(1, 2, list(b = 1), list(b = 2), list(1, 2), list(2, 1), list(a = 1, 2), list(a = 2, 1), list(a = 1, b = 2))) {
        test <- ans(X)
        for (mode in c("reverse", "forward")) {
            print(paste0("  ......mode ", mode))
            expect_equal(test, ad_grad(f, X, mode = mode))
        }
    }
})
