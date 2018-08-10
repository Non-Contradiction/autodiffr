.AD$trace_list <- list("colSums", "colMeans", "rowSums", "rowMeans",
                       "%*%", "crossprod", "tcrossprod", "diag",
                       "mapply", "sapply", "matrix", "apply", "[<-")

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
    if (!silent) message("ad_variant will try to wrap your function in a special environment, which redefines some R functions to be compatible with autodiffr. Please use it with care.")

    newEnv <- decorate(environment(f))
    orig_f <- f
    environment(f) <- newEnv

    if (!is.null(checkArgs)) {
        if (!silent) message("Start checking...")

        if (!silent) traceAll(newEnv)

        if (is.list(checkArgs)) {
            orig_result <- as.vector(do.call(orig_f, checkArgs))
            new_result <- as.vector(do.call(f, checkArgs))
        }
        else {
            orig_result <- as.vector(orig_f(checkArgs))
            new_result <- as.vector(f(checkArgs))
        }

        detraceAll(newEnv)

        if (!all.equal(orig_result, new_result, tolerance = 1e-6)) {
            stop("New function doesn't give same result with original function. Please report an issue to autodiffr with the function and argument(s) at https://github.com/Non-Contradiction/autodiffr")
        }
        else {
            if (!silent) message("New function gives the same result as the original function at the given arguments. Still need to use it with care.")
        }

        if (!silent) message("Checking finished...")
    }

    f
}

traceOne <- function(func, env, old = func, new = NULL, msg = NULL){
    get(func, env, inherits = FALSE)

    if (is.null(msg)) {
        msg <- paste0(old, " has been replaced with ", new, ".")
    }

    tracer <- call("message", msg)

    suppressMessages(
    trace(func, tracer, print = FALSE,
          where = env,
          exit = function() suppressMessages(untrace(func, where = env)))
    )
}

untraceOne <- function(func, env){
    get(func, env, inherits = FALSE)

    suppressMessages(untrace(func, where = env))
}

traceAll <- function(env){
    traceOne("colSums", env, new = "cSums")
    traceOne("colMeans", env, new = "cMeans")
    traceOne("rowSums", env, new = "rSums")
    traceOne("rowMeans", env, new = "rMeans")
    traceOne("%*%", env, old = "Matrix multiplication %*%", new = "%m%")

    traceOne("crossprod", env, new = "t(x) %m% y")
    traceOne("tcrossprod", env, new = "x %m% t(y)")

    traceOne("diag", env, msg = "Use of diag on vector to create a diagonal matrix has been replaced by diagm.")

    traceOne("mapply", env, new = "map")

    traceOne("sapply", env, msg = "Use of sapply has been replaced by map.")

    traceOne("matrix", env, new = "array")

    traceOne("apply", env, msg = "apply has been replaced to be compatible with arrays in Julia.")

    traceOne("[<-", env, msg = "assignment in arrays has been replaced to be compatible with arrays in Julia.")
}

detraceAll <- function(env){
    for (f in .AD$trace_list) {
        untraceOne(f, env)
    }
}
