
## Global objects for 2024 skal være her
## ------------------------------------

oldCols <- names(dt)
newCols <- tolower(oldCols)
data.table::setnames(dt, oldCols, newCols)


## Vekting
dt[, nyvekt2 := vekt/mean(vekt, na.rm = T)]
vekt <- "vekt" #use global object for weighting

## Gender values
kjonn_values <- c("Menn" = 0, "Kvinner" = 1, "Alle" = 3)
kjonnkb <- data.table(v1 = as.integer(kjonn_values),
                      v2 = names(kjonn_values))

## Alders kategorier ---
ageBreak <- c(16, 25, 35, 45, 55, 65, Inf)
ageLab <- c("16-24", "25-34", "35-44", "45-54", "55-64", "65-79")

group_age(dt = dt, var = "alder", breaks = ageBreak,
          labels = ageLab, new_var = "agecat",
          right = FALSE, missing_values = c(999, 998))

## group_age_standard(dt = dt,
##                    var = "alder",
##                    type = "rusund",
##                    new_var = "agecat",
##                    missing_values = c(999, 998))
