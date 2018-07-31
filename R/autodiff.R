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
ad_setup <- function(reverse = TRUE, forward = TRUE, ...) {
    if (!isTRUE(.AD$inited)) {
        .AD$julia <- JuliaCall::julia_setup(...)

        .AD$julia$install_package_if_needed("DiffResults")
        .AD$julia$library("DiffResults")

        if (reverse) {
            .AD$julia$install_package_if_needed("ReverseDiff")
            .AD$julia$library("ReverseDiff")

            ## Need to define is_tape function for ReverseDiff
            JuliaCall::julia_command("function is_tape(x) issubtype(typeof(x), ReverseDiff.AbstractTape) end;")

            JuliaCall::julia_command("import Base.float")
            JuliaCall::julia_command("using Suppressor")
            JuliaCall::julia_command("@suppress begin function Base.float{V,D,O}(t::ReverseDiff.TrackedReal{V,D,O}) t end end")

        }

        if (forward) {
            .AD$julia$install_package_if_needed("ForwardDiff")
            .AD$julia$library("ForwardDiff")

            # JuliaCall::julia_command("for R in (:Bool, :BigFloat)
            #                             @eval begin
            #                                 Base.promote_rule(::Type{$R}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type($R, V),N}
            #                                 Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{$R}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, $R),N}
            #                             end
            #                          end")
            JuliaCall::julia_command("import Base.promote_rule")
            JuliaCall::julia_command("Base.promote_rule(::Type{Bool}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(Bool, V),N}")
            JuliaCall::julia_command("Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{Bool}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, Bool),N}")
        }

        apiFuncs(reverse = reverse, forward = forward)

        .AD$inited <- TRUE
    }
}
