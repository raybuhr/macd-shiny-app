library(httr)
library(data.table)
library(dplyr)
library(tidyr)
library(TTR)
library(jsonlite)
library(ggplot2)
library(grid)
source("macd_plot.R")

gdax_url <- "https://api.gdax.com"

prods <- content(GET(gdax_url, path = "/products"), as = "text") %>%
  fromJSON()

btc_usd <- GET(gdax_url, path = "/products/BTC-USD/candles",
               query = list(granularity=300)) %>%
  content(as = "text") %>%
  fromJSON() %>%
  data.table()

colnames(btc_usd) <- c("time", "low", "high", "open", "close", "volume")

btc_usd$datetime <- as.POSIXct(btc_usd$time, origin="1970-01-01")

btc_usd <- btc_usd[order(time)]

macd <- data.table(MACD(btc_usd[, "close"]))

btc_macd <- bind_cols(btc_usd, macd) %>%
  select(datetime, close, macd, signal)

macd_plot(btc_macd)

actions <- btc_macd %>%
  na.omit() %>%
  mutate(up = macd > signal,
         close_at_up = up * close,
         buy = up & (up > lag(up)),
         sell = close_at_up == 0 & lag(close_at_up) > 0) %>%
  filter(buy | sell) %>%
  select(datetime, buy, close) %>%
  head(20)

orders <- data.frame(buy_at = actions$datetime[actions$buy==TRUE],
                      buy_price = actions$close[actions$buy==TRUE],
                      sell_at = actions$datetime[actions$buy==FALSE],
                      sell_price = actions$close[actions$buy==FALSE]) %>%
  mutate(earnings = sell_price - buy_price)

sum(orders$earnings)
