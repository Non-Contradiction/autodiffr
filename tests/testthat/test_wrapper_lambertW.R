context("More Tests for Wrapper Functions")

test_that("Deriv test for lambertW function", {
    skip_on_cran()
    ad_setup()

    lambertW <- function(x) {
        w0 <- 1
        w1 <- w0 - (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
        while (w0 != w1) {
            w0 <- w1
            w1 <- w0 -
                (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
        }
        return(w1)
    }

    autodiffr:::expect_deriv(lambertW, 1.0, 0.361896256634889)

})
