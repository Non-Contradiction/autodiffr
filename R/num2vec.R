num2vec <- function(x){
    if (is.list(x)) {
        lapply(x, num2vec)
    }
    else {
        if (length(x) > 1) {
            x
        }
        JuliaCall::julia_call("vcat", x, need_return = "Julia")
    }
}

vec2num <- function(x){
    if (length(x) == 1) x[1]
    else x
}
