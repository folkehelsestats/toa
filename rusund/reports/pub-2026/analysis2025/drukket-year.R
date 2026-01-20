## Andel som har drukket siste år i 2024
## -------------------------------------
dt[, drukket1 := as.integer(drukket1)]
dt[, alkosistaar := fifelse(drukket1 == 8, NA, drukket1)]

## Var values
alksistaar_values <- c(
  "drukket alkohol siste 12 mnd" = 1,
  "ikke drukket alkohol siste 12 mnd" = 2
)

dt[, kj := as.numeric(kjonn)]
alko <- proscat_weighted(x = "kj", y = "alkosistaar", weight = vekt)

alkkb <- data.table(v1 = as.integer(alksistaar_values),
                    v2 = names(alksistaar_values))

alko[kjonnkb, on = c(kj = "v1"), gender := i.v2]
alko[alkkb, on = c(alkosistaar ="v1"), alkoyr := i.v2]
