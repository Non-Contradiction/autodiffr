using Suppressor

try
    using DiffResults;
catch e;
    Pkg.add("DiffResults");
    using DiffResults;
end;
