macd_plot <- function(macd_data) {
  btc_macd_plot <- macd_data %>%
    na.omit() %>%
    mutate(up = macd > signal)

  p1 <- ggplot(btc_macd_plot, aes(x=datetime)) +
    geom_point(aes(y=close, color=up)) +
    theme_minimal() +
    theme(legend.position = "top",
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.x = element_blank()) +
    scale_y_continuous(labels = scales::dollar) +
    ggtitle("BTC-USD Hourly Close Price")

  btc_macd_plot <- btc_macd_plot %>%
    select(-up) %>%
    gather(key = "stat", value = "value", -c(datetime, close))

  p2 <- ggplot(btc_macd_plot, aes(x=datetime, y=value, color=stat)) +
    geom_line() +
    theme_minimal() +
    theme(legend.position = "bottom",
          axis.title.x = element_blank(),
          axis.title.y = element_blank())

  grid.newpage()
  grid.draw(rbind(ggplotGrob(p1), ggplotGrob(p2), size = "first"))
}
