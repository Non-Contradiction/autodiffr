#' Construct a diagonal matrix
#'
#' `diag` construct a diagnonal matrix.
#'
#' @param x a vector or 1D array.
#'
#' @return a matrix with `x` as diagonal and zero off-diagonal entries.
#'
#' @export
diagm <- function(x) JuliaCall::julia_call("diagm", x)
