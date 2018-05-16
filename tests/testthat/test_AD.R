context("Automatic Differentiation Test")

test_that("test of AD on basic functions", {
    skip_on_cran()
    ad_setup()

    f <- function(x) sum(x^2L)
    expect_equal(grad(f, c(2, 3)), c(4, 6))
})
