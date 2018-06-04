#' Matrix Multiplication Compatable with JuliaObject
#'
#' `%m%` is matrix multiplication operator compatible with `JuliaObject`.
#'
#' @param x,y numeric or complex matrices or vectors.
#'
#' @md
#'
#' @export
`%m%` <- function(x, y) JuliaCall::julia_call("*", x, y)
