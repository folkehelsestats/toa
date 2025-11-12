## Example to get prevelance adjusted for age and gender with 95%CI

source("c:/Users/ykama/Git-hdir/toa/rusund/setup.R")

odrive <- "O:\\Prosjekt\\Rusdata"
source(file.path(odrive, "folder-path.R"))
source(file.path(here::here(), "rusund/functions/fun-call.R"))

## Data 2012 - 2024
ddt <- readRDS(file.path(Rususdata, "Rusus_2012_2023", "data_2012_2024.rds"))
cleanFile <- file.path("rusund", "cleaning", "history", "history-cleaning.R")
## Datasettet ddt blir omdefinert her
source(file.path(here::here(), cleanFile))

library(survey)
library(emmeans)

# First, ensure alkosistaar is properly coded as 0/1
ddt[, alkosistaar2 := as.numeric(alkosistaar == 1)]

## Adjusted for age and gender
drink12 <- ddt[!is.na(alkosistaar2), {
  # Create survey design object
  svy_design <- svydesign(ids = ~1, weights = ~nyvekt2, data = .SD)

  # Fit weighted logistic regression
  model <- svyglm(alkosistaar2 ~ alder + kjonn,
                  design = svy_design,
                  family = binomial(link = "logit"))

  # Get estimated marginal means on the response scale
  em <- emmeans(model, ~ 1, type = "response")
  em_smry <- summary(em)

  data.table(
    adj_percentage = em_smry$prob * 100,
    SE = em_smry$SE * 100,
    lower_95CI = em_smry$asymp.LCL * 100,  # Note: asymp.LCL/UCL for svyglm
    upper_95CI = em_smry$asymp.UCL * 100
  )
}, by = year]
