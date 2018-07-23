context("Tests for is.numeric as.numeric numeric rep(0,n) and etc")

diff2 <- function(x) {
    stopifnot(is.numeric(x))
    n <- length(x)
    as.numeric(x[1:(n-1)] - x[2:n])
}
f2 <- function(x) diff2(x)^2

x <- 1/c(8,4,2,1)

diff3 <- function(x) {
    n <- length(x)
    (x[1:(n-1)] - x[2:n])
}
f3 <- function(x) diff3(x)^2

diff4 <- function(x) {
    n <- length(x)
    if (n <= 1) return( vector(mode="numeric"))
    y <- JuliaCall::JuliaObject(numeric(n-1))
    for (i in 1:(n-1)) {
        y[i] <- x[i] - x[i+1]
    }
    return(y)
}
f4 <- function(x) diff4(x)^2

test_that("Test on various diff implementations", {
    skip_on_cran()
    ad_setup()

    R2 <- jacobian(f2, x, mode = "reverse")
    F2 <- jacobian(f2, x, mode = "forward")
    expect_equal(R2, F2)
    R3 <- jacobian(f3, x, mode = "reverse")
    expect_equal(R2, R3)
    F3 <- jacobian(f3, x, mode = "forward")
    expect_equal(R2, F3)
    R4 <- jacobian(f4, x, mode = "reverse")
    expect_equal(R2, R4)
    F4 <- jacobian(f4, x, mode = "forward")
    expect_equal(R2, F4)

})

ff <- function(x) as.double(sum(as.double(x)^2))

test_that("Test on hessian with as.double", {
    skip_on_cran()
    ad_setup()

    expect_equal(hessian(ff, c(1, 1), mode = "reverse"),
                 2 * diag(2))

    expect_equal(hessian(ff, c(1, 1), mode = "forward"),
                 2 * diag(2))

})
