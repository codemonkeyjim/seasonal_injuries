library(dplyr)
library(ggplot2)

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

mon = 'Jan'
month_products <- subset(top_monthly, month %in% c(mon))$prod1

graph_data = monthly %>%
  filter(
    prod1 %in% (month_products)
  )

g <- ggplot(graph_data)
g <- g + geom_line(aes(month, num, group = 1))
g <- g + facet_wrap(~prod1, scales = 'free_y')
g
