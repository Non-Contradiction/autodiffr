reverse.grad <- function(f, input,
                         cfg = JuliaCall::julia_call("GradientConfig", input)){
    JuliaCall::julia_call("ReverseDiff.gradient", f, input, cfg)
}

reverse.jacobian <- function(f, input,
                             cfg = JuliaCall::julia_call("JacobianConfig", input)){
    JuliaCall::julia_call("ReverseDiff.jacobian", f, input, cfg)
}

reverse.hessian <- function(f, input,
                            cfg = JuliaCall::julia_call("HessianConfig", input)){
    JuliaCall::julia_call("ReverseDiff.hessian", f, input, cfg)
}
