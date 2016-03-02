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

save(injuries, file = 'data/injuries.Rdata')
