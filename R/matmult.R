#' Matrix Multiplication Compatable with JuliaObject
#'
#' `%x%` is matrix multiplication operator compatible with `JuliaObject`.
#'
#' @param x,y numeric or complex matrices or vectors.
#'
#' @export
`%x%` <- function(x, y) JuliaCall::julia_call("*", x, y)
