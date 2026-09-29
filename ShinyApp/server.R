library(shiny)
library(datasets)

data(mtcars)
cars <- mtcars
cars$cyl <- factor(cars$cyl)
cars$am  <- factor(cars$am, labels = c("Automatic", "Manual"))
cars$name <- rownames(mtcars)

fit <- lm(mpg ~ wt + hp + cyl + am, data = cars)

shinyServer(function(input, output) {

    newCar <- reactive({
        data.frame(wt  = input$wt,
                   hp  = input$hp,
                   cyl = factor(input$cyl, levels = levels(cars$cyl)),
                   am  = factor(ifelse(input$am == "1", "Manual", "Automatic"),
                                levels = levels(cars$am)))
    })

    pred <- reactive({
        predict(fit, newCar(), interval = "prediction", level = 0.95)
    })

    output$prediction <- renderText({
        sprintf("Predicted fuel economy: %.1f MPG", pred()[1, "fit"])
    })

    output$interval <- renderText({
        sprintf("95%% prediction interval: %.1f to %.1f MPG",
                pred()[1, "lwr"], pred()[1, "upr"])
    })

    output$comparison <- renderText({
        p <- pred()[1, "fit"]
        pct <- round(100 * mean(cars$mpg < p))
        warn <- ""
        if (input$hp > max(cars$hp[cars$cyl == input$cyl]) ||
            input$hp < min(cars$hp[cars$cyl == input$cyl])) {
            warn <- paste(" Note: this horsepower is outside the range observed for",
                          input$cyl, "cylinder cars, so the prediction is an extrapolation.")
        }
        paste0("That is better than ", pct, "% of the cars in the dataset.", warn)
    })

    output$plot <- renderPlot({
        amLabel <- ifelse(input$am == "1", "Manual", "Automatic")
        p <- pred()[1, "fit"]

        plot(cars$wt, cars$mpg, pch = 19, cex = 1.2,
             col = ifelse(cars$am == "Manual", "darkgreen", "steelblue"),
             xlab = "Weight (1000 lbs)", ylab = "Miles per gallon",
             main = "Your car against the 32 cars in mtcars",
             xlim = c(1.4, 5.6), ylim = c(8, 36))

        # fitted line holding hp and cyl at the user's chosen values
        wseq <- seq(1.5, 5.5, length.out = 100)
        line <- predict(fit, data.frame(
            wt = wseq, hp = input$hp,
            cyl = factor(input$cyl, levels = levels(cars$cyl)),
            am  = factor(amLabel, levels = levels(cars$am))))
        lines(wseq, line, lwd = 2, lty = 2,
              col = ifelse(amLabel == "Manual", "darkgreen", "steelblue"))

        points(input$wt, p, pch = 18, cex = 3.2, col = "red")
        if (input$showCI) {
            arrows(input$wt, pred()[1, "lwr"], input$wt, pred()[1, "upr"],
                   code = 3, angle = 90, length = 0.08, col = "red", lwd = 2)
        }
        legend("topright", bty = "n", pch = c(19, 19, 18), pt.cex = c(1.2, 1.2, 2),
               col = c("steelblue", "darkgreen", "red"),
               legend = c("Automatic", "Manual", "Your car"))
    })

    output$neighbours <- renderTable({
        d <- scale(cars[, c("wt", "hp")])
        target <- scale(cars[, c("wt", "hp")],
                        center = attr(d, "scaled:center"),
                        scale  = attr(d, "scaled:scale"))
        tgt <- c((input$wt - attr(d, "scaled:center")["wt"]) / attr(d, "scaled:scale")["wt"],
                 (input$hp - attr(d, "scaled:center")["hp"]) / attr(d, "scaled:scale")["hp"])
        dist <- sqrt((d[, 1] - tgt[1])^2 + (d[, 2] - tgt[2])^2)
        idx <- order(dist)[1:5]
        data.frame(Car = cars$name[idx],
                   Weight = cars$wt[idx],
                   HP = cars$hp[idx],
                   Cylinders = as.character(cars$cyl[idx]),
                   Transmission = as.character(cars$am[idx]),
                   `Actual MPG` = cars$mpg[idx],
                   check.names = FALSE)
    })
})
