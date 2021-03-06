try
    using ReverseDiff;
catch e
    Pkg.add("ReverseDiff");
    using ReverseDiff;
end

function is_tape(x)
    typeof(x) <: ReverseDiff.AbstractTape
end

import Base.float
function Base.float(t::ReverseDiff.TrackedReal{V,D,O}) where {V,D,O} t end;

(::Type{ReverseDiff.TrackedReal{V,D,O}})(t::ReverseDiff.TrackedReal{V,D,O}) where {V,D,O} = t;
