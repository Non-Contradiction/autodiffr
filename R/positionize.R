# Related to issue #15.
# Turns a function with named arguments into a function with positional arguments
# where the names of the positional arguments would be ns.

positionize <- function(f, ns) {
    force(f)
    force(ns)
    ff <- function(...){
        arg_list1 <- list(...)
        names(arg_list1) <- ns
        do.call("f", arg_list1)
    }
    ff
}
