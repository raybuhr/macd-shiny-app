library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  theme = shinytheme("cyborg"),
  title = "GDAX Price History",
  h1("GDAX Price History"),
  br(),

  fluidRow(
    column(3,
      selectInput("product",
                  "GDAX Product to Explore",
                  choices = get_gdax_products()$id,
                  selected = "ETH-BTC"
      )
    ),
    column(5,
      selectInput("timeslice",
                  "Timeslice (mins) for Price History",
                  choices = c(1, 5, 15, 60, 360, 1440),
                  selected = 5
      )
    )
  ),
  br(),
  h3("Potential Earnings"),
  textOutput("earnings"),
  br(),
  h4("Buy and Sell Recommendations"),
  tableOutput("earnings_table"),
  br(),
  plotOutput("macd_plot", height = "800px"),
  br(),
  h3("Raw Data"),
  tableOutput("gdax_data")
))
