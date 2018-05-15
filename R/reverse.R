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

## Constructing Config objects for ReverseDiff

reverse.grad.config <- function(input,
                                tp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.GradientConfig", input, tp)
}

reverse.jacobian.config <- function(input,
                                    tp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.JacobianConfig", input, tp)
}

reverse.hessian.config <- function(input,
                                   gtp = JuliaCall::julia_call("Rawtape"),
                                   jtp = JuliaCall::julia_call("Rawtape")){
    JuliaCall::julia_call("ReverseDiff.HessianConfig", input, gtp, jtp)
}
