## Adapt from DiffTests at
## <https://github.com/JuliaDiff/DiffTests.jl/blob/master/src/DiffTests.jl>

#
# These functions are organized in sets based on input/output type. They are unary and not
# in-place unless otherwised specified. These functions have been written with the following
# assumptions:
#     - Array input is of length >= 5
# - Matrix input is square
# - Matrix inputs for n-ary functions are of equal shape
# Some of these functions have been modified from their original form to to allow for tunable
# input/output sizes, or to test certain programmatic behaviors. Thus, regardless of their
# names, one should not expect these functions to be "correct" for their original purpose.
#

########################
# f(x::Number)::Number #
########################

# num2num_1(x) = sin(x)^2 / cos(x)^2
num2num_1 <- function(x) sin(x)^2 / cos(x)^2
# num2num_2(x) = 2*x + sqrt(x*x*x)
num2num_2 <- function(x) 2*x + sqrt(x*x*x)
# num2num_3(x) = 10.31^(x + x) - x
num2num_3 <- function(x) 10.31^(x + x) - x
# num2num_4(x) = 1
num2num_4 <- function(x) 1
# num2num_5(x) = 1. / (1. + exp(-x))
num2num_5 <- function(x) 1 / (1 + exp(-x))

# const NUMBER_TO_NUMBER_FUNCS = (num2num_1, num2num_2, num2num_3,
#                                 num2num_4, num2num_5, identity)
NUMBER_TO_NUMBER_FUNCS <- list(num2num_1, num2num_2, num2num_3,
                               num2num_4, num2num_5, identity)
names(NUMBER_TO_NUMBER_FUNCS) <- c("num2num_1", "num2num_2", "num2num_3",
                                   "num2num_4", "num2num_5", "identity")

#######################
# f(x::Number)::Array #
#######################

# function num2arr_1(x)
# return reshape([num2num_1(x),
#                 num2num_2(x),
#                 num2num_3(x),
#                 num2num_1(x) - num2num_2(x),
#                 num2num_2(x),
#                 num2num_3(x),
#                 num2num_2(x),
#                 num2num_3(x)], 2, 2, 2)
# end
num2arr_1 <- function(x){
    array(c(num2num_1(x),
            num2num_2(x),
            num2num_3(x),
            num2num_1(x) - num2num_2(x),
            num2num_2(x),
            num2num_3(x),
            num2num_2(x),
            num2num_3(x)), rep(2, 3))
}

# const NUMBER_TO_ARRAY_FUNCS = (num2arr_1,)
NUMBER_TO_ARRAY_FUNCS <- list(num2arr_1)
names(NUMBER_TO_ARRAY_FUNCS) <- c("num2arr_1")

#################################
# f!(y::Array, x::Number)::Void #
#################################

# function num2arr_1!(y, x)
# fill!(y, zero(x))
# for i in 2:length(y)
# y[i] = (sin(x) + y[i-1])^2
# end
# return nothing
# end
#
# const INPLACE_NUMBER_TO_ARRAY_FUNCS = (num2arr_1!,)

########################
# f(x::Vector)::Number #
########################

## additional functions to define vecnorm in R
vecnorm <- function(x) sqrt(sum(x ^ 2))

# vec2num_1(x) = (exp(x[1]) + log(x[3]) * x[4]) / x[5]
vec2num_1 <- function(x) (exp(x[1]) + log(x[3]) * x[4]) / x[5]
# vec2num_2(x) = x[1]*x[2] + sin(x[1])
vec2num_2 <- function(x) x[1]*x[2] + sin(x[1])
# vec2num_3(x) = vecnorm(x' .* x)
vec2num_3 <- function(x) vecnorm(sum(x^2))
# vec2num_4(x) = ((sum(x) + prod(x)); 1)
vec2num_4 <- function(x){sum(x) + prod(x); 1}
# vec2num_5(x) = sum((-x).^3)
vec2num_5 <- function(x) sum((-x) ^ 3)
# vec2num_6(x) = sum([ifelse(i > 0, i, 0) for i in x])
vec2num_6 <- function(x) sum(ifelse(x > 0, x, 0))
# vec2num_7(x) = sum(map(y -> x[1] * y, x))
# vec2num_7 <- function(x) sum(sapply(x, function(y) x[1] * y))
vec2num_7 <- function(x) sum(map(function(y) x[1] * y, x))

