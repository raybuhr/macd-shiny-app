library(shiny)
library(DT)
library(httr)
library(dplyr)
library(ggplot2)
library(grid)
library(TTR)
library(jsonlite)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  dataset <- reactive(get_coin_data(coin = input$product, timeslice = input$timeslice))

  output$gdax_data <- renderTable({
    gdax_table <- dataset() %>%
      mutate(datetime = format(datetime, "%Y-%m-%d %H:%M"))
    gdax_table
    })

  output$macd_plot <- renderPlot({
    macd_plot(macd_data = dataset(),
              plot_title = paste(input$product, "Close Price at",
                                 input$timeslice, "Minute Intervals"))
    })

  output$earnings <- renderText({
    earning_df <- get_earnings_data(dataset())
    profit <- round(sum(earning_df$earnings), 5)
    msg <- paste("The MACD strategy would have generated", profit, "in earnings.")
    msg
  })

  output$earnings_table <- renderTable({
    earnings_table <- get_earnings_data(dataset()) %>%
      mutate(buy_at = format(buy_at, "%Y-%m-%d %H:%M"),
             sell_at = format(sell_at, "%Y-%m-%d %H:%M"))
    earnings_table
  })

})
