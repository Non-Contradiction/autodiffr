#' Create Julia Arrays.
#'
#'  `julia_array` is a helper function to create Julia arrays including vectors, matrices and etc.
#'  And it can be used in functions to facilitate automatic differentiation.
#'
#' @param data the data to create the array.
#' @param n1,n2,... the dimensions.
#'
#' @details If n1 is missing, then all the dimensions will be ignored,
#'   and the result will be a Julia array coresponding to the data argument.
#'   If n1, n2, ... are given, they will determine the shape of the result,
#'   and data will be used for the content.
#'
#' @examples
#'
#' \donttest{ ## setup is quite time consuming
#'   julia_array(0, 3) ## will return a Julia vector with length 3 and filled with 0
#'   julia_array(0, 3, 4) ## will return a Julia matrix of 3x4 and filled with 0
#'   julia_array(matrix(1, 2, 2)) ## dimension is not given, will return a Julia matrix
#'   julia_array(matrix(1, 2, 2), 4) ## dimension is given, will return a Julia vector
#' }
#'
#' @md
#' @export
julia_array <- function(data, n1, n2, ...){
    ## if n1 is missing, then ignore all the dimensions (even if given),
    ## then just use JuliaObject to wrap the data
    if (missing(n1)) {
        return(JuliaCall::JuliaObject(data))
    }

    if (missing(n2)) dims <- n1
    else dims <- c(n1, n2, ...)

    # if (length(data) > prod(dims)) dims <- c(dims, length(data) / prod(dims))

    JuliaCall::JuliaObject(array(data, dims))
}
