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

Jmatrix <- function(data, nrow = 1, ncol = 1){
    if (missing(ncol)) {
        if (!missing(nrow)) {
            ncol <- if (length(data) < nrow) 1 else length(data) / nrow}
    }
    if (missing(nrow)) nrow <- length(data) / ncol

    array(data, dim = c(nrow, ncol))
}

Japply <- function(X, MARGIN, FUN){
    if (MARGIN == 1) {

    }
}

original_assign <- .Primitive("[<-")

Jassign <- function(x, i, j, ..., value){
    if (inherits(value, "JuliaObject")) {
        x <- JuliaCall::JuliaObject(x)
    }
    if (missing(j)) original_assign(x, i, value = value)
    else original_assign(x, i, j, ..., value = value)
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
#' @md
#' @export
ad_variant <- function(f){
    if (is.null(.AD$env)) {
        .AD$env <- decorate(environment(f))
    }
    environment(f) <- .AD$env
    f
}
