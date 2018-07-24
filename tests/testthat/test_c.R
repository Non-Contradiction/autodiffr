context("Tests for is.numeric as.numeric numeric rep(0,n) and etc")

N <- 5
heq <- function(p) {
    c(p[1], p[N] - 1, p[N+1] - 1, p[2*N] - 1)
}
p0 <- runif(10)
J <- matrix(0, 4, 10)
J[1,1] <- 1
J[2,5] <- 1
J[3,6] <- 1
J[4,10] <- 1

test_that("Test on c function", {
    skip_on_cran()
    ad_setup()

    expect_equal(jacobian(heq, p0), J)

})
