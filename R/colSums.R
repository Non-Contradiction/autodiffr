#' Row and Column Sums and Means Compatable with JuliaObject
#'
#' Calculate row and column sums and means compatible with `JuliaObject`.
#'
#' @param x `R` or `julia` numeric matrices or vectors.
#'
#' @md
#'
#' @name colSums
NULL

#' @rdname colSums
#' @export
rSums <- function(x) as.vector(JuliaCall::julia_call("sum", x, 2L))

#' @rdname colSums
#' @export
rMeans <- function(x) as.vector(JuliaCall::julia_call("mean", x, 2L))

#' @rdname colSums
#' @export
cSums <- function(x) as.vector(JuliaCall::julia_call("sum", x, 1L))

#' @rdname colSums
#' @export
cMeans <- function(x) as.vector(JuliaCall::julia_call("mean", x, 1L))
