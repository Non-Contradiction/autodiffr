context("Rosenbrock Test for Wrapper Functions")

test_that("Grad and Hessian for Rosenbrock function", {
    skip_on_cran()
    ad_setup()

    fnRosenbrock <- function(x){
        n <- length(x)
        x1 <- x[2:n]
        x2 <- x[1:(n - 1)]
        sum(100 * (x1 - x2^2)^2 + (1 - x2)^2)
    }

    autodiffr:::expect_grad(fnRosenbrock, rep(1,3))
    autodiffr:::expect_grad(fnRosenbrock, c(1,2,3))
    autodiffr:::expect_grad(fnRosenbrock, c(1,2,1))

    autodiffr:::expect_hessian(fnRosenbrock, rep(1,3))
    autodiffr:::expect_hessian(fnRosenbrock, c(1,2,3))
    autodiffr:::expect_hessian(fnRosenbrock, c(1,2,1))
})
