% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zinterface.R
\name{autodiff}
\alias{autodiff}
\alias{ad_jacobian}
\alias{ad_hessian}
\alias{ad_grad}
\alias{ad_deriv}
\title{Calculate Gradient, Jacobian and Hessian using Automatic Differentiation.}
\usage{
ad_jacobian(func, x, ..., mode = c("reverse", "forward"), debug = TRUE)

ad_hessian(func, x, ..., mode = c("reverse", "forward"), debug = TRUE)

ad_grad(func, x, ..., mode = c("reverse", "forward"), debug = TRUE)

ad_deriv(func, x, ..., mode = c("reverse", "forward"), debug = TRUE)
}
\arguments{
\item{func}{the target function to calculate gradient, jacobian or hessian.}

\item{x}{the input(s) where derivative is (are) taken.}

\item{...}{other arguments passed to the target function \code{func}.}

\item{mode}{whether to use forward or reverse mode automatic differentiation.}

\item{debug}{Whether to activate debug mode.
With the debug mode, users can have more informative error messages.
Without the debug mode, the functions will be more performant.}
}
\value{
if \code{x} is given, then return will be derivatives;
if \code{x} is not given, then return will be a function to calculate derivatives.
}
\description{
These functions calculate gradient, jacobian or hessian for the target function.
}
