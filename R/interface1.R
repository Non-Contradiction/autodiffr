#' @rdname autodiff
#' @export
jacobian <- createInterface("jacobian")

#' @rdname autodiff
#' @export
hessian <- createInterface("hessian")

## currently, gradient and derivative don't use the creator
## because we may need to make them alias of each other.
