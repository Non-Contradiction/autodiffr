#' Create an array of all zeros with the same element type and dims as `x`.
#'
#' `zeros` create an array of all zeros with the same element type and dims as `x`.
#'
#' @param x `R` or `julia` matrices or vectors.
#'
#' @md
#'
#' @export
zeros <- function(x){
    JuliaCall::julia_call("zero", x)
}

#' Create an array of all ones with the same element type and dims as `x`.
#'
#' `ones` create an array of all ones with the same element type and dims as `x`.
#'
#' @param x `R` or `julia` matrices or vectors.
#'
#' @md
#'
#' @export
ones <- function(x){
    JuliaCall::julia_call("fill!", JuliaCall::julia_call("similar", x), 1)
}
