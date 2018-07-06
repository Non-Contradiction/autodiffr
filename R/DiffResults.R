GradientResult <- R6::R6Class("GradientResult",
                              public = list(
                                  name = NULL,
                                  hair = NULL,
                                  initialize = function(name = NA, hair = NA) {
                                      self$name <- name
                                      self$hair <- hair
                                      self$greet()
                                  },
                                  gradient = function(val) {
                                      self$hair <- val
                                  },
                                  getvalue = function() {
                                      cat(paste0("Hello, my name is ", self$name, ".\n"))
                                  },
                                  getgradient = function() {
                                      cat(paste0("Hello, my name is ", self$name, ".\n"))
                                  }
                              )
)

JacobianResult <- R6::R6Class("JacobianResult",
                  public = list(
                      name = NULL,
                      hair = NULL,
                      initialize = function(name = NA, hair = NA) {
                          self$name <- name
                          self$hair <- hair
                          self$greet()
                      },
                      jacobian = function(val) {
                          self$hair <- val
                      },
                      getvalue = function() {
                          cat(paste0("Hello, my name is ", self$name, ".\n"))
                      },
                      getjacobian = function() {
                          cat(paste0("Hello, my name is ", self$name, ".\n"))
                      }
                  )
)

HessianResult <- R6::R6Class("HessianResult",
                              public = list(
                                  name = NULL,
                                  hair = NULL,
                                  initialize = function(name = NA, hair = NA) {
                                      self$name <- name
                                      self$hair <- hair
                                      self$greet()
                                  },
                                  hessian = function(val) {
                                      self$hair <- val
                                  },
                                  getvalue = function() {
                                      cat(paste0("Hello, my name is ", self$name, ".\n"))
                                  },
                                  getgradient = function() {
                                      cat(paste0("Hello, my name is ", self$name, ".\n"))
                                  },
                                  gethessian = function() {
                                      cat(paste0("Hello, my name is ", self$name, ".\n"))
                                  }
                              )
)