# function rosenbrock_1(x)
# a = one(eltype(x))
# b = 100 * a
# result = zero(eltype(x))
# for i in 1:length(x)-1
# result += (a - x[i])^2 + b*(x[i+1] - x[i]^2)^2
# end
# return result
# end

rosenbrock_1 <- function(x){
    a <- 1
    b <- 100 * a
    result <- 0
    for (i in 1:(length(x) - 1)) {
        result <- result + (a - x[i])^2 + b*(x[i + 1] - x[i]^2)^2
    }
    result
}

# function rosenbrock_2(x)
# a = x[1]
# b = 100 * a
# v = map((i, j) -> (a - j)^2 + b*(i - j^2)^2, x[2:end], x[1:end-1])
# return sum(v)
# end

rosenbrock_2 <- function(x){
    a <- x[1]
    b <- 100 * a
    # v <- mapply(function(i, j) (a - j)^2 + b * (i - j ^ 2) ^ 2, x[2:length(x)], x[1:(length(x) - 1)])
    v <- map(function(i, j) (a - j)^2 + b * (i - j ^ 2) ^ 2, x[2:length(x)], x[1:(length(x) - 1)])
    sum(v)
}

# rosenbrock_3(x) = sum(map((i, j) -> (1 - j)^2 + 100*(i - j^2)^2, x[2:end], x[1:end-1]))

# rosenbrock_3 <- function(x) sum(mapply(function(i, j) (1 - j)^2 + 100 * (i - j ^ 2) ^ 2,
#                                        x[2:length(x)],
#                                        x[1:(length(x) - 1)]))

rosenbrock_3 <- function(x) sum(map(function(i, j) (1 - j)^2 + 100 * (i - j ^ 2) ^ 2,
                                    x[2:length(x)],
                                    x[1:(length(x) - 1)]))

# function rosenbrock_4(x)
# t1 = (1 .+ x[1:end-1]).^2
# t2 = x[2:end] .+ (x[1:end-1]).^2
# return sum(t1 .+ 100 .* (abs.(t2)).^2)
# end

rosenbrock_4 <- function(x){
    t1 <- (1 + x[1:(length(x) - 1)]) ^ 2
    t2 <- x[2:length(x)] + (x[1:(length(x) - 1)]) ^ 2
    sum(t1 + 100 * (abs(t2)) ^ 2)
}

# function ackley(x)
# a, b, c = 20.0, -0.2, 2.0*π
# len_recip = inv(length(x))
# sum_sqrs = zero(eltype(x))
# sum_cos = sum_sqrs
# for i in x
# sum_cos += cos(c*i)
# sum_sqrs += i^2
# end
# return (-a * exp(b * sqrt(len_recip*sum_sqrs)) -
#             exp(len_recip*sum_cos) + a + exp(1))
# end

# ackley <- function(x){
#     a <- 20.0; b <- -0.2; c <- 2.0 * pi
#     len_recip <- 1 / length(x)
#     sum_sqrs <- 0
#     sum_cos <- sum_sqrs
#     for (i in x) {
#         sum_cos <- sum_cos + cos(c * i)
#         sum_sqrs <- sum_sqrs + i ^ 2
#     }
#     - a * exp(b * sqrt(len_recip * sum_sqrs)) -
#         exp(len_recip * sum_cos) + a + exp(1)
# }

