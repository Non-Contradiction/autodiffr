#' Create (Optimized) Gradient, Jacobian and Hessian Functions using Automatic Differentiation.
#'
#' These functions give (optimized) gradient, jacobian or hessian functions for the target function.
#'
#' @param func the target function to calculate gradient, jacobian or hessian.
#' @param ... other arguments passed to the target function `func`.
#' @param mode whether to use forward or reverse mode automatic differentiation.
#' @param x If `x` is given, then the returning functiopn
#'   will be optimized w.r.t. the input(s) of the same shape with `x`.
#'   Note that if `x` is not given, then all the following parameters will be ignored.
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
#' @param debug Whether to activate debug mode.
#'   With the debug mode, users can have more informative error messages.
#'   Without the debug mode, functions will be more performant.
#'
#' @return if `x` is not given, the returned function will be a general function to calculate derivatives,
#'  which accepts other arguments to `func` besides `x`;
#'  if `x` is given, the returned function will be an optimized function speciallised for inputs of the same
#'  shape with the given `x`.
#'
#' @md
#'
#' @name autodifffunc
NULL

funcInterface <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    if (fname == "grad") {
        D <- list(forward = multi.forward.grad, reverse = reverse.grad)
        Config <- list(forward = multi.forward.grad.config, reverse = reverse.grad.config)
        Tape <- reverse.grad.tape
        interface <- grad
    }
    if (fname == "jacobian") {
        D <- list(forward = multi.forward.jacobian, reverse = reverse.jacobian)
        Config <- list(forward = multi.forward.jacobian.config, reverse = reverse.jacobian.config)
        Tape <- reverse.jacobian.tape
        interface <- jacobian
    }
    if (fname == "hessian") {
        D <- list(forward = multi.forward.hessian, reverse = reverse.hessian)
        Config <- list(forward = multi.forward.hessian.config, reverse = reverse.hessian.config)
        Tape <- reverse.hessian.tape
        interface <- hessian
    }

    f <- function(func, ..., mode = c("reverse", "forward"),
                  x = NULL, chunk_size = NULL,
                  use_tape = FALSE, compiled = FALSE, debug = TRUE){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        ## construction of target function
        force(func)
        dot <- list(...)

        ## when x is null, need to return an unoptimized function

        if (is.null(x)) {
            return(function(x, ...) do.call(interface, c(list(func, x), list(...), dot, debug = debug)))
        }

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

        ## x is given, further optimization is possible
        if (mode == "forward") {
            ## when mode is forward,
            ## the only possible optimization is construction of Config objects

            ## note that the chunk size cannot be greater than length(x)
            if (!is.null(chunk_size)) {
                if (chunk_size > alength(x)) {
                    warning("chunk size cannot be greater than the length of input vector(s),
                            automatically reduce chunk size.")
                    chunk_size <- alength(x)
                }
            }

            config <- Config$forward(target, scalar2vector(x), chunk_size = chunk_size)
            return(function(x) D$forward(target, scalar2vector(x), cfg = config, debug = debug))
        }

        if (!use_tape) {
            ## If not use_tape,
            ## the only possible optimization in rev mode is also construction of Config objects
            config <- Config$reverse(scalar2vector(x))
            return(function(x) D$reverse(target, scalar2vector(x), cfg = config, debug = debug))
        }

        ## use_tape,
        tape <- Tape(target, scalar2vector(x))
        if (isTRUE(compiled)) {
            tape <- reverse.compile(tape)
        }
        return(function(x) D$reverse(tape, scalar2vector(x), debug = debug))
    }

    f
}

#' @rdname autodifffunc
#' @export
makeJacobianFunc <- funcInterface("jacobian")

#' @rdname autodifffunc
#' @export
makeHessianFunc <- funcInterface("hessian")

#' @rdname autodifffunc
#' @export
makeGradFunc <- funcInterface("grad")

#' @rdname autodifffunc
#' @export
makeDerivFunc <- makeGradFunc
