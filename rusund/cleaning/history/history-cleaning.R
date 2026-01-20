## Clean longitudinal data

## dataPath <- "O:\\Prosjekt\\Rusdata"
## source(file.path(dataPath, "folder-path.R"))

## source(here::here("rusund/setup.R"))
## ddt <- readRDS(file.path(Rususdata, "Rusus_2012_2023/arkiv/data_2012_2024.rds"))

## pth <- "~/Git-hdir/toa/rusund"
## source(file.path(pth, "functions.R"))

## Drukket siste 12 månedene
ddt[year == 2018, drukket1 := ifelse(drukket1 == 0, 2, drukket1)]
ddt[, alkosistaar := ifelse(drukket1 %in% 8:9, NA, drukket1)]

## Kjønn
ddt[year %in% c(2022,2024), kjonn := fcase(kjonn == 1, 2, #Kvinne
                                          kjonn == 0, 1)] #Mann

ddt[, kjonn := as.integer(kjonn)]

## Age
## ----------------
ddt[, alder := as.numeric(alder)]


## Exclude 2012 and 2013 since the answers are different for drukk2c than the others
## The recoding for frequency differ from Elin og Ingeborg. This one is the way Ingeborg defines it.
## Antall dager drukket alkohol siste år (blant siste års drikkere)
ddt[!(year %in% 2012:2013), alkodager := fcase(
                             drukket2 == 1, 365,
                             drukket2 == 2 & drukk2a == 1, 234,
                             drukket2 == 2 & drukk2a == 2, 130,
                             drukket2 == 2 & drukk2a == 3, 52, # differ
                             drukket2 == 3 & drukk2b == 1, 42, #
                             drukket2 == 3 & drukk2b == 2, 30,
                             drukket2 == 3 & drukk2b == 3, 12,
                             drukket2 == 4 & drukk2c == 1, 7.5, #
                             drukket2 == 4 & drukk2c == 2, 2.5, #
                             drukket2 == 4 & drukk2c == 3, 1,
                             drukket2 == 9 |
                             drukk2a == 8 |
                             drukk2b == 9 |
                             drukk2c %in% c(8, 9) |
                             drukket1 %in% c(8, NA), NA_real_,
                             default = 0
                           )]

## Coding for 2012 to 2014 was opposite
ddt[year %in% 2012:2014,  audit3 := fcase(audit3 == 5, 1,
                                         audit3 == 4, 2,
                                         audit3 == 2, 4,
                                         audit3 == 1, 5,
                                         default = as.numeric(audit3))]
