alength <- function(x){
    if (is.list(x)) {
        min(sapply(x, length))
    }
    else {
        length(x)
    }
}
