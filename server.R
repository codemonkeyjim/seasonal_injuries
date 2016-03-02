library(dplyr)
library(ggplot2)

shinyServer(function(input, output) {
  load('data/injuries.Rdata')

  # Seasonality of injuries
  # For each month generate a top-n list
  # Graph the full year of the top-n members

  # Determine the proportion of injuries per month per product code
  monthly <- injuries %>%
    group_by(prod1, month) %>%
    summarize(
      num = round(sum(weight))
    ) %>%
    mutate(
      portion = num / sum(num)
    )

  top_monthly <- monthly %>%
    group_by(month) %>%
    top_n(20, portion)

  output$top_n <- renderTable(top_monthly)
})
