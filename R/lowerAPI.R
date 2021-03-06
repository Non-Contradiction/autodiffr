lowerAPICreate <- function(n){
    force(n)
    rawFunc <- JuliaCall::julia_eval(n)
    f <- function(..., debug = TRUE) {
        if (!debug) {
            return(rawFunc(...))
        }
        JuliaCall::julia_call(n, ...)
    }

    f
}

apiFuncs <- function(reverse = TRUE, forward = TRUE){
    if (reverse) {
        for (n in c("ReverseDiff.gradient", "ReverseDiff.gradient!",
                    "ReverseDiff.jacobian", "ReverseDiff.jacobian!",
                    "ReverseDiff.hessian", "ReverseDiff.hessian!")) {
            .AD[[n]] <- lowerAPICreate(n)
        }
    }

    if (forward) {
        for (n in c("ForwardDiff.gradient", "ForwardDiff.gradient!",
                    "ForwardDiff.jacobian", "ForwardDiff.jacobian!",
                    "ForwardDiff.hessian", "ForwardDiff.hessian!")) {
            .AD[[n]] <- lowerAPICreate(n)
        }
    }
}
