
## Global objects for 2024 skal være her
## ------------------------------------
## Vekting
dt[, nyvekt2 := VEKT/mean(VEKT, na.rm = T)]
vekt <- "VEKT" #use global object for weighting

## Gender values
kjonn_values <- c("Menn" = 0, "Kvinner" = 1, "Totalt" = 2)
kjonnkb <- data.table(v1 = as.integer(kjonn_values),
                      v2 = names(kjonn_values))
