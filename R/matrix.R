#' `matrix` Compatible with `JuliaObject`.
#'
#' `Jmatrix` creates a matrix from the given set of values.
#'
#' @param data the data vector used to create matrix.
#' @param nrow number of rows of the matrix.
#' @param ncol number of columns of the matrix.
#'
#' @export
Jmatrix <- function(data, nrow, ncol){
    JuliaCall::julia_call("reshape", JuliaCall::julia_call("copy", data),
                          as.integer(nrow), as.integer(ncol))
}
