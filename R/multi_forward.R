singleDs <- list(grad = forward_grad,
                 jacobian = forward_jacobian,
                 hessian = forward_hessian)

singleCfgs <- list(grad = forward_grad_config,
                   jacobian = forward_jacobian_config,
                   hessian = forward_hessian_config)

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

correspond_null <- function(x){
    if (is.list(x)) return(replicate(length(x), NULL))
    NULL
}

multi_forward_D <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    singleD <- singleDs[[fname]]

    f <- function(func, x, cfg = correspond_null(x), diffresult = NULL, debug = TRUE){
        if (!is.list(x)) {
            return(singleD(func, x, cfg, diffresult = diffresult, debug = debug))
        }

        # deal with diffresult first

        if (!is.null(diffresult)) {
            warning("Doesn't support DiffResults API with multi-input function currently.")
            diffresult <- NULL
        }

        funcs <- lapply(1:length(x), subfunc, func = func, x = x)

        results <- lapply(1:length(x), function(i) singleD(funcs[[i]], x[[i]], cfg[[i]], debug = debug))

        names(results) <- names(x)

        results
    }

    f
}

multi_forward_config <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    singleCfg <- singleCfgs[[fname]]

    f <- function(func, x, chunk_size = NULL, diffresult = NULL){
        if (!is.list(x)) {
            return(singleCfg(func, x, chunk_size, diffresult = diffresult))
        }

        ## deal with diffresult first

        if (!is.null(diffresult)) {
            warning("Doesn't support DiffResults API with multi-input function currently.")
            diffresult <- NULL
        }

        funcs <- lapply(1:length(x), subfunc, func = func, x = x)

        results <- lapply(1:length(x), function(i) singleCfg(funcs[[i]], x[[i]], chunk_size))

        names(results) <- names(x)

        results
    }

    f
}

multi_forward_grad <- multi_forward_D("grad")
multi_forward_jacobian <- multi_forward_D("jacobian")
multi_forward_hessian <- multi_forward_D("hessian")

multi_forward_grad_config <- multi_forward_config("grad")
multi_forward_jacobian_config <- multi_forward_config("jacobian")
multi_forward_hessian_config <- multi_forward_config("hessian")
