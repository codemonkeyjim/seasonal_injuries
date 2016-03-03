# Cache the filtered data to make the Shiny app small enough to run on a free account

if (length(find.package('neiss', quiet = TRUE)) == 0) {
  if (length(find.package('devtools', quiet = TRUE)) == 0) {
    install.packages('devtools')
  }
  devtools::install_github("hadley/neiss")
}

library(dplyr)
library(lubridate)
library(neiss)

data("injuries")
data("products")

# Limit to 2014 injuries and clean up data
injuries <- injuries %>%
  filter(year(trmt_date) == 2014) %>%
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

remove(injuries) # To save memory
save(yearly, file = 'shiny/seasonal_injuries/data/yearly.Rdata')
save(monthly, file = 'shiny/seasonal_injuries/data/monthly.Rdata')
