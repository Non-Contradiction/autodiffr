// [[Rcpp::depends(JuliaCall)]]
#include <JuliaObject.h>

JuliaObject _fn(JuliaObject x){
    return sum(log(sqrt(x)));
}

// [[Rcpp::export]]
SEXP fn(JuliaObject x){
    return wrap(_fn(x));
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically
// run after the compilation.
//

/*** R
library(autodiffr)
ad_setup()

fn(42)
grad(fn, 42)
*/
