.AD <- new.env(parent = emptyenv())

#' Do initial setup for package autodiffr.
#'
#' \code{ad_setup} does the initial setup for package autodiffr.
#'
#' @param ... arguments passed to \code{JuliaCall::julia_setup}.
#'
#' @examples
#' \dontrun{
#' ad_setup()
#' }
#'
#' @export
ad_setup <- function(...) {
    if (!isTRUE(.AD$inited)) {
        .AD$julia <- JuliaCall::julia_setup(...)
        .AD$julia$install_package_if_needed("ForwardDiff")
        .AD$julia$install_package_if_needed("ReverseDiff")
        .AD$julia$library("ForwardDiff")
        .AD$julia$library("ReverseDiff")

        JuliaCall::julia_command("for R in (:Bool, :BigFloat)
                                    @eval begin
                                        Base.promote_rule(::Type{$R}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type($R, V),N}
                                        Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{$R}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, $R),N}
                                    end
                                 end")

        .AD$inited <- TRUE
    }
}

#' Calculate the gradient of a function.
#'
#' \code{grad} calculates the gradient of a function.
#'
#' @param func the function you want to caculate the gradient,
#'   it should be a function with a scalar result.
#' @param x the point where the gradient is calculated.
#'   If not given (or NULL), return will be the gradient function.
#'
#' @export
grad <- function(func, x = NULL){
    ## ad_setup() is not necessary,
    ## unless you want to pass some arguments to it.
    ad_setup()

    if (!is.null(x)) {
        JuliaCall::julia_call("ForwardDiff.gradient", func, x)
    }
    else {
        force(func)
        function(x) JuliaCall::julia_call("ForwardDiff.gradient", func, x)
    }
}



