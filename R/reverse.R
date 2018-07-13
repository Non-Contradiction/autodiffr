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
#' @param tape the object to record the target function's execution trace used by
#'   reverse mode automatic differentiation.
#'   In many cases, pre-recording and pre-compiling a reusable tape for a given function and
#'   differentiation operation can improve the performance of reverse mode automatic differentiation.
#'   Note that pre-recording a tape can only capture the the execution trace of the target function
#'   with the given input values.
#'   In other words, the tape cannot any re-enact branching behavior that depends on the input values.
#'   If the target functions contain control flow based on the input values, be careful or not to
#'   use tape-related APIs.
#' @param f_or_tape the target function `f` or the tape recording execution trace of `f`.
#' @param input the point where you take the gradient, jacobian and hessian.
#'   Note that it should be a a vector of length greater than 1.
#'   If you want to calulate the derivative of a function, you can considering using `forward.deriv`.
#' @param cfg Config objects which contains the preallocated tape and work buffers
#'   used by reverse mode automatic differentiation.
#'   `ReverseDiff`'s API methods will allocate the Config object automatically by default,
#'   but you can preallocate them yourself and reuse them for subsequent calls to reduce memory usage.
#' @param diffresult Optional DiffResult object to store the derivative information.
#' @param debug Whether to use the wrapper functions under debug mode.
#'   With the debug mode, users can have more informative error messages.
#'   Without the debug mode, the wrapper functions will be more performant.
#'
#' @return `reverse.grad`, `reverse.jacobian` and `reverse.hessian` return
#'   the gradient, jacobian and hessian of `f` or `tape` correspondingly evaluated at `input`.
#'   `reverse.grad.config`, `reverse.jacobian.config` and `reverse.hessian.config`
#'   return Config instances containing the preallocated tape and work buffers used by
#'   reverse mode automatic differentiation.
#'   `reverse.grad.tape`, `reverse.jacobian.tape` and `reverse.hessian.tape`
#'   return Tape instances containing the the execution trace of the target function
#'   with the given input values.
#' @md
#'
#' @name ReverseDiff
NULL

reverse_diff <- function(name){
    fullname <- paste0("ReverseDiff.", name)
    fullmutatename <- paste0("ReverseDiff.", name, "!")

    diff <- function(f_or_tape, input, cfg = NULL, diffresult = NULL, debug = TRUE){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        is_list <- is.list(input)

        if (is_list) {
            ns <- names(input)
            names(input) <- NULL
            class(input) <- "JuliaTuple"

            if (!is.null(diffresult)) {
                warning("Doesn't support DiffResults API with multi-input function currently.")
                diffresult <- NULL
            }
        }

        ## deal with diffresult first
        if (!is.null(diffresult)) {
            if (!is.null(cfg) && !is_tape(f_or_tape))
                return(.AD[[fullmutatename]](diffresult, f_or_tape, input, cfg, debug = debug))
            return(.AD[[fullmutatename]](diffresult, f_or_tape, input, debug = debug))
        }

        if (is_tape(f_or_tape)) {
            r <- .AD[[fullmutatename]](f_or_tape, input, debug = debug)
        }
        else {
            if (is_list) {
                f_or_tape <- positionize(f_or_tape, ns)
            }

            if (is.null(cfg)) {
                r <- .AD[[fullname]](f_or_tape, input, debug = debug)
            }
            else {
                r <- .AD[[fullname]](f_or_tape, input, cfg, debug = debug)
            }
        }

        if (is_list) {
            names(r) <- ns
            class(r) <- NULL
        }

        r
    }

    diff

}

#' @rdname ReverseDiff
#' @export
reverse.grad <- reverse_diff("gradient")

#' @rdname ReverseDiff
#' @export
reverse.jacobian <- reverse_diff("jacobian")

#' @rdname ReverseDiff
#' @export
reverse.hessian <- reverse_diff("hessian")

####### Constructing Config objects for ReverseDiff

reverse_config <- function(name){
    fullname <- paste0("ReverseDiff.", name)

    config <- function(input, diffresult = NULL){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        if (is.list(input)) {
            names(input) <- NULL
            class(input) <- "JuliaTuple"

            if (!is.null(diffresult)) {
                warning("Doesn't support DiffResults API with multi-input function currently.")
                diffresult <- NULL
            }
        }

        ## deal with diffresult first

        if (!is.null(diffresult) && identical(fullname, "ReverseDiff.HessianConfig")) {
            return(JuliaCall::julia_call(fullname, diffresult, input))
        }

        JuliaCall::julia_call(fullname, input)
    }

    config
}

#' @rdname ReverseDiff
#' @export
reverse.grad.config <- reverse_config("GradientConfig")

#' @rdname ReverseDiff
#' @export
reverse.jacobian.config <- reverse_config("JacobianConfig")

#' @rdname ReverseDiff
#' @export
reverse.hessian.config <- reverse_config("HessianConfig")

####### Constructing Tape objects for ReverseDiff

reverse_tape <- function(name){
    fullname <- paste0("ReverseDiff.", name)

    tape_func <- function(f, input, cfg = NULL){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        if (is.list(input)) {
            f <- positionize(f, names(input))
            names(input) <- NULL
            class(input) <- "JuliaTuple"
        }

        if (is.null(cfg)) {
            return(JuliaCall::julia_call(fullname, f, input))
        }

        r <- JuliaCall::julia_call(fullname, f, input, cfg)
        attr(r, "type") <- "AbstractTape"
        r
    }

    tape_func
}

#' @rdname ReverseDiff
#' @export
reverse.grad.tape <- reverse_tape("GradientTape")

#' @rdname ReverseDiff
#' @export
reverse.jacobian.tape <- reverse_tape("JacobianTape")

#' @rdname ReverseDiff
#' @export
reverse.hessian.tape <- reverse_tape("HessianTape")

#' @rdname ReverseDiff
#' @export
reverse.compile <- function(tape){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    r <- JuliaCall::julia_call("ReverseDiff.compile", tape)
    attr(r, "type") <- "AbstractTape"
    r
}

is_tape <- function(tape) {
    if (identical("AbstractTape", attr(tape, "type"))) return(TRUE)
    JuliaCall::julia_call("is_tape", tape)
}
