#' @rdname autodiff
#' @export
jacobian <- createInterface("jacobian")

#' @rdname autodiff
#' @export
hessian <- createInterface("hessian")

#' @rdname autodiff
#' @export
grad <- createInterface("grad")

## currently, deriv don't use the creator
## and we may need to make grad and deriv alias of each other.
