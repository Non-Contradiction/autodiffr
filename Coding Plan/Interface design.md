## Thoughts on Interface Design

### Dimensions
The package need to deal with
* derivatives and second-order (or higher-order) derivatives of R1 -> R1 functions
* gradients and hessians of Rn(n>1) -> R1 functions
* jacobians of Rn(n>1) -> Rm(m>1) functions

And the package will provide separate functions, like `deriv` for derivatives,
and `grad` for gradients.

It is expected that users understand the difference and use corresponding functions when dealing with problems in different dimensionality.

Maybe we can include some error messages like "`grad` is not for R1 -> R1 functions, maybe you want to use `deriv`?"
if the user uses `grad` for a scalar function of one variable.

### Arguments
The arguments to the interface functions will look like:
`grad(func, x = NULL, mode = c("forward", "reverse"), ...)
`
where
* `func` is the original function.
* `x` is where the gradient is calculated, and it should be the first argument to `func` except the arguments matched by `...`. If it is `NULL`, then a gradient function will be returned.
* `mode` is whether forward or reverse mode automatic differentiation is used,
* And `...` are other arguments to the function `func`.
