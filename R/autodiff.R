.AD <- new.env(parent = emptyenv())

#' Do initial setup for package autodiffr.
#'
#' \code{ad_setup} does the initial setup for package autodiffr.
#'
#' @param ... arguments passed to \code{JuliaCall::julia_setup}.
#'
#' @examples
#' \dontrun{
#' ad_setup()
#' }
#'
#' @export
ad_setup <- function(...) {
    .AD$julia <- JuliaCall::julia_setup(...)
    .AD$julia$install_package_if_needed("ForwardDiff")
    .AD$julia$install_package_if_needed("ReverseDiff")
    .AD$julia$library("ForwardDiff")
    .AD$julia$library("ReverseDiff")

    .AD$initialized <- TRUE
}

#' Calculate the gradient of a function.
#'
#' \code{grad} calculates the gradient of a function.
#'
#' @param func the function you want to caculate the gradient,
#'   it should be a function with a scalar result.
#' @param x the point where the gradient is calculated.
#'   If not given (or NULL), return will be the gradient function.
#'
#' @export
grad <- function(func, x = NULL){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    if (!(isTRUE(.AD$initialized))) {
        ad_setup()
    }

    if (!is.null(x)) {
        JuliaCall::julia_call("ForwardDiff.gradient", func, x)
    }
    else {
        force(func)
        function(x) JuliaCall::julia_call("ForwardDiff.gradient", func, x)
    }
}



