# Related to issue #15.
# Turns a function with named arguments into a function with positional arguments
# where the names of the positional arguments would be like the names of the list.

positionize <- function(f, arg_list) {
    force(f)
    force(arg_list)
    ff <- function(...){
        arg_list1 <- list(...)
        names(arg_list1) <- names(arg_list)
        do.call("f", arg_list1)
    }
    ff
}
