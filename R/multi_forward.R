singleDs <- list(grad = forward.grad,
                 jacobian = forward.jacobian,
                 hessian = forward.hessian)

singleCfgs <- list(grad = forward.grad.config,
                   jacobian = forward.jacobian.config,
                   hessian = forward.hessian.config)

## for list x, need to have a function to construct sub-functions

subfunc <- function(func, x, i){
    force(func)
    force(x)
    force(i)
    subF <- function(input){
        newx <- x
        newx[[i]] <- input
        do.call(func, newx)
    }
    subF
}

multi.forward.D <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    Cfg <- multi.forward.config(fname)
    singleD <- singleDs[[fname]]

    f <- function(func, x, cfg = Cfg(func, x)){
        if (!is.list(x)) {
            return(singleD(func, x, cfg))
        }

        funcs <- lapply(1:length(x), subfunc, func = func, x = x)

        results <- lapply(1:length(x), function(i) singleD(funcs[[i]], x[[i]], cfg[[i]]))

        names(results) <- names(x)

        results
    }

    f
}

multi.forward.config <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    singleCfg <- singleCfgs[[fname]]

    f <- function(func, x, chunk_size = NULL){
        if (!is.list(x)) {
            return(singleCfg(func, x, chunk_size))
        }

        funcs <- lapply(1:length(x), subfunc, func = func, x = x)

        results <- lapply(1:length(x), function(i) singleCfg(funcs[[i]], x[[i]], chunk_size))

        names(results) <- names(x)

        results
    }

    f
}

multi.forward.grad <- multi.forward.D("grad")
multi.forward.jacobian <- multi.forward.D("jacobian")
multi.forward.hessian <- multi.forward.D("hessian")

multi.forward.grad.config <- multi.forward.config("grad")
multi.forward.jacobian.config <- multi.forward.config("jacobian")
multi.forward.hessian.config <- multi.forward.config("hessian")