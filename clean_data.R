library(dplyr)
library(lubridate)
library(neiss)
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
products <- filter(products, code %in% unique(injuries$prod1) || code %in% unique(injuries$prod2))
injuries <- injuries %>%
  mutate(
    prod1 = factor(prod1, levels = products$code, labels = products$title),
    prod2 = factor(prod2, levels = products$code, labels = products$title)
  )

# Add additional columns
injuries <- injuries %>%
  mutate(
    dow = factor(weekdays(trmt_date), levels=c('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'))
  )
