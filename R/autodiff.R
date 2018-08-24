#' Do initial setup for package autodiffr.
#'
#' \code{ad_setup} does the initial setup for package autodiffr.
#'
#' @param reverse whether to use load reverse mode automatic differentiation.
#' @param forward whether to use forward mode automatic differentiation.
#' @param JULIA_HOME the file folder which contains julia binary,
#'     if not set, it will try to look at global option JULIA_HOME,
#'     if the global option is not set,
#'     it will then look at the environmental variable JULIA_HOME,
#'     if still not found, julia in path will be used.
#' @param ... arguments passed to \code{JuliaCall::julia_setup}.
#'
#' @examples
#' \dontrun{
#' ad_setup()
#' }
#'
#' @export
ad_setup <- function(JULIA_HOME = NULL, reverse = TRUE, forward = TRUE, ...) {
    if (!isTRUE(.AD$inited)) {
        .AD$julia <- JuliaCall::julia_setup(JULIA_HOME = JULIA_HOME, ...)

        .AD$julia$install_package_if_needed("DiffResults")
        .AD$julia$library("DiffResults")

        if (reverse) {
            .AD$julia$install_package_if_needed("ReverseDiff")
            .AD$julia$library("ReverseDiff")

            ## Need to define is_tape function for ReverseDiff
            JuliaCall::julia_command("function is_tape(x) typeof(x) <: ReverseDiff.AbstractTape end;")

            JuliaCall::julia_command("import Base.float")
            JuliaCall::julia_command("using Suppressor")
            JuliaCall::julia_command("@suppress begin function Base.float(t::ReverseDiff.TrackedReal{V,D,O}) where {V,D,O} t end end")

            JuliaCall::julia_command("(::Type{ReverseDiff.TrackedReal{V,D,O}})(t::ReverseDiff.TrackedReal{V,D,O}) where {V,D,O} = t")
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
