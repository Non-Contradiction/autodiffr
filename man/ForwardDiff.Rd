% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/forward.R
\name{ForwardDiff}
\alias{ForwardDiff}
\alias{forward_deriv}
\alias{forward_grad_config}
\alias{forward_jacobian_config}
\alias{forward_hessian_config}
\alias{forward_grad}
\alias{forward_jacobian}
\alias{forward_hessian}
\title{Wrapper functions for API of \code{ForwardDiff.jl}.}
\usage{
forward_deriv(f, x)

forward_grad_config(f, x, chunk_size = NULL, diffresult = NULL)

forward_jacobian_config(f, x, chunk_size = NULL, diffresult = NULL)

forward_hessian_config(f, x, chunk_size = NULL, diffresult = NULL)

forward_grad(f, x, cfg = NULL, check = TRUE, diffresult = NULL,
  debug = TRUE)

forward_jacobian(f, x, cfg = NULL, check = TRUE, diffresult = NULL,
  debug = TRUE)

forward_hessian(f, x, cfg = NULL, check = TRUE, diffresult = NULL,
  debug = TRUE)
}
\arguments{
\item{f}{the function you want to calulate the derivative, gradient and etc.
Note that \code{f(x)} should be a scalar for \code{grad} and \code{hessian},
a vector of length greater than 1 for \code{jacobian},
and could be either a scalar or a vector for \code{deriv}.}

\item{x}{the point where you take the derivative, gradient and etc.
Note that it should be a scalar for \code{deriv} and a vector of length greater than 1 for
\code{grad}, \code{jacobian} and \code{hessian}.}

\item{chunk_size}{the size of the chunk to construct the Config objects for \code{ForwardDiff}.
It may be explicitly provided, or omitted,
in which case \code{ForwardDiff} will automatically select a chunk size for you.
However, it is highly recommended to specify the chunk size manually when possible.
See
\url{http://www.juliadiff.org/ForwardDiff.jl/stable/user/advanced.html#Configuring-Chunk-Size-1}
for more details.}

\item{diffresult}{Optional DiffResult object to store the derivative information.}

\item{cfg}{Config object which have
information useful to do automatic differentiation for \code{f}.
It allows the user to easily feed several different parameters to \code{ForwardDiff}'s API,
such as chunk size, work buffers, and perturbation seed configurations.
\code{ForwardDiff}'s basic API methods will allocate these types automatically by default,
but you can drastically reduce memory usage if you preallocate them yourself.}

\item{check}{whether to allow tag checking.
Set check to \code{FALSE} to disable tag checking for \code{ForwardDiff}.
This can lead to perturbation confusion, so should be used with care.}

\item{debug}{Whether to use the wrapper functions under debug mode.
With the debug mode, users can have more informative error messages.
Without the debug mode, the wrapper functions will be more performant.}
}
\value{
\code{forward_deriv}, \code{forward_grad}, \code{forward_jacobian} and \code{forward_hessian} return
the derivative, gradient, jacobian and hessian of \code{f} correspondingly evaluated at \code{x}.
\code{forward_grad_config}, \code{forward_jacobian_config} and \code{forward_hessian_config}
return Config instances based on \code{f`` and }x`,
which contain all the work buffers required to carry out the forward mode automatic differentiation.
}
\description{
Wrapper functions for API of \code{ForwardDiff.jl} at
\url{http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html}.
These functions can help you calculate derivative, gradient, jacobian and hessian
for your functions using forward mode automatic differentiation.
For more details, see \url{http://www.juliadiff.org/ForwardDiff.jl/stable/user/api.html}.
}
