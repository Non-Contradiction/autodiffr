context("Automatic Differentiation Test")

test_that("test of AD on basic functions", {
    skip_on_cran()
    ad_setup()

    f <- function(x) sum(x^2L)
    expect_equal(grad(f, c(2, 3)), c(4, 6))
})

# test_that("test of AD of lambertW function", {
#     skip_on_cran()
#     ad_setup()
#
#     lambertW <- function(x) {
#         ## add the first line so the function could be accepted by ForwardDiff
#         x <- x[1L]
#         w0 <- 1
#         w1 <- w0 - (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
#         while (w0 != w1) {
#             w0 <- w1
#             w1 <- w0 -
#                 (w0*exp(w0)-x)/((w0+1)*exp(w0)-(w0+2)*(w0*exp(w0)-x)/(2*w0+2))
#         }
#         return(w1)
#     }
#
#     expect_equal(grad(lambertW, [1.0]), 0.361896256634889)
# })
