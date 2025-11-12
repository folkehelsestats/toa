## Bestilling fra GDB for data 2020 to 2024
## ----------------------------------------

source("c:/Users/ykama/Git-hdir/toa/rusund/setup.R")

odrive <- "O:\\Prosjekt\\Rusdata"
source(file.path(odrive, "folder-path.R"))
source(file.path(here::here(), "rusund/functions/fun-call.R"))

## Data 2012 - 2024
ddt <- readRDS(file.path(Rususdata, "Rusus_2012_2023", "data_2012_2024.rds"))
cleanFile <- file.path("rusund", "cleaning", "history", "history-cleaning.R")
## Datasettet ddt blir omdefinert her
source(file.path(here::here(), cleanFile))

dt <- ddt[year %in% 2020:2024] #as requested


## Fordeling etter kjønn og 5-årige aldersgrupper (eller 10-årige) for 2020 til
## 2024 med CI. Gjerne antall dager per måned alkoholkonsum framfor ja/nei
## drukket alkohol siste 12 måneder

## Alders kategorier ---
ageBreak5 <- c(16, 21, 26, 31, 36, 41, 46, 51, 56, 61, 66, 71, 76, Inf)
ageLab5 <- c("16-20", "21-25", "26-30", "31-35", "36-40",
            "41-45", "46-50", "51-55", "56-60", "61-65",
            "66-70", "71-75", "76-79")

group_age(dt = dt, var = "alder", breaks = ageBreak5,
          labels = ageLab5, new_var = "age5",
          right = FALSE, missing_values = c(999, 998))

ageBreak10 <- c(16, 25, 35, 45, 55, 65, Inf)
ageLab10 <- c("16-24", "25-34", "35-44", "45-54", "55-64", "65-79")

group_age(dt = dt, var = "alder", breaks = ageBreak10,
          labels = ageLab10, new_var = "age10",
          right = FALSE, missing_values = c(999, 998))


## Kjonn kodebook
kjonnval <- c("Menn" = 1, "Kvinner" = 2, "Alle" = 3)
kjonnkb <- data.table(v1 = as.integer(kjonnval),
                      v2 = names(kjonnval))

dt[, kjonnStr := fcase(kjonn == 1, "Menn",
                       kjonn == 2, "Kvinner")]

## 1. Andel =current drinkers= (drukket alkohol de siste 12 måneder)
## -----------------------------------------------------------------
source(file.path(here::here(), "misc/GBD/fun-prevalence-with-ci.R"))

## Crude
drinkCIx <- dt[, {
calc_prevalence(.SD, "alkosistaar")
}, by = .(year, kjonn)]

## Weighted
drinkCIw <- dt[, {
  calc_prevalence(.SD, "alkosistaar", weight = "nyvekt2")
}, keyby = .(year, kjonnStr)]

drinkCIwage <- dt[, {
  calc_prevalence(.SD, "alkosistaar", weight = "nyvekt2")
}, keyby = .(year, kjonnStr, age5)]

## 2. Drikkefrekvens - Antall dager siste 12 måneder
## -------------------------------------------------
source(file.path(here::here(), "misc/GBD/fun-prevalence-cat.R"))
                                        # Usage:
freqD <- dt[, {
  result <- calc_prevalence_category(.SD, "alkodager", weight = "nyvekt2")
  setnames(result, "category", "alkodager")
  result
}, by = .(year, kjonnStr)]

freqD <- freqD[, lapply(.SD, \(i) if(is.numeric(i)) round(i, 2) else i)]

## 3. Mengde forbruk (gram per dag)
## --------------------------------
source("https://raw.githubusercontent.com/folkehelsestats/toa/refs/heads/main/rusund/rapport/analysis2024/drikk-enheter.R")

## En enhet er 1.5cl
## Covert to gram by multiply the result with 8. coz 12/1.5 = 8
enhetKjonn <- dt[, {
  model <- lm(totalcl ~ alder, weights = nyvekt2, data = .SD)
  em <- emmeans(model, ~ 1)
  em_smry <- summary(em)
  data.table(
    adj_mean = em_smry$emmean,
    SE = em_smry$SE,
    lower_95CI = em_smry$lower.CL,
    upper_95CI = em_smry$upper.CL,
    adj_enhet = em_smry$emmean/1.5, # 1.5cl
    SE_enhet = em_smry$SE/1.5,
    lower_enhet = em_smry$lower.CL/1.5,
    upper_enhet = em_smry$upper.CL/1.5
  )
}, keyby = .(year, kjonnStr)]


