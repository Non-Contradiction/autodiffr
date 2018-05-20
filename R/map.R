#' Apply a Function to Multiple List or Vector Arguments
#'
#' `map` is same as `mapply`, except more efficient for `JuliaObject`.
#'
#' @param FUN function to apply.
#' @param ... arguments.
#' @param MoreArgs a list of other arguments to FUN.
#' @param SIMPLIFY whether or not to simplify the result.
#' @param USE.NAMES whether or not to use names.
#'
#' @export
map <- function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE){
    dots <- list(...)
    UseMethod("map", dots[[1]])
}

map.default <- function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE)
    mapply(FUN, ..., MoreArgs = MoreArgs, SIMPLIFY = SIMPLIFY, USE.NAMES = USE.NAMES)

map.JuliaObject <- function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE){
    args <- c(FUN, ...)
    JuliaCall::julia_do.call("map", args)
}
