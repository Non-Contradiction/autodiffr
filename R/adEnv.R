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
    if (is.vector(x)) {
        return(diagm(x))
    }
    diag(x)
}

Jsapply <- function(X, FUN){
    map(FUN, X)
}

decorate <- function(parentEnv){
    newEnv <- new.env(parent = parentEnv)

    newEnv$colSums <- cSums
    newEnv$colMeans <- cMeans
    newEnv$rowSums <- rSums
    newEnv$rowMeans <- rMeans
    newEnv$`%*%` <- `%m%`

    newEnv$crossprod <- Jcrossprod
    newEnv$tcrossprod <- Jtcrossprod

    newEnv$diag <- Jdiag

    newEnv$mapply <- map

    newEnv$sapply <- Jsapply

    newEnv$matrix <- array

    newEnv
}

#' Create Variant Functions (more) Suitable for AD.
#'
#'  `ad.variant` is a helper function which creates variant functions more suitable for automatic differentiation.
#'
#' @param f the original function.
#' @md
ad.variant <- function(f){
    if (is.null(.AD$env)) {
        .AD$env <- decorate(environment(f))
    }
    environment(f) <- .AD$env
    f
}
