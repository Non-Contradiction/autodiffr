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

#' @rdname ReverseDiff
#' @export
reverse.grad <- function(f_or_tape, input, cfg = NULL){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    is_list <- is.list(input)

    if (is_list) {
        f_or_tape <- positionize(f_or_tape, input)
        ns <- names(input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    if (is_tape(f_or_tape)) {
        r <- JuliaCall::julia_call("ReverseDiff.gradient!", f_or_tape, input)
    }
    else {
        if (is.null(cfg)) {
            r <- JuliaCall::julia_call("ReverseDiff.gradient", f_or_tape, input)
        }
        else {
            r <- JuliaCall::julia_call("ReverseDiff.gradient", f_or_tape, input, cfg)
        }
    }

    if (is_list) {
        names(r) <- ns
    }

    r
}

#' @rdname ReverseDiff
#' @export
reverse.jacobian <- function(f_or_tape, input, cfg = NULL){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    is_list <- is.list(input)

    if (is_list) {
        f_or_tape <- positionize(f_or_tape, input)
        ns <- names(input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    if (is_tape(f_or_tape)) {
        r <- JuliaCall::julia_call("ReverseDiff.jacobian!", f_or_tape, input)
    }
    else {
        if (is.null(cfg)) {
            r <- JuliaCall::julia_call("ReverseDiff.jacobian", f_or_tape, input)
        }
        else {
            r <- JuliaCall::julia_call("ReverseDiff.jacobian", f_or_tape, input, cfg)
        }
    }

    if (is_list) {
        names(r) <- ns
    }

    r
}

#' @rdname ReverseDiff
#' @export
reverse.hessian <- function(f_or_tape, input, cfg = NULL){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    is_list <- is.list(input)

    if (is_list) {
        f_or_tape <- positionize(f_or_tape, input)
        ns <- names(input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    if (is_tape(f_or_tape)) {
        r <- JuliaCall::julia_call("ReverseDiff.hessian!", f_or_tape, input)
    }
    else {
        if (is.null(cfg)) {
            r <- JuliaCall::julia_call("ReverseDiff.hessian", f_or_tape, input)
        }
        else {
            r <- JuliaCall::julia_call("ReverseDiff.hessian", f_or_tape, input, cfg)
        }
    }

    if (is_list) {
        names(r) <- ns
    }

    r
}

####### Constructing Config objects for ReverseDiff

#' @rdname ReverseDiff
#' @export
reverse.grad.config <- function(input){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.GradientConfig", input)
}

#' @rdname ReverseDiff
#' @export
reverse.jacobian.config <- function(input){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.JacobianConfig", input)
}

#' @rdname ReverseDiff
#' @export
reverse.hessian.config <- function(input){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.HessianConfig", input)
}

#' @rdname ReverseDiff
#' @export
reverse.grad.tape <- function(f, input, cfg = reverse.grad.config(input)){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        f <- positionize(f, input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.GradientTape", f, input, cfg)
}

#' @rdname ReverseDiff
#' @export
reverse.jacobian.tape <- function(f, input, cfg = reverse.jacobian.config(input)){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        f <- positionize(f, input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.JacobianTape", f, input, cfg)
}

#' @rdname ReverseDiff
#' @export
reverse.hessian.tape <- function(f, input, cfg = reverse.hessian.config(input)){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (is.list(input)) {
        f <- positionize(f, input)
        names(input) <- NULL
        class(input) <- "JuliaTuple"
    }

    JuliaCall::julia_call("ReverseDiff.HessianTape", f, input, cfg)
}

#' @rdname ReverseDiff
#' @export
reverse.compile <- function(tape){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    JuliaCall::julia_call("ReverseDiff.compile", tape)
}

is_tape <- function(tape) {
    JuliaCall::julia_command("function is_tape(x) issubtype(typeof(x), ReverseDiff.AbstractTape) end")
    JuliaCall::julia_call("is_tape", tape)
}
