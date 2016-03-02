shinyUI(fluidPage(
  titlePanel("Seasonality of Product Injuries"),

  sidebarLayout(
    sidebarPanel(
      numericInput('n',
                   label = strong('Top N'),
                   value = 10,
                   step = 5,
                   min = 5),
      selectizeInput('month',
                     label = strong('Month'),
                     choices = list('Jan', 'Feb', 'Mar',
                                    'Apr', 'May', 'Jun',
                                    'Jul', 'Aug', 'Sep',
                                    'Oct', 'Nov', 'Dec')),
      sliderInput('min_injuries',
                  "Minimum total injuries",
                  min = 0,
                  max = 250000,
                  value = 0,
                  step = 10000)
    ),
    mainPanel(
      htmlOutput('top_n'),
      plotOutput('plot_grid')
    )
  )
))

