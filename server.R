library(dplyr)
library(ggplot2)

load('data/injuries.Rdata')

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
