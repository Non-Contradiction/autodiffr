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
}
