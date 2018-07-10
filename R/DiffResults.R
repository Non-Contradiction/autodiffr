#' Create `DiffResult` Object.
#'
#' Create `DiffResult` object which can be used for storage of functions values and different orders
#' of derivative results at the same time.
#'
#' @param x a vector of same shape with potential input vectors.
#' @param y a vector of same shape with potential output vectors.
#'   When it is NULL (default), it means that `y` has the same shape with `x`.
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
    r$type <- "GradientResult"
    r
}

#' @rdname DiffResults
#' @export
JacobianResult <- function(x, y = NULL){
    ad_setup()
    if (is.null(y)) {
        r <- JuliaCall::julia_call("DiffResults.JacobianResult", x)
    }
    else {
        r <- JuliaCall::julia_call("DiffResults.JacobianResult", y, x)
    }
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("jacobian", function() JuliaCall::julia_call("DiffResults.jacobian", r), r)
    r$type <- "JacobianResult"
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
    r$type <- "HessianResult"
    r
}

extractDiff <- function(diffresult){
    if (is.environment(diffresult) && is.character(diffresult$type)) {
        return(switch(diffresult$type,
                      GradientResult = list(value = diffresult$value,
                                            grad = diffresult$grad),
                      JacobianResult = list(value = diffresult$value,
                                            jacobian = diffresult$jacobian),
                      HessianResult = list(value = diffresult$value,
                                           grad = diffresult$grad,
                                           hessian = diffresult$hessian),
                      diffresult))
    }
    diffresult
}
