% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adEnv.R
\name{ad_variant}
\alias{ad_variant}
\title{Create Variant Functions (more) Suitable for AD.}
\usage{
ad_variant(f, checkArgs = NULL, silent = FALSE)
}
\arguments{
\item{f}{the original function.}

\item{checkArgs}{if given, then the original function and the new version will be checked on the argument(s).
If it's a list, then it will be regarded as a list of arguments; otherwise it will be regarded as the only argument.}

\item{silent}{whether to silence the message printed by \code{ad_variant}.}
}
\description{
\code{ad_variant} is a helper function which creates variant functions more suitable for automatic differentiation.
}
