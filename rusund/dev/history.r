## This analyses based on data from 2012 to 2024
## -----------------------------------------------

## This will produce a dataset called DD
source("c:/Users/ykama/Git-hdir/toa/rusund/rapport/dev/history-cleaning.R")

dim(DD)
skimr::skim(DD)

labelled::val_labels(DD$alder)
labelled::val_labels(DD$audit2)

labelled::var_label(DD$audit3)
labelled::val_labels(DD$audit3)

DD[, .N, keyby = kjonn] #Find what codes are there
kjonnVar <- DD[, .N, keyby = .(year, kjonn)]
unique(kjonnVar$kjonn)

DD[year %in% 2012:2016, .N, keyby = .(year, audit2)]
DD[year %in% 2017:2024, .N, keyby = .(year, audit2)]

labelled::var_label(DD$drukket1)
labelled::val_labels(DD$drukket1)
DD[, .N, keyby = drukket1]
DD[year %in% 2012:2016, .N, keyby = .(year, drukket1)]
DD[year %in% 2017:2024, .N, keyby = .(year, drukket1)]

## Andel som har drukket siste år
DD[, .N, keyby = .(year, drukket1)]

## ## Recode -----------
## DD[year == 2018, drukket1 := ifelse(drukket1 == 0, 2, drukket1)]
## DD[, alkosistaar := ifelse(drukket1 %in% 8:9, NA, drukket1)]
## ## --------------------

DD[, .N, keyby = .(year, alkosistaar)]

DD[, .N, keyby = .(kjonn)]
DD[kjonn == 0, .N, keyby = year]
DD[year == 2022, .N, keyby = .(kjonn)]
DD[year == 2022, .N, keyby = .(kjonn, drukket1)]
DD[year == 2024, .N, keyby = .(kjonn)]

## ## Recode -----------
## DD[year %in% c(2022,2024), kjonn := fcase(kjonn == 1, 2, #Kvinne
##                                           kjonn == 0, 1)] #Mann
## ## ------------------

## select - value for y to be selected
split_gender <- function(d, x, y, select, total = FALSE){

  all <- proscat(x = x, y = y, d=d, total = total)
  men <- proscat(x = x, y = y, d=d[kjonn == 1], total = total)
  wom <- proscat(x = x, y = y, d=d[kjonn == 2], total = total)

  ## For table
  all[, pop := "Alle"]
  men[, pop := "Menn"]
  wom[, pop := "Kvinner"]

  ## For figure
  allx <- all[get(y) == select][, pop := "Alle"]
  menx <- men[get(y) == select][, pop := "Menn"]
  womx <- wom[get(y) == select][, pop := "Kvinner"]

  dt <- data.table::rbindlist(list(all, men, wom))
  dtx <- data.table::rbindlist(list(allx, menx, womx))

  return(list(d1 = dt, d2 = dtx))
}



## Drukket siste år -------------
alkoAll <- proscat("year", "alkosistaar", d=DD, total = FALSE)

alkoAllMan <- proscat("year", "alkosistaar", d=DD[kjonn == 1,], total = FALSE)
alkoAllWom <- proscat("year", "alkosistaar", d=DD[kjonn == 2,], total = FALSE)

alkoAll[, pop := "Alle"]
alkoAllMan[, pop := "Menn"]
alkoAllWom[, pop := "Kvinner"]

alkoAllx <- alkoAll[alkosistaar == 1][, pop := "Alle"]
alkoAllManx <- alkoAllMan[alkosistaar == 1][, pop := "Menn"]
alkoAllWomx <- alkoAllWom[alkosistaar == 1][, pop := "Kvinner"]

alkoDT <- rbindlist(list(alkoAll, alkoAllMan, alkoAllWom))
alkoDTx <- rbindlist(list(alkoAllx, alkoAllManx, alkoAllWomx))

alkox <- split_gender(d = DD, x = "year", y = "alkosistaar", select = 1)

# Call your function with the combined data
make_hist(
  d = alkoDTx,
  x = year,
  y = percentage,
  group = pop,
  n = count,
  title = "Alkoholbruk siste år 2012-2024",
  type = "line"
)


## Har noen gang drukket -------------
## drukk1b



## Drikkefrekvens -----------------

