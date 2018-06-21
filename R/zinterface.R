#' Calculate Gradient, Jacobian and Hessian using Automatic Differentiation.
#'
#' These functions calculate gradient, jacobian or hessian for the target function.
#'
#' @param func the target function to calculate gradient, jacobian or hessian.
#' @param x the input(s) where derivative is (are) taken.
#' @param mode whether to use forward or reverse mode automatic differentiation.
#' @param xsize If `x` is not given and `xsize` is given, then the returning functiopn
#'   will be optimized w.r.t. the input(s) of the same size with `x`.
#'   Note that if `xsize` is not given, then all the following parameters will be ignored.
#' @param chunk_size the chunk size to use in forward mode automatic differentiation.
#'   Note that this parameter is only effective when `mode = "forward"`.
#' @param use_tape whether or not to use tape for reverse mode automatic differentiation.
#'   Note that although `use_tape` can greatly improve the performance sometime,
#'   it can only calculate the derivatives w.r.t a certain branching,
#'   so it may not give the correct result for functions containing things like `if`.
#'   And this parameter is only effective when `mode = "reverse"`.
#' @param compiled whether or not to use compiled tape for reverse mode automatic differentiation.
#'   Note that tape compiling can take a lot of time and
#'   this parameter is only effective when `use_tape = TRUE`.
#' @param ... other arguments passed to the target function `func`.
#'
#' @return if `x` is given, then return will be derivatives;
#'   if `x` is not given, then return will be a function to calculate derivatives.
#'
#' @md
#'
#' @name autodiff
NULL

createInterface <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    if (fname == "grad") {
        D <- list(forward = multi.forward.grad, reverse = reverse.grad)
        Config <- list(forward = multi.forward.grad.config, reverse = reverse.grad.config)
        Tape <- reverse.grad.tape
    }
    if (fname == "jacobian") {
        D <- list(forward = multi.forward.jacobian, reverse = reverse.jacobian)
        Config <- list(forward = multi.forward.jacobian.config, reverse = reverse.jacobian.config)
        Tape <- reverse.jacobian.tape
    }
    if (fname == "hessian") {
        D <- list(forward = multi.forward.hessian, reverse = reverse.hessian)
        Config <- list(forward = multi.forward.hessian.config, reverse = reverse.hessian.config)
        Tape <- reverse.hessian.tape
    }

    f <- function(func, x = NULL, ..., mode = c("reverse", "forward"),
                  xsize = x, chunk_size = NULL,
                  use_tape = FALSE, compiled = FALSE){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        ## construction of target function
        force(func)
        dot <- list(...)

        target0 <- function(...){
            x <- list(...)
            do.call(func, c(x, dot))
        }

        ## in jacobian, the output of the target function should be a vector,
        ## otherwise a scalar

        target <-
            if (fname == "jacobian") {
                function(...) scalar2vector(target0(...))
            }
            else {
                function(...) vector2scalar(target0(...))
            }

        mode <- match.arg(mode)
        if (!is.null(x)) {
            ## when x is given, return result directly,
            ## and no optimization is possible
            return(D[[mode]](target, scalar2vector(x)))
        }
        ## when x is null, need to return a function

        if (is.null(xsize)) {
            ## since xsize is not given, no optimization will be carried on
            return(function(x) D[[mode]](target, scalar2vector(x)))
        }

        ## xsize is given, further optimization is possible
        if (mode == "forward") {
            ## when mode is forward,
            ## the only possible optimization is construction of Config objects

            ## note that the chunk size cannot be greater than length(x)
            if (!is.null(chunk_size)) {
                if (chunk_size > alength(xsize)) {
                    warning("chunk size cannot be greater than the length of input vector(s),
                            automatically reduce chunk size.")
                    chunk_size <- alength(xsize)
                }
            }

            config <- Config$forward(target, scalar2vector(xsize), chunk_size = chunk_size)
            return(function(x) D$forward(target, scalar2vector(x), cfg = config))
        }

        if (isFALSE(use_tape)) {
            ## If not use_tape,
            ## the only possible optimization in rev mode is also construction of Config objects
            config <- Config$reverse(scalar2vector(xsize))
            return(function(x) D$reverse(target, scalar2vector(x), cfg = config))
        }

        ## use_tape,
        tape <- Tape(target, scalar2vector(xsize))
        if (isTRUE(compiled)) {
            tape <- reverse.compile(tape)
        }
        return(function(x) D$reverse(tape, scalar2vector(x)))
    }

    f
}

#' @rdname autodiff
#' @export
jacobian <- createInterface("jacobian")

#' @rdname autodiff
#' @export
hessian <- createInterface("hessian")

#' @rdname autodiff
#' @export
grad <- createInterface("grad")

#' @rdname autodiff
#' @export
deriv <- grad

