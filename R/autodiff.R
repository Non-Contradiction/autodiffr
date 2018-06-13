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

        # JuliaCall::julia_command("for R in (:Bool, :BigFloat)
        #                             @eval begin
        #                                 Base.promote_rule(::Type{$R}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type($R, V),N}
        #                                 Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{$R}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, $R),N}
        #                             end
        #                          end")
        JuliaCall::julia_command("import Base.promote_rule")
        JuliaCall::julia_command("Base.promote_rule(::Type{Bool}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(Bool, V),N}")
        JuliaCall::julia_command("Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{Bool}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, Bool),N}")

        .AD$inited <- TRUE
    }
}
