#' Wrapper functions for API of `ForwardDiff.jl`.
#'
#'  Wrapper functions for API of `ForwardDiff.jl` at
#'  <http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html>.
#'  These functions can help you calculate derivative, gradient, jacobian and hessian
#'  for your functions using forward mode automatic differentiation.
#'  For more details, see <http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html>.
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