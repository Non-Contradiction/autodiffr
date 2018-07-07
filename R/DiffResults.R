#' Create `DiffResult` Object.
#'
#' Create `DiffResult` object which can be used for storage of functions values and different orders
#' of derivative results at the same time.
#'
#' @param x a vector of same shape with potential input vectors.
#' @md
#'
#' @name DiffResults
NULL

#' @rdname DiffResults
#' @export
GradientResult <- function(x){
    ad_setup()
    r <- JuliaCall::julia_call("DiffResults.GradientResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("grad", function() JuliaCall::julia_call("DiffResults.gradient", r), r)
    r
}

#' @rdname DiffResults
#' @export
JacobianResult <- function(x){
    ad_setup()
    r <- JuliaCall::julia_call("DiffResults.JacobianResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("jacobian", function() JuliaCall::julia_call("DiffResults.jacobian", r), r)
    r
}

#' @rdname DiffResults
#' @export
HessianResult <- function(x){
    ad_setup()
    r <- JuliaCall::julia_call("DiffResults.HessianResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("grad", function() JuliaCall::julia_call("DiffResults.gradient", r), r)
    makeActiveBinding("hessian", function() JuliaCall::julia_call("DiffResults.hessian", r), r)
    r
}
