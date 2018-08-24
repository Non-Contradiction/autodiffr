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

    JuliaCall::julia_eval("function rosenjl(x) n = length(x);
                          x1 = x[2:n]; x2 = x[1:(n - 1)];
                          sum(100 * (x1 - x2.^2).^2 + (1 .- x2).^2) end")

    autodiffr:::expect_grad(fnRosenbrock, rep(1,3), jf_str = "rosenjl")
    autodiffr:::expect_grad(fnRosenbrock, c(1,2,3), jf_str = "rosenjl")
    autodiffr:::expect_grad(fnRosenbrock, c(1,2,1), jf_str = "rosenjl")

    autodiffr:::expect_hessian(fnRosenbrock, rep(1,3), jf_str = "rosenjl")
    autodiffr:::expect_hessian(fnRosenbrock, c(1,2,3), jf_str = "rosenjl")
    autodiffr:::expect_hessian(fnRosenbrock, c(1,2,1), jf_str = "rosenjl")
})
