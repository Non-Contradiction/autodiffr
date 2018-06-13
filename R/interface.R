#' #' Calculate the gradient of a function.
#' #'
#' #' \code{grad} calculates the gradient of a function.
#' #'
#' #' @param func the function you want to caculate the gradient,
#' #'   it should be a function with a scalar result.
#' #' @param x the point where the gradient is calculated.
#' #'   If not given (or NULL), return will be the gradient function.
#' #'
#' #' @export
#' grad <- function(func, x = NULL){
#'     ## ad_setup() is not necessary,
#'     ## unless you want to pass some arguments to it.
#'     ad_setup()
#'
#'     if (!is.null(x)) {
#'         JuliaCall::julia_call("ForwardDiff.gradient", func, x)
#'     }
#'     else {
#'         force(func)
#'         function(x) JuliaCall::julia_call("ForwardDiff.gradient", func, x)
#'     }
#' }
