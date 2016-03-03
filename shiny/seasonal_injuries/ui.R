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
                  step = 5000)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Instructions",
          p('This tool will help you see the seasonality of product-based injuries. The underlying data is the number of US emergency room visits attributed to product classes in 2014. (More detail can be found on the Credits tab.)'),
          p('Products are filtered based on the proportion of total injuries that occurred in the selected month. The top N largest proportions are then graphed. Thus products with about the same number of injuries every month are filtered out.'),
          p('Use the ',em('Minimum total injuries'), 'slider to filter out products that caused few total injuries in 2014.'),
          p('The Plot tab shows the full year of injuries attributed to the named products, broken down by month.')
        ),
        tabPanel(
          "Plot",
          plotOutput('plot_grid')
        ),
        tabPanel(
          "Credits",
          p('The original data for this project comes from the US ',
            a(href='http://www.cpsc.gov/en/Research--Statistics/NEISS-Injury-Data/',
              'National Electronic Injury Surveillance System (NEISS)'),
            ' and it was converted to an R package by ',
            a(href='https://github.com/hadley/neiss', 'Hadley Wickham'),
            '.'
          ),
          p('This project was inspired by other analyses of the NEISS data on ',
            a(href='http://qz.com/609255/the-injuries-most-likely-to-land-you-in-an-emergency-room-in-america/', 'Quartz'),
            ' and ',
            a(href='http://flowingdata.com/2016/02/09/why-people-visit-the-emergency-room/', 'Flowing Data'),
            '.'
          ),
          p('The source for this project is available on ',
            a(href='https://github.com/codemonkeyjim/seasonal_injuries', 'GitHub'),
            '.'
          )
        )
      )
    )
  )
))

