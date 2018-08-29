try
    using ForwardDiff
catch e
    Pkg.add("ForwardDiff")
    using ForwardDiff
end

import Base.promote_rule
Base.promote_rule(::Type{Bool}, ::Type{ForwardDiff.Dual{T,V,N}}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(Bool, V),N}
Base.promote_rule(::Type{ForwardDiff.Dual{T,V,N}}, ::Type{Bool}) where {T,V<:Real,N} = ForwardDiff.Dual{T,promote_type(V, Bool),N}