alkodag <- proscat("year", "drukket2", d = DD, total = FALSE)
alkodag <- alkodag[drukket2!=9]
alkodag[, dk2 := as.factor(drukket2)]

create_bar(alkodag, "dk2")

alkodag[drukket2 %in% 1:2]

alkodag2 <- proscat("year", "drukk2a", d = DD, total = FALSE)
alkodag2 <- alkodag2[!(drukk2a %in% 8:9)]
alkodag2[, dk2a := as.numeric(drukk2a)]

create_bar(alkodag2, "dk2a")

alkodag3 <- proscat("year", "drukk2b", d = DD, total = FALSE)
alkodag3 <- alkodag3[!(drukk2b %in% 8:9)]
alkodag3[, dk2b := as.numeric(drukk2b)]

create_bar(alkodag3, "dk2b")

alkodag2c <- proscat("year", "drukk2c", d = DD, total = FALSE)
alkodag2c <- alkodag2c[!(drukk2c %in% 8:9)]
alkodag2c[, dk2c := as.numeric(drukk2c)]

create_bar(alkodag2c, "dk2c")

## ## Recode ---------
## DD[!(year %in% 2012:2013), alkodager := fcase(
##                              drukket2 == 1, 365,
##                              drukket2 == 2 & drukk2a == 1, 234,
##                              drukket2 == 2 & drukk2a == 2, 130,
##                              drukket2 == 2 & drukk2a == 3, 52,
##                              drukket2 == 3 & drukk2b == 1, 42,
##                              drukket2 == 3 & drukk2b == 2, 30,
##                              drukket2 == 3 & drukk2b == 3, 12,
##                              drukket2 == 4 & drukk2c == 1, 7.5,
##                              drukket2 == 4 & drukk2c == 2, 2.5,
##                              drukket2 == 4 & drukk2c == 3, 1,
##                              drukket2 == 9 |
##                              drukk2a == 8 |
##                              drukk2b == 9 |
##                              drukk2c %in% c(8, 9) |
##                              drukket1 %in% c(8, NA), NA_real_,
##                              default = 0
##                            )]


aldagMean <- DD[, mean(alkodager,na.rm = T), keyby = .(year)]
aldagMeanGender <- DD[, mean(alkodager,na.rm = T), keyby = .(year, kjonn)]



## Drukket 6+ samme anledning siste år -------------
var_label(DD$audit3)
val_labels(DD$audit3)
DD[, .N, keyby = audit3]
DD[, .N, keyby = .(year, audit3)]

(drink6 <- proscat("year", "audit3", d=DD, total = F))
## Range drinking daily with median. 2012-2024
drink6[, audit3 := as.numeric(audit3)]
val_labels(DD[year == 2012,]$audit3)
val_labels(DD[year == 2024,]$audit3)
make_hist(d=drink6, year, percentage, group = "audit3", title = "Drink 6+")

## ## Recode ------------------
## ## DD[, audit33 := audit3] # keep original
## DD[year %in% 2012:2014,  audit3 := fcase(audit3 == 5, 1,
##                                          audit3 == 4, 2,
##                                          audit3 == 2, 4,
##                                          audit3 == 1, 5,
##                                          default = as.numeric(audit3))]
## ## -----------------

## (drink66 <- proscat("year", "audit3", d=DD, total = F))
# DD[ year  %in% 2012:2014, .N, keyby = .(year, audit33, audit3)]



## Alder ---------

ageBreak <- c(16, 25, 35, 45, 55, 65, Inf)
ageLab <- c("16-24", "25-34", "35-44", "45-54", "55-64", "65+")

group_age(dt = DD, var = "alder", breaks = ageBreak,
          labels = ageLab, new_var = "agecat",
          right = FALSE, missing_values = c(999, 998))

DD[alder %in% c(998, 999), agecat := NA_character_]


d6w <- proscat("year", "drink6w", d = DD, total = F, z = "agecat")
d6wMen <- proscat("year", "drink6w", d = DD[kjonn == 1], total = F, z = "agecat")
d6wWom <- proscat("year", "drink6w", d = DD[kjonn == 2], total = F, z = "agecat")

d6w2 <- proscat_v2("year", "drink6w", d = DD, total = F, z = "agecat")
