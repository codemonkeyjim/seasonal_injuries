if (length(find.package('neiss', quiet = TRUE)) == 0) {
  if (length(find.package('devtools', quiet = TRUE)) == 0) {
    install.packages('devtools')
  }
  devtools::install_github("hadley/neiss")
}

library(dplyr)
library(lubridate)
library(neiss)
library(ggplot2)

data("injuries")
data("products")

# Limit to 2014 injuries
injuries_2014 <- filter(injuries, year(trmt_date) == 2014)

# Clean up data
injuries <- injuries_2014 %>%
  mutate(
    psu = factor(psu),
    stratum = factor(
      stratum,
      levels = c('S', 'M', 'L', 'V', 'C'),
      labels = c('Small', 'Medium', 'Large', 'Very Large', 'Children\'s')),
    age = ifelse(age == 0, NA, age),
    sex = factor(sex, levels = c('Female', 'Male')),
    race = factor(race, exclude = c('None listed')),
    body_part = factor(body_part),
    fmv = factor(fmv),
    diag = factor(diag),
    disposition = factor(disposition),
    location = factor(location)
  ) %>%
  rename(hospital = psu, fire_dept = fmv, diagnosis = diag) %>%
  select(-race_other, -diag_other)

# Apply product codes
# Eliminate duplicate product codes by only using ones needed for this subset of injuries
product_codes <- products %>%
  filter(code %in% unique(c(injuries$prod1, injuries$prod2)))

injuries <- injuries %>%
  mutate(
    prod1 = factor(prod1, levels = product_codes$code, labels = product_codes$title),
    prod2 = factor(prod2, levels = product_codes$code, labels = product_codes$title)
  )

# Add additional columns
injuries <- injuries %>%
  mutate(
    dow = factor(
      weekdays(trmt_date),
      levels=c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')),
    month = factor(
      month(trmt_date),
      levels = (1:12),
      #       labels=c(
      #         'January', 'February', 'March',
      #         'April', 'May', 'June',
      #         'July', 'August', 'September',
      #         'October', 'November', 'December'))
      labels=c(
        'Jan', 'Feb', 'Mar',
        'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep',
        'Oct', 'Nov', 'Dec'))
  )

# Determine the proportion of injuries per month per product code
monthly <- injuries %>%
  group_by(prod1, month) %>%
  summarize(
    num = round(sum(weight))
  ) %>%
  mutate(
    portion = num / sum(num)
  )

yearly <- injuries %>%
  group_by(prod1) %>%
  summarize(
    num = round(sum(weight))
  )

shinyServer(function(input, output, clientData, session) {

  min_inj_products <- reactive({
    subset(yearly, num >= input$min_injuries)$prod1
  })

  top_monthly <- reactive({
    monthly %>%
      filter(prod1 %in% min_inj_products()) %>%
      group_by(month) %>%
      top_n(input$n, portion)
  })

  month_products <- reactive({
    subset(top_monthly(), month %in% c(input$month))$prod1
  })

  graph_data <- reactive({
    monthly %>%
      filter(
        prod1 %in% (month_products())
      )
  })

  plot_grid <- reactive({
    ggplot(graph_data()) +
      geom_line(aes(month, num, group = 1)) +
      facet_wrap(~prod1, scales = 'free_y') +
      labs(x = 'Month', y = 'Injuries')
  })

#   observe({
#     updateSliderInput(session, 'min_injuries', max = max(yearly$num))
#   })

  # output$top_n <- renderTable(graph_data())
  output$plot_grid <- renderPlot(plot_grid())
})
