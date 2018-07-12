#' Calculate Gradient, Jacobian and Hessian using Automatic Differentiation.
#'
#' These functions calculate gradient, jacobian or hessian for the target function.
#'
#' @param func the target function to calculate gradient, jacobian or hessian.
#' @param x the input(s) where derivative is (are) taken.
#' @param mode whether to use forward or reverse mode automatic differentiation.
#' @param ... other arguments passed to the target function `func`.
#'
#' @return if `x` is given, then return will be derivatives;
#'   if `x` is not given, then return will be a function to calculate derivatives.
#'
#' @md
#'
#' @name autodiff
NULL

createInterface <- function(fname = c("grad", "jacobian", "hessian")){
    fname <- match.arg(fname)
    if (fname == "grad") {
        D <- list(forward = multi.forward.grad, reverse = reverse.grad)
    }
    if (fname == "jacobian") {
        D <- list(forward = multi.forward.jacobian, reverse = reverse.jacobian)
    }
    if (fname == "hessian") {
        D <- list(forward = multi.forward.hessian, reverse = reverse.hessian)
    }

    f <- function(func, x, ..., mode = c("reverse", "forward")){
        ## ad_setup() is not necessary,
        ## unless you want to pass some arguments to it.
        ad_setup()

        ## construction of target function
        force(func)
        dot <- list(...)

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

        D[[mode]](target, scalar2vector(x)))
    }

    f
}

#' @rdname autodiff
#' @export
jacobian <- createInterface("jacobian")

#' @rdname autodiff
#' @export
hessian <- createInterface("hessian")

#' @rdname autodiff
#' @export
grad <- createInterface("grad")

#' @rdname autodiff
#' @export
deriv <- grad

