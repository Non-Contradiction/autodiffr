#' Wrapper functions for API of `ReverseDiff.jl`.
#'
#'  Wrapper functions for API of `ReverseDiff.jl` at
#'  <http://www.juliadiff.org/ReverseDiff.jl/api/>.
#'  These functions can help you calculate gradient, jacobian and hessian
#'  for your functions using reverse mode automatic differentiation.
#'  For more details, see <http://www.juliadiff.org/ReverseDiff.jl/api/>.
#'
#' @param f the function you want to calulate the derivative, gradient and etc.
#'   Note that `f(x)` should be a scalar for `grad` and `hessian`,
#'   a vector of length greater than 1 for `jacobian`,
#'   and could be either a scalar or a vector for `deriv`.
#' @param x the point where you take the derivative, gradient and etc.
#'   Note that it should be a scalar for `deriv` and a vector of length greater than 1 for
#'   `grad`, `jacobian` and `hessian`.
#' @param cfg objects of ForwardDiff.AbstractConfig types, which have
#'   information useful to do automatic differentiation for `f`.
#'   These types allow the user to easily feed several different parameters to ForwardDiff's API,
#'   such as chunk size, work buffers, and perturbation seed configurations.
#'   ForwardDiff's basic API methods will allocate these types automatically by default,
#'   but you can drastically reduce memory usage if you preallocate them yourself.
#' @param check whether to allow tag checking.
#'   Set check to `JuliaCall::julia_call("Val{false}")` to disable tag checking for ForwardDiff.
#'   This can lead to perturbation confusion, so should be used with care.
#' @param chunk the chunk to construct the Config objects for ForwardDiff.
#'   Its size may be explicitly provided, or omitted,
#'   in which case ForwardDiff will automatically select a chunk size for you.
#'   However, it is highly recommended to specify the chunk size manually when possible.
#'   See
#'   <http://www.juliadiff.org/ForwardDiff.jl/stable/user/advanced.html#Configuring-Chunk-Size-1>
#'   for more details.
#' @return `forward.deriv`, `forward.grad`, `forward.jacobian` and `forward.hessian` return
#'   the derivative, gradient, jacobian and hessian of `f` correspondingly evaluated at `x`.
#'   `forward.grad.config`, `forward.jacobian.config` and `forward.hessian.config`
#'   return Config instances based on `f`` and `x`,
#'   which contain all the work buffers required to carry out the automatic differentiation.
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