enhetKjonn <- enhetKjonn[, lapply(.SD, \(i) if(is.numeric(i)) round(i, 2) else i)]

## Antall aldri drukket alkohol
## ---------------------------------
vekt <- "nyvekt2"
source("https://raw.githubusercontent.com/folkehelsestats/toa/refs/heads/main/rusund/rapport/analysis2024/drikk-frekvens.R")

dt[!is.na(alkofrekvens), ikkedrk := fifelse(alkofrekvens != 0, 0, 1)]
## dt[, .N, keyby = .(year, kjonn, ikkedrk)]

## z <- qnorm(1 - (1 - 0.95) / 2)
## ikkDrk <- dt[!is.na(ikkedrk), {
##   n_success <- sum(ikkedrk * nyvekt2)
##   n_total <- sum(nyvekt2)
##   pct <- n_success / n_total
##   se <- sqrt((pct * (1 - pct)) / n_total)
##   data.table(
##     n_weighted = n_success,
##     total_weighted = n_total,
##     percentage = pct * 100,
##     SE = se * 100,
##     low_CI = (pct - z * se) * 100,
##     up_CI = (pct + z * se) * 100
##   )
## }, keyby = .(year, kjonnStr)]

ikkDrk <- dt[, {
  calc_prevalence(.SD, "ikkedrk", weight = "nyvekt2")
}, keyby = .(year, kjonnStr)]

ikkDrk <- ikkDrk[, lapply(.SD, \(x) if(is.numeric(x)) round(x, 2) else x)]

## Antall som tidligere drakk alkohol, men ikke lenger
## ---------------------------------------------------

dt[!is.na(alkofrekvens), ikkedrknow := fifelse(alkofrekvens != 1, 0, 1)]

## z <- qnorm(1 - (1 - 0.95) / 2)
## ikkDrkNo <- dt[!is.na(ikkedrknow), {
##   n_success <- sum(ikkedrknow * nyvekt2)
##   n_total <- sum(nyvekt2)
##   pct <- n_success / n_total
##   se <- sqrt((pct * (1 - pct)) / n_total)
##   data.table(
##     n_weighted = n_success,
##     total_weighted = n_total,
##     percentage = pct * 100,
##     SE = se * 100,
##     low_CI = (pct - z * se) * 100,
##     up_CI = (pct + z * se) * 100
##   )
## }, keyby = .(year, kjonnStr)]

ikkDrkNo2 <- dt[, {
  calc_prevalence(.SD, "ikkedrknow", weight = "nyvekt2")
}, keyby = .(year, kjonnStr)]

ikkDrkNo <- ikkDrkNo[, lapply(.SD, \(x) if(is.numeric(x)) round(x, 2) else x)]


## Andel binge drinkers siste 12 måneder
## -------------------------------------
## Nevner inkluderer de som ikke har drukket siste år også dvs. drukket1=2(Nei)
dt[, drink6 := fcase(audit3 %in% 1:4, 1, #Daglig, ukenlig, månedlig og sjeldenere
                     audit3 == 5, 0, #aldri
                     drukket1 == 2, 0,
                     default = NA)]


drink6 <- dt[, {
  calc_prevalence(.SD, "drink6", weight = "nyvekt2")
}, keyby = .(year, kjonnStr, age5)]

drink6 <- drink6[, lapply(.SD, \(i) if(is.numeric(i)) round(i, 2) else i)]


### Downloads
### ------------
library(DT)

datatable(drink6,
          rownames = FALSE,  # This removes the row numbers
          extensions = 'Buttons',
          options = list(
            pageLength = 10,
            lengthMenu = c(10, 25, 50, 100),  # Let users choose
            dom = 'Blfrtip', #
            buttons = c('csv', 'excel')
          ))
