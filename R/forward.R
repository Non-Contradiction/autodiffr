forward.deriv <- function(f, x){
    JuliaCall::julia_call("ForwardDiff.derivative", f, x)
}

forward.grad <- function(f, x,
                         cfg = JuliaCall::julia_call("GradientConfig", f, x),
                         check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.gradient", f, x, cfg, check)
}

forward.jacobian <- function(f, x,
                             cfg = JuliaCall::julia_call("JacobianConfig", f, x),
                             check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.jacobian", f, x, cfg, check)
}

forward.hessian <- function(f, x,
                            cfg = JuliaCall::julia_call("HessianConfig", f, x),
                            check = JuliaCall::julia_call("Val{true}")){
    JuliaCall::julia_call("ForwardDiff.hessian", f, x, cfg, check)
}

## Constructing Config objects for ForwardDiff

forward.grad.config <- function(f, x,
                                chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.GradientConfig", f, x, chunk)
}

forward.jacobian.config <- function(f, x,
                                    chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.JacobianConfig", f, x, chunk)
}

forward.hessian.config <- function(f, x,
                                   chunk = JuliaCall::julia_call("Chunk", x)){
    JuliaCall::julia_call("ForwardDiff.HessianConfig", f, x, chunk)
}
