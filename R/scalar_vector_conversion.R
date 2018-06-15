scalar2vector <- function(x){
    if (is.list(x)) {
        lapply(x, scalar2vector)
    }
    else {
        if (length(x) > 1) {
            x
        }
        else {
            JuliaCall::julia_call("vcat", x, need_return = "Julia")
        }
    }
}

vector2scalar <- function(x){
    if (length(x) == 1) x[1]
    else x
}
