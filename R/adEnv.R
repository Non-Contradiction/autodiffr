JcolSums <- function(...) cSums(...)
JcolMeans <- function(...) cMeans(...)
JrowSums <- function(...) rSums(...)
JrowMeans <- function(...) rMeans(...)
Jmatmult <- function(...) `%m%`(...)
Jmapply <- function(...) map(...)

Jcrossprod <- function(x, y = NULL){
    if (is.null(y)) {
        return(t(x) %m% x)
    }
    t(x) %m% y
}

Jtcrossprod <- function(x, y = NULL){
    if (is.null(y)) {
        return(x %m% t(x))
    }
    x %m% t(y)
}

Jdiag <- function(x = 1, nrow, ncol, names = TRUE){
    # if (!inherits(x, "JuliaObject")) return(diag(x))

    if (is.vector(x)) {
        return(diagm(x))
    }
    diag(x)
}

Jsapply <- function(X, FUN){
    # if (!inherits(X, "JuliaObject")) return(sapply(X, FUN))

    map(FUN, X)
}

Jmatrix <- function(data, nrow = 1, ncol = 1){
    # if (!inherits(data, "JuliaObject")) return(matrix(data, nrow, ncol))

    if (missing(ncol)) {
        if (!missing(nrow)) {
            ncol <- if (length(data) < nrow) 1 else length(data) / nrow}
    }
    if (missing(nrow)) nrow <- length(data) / ncol

    array(data, dim = c(nrow, ncol))
}

Japply <- function(X, MARGIN, FUN, ...){
    # if (!inherits(X, "JuliaObject")) return(apply(X, MARGIN, FUN, ...))

    if (MARGIN == 1) {
        as.vector(JuliaCall::julia_call("mapslices", FUN, X, 2L))
    }
    else {
        if (MARGIN == 2) JuliaCall::julia_call("mapslices", FUN, X, 1L)
        else stop("autodiffr doesn't know how to deal with apply with MARGIN != 1,2 currently.")
    }
}

original_assign <- .Primitive("[<-")

Jassign <- function(x, i, j, ..., value){
    # if (inherits(value, "JuliaObject")) {
    #     x <- JuliaCall::JuliaObject(x)
    # }
    x <- JuliaCall::JuliaObject(x)

    if (missing(j)) original_assign(x, i, value = value)
    else original_assign(x, i, j, ..., value = value)
}

decorate <- function(parentEnv){
    newEnv <- new.env(parent = parentEnv)

    newEnv$colSums <- JcolSums
    newEnv$colMeans <- JcolMeans
    newEnv$rowSums <- JrowSums
    newEnv$rowMeans <- JrowMeans
    newEnv$`%*%` <- Jmatmult

    newEnv$crossprod <- Jcrossprod
    newEnv$tcrossprod <- Jtcrossprod

    newEnv$diag <- Jdiag

    newEnv$mapply <- Jmapply

    newEnv$sapply <- Jsapply

    newEnv$matrix <- Jmatrix

    newEnv$apply <- Japply

    newEnv[["[<-"]] <- Jassign

    newEnv
}

#' Create Variant Functions (more) Suitable for AD.
#'
#'  `ad_variant` is a helper function which creates variant functions more suitable for automatic differentiation.
#'
#' @param f the original function.
#' @param checkArgs if given, then the original function and the new version will be checked on the argument(s).
#'   If it's a list, then it will be regarded as a list of arguments; otherwise it will be regarded as the only argument.
#' @param silent whether to silence the message printed by `ad_variant`.
#'
#' @md
#' @export
ad_variant <- function(f, checkArgs = NULL, silent = FALSE){
    if (!silent) message("ad_variant will try to wrap your function in a special environment,
                         which redefines some R functions to be compatible with autodiffr.
                         Please use it with care.")

    newEnv <- decorate(environment(f))
    orig_f <- f
    environment(f) <- newEnv

    if (!is.null(checkArgs)) {
        if (is.list(checkArgs)) {
            orig_result <- as.vector(do.call(orig_f, checkArgs))
            new_result <- as.vector(do.call(f, checkArgs))
        }
        else {
            orig_result <- as.vector(orig_f(checkArgs))

            if (!silent) traceAll()

            new_result <- as.vector(f(checkArgs))

            detraceAll()
        }
        if (!all.equal(orig_result, new_result, tolerance = 1e-6)) {
            stop("New function doesn't give same result with original function.
                 Please report an issue to autodiffr with the function and argument(s) at
                 https://github.com/Non-Contradiction/autodiffr")
        }
        else {
            if (!silent) message("New function gives the same result as the original function at the given arguments.
                                 Still need to use it with care.")
        }
    }

    f
}

traceOne <- function(func, func_names = NULL, msg = NULL){
    env <- parent.env(.AD)

    get(func, env)

    if (!is.null(func_names)) {
        msg <- paste0(func_names$old, " has been replaced with ", func_names$new, ".")
    }

    force(msg)
    msg_func <- function() message(msg)

    trace(func, msg_func, print = FALSE,
          where = env,
          exit = function() untrace(func, where = env))
}

untraceOne <- function(func){
    get(func, parent.env(.AD))

    untrace(func, where = parent.env(.AD))
}

traceAll <- function(){
    traceOne("JcolSums", list(old = "colSums", new = "cSums"))
    traceOne("JcolMeans", list(old = "colMeans", new = "cMeans"))
    traceOne("JrowSums", list(old = "rowSums", new = "rSums"))
    traceOne("JrowMeans", list(old = "rowMeans", new = "rMeans"))
    traceOne("Jmatmult", list(old = "Matrix multiplication %*%", new = "%m%"))

    traceOne("Jcrossprod", msg = "crossprod has been replaced by t(x) %m% y.")
    traceOne("Jtcrossprod", msg = "tcrossprod has been replaced by x %m% t(y).")

    traceOne("Jdiag", msg = "Use of diag on vector to create a diagonal matrix has been replaced by diagm.")

    traceOne("Jmapply", msg = "mapply has been replaced by map.")

    traceOne("Jsapply", msg = "Use of sapply has been replaced by map.")

    traceOne("Jmatrix", msg = "matrix has been replaced by array.")

    traceOne("Japply", msg = "apply has been replaced to take care with arrays in Julia.")

    traceOne("Jassign", msg = "assignment in arrays has been replaced to take care with arrays in Julia.")
}

detraceAll <- function(){
    untraceOne("JcolSums")
    untraceOne("JcolMeans")
    untraceOne("JrowSums")
    untraceOne("JrowMeans")
    untraceOne("Jmatmult")

    untraceOne("Jcrossprod")
    untraceOne("Jtcrossprod")

    untraceOne("Jdiag")

    untraceOne("Jsapply")
    untraceOne("Jmapply")

    untraceOne("Jmatrix")

    untraceOne("Japply")

    untraceOne("Jassign")
}
