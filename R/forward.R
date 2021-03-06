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
#' @param cfg Config object which have
#'   information useful to do automatic differentiation for `f`.
#'   It allows the user to easily feed several different parameters to `ForwardDiff`'s API,
#'   such as chunk size, work buffers, and perturbation seed configurations.
#'   `ForwardDiff`'s basic API methods will allocate these types automatically by default,
#'   but you can drastically reduce memory usage if you preallocate them yourself.
#' @param check whether to allow tag checking.
#'   Set check to `FALSE` to disable tag checking for `ForwardDiff`.
#'   This can lead to perturbation confusion, so should be used with care.
#' @param chunk_size the size of the chunk to construct the Config objects for `ForwardDiff`.
#'   It may be explicitly provided, or omitted,
#'   in which case `ForwardDiff` will automatically select a chunk size for you.
#'   However, it is highly recommended to specify the chunk size manually when possible.
#'   See
#'   <http://www.juliadiff.org/ForwardDiff.jl/stable/user/advanced.html#Configuring-Chunk-Size-1>
#'   for more details.
#' @param diffresult Optional DiffResult object to store the derivative information.
#' @param debug Whether to use the wrapper functions under debug mode.
#'   With the debug mode, users can have more informative error messages.
#'   Without the debug mode, the wrapper functions will be more performant.
#'
#' @return `forward_deriv`, `forward_grad`, `forward_jacobian` and `forward_hessian` return
#'   the derivative, gradient, jacobian and hessian of `f` correspondingly evaluated at `x`.
#'   `forward_grad_config`, `forward_jacobian_config` and `forward_hessian_config`
#'   return Config instances based on `f`` and `x`,
#'   which contain all the work buffers required to carry out the forward mode automatic differentiation.
#' @md
#'
#' @name ForwardDiff
NULL

#' @rdname ForwardDiff
#' @export
forward_deriv <- function(f, x){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    JuliaCall::julia_call("ForwardDiff.derivative", f, x)
}

######### Constructing Config objects for ForwardDiff

forward_config <- function(name){
    fullname <- paste0("ForwardDiff.", name)

    config <- function(f, x, chunk_size = NULL, diffresult = NULL){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        ## deal with diffresult first

        if (!is.null(diffresult) && identical(fullname, "ForwardDiff.HessianConfig")) {
            if (is.null(chunk_size)) {
                return(JuliaCall::julia_call(fullname, f, diffresult, x))
            }
            JuliaCall::julia_assign("_chunk_size", as.integer(chunk_size))
            chunk <- JuliaCall::julia_eval("ForwardDiff.Chunk{_chunk_size}()")
            return(JuliaCall::julia_call(fullname, f, diffresult, x, chunk))
        }

        if (is.null(chunk_size)) {
            return(JuliaCall::julia_call(fullname, f, x))
        }
        JuliaCall::julia_assign("_chunk_size", as.integer(chunk_size))
        chunk <- JuliaCall::julia_eval("ForwardDiff.Chunk{_chunk_size}()")
        JuliaCall::julia_call(fullname, f, x, chunk)
    }

    config
}

#' @rdname ForwardDiff
#' @export
forward_grad_config <- forward_config("GradientConfig")

#' @rdname ForwardDiff
#' @export
forward_jacobian_config <- forward_config("JacobianConfig")

#' @rdname ForwardDiff
#' @export
forward_hessian_config <- forward_config("HessianConfig")

######### ForwardDiff

forward_diff <- function(name, config_method){
    fullname <- paste0("ForwardDiff.", name)
    fullmutatename <- paste0(fullname, "!")
    force(config_method)

    diff <- function(f, x, cfg = NULL, check = TRUE, diffresult = NULL, debug = TRUE){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        ## deal with diffresult first

        if (!is.null(diffresult)) {
            if (!check) {
                check <- JuliaCall::julia_eval("Val{false}()")

                if (is.null(cfg)) cfg <- config_method(f, x)

                return(.AD[[fullmutatename]](diffresult, f, x, cfg, check, debug = debug))
            }

            if (is.null(cfg)) {
                return(.AD[[fullmutatename]](diffresult, f, x, debug = debug))
            }

            return(.AD[[fullmutatename]](diffresult, f, x, cfg, debug = debug))
        }

        if (!check) {
            check <- JuliaCall::julia_eval("Val{false}()")

            if (is.null(cfg)) cfg <- config_method(f, x)

            return(.AD[[fullname]](f, x, cfg, check, debug = debug))
        }

        if (is.null(cfg)) {
            return(.AD[[fullname]](f, x, debug = debug))
        }

        .AD[[fullname]](f, x, cfg, debug = debug)
    }

    diff
}

#' @rdname ForwardDiff
#' @export
forward_grad <- forward_diff("gradient", forward_grad_config)

#' @rdname ForwardDiff
#' @export
forward_jacobian <- forward_diff("jacobian", forward_jacobian_config)

#' @rdname ForwardDiff
#' @export
forward_hessian <- forward_diff("hessian", forward_hessian_config)
