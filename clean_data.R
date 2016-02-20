library(dplyr)
library(lubridate)
library(neiss)
data("injuries")
data("products")

# Limit to 2014 injuries
injuries_2014 <- filter(injuries, year(trmt_date) == 2014)

injuries <- injuries_2014 %>%
  mutate(
    age = ifelse(age == 0, NA, age),
    sex = factor(sex, level = c('Female', 'Male')),
    race = factor(race, exclude = c('None listed'))
  ) %>%
  select(-race_other)