ackley <- function(x){
    a <- 20.0; b <- -0.2; c <- 2.0 * pi
    len_recip <- 1 / length(x)
    sum_sqrs <- 0
    sum_cos <- sum_sqrs
    for (i in as.list(x)) {
        sum_cos <- sum_cos + cos(c * i)
        sum_sqrs <- sum_sqrs + i ^ 2
    }
    - a * exp(b * sqrt(len_recip * sum_sqrs)) -
        exp(len_recip * sum_cos) + a + exp(1)
}

# self_weighted_logit(x) = inv(1.0 + exp(-dot(x, x)))

self_weighted_logit <- function(x){1 / (1.0 + exp(-sum(x ^ 2)))}

# const VECTOR_TO_NUMBER_FUNCS = (vec2num_1, vec2num_2,  vec2num_3, vec2num_4, vec2num_5,
#                                 vec2num_6, vec2num_7, rosenbrock_1, rosenbrock_2,
#                                 rosenbrock_3, rosenbrock_4, ackley, self_weighted_logit,
#                                 first)

VECTOR_TO_NUMBER_FUNCS <- list(vec2num_1, vec2num_2, vec2num_3, vec2num_4, vec2num_5, vec2num_6, vec2num_7,
                               rosenbrock_1, rosenbrock_2, rosenbrock_3, rosenbrock_4,
                               ackley, self_weighted_logit, function(x) x[1])
names(VECTOR_TO_NUMBER_FUNCS) <- c("vec2num_1", "vec2num_2", "vec2num_3", "vec2num_4", "vec2num_5",
                                   "vec2num_6",
                                   "vec2num_7", "rosenbrock_1", "rosenbrock_2", "rosenbrock_3",
                                   "rosenbrock_4", "ackley", "self_weighted_logit", "first")

########################
# f(x::Matrix)::Number #
########################

# mat2num_1(x) = det(first(x) * inv(x * x) + x)
mat2num_1 <- function(x) det(x[1,1] * solve(x %m% x) + x)

# function mat2num_2(x)
# a = reshape(x, length(x), 1)
# b = reshape(copy(x), 1, length(x))
# return trace(log.((1 .+ (a * b)) .+ a .- b))
# end

mat2num_2 <- function(x){
    a <- Jmatrix(x, length(x), 1)
    b <- Jmatrix(x, 1, length(x))
    sum(log((1 + (a %m% b)) + a - b))
}

# function mat2num_3(x)
# k = length(x)
# N = isqrt(k)
# A = reshape(x, N, N)
# return sum(map(n -> sqrt(abs(n) + n^2) * 0.5, A))
# end

mat2num_3 <- function(x){
    k <- length(x)
    N <- as.integer(sqrt(k))
    A <- Jmatrix(x, N, N)
    sum(map(function(n) sqrt(abs(n) + n^2) * 0.5, A))
}

# mat2num_4(x) = mean(sum(sin.(x) * x, 2))
mat2num_4 <- function(x) mean(rSums(sin(x) %m% x))
# softmax(x) = sum(exp.(x) ./ sum(exp.(x), 2))
softmax <- function(x) sum(exp(x) / rSums(exp(x)))

# const MATRIX_TO_NUMBER_FUNCS = (det, mat2num_1, mat2num_2, mat2num_3, mat2num_4, softmax)
MATRIX_TO_NUMBER_FUNCS <- list(det, mat2num_1, mat2num_2, mat2num_3, mat2num_4, softmax)
names(MATRIX_TO_NUMBER_FUNCS) <- c("det", "mat2num_1", "mat2num_2", "mat2num_3", "mat2num_4", "softmax")

####################
# binary broadcast #
####################

# if VERSION >= v"0.6.0-dev.1614"
# const BINARY_BROADCAST_OPS = ((a, b) -> broadcast(+, a, b),
#                               (a, b) -> broadcast(-, a, b),
#                               (a, b) -> broadcast(*, a, b),
#                               (a, b) -> broadcast(/, a, b),
#                               (a, b) -> broadcast(\, a, b),
#                               (a, b) -> broadcast(^, a, b))
# else
#     const BINARY_BROADCAST_OPS = (.+, .-, .*, ./, .\, .^)
# end

