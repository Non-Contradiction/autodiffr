#' Matrix Multiplication Compatable with JuliaObject.
#'
#' \code{grapes-m-grapes} is matrix multiplication operator compatible with \code{JuliaObject}.
#'
#' @param x,y numeric or complex matrices or vectors.
#'
#' @export
`%m%` <- function(x, y) JuliaCall::julia_call("*", x, y)
