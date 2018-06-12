createInterface <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    if (fname == "grad") {
        D <- list(forward = forward.grad, reverse = reverse.grad)
        Config <- list(forward = forward.grad.config, reverse = reverse.grad.config)
        Tape <- reverse.grad.tape
    }
    if (fname == "jacobian") {
        D <- list(forward = forward.jacobian, reverse = reverse.jacobian)
        Config <- list(forward = forward.jacobian.config, reverse = reverse.jacobian.config)
        Tape <- reverse.jacobian.tape
    }
    if (fname == "hessian") {
        D <- list(forward = forward.hessian, reverse = reverse.hessian)
        Config <- list(forward = forward.hessian.config, reverse = reverse.hessian.config)
        Tape <- reverse.hessian.tape
    }

    f <- function(func, x = NULL, mode = c("forward", "reverse"),
                  xsize = x, chunk_size = NULL,
                  use_tape = FALSE, compiled = FALSE,
                  ...){
        ## construction of target function
        force(func)
        force(...)

        target <- function(x){
            if (is.list(x)) {
                do.call(func, c(x, ...))
            }
            ## x is not list
            func(x, ...)
        }

        mode <- match.arg(mode)
        if (!is.null(x)) {
            ## when x is given, return result directly,
            ## and no optimization is possible
            return(D[[mode]](target, x))
        }
        ## when x is null, need to return a function

        if (is.null(xsize)) {
            ## since xsize is not given, no optimization will be carried on
            return(function(x) D[[mode]](target, x))
        }

        ## xsize is given, further optimization is possible
        if (mode == "forward") {
            ## when mode is forward,
            ## the only possible optimization is construction of Config objects
            config <- Config$forward(target, xsize, chunk_size = chunk_size)
            return(function(x) D[[mode]](target, x, cfg = config))
        }

        if (isFALSE(use_tape)) {
            ## If not use_tape,
            ## the only possible optimization in rev mode is also construction of Config objects
            config <- Config$reverse(xsize)
            return(function(x) D[[mode]](target, x, cfg = config))
        }

        ## use_tape,
        tape <- Tape(target, xsize)
        if (isTRUE(compiled)) {
            tape <- reverse.compile(tape)
        }
        return(function(x) D[[mode]](tape, x))
    }

    f
}
