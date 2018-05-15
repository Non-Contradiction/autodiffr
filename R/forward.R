#' Wrapper functions for API of `ForwardDiff.jl`.
#'
#' @param f the function you want to calulate the derivative, gradient and etc.
#'   Note that `f(x)` should be a scalar for `grad` and `hessian`,
#'   a vector of length greater than 1 for `jacobian`,
#'   and could be either a scalar or a vector for `deriv`.
#' @param x the point where you take the derivative, gradient and etc.
#'   Note that it should be a scalar for `deriv` and a vector of length greater than 1 for
#'   `grad`, `jacobian` and `hessian`.
#' @param cfg
#' @param check
#' @param chunk
#' @return julia_installed_package will return the version number of the julia package,
#'     "nothing" if the package is not installed.
#'
#' @name ForwardDiff
NULL

#' @rdname ForwardDiff
#' @export
forward.deriv <- function(f, x){
    JuliaCall::julia_call("ForwardDiff.derivative", f, x)
}

#' @rdname ForwardDiff
#' @export
forward.grad <- function(f, x,
                         cfg = JuliaCall::julia_call("GradientConfig", f, x),
                         check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.gradient", f, x, cfg, check)
}

#' @rdname ForwardDiff
#' @export
forward.jacobian <- function(f, x,
                             cfg = JuliaCall::julia_call("JacobianConfig", f, x),
                             check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.jacobian", f, x, cfg, check)
}

#' @rdname ForwardDiff
#' @export
forward.hessian <- function(f, x,
                            cfg = JuliaCall::julia_call("HessianConfig", f, x),
                            check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.hessian", f, x, cfg, check)
}

######### Constructing Config objects for ForwardDiff

#' @rdname ForwardDiff
#' @export
forward.grad.config <- function(f, x,
                                chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.GradientConfig", f, x, chunk)
}

#' @rdname ForwardDiff
#' @export
forward.jacobian.config <- function(f, x,
                                    chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.JacobianConfig", f, x, chunk)
}

#' @rdname ForwardDiff
#' @export
forward.hessian.config <- function(f, x,
                                   chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.HessianConfig", f, x, chunk)
}
