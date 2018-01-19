library(httr)
library(dplyr)
library(tidyr)
library(TTR)
library(jsonlite)
library(ggplot2)
library(grid)
library(ggthemes)

gdax_url <- "https://api.gdax.com"
# gdax_prods <- get_gdax_products()

get_gdax_products <- function() {
  gdax_prods <- content(GET(gdax_url, path = "/products"), as = "text") %>%
    fromJSON() %>% select(id)
}

get_coin_data <- function(coin, timeslice) {
  timeslice <- as.numeric(timeslice) * 60
  coin_df <- GET(gdax_url, path = paste0("/products/", coin, "/candles"),
                 query = list(granularity=timeslice)) %>%
    content(as = "text") %>%
    fromJSON() %>%
    as.data.frame()

  colnames(coin_df) <- c("time", "low", "high", "open", "close", "volume")
  coin_df$datetime <- as.POSIXct(coin_df$time, origin="1970-01-01")
  coin_df <- coin_df[order(coin_df$time), ]

  macd <- data.frame(MACD(coin_df[, "close"]))

  final_df <- bind_cols(coin_df, macd) %>%
    select(datetime, close, macd, signal)
  return(final_df)
}

get_earnings_data <- function(coin_data) {
  actions <- coin_data %>%
    na.omit() %>%
    mutate(up = macd > signal,
           close_at_up = up * close,
           buy = up & (up > lag(up)),
           sell = close_at_up == 0 & lag(close_at_up) > 0) %>%
    filter(buy | sell) %>%
    select(datetime, buy, close)

  if(nrow(actions) %% 2 != 0) {
    actions <- actions[1:(nrow(actions)-1), ]
  }

  orders <- data.frame(buy_at = actions$datetime[actions$buy==TRUE],
                       buy_price = actions$close[actions$buy==TRUE],
                       sell_at = actions$datetime[actions$buy==FALSE],
                       sell_price = actions$close[actions$buy==FALSE]) %>%
    mutate(earnings = sell_price - buy_price)

  return(orders)
}

macd_plot <- function(macd_data, plot_title="Some Coin's Hourly Close Price") {
  macd_plot_df <- macd_data %>%
    na.omit() %>%
    mutate(up = macd > signal)

  p1 <- ggplot(macd_plot_df, aes(x=datetime)) +
    geom_point(aes(y=close, color=up)) +
    geom_line(aes(y=close), color="gray") +
    theme_hc(base_size = 20, bgcolor = "darkunica") +
    theme(legend.position = "top",
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_text(colour="white"),
          axis.text.x = element_blank()
          ) +
    ggtitle(plot_title)

  macd_plot_df <- macd_plot_df %>%
    select(-up) %>%
    gather(key = "stat", value = "value", -c(datetime, close))

  p2 <- ggplot(macd_plot_df, aes(x=datetime, y=value, color=stat)) +
    geom_line() +
    theme_hc(base_size = 20, bgcolor = "darkunica") +
    theme(legend.position = "bottom",
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_text(colour="white"),
          axis.text.y = element_text(colour="white")
          )

  grid.newpage()
  grid.draw(rbind(ggplotGrob(p1), ggplotGrob(p2), size = "first"))
}
