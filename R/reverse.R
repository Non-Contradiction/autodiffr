#' Wrapper functions for API of `ReverseDiff.jl`.
#'
#'  Wrapper functions for API of `ReverseDiff.jl` at
#'  <http://www.juliadiff.org/ReverseDiff.jl/api/>.
#'  These functions can help you calculate gradient, jacobian and hessian
#'  for your functions using reverse mode automatic differentiation.
#'  For more details, see <http://www.juliadiff.org/ReverseDiff.jl/api/>.
#'
#' @param f the function you want to calulate the gradient, jacobian and hessian.
#'   Note that `f(x)` should be a scalar for `grad` and `hessian`,
#'   a vector of length greater than 1 for `jacobian`.
#' @param input the point where you take the gradient, jacobian and hessian.
#'   Note that it should be a a vector of length greater than 1.
#'   If you want to calulate the derivative of a function, you can considering using `forward.deriv`.
#' @param cfg Config objects which contains the preallocated tape and work buffers
#'   used by reverse mode automatic differentiation.
#'   `ReverseDiff`'s API methods will allocate the Config object automatically by default,
#'   but you can preallocate them yourself and reuse them for subsequent calls to reeuce memory usage.
#' @param tp,gtp,jtp the tapes to construct the Config objects for `ReverseDiff`,
#'   which are for advantage usage.
#'   See
#'   <http://www.juliadiff.org/ReverseDiff.jl/api/#the-abstracttape-api>
#'   for more details.
#' @return `reverse.grad`, `reverse.jacobian` and `reverse.hessian` return
#'   the gradient, jacobian and hessian of `f` correspondingly evaluated at `input`.
#'   `reverse.grad.config`, `reverse.jacobian.config` and `reverse.hessian.config`
#'   return Config instances containing the preallocated tape and work buffers used by
#'   reverse mode automatic differentiation.
#' @md
#'
#' @name ReverseDiff
NULL

#' @rdname ReverseDiff
#' @export
reverse.grad <- function(f, input,
                         cfg = JuliaCall::julia_call("GradientConfig", input)){
    JuliaCall::julia_call("ReverseDiff.gradient", f, input, cfg)
}

#' @rdname ReverseDiff
#' @export
reverse.jacobian <- function(f, input,
                             cfg = JuliaCall::julia_call("JacobianConfig", input)){
    JuliaCall::julia_call("ReverseDiff.jacobian", f, input, cfg)
}

#' @rdname ReverseDiff
#' @export
reverse.hessian <- function(f, input,
                            cfg = JuliaCall::julia_call("HessianConfig", input)){
    JuliaCall::julia_call("ReverseDiff.hessian", f, input, cfg)
}

####### Constructing Config objects for ReverseDiff

#' @rdname ReverseDiff
#' @export
reverse.grad.config <- function(input,
                                tp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.GradientConfig", input, tp)
}

#' @rdname ReverseDiff
#' @export
reverse.jacobian.config <- function(input,
                                    tp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.JacobianConfig", input, tp)
}

#' @rdname ReverseDiff
#' @export
reverse.hessian.config <- function(input,
                                   gtp = JuliaCall::julia_call("Rawtape"),
                                   jtp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.HessianConfig", input, gtp, jtp)
}
