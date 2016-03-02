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
                  max = 150000,
                  value = 10000,
                  step = 5000),
      helpText(
        p('This tool will help you see the seasonality of product-based injuries. The underlying data is the number of US emergency room visits attributed to product classes in 2014.'),
        p('The graphs to the right show the monthly injuries attributed to the named products.'),
        p('Products are filtered based on the proportion of total injuries that occurred in the selected month. The top N largest proportions are then graphed. Thus products with about the same number of injuries every month are filtered out.'),
        p('Use the ',em('Minimum total injuries'), 'slider to filter out products that caused few total injuries in 2014.')
      )
    ),
    mainPanel(
      htmlOutput('top_n'),
      plotOutput('plot_grid')
    )
  )
))