#################################
# f(::Matrix, ::Matrix)::Number #
#################################

# const BINARY_MATRIX_TO_MATRIX_FUNCS = (+, -, *, /, \,
#                                        BINARY_BROADCAST_OPS...,
#                                        A_mul_Bt, At_mul_B, At_mul_Bt,
#                                        A_mul_Bc, Ac_mul_B, Ac_mul_Bc)

A_mul_Bt <- function(x, y) x %m% t(y)
At_mul_B <- function(x, y) t(x) %m% y
At_mul_Bt <- function(x, y) t(x) %m% t(y)

BINARY_MATRIX_TO_MATRIX_FUNCS <- list(`+`, `-`, `*`, `%m%`, `/`, solve,
                                      `^`, A_mul_Bt, At_mul_B, At_mul_Bt)
names(BINARY_MATRIX_TO_MATRIX_FUNCS) <- c("+", "-", "*", "%m%", "/",
                                          "solve", "^",
                                          "A_mul_Bt", "At_mul_B", "At_mul_Bt")

###########################################
# f(::Matrix, ::Matrix, ::Matrix)::Number #
###########################################

# relu(x) = log.(1.0 .+ exp.(x))
relu <- function(x) log(1.0 + exp(x))
# sigmoid(n) = 1. / (1. + exp.(-n))
sigmoid <- function(n) 1 / (1 + exp(-n))
# neural_step(x1, w1, w2) = sigmoid(dot(w2[1:size(w1, 2)], relu(w1 * x1[1:size(w1, 2)])))
## additional function dot in R
dot <- function(x, y) sum(x * y)
neural_step <- function(x1, w1, w2) sigmoid(dot(w2[1:ncol(w1)], relu(w1 %m% x1[1:ncol(w1)])))

# const TERNARY_MATRIX_TO_NUMBER_FUNCS = (neural_step,)
TERNARY_MATRIX_TO_NUMBER_FUNCS <- list(neural_step)
names(TERNARY_MATRIX_TO_NUMBER_FUNCS) <- c("neural_step")

################################
# f!(y::Array, x::Array)::Void #
################################
# Credit for `chebyquad!`, `brown_almost_linear!`, and `trigonometric!` goes to
# Kristoffer Carlsson (@KristofferC).

# function chebyquad!(y, x)
# tk = 1/length(x)
# for j = 1:length(x)
# temp1 = 1.0
# temp2 = 2x[j]-1
# temp = 2temp2
# for i = 1:length(y)
# y[i] += temp2
# ti = temp*temp2 - temp1
# temp1 = temp2
# temp2 = ti
# end
# end
# iev = -1.0
# for k = 1:length(y)
# y[k] *= tk
# if iev > 0
# y[k] += 1/(k^2-1)
# end
# iev = -iev
# end
# return nothing
# end
#
# function brown_almost_linear!(y, x)
# c = sum(x) - (length(x) + 1)
# for i = 1:(length(x)-1), j = 1:(length(y)-1)
# y[j] += x[i] + c
# end
# y[length(y)] = prod(x) - 1
# return nothing
# end
#
# function trigonometric!(y, x)
# for i in x
# for j in eachindex(y)
# y[j] = cos(i)
# end
# end
# c = sum(y)
# n = length(x)
# for i in x
# for j in eachindex(y)
# y[j] = sin(i) * y[j] + n - c
# end
# end
# return nothing
# end
#
# function mutation_test_1!(y, x)
# y[1] = x[1]
# y[1] = y[1] * x[2]
# y[2] = y[2] * x[3]
# y[3] = sum(y)
# return nothing
# end
#
# function mutation_test_2!(y, x)
# y[1] *= x[1]
# y[2] *= x[1]
# y[1] *= x[2]
# y[2] *= x[2]
# return nothing
# end
#
# const INPLACE_ARRAY_TO_ARRAY_FUNCS = (chebyquad!, brown_almost_linear!, trigonometric!,
#                                       mutation_test_1!, mutation_test_2!)

