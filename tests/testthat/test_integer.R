context("Tests for integer input")

penalty_I <- function(p){
    n <- length(p)
    if (n < 1) {
        stop("Penalty Function I: n must be positive")
    }
    fsum <- 0
    fn1 <- 0
    for (i in 1:n) {
        fi <- sqrt(1e-05) * (p[i] - 1)
        fsum <- fsum + fi * fi
        fn1 <- fn1 + p[i] * p[i]
    }
    fn1 <- fn1 - 0.25
    fsum <- fsum + fn1 * fn1
    fsum
}

test_that("Test integer input", {
    skip_on_cran()
    ad_setup()

    expect_equal(grad(penalty_I, 1:4, mode = "forward"),
                 grad(penalty_I, 1:4, mode = "reverse"))

    expect_equal(grad(penalty_I, 1L, mode = "forward"),
                 grad(penalty_I, 1L, mode = "reverse"))

    expect_equal(grad(penalty_I, list(p = 1:4), mode = "forward"),
                 grad(penalty_I, list(p = 1:4), mode = "reverse"))

    expect_equal(grad(penalty_I, list(p = 1L), mode = "forward"),
                 grad(penalty_I, list(p = 1L), mode = "reverse"))
})
