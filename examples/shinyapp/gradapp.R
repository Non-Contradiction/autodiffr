#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(autodiffr)

require(numDeriv)

testing_funcs <- c(autodiffr:::VECTOR_TO_NUMBER_FUNCS)

diffnorm <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))

# Define UI for application that draws a histogram
ui <- fluidPage(

   # Application title
   titlePanel("Gradient in autodiffr"),

   # Sidebar with a slider input for number of bins
   sidebarLayout(
      sidebarPanel(
          selectInput("fn", "Functions",
                      names(testing_funcs)
          ),
          textInput("len", "Length of input", "5"),
          h4("Function Source"),
          verbatimTextOutput("func")
      ),

      # Show a plot of the generated distribution
      mainPanel(
          # h3("X"),
          # textOutput("X"),
          # h3("Function Source"),
          # textOutput("func"),

          wellPanel(
              h3("numDeriv"),
              h4("Time"),
              textOutput("nT"),
              h4("L2 norm of Difference Between numDeriv and Forward Mode"),
              textOutput("nD")
              ),

          wellPanel(
              h3("Forward Mode"),
              h4("Time"),
              textOutput("fT"),
              h4("L2 norm of Difference Between Forward and Reverse Mode"),
              textOutput("fD")
          ),

          wellPanel(
              h3("Reverse Mode"),
              h4("Time"),
              textOutput("rT"),
              h4("Time with Tape"),
              textOutput("tT"),
              h4("L2 norm of Difference in Reverse Mode with and without Tape"),
              textOutput("tD")
          )

      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    X <- reactive(runif(as.integer(input$len)))
    func <- reactive(testing_funcs[[input$fn]])
    # output$X <- renderText(X())
    output$func <- renderText({
        paste0(deparse(func()), collapse = "\n")
        })

    nR <- reactive(numDeriv::grad(func(), X()))
    nT <- reactive(system.time(numDeriv::grad(func(), X())))
    output$nT <- renderText(nT()[3])
    # output$nR <- renderText(nR())

    fR <- reactive(forward_grad(func(), X()))
    fT <- reactive(system.time(forward_grad(func(), X())))
    output$fT <- renderText(fT()[3])
    # output$fR <- renderText(fR())

    rR <- reactive(reverse_grad(func(), X()))
    rT <- reactive(system.time(reverse_grad(func(), X())))
    tp <- reactive(reverse_grad_tape(func(), X()))
    tR <- reactive(reverse_grad(tp(), X()))
    tT <- reactive(system.time(reverse_grad(tp(), X())))
    output$rT <- renderText(rT()[3])
    output$tT <- renderText(tT()[3])
    # output$tR <- renderText(rR())

    output$nD <- renderText(diffnorm(nR(), fR()))
    output$fD <- renderText(diffnorm(fR(), rR()))
    output$tD <- renderText(diffnorm(rR(), tR()))


}

# Run the application
shinyApp(ui = ui, server = server)