######################
# f(x::Array)::Array #
######################

# chebyquad(x) = (y = fill(zero(eltype(x)), size(x)); chebyquad!(y, x); return y)

chebyquad <- function(x){
    y <- zeros(x)
    tk <- 1 / length(x)
    for (j in 1:length(x)) {
        temp1 <- 1.0
        temp2 <- 2 * x[j] - 1
        temp <- 2 * temp2
        for (i in 1:length(y)) {
            y[i] <- y[i] + temp2
            ti <- temp * temp2 - temp1
            temp1 <- temp2
            temp2 <- ti
        }
    }
    iev <- -1.0
    for (k in 1:length(y)) {
        y[k] <- y[k] * tk
        if (iev > 0) {
            y[k] <- y[k] + 1 / (k ^ 2 - 1)
        }
        iev <- -iev
    }
    y
}

# brown_almost_linear(x) = (y = fill(zero(eltype(x)), size(x)); brown_almost_linear!(y, x); return y)

brown_almost_linear <- function(x){
    y <- zeros(x)
    c <- sum(x) - (length(x) + 1)
    for (i in  1:(length(x) - 1)) {
        for (j in 1:(length(y) - 1)) {
            y[j] <- y[j] + x[i] + c
        }
    }
    y[length(y)] <- prod(x) - 1
    y
}

# trigonometric(x) = (y = fill(one(eltype(x)), size(x)); trigonometric!(y, x); return y)

trigonometric <- function(x){
    y <- zeros(x)
    for (i in as.list(x)) {
        for (j in 1:length(y)) {
            y[j] <- cos(i)
        }
    }
    c <- sum(y)
    n <- length(x)
    for (i in as.list(x)) {
        for (j in 1:length(y)) {
            y[j] <- sin(i) * y[j] + n - c
        }
    }
    y
}

# mutation_test_1(x) = (y = fill(zero(eltype(x)), size(x)); mutation_test_1!(y, x); return y)

mutation_test_1 <- function(x){
    y <- zeros(x)
    y[1] <- x[1]
    y[1] <- y[1] * x[2]
    y[2] <- y[2] * x[3]
    y[3] <- sum(y)
    y
}

# mutation_test_2(x) = (y = fill(one(eltype(x)), size(x)); mutation_test_2!(y, x); return y)

mutation_test_2 <- function(x){
    y <- ones(x)
    y[1] <- y[1] * x[1]
    y[2] <- y[2] * x[1]
    y[1] <- y[1] * x[2]
    y[2] <- y[2] * x[2]
    y
}

# arr2arr_1(x) = (sum(x .* x); fill(zero(eltype(x)), size(x)))
arr2arr_1 <- function(x){sum(x * x); rep(0, length(x))}
# arr2arr_2(x) = x[1, :] .+ x[1, :] .+ first(x)
#
# const ARRAY_TO_ARRAY_FUNCS = (-, chebyquad, brown_almost_linear, trigonometric, arr2arr_1,
#                               arr2arr_2, mutation_test_1, mutation_test_2, identity)
ARRAY_TO_ARRAY_FUNCS <- list(`-`, chebyquad, brown_almost_linear, trigonometric, arr2arr_1,
                             mutation_test_1, mutation_test_2, identity)
names(ARRAY_TO_ARRAY_FUNCS) <- c("-", "chebyquad", "brown_almost_linear", "trigonometric", "arr2arr_1",
                             "mutation_test_1", "mutation_test_2", "identity")

#######################
# f(::Matrix)::Matrix #
#######################

# const MATRIX_TO_MATRIX_FUNCS = (inv,)
MATRIX_TO_MATRIX_FUNCS <- list(solve)
names(MATRIX_TO_MATRIX_FUNCS) <- c("solve")
