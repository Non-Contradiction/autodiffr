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

juliasum <- function(x, dims){
    if (.AD$julia07) r <- JuliaCall::julia_call("sum", x, dims = as.integer(dims))
    else r <- JuliaCall::julia_call("sum", x, as.integer(dims))
    as.vector(r)
}

juliamean <- function(x, dims){
    if (.AD$julia07) r <- JuliaCall::julia_call("mean", x, as.integer(dims))
    else r <- JuliaCall::julia_call("mean", x, as.integer(dims))
    as.vector(r)
}

#' @rdname colSums
#' @export
rSums <- function(x) juliasum(x, dims = 2L)

#' @rdname colSums
#' @export
rMeans <- function(x) juliamean(x, dims = 2L)

#' @rdname colSums
#' @export
cSums <- function(x) juliasum(x, dims = 1L)

#' @rdname colSums
#' @export
cMeans <- function(x) juliamean(x, dims = 1L)
