library(shiny)

shinyUI(fluidPage(

    titlePanel("Fuel Economy Predictor"),

    sidebarLayout(
        sidebarPanel(
            h4("Describe a car"),
            sliderInput("wt", "Weight (1000 lbs)",
                        min = 1.5, max = 5.5, value = 3.0, step = 0.1),
            sliderInput("hp", "Gross horsepower",
                        min = 50, max = 340, value = 150, step = 5),
            radioButtons("cyl", "Number of cylinders",
                         choices = c("4" = 4, "6" = 6, "8" = 8),
                         selected = 6, inline = TRUE),
            radioButtons("am", "Transmission",
                         choices = c("Automatic" = 0, "Manual" = 1),
                         selected = 1, inline = TRUE),
            checkboxInput("showCI", "Show 95% prediction interval", TRUE),
            hr(),
            helpText("The prediction updates automatically as you move the controls.")
        ),

        mainPanel(
            tabsetPanel(
                type = "tabs",

                tabPanel("Prediction",
                    br(),
                    h3(textOutput("prediction")),
                    conditionalPanel("input.showCI",
                                     h5(textOutput("interval"))),
                    textOutput("comparison"),
                    br(),
                    plotOutput("plot", height = "360px"),
                    br(),
                    h4("Closest real cars in the data"),
                    tableOutput("neighbours")
                ),

                tabPanel("Documentation",
                    br(),
                    h3("What this app does"),
                    p("This app predicts the fuel economy (miles per gallon) of a car",
                      "from four of its characteristics, using a linear regression model",
                      "fitted to the 32 cars in R's built-in", code("mtcars"), "dataset",
                      "(1973-74 model year, from Motor Trend magazine)."),

                    h3("How to use it"),
                    tags$ol(
                      tags$li(strong("Set the weight"), "with the first slider. This is",
                              "the strongest single predictor of fuel economy."),
                      tags$li(strong("Set the horsepower"), "with the second slider."),
                      tags$li(strong("Choose the number of cylinders"), "and the",
                              strong("transmission type"), "with the radio buttons."),
                      tags$li("Read the predicted MPG at the top of the Prediction tab.",
                              "It recalculates instantly - there is no submit button."),
                      tags$li("Untick the checkbox if you do not want to see the",
                              "95% prediction interval.")
                    ),

                    h3("Reading the results"),
                    p("The large number is the predicted MPG. The interval below it is a",
                      "95% prediction interval: roughly speaking, a real car with these",
                      "characteristics would be expected to fall inside that range 95% of",
                      "the time. It is wide because the model is fitted to only 32 cars."),
                    p("The chart plots your car (red diamond) against all 32 cars in the",
                      "dataset, with the fitted line for the transmission type you chose.",
                      "The table lists the five real cars whose specifications are closest",
                      "to the ones you entered, so you can sanity-check the prediction",
                      "against actual vehicles."),

                    h3("The model"),
                    p("The underlying model is",
                      code("lm(mpg ~ wt + hp + factor(cyl) + factor(am))"),
                      "fitted once when the app starts. Weight and horsepower enter",
                      "linearly; cylinders and transmission enter as factors."),
                    p(strong("A caveat:"), "these are cars from 1973-74. Predictions for",
                      "combinations far outside the original data - a very light car with",
                      "very high horsepower, say - are extrapolations and should not be",
                      "trusted. The app flags when your inputs fall outside the range of",
                      "the observed data."),

                    h3("Source"),
                    p("Data:", code("datasets::mtcars"), "in base R.",
                      "Henderson and Velleman (1981), Building multiple regression models",
                      "interactively.", em("Biometrics"), "37, 391-411.")
                )
            )
        )
    )
))
