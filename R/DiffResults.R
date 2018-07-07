GradientResult <- function(x){
    r <- JuliaCall::julia_call("DiffResults.GradientResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("grad", function() JuliaCall::julia_call("DiffResults.gradient", r), r)
    r
}

JacobianResult <- function(x){
    r <- JuliaCall::julia_call("DiffResults.JacobianResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("jacobian", function() JuliaCall::julia_call("DiffResults.jacobian", r), r)
    r
}

HessianResult <- function(x){
    r <- JuliaCall::julia_call("DiffResults.HessianResult", x)
    makeActiveBinding("value", function() JuliaCall::julia_call("DiffResults.value", r), r)
    makeActiveBinding("grad", function() JuliaCall::julia_call("DiffResults.gradient", r), r)
    makeActiveBinding("hessian", function() JuliaCall::julia_call("DiffResults.hessian", r), r)
    r
}
