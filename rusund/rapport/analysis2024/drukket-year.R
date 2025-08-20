## Andel som har drukket siste år i 2024
## -------------------------------------
dt[, Drukket1 := as.integer(Drukket1)]
dt[, alkosistaar := fifelse(Drukket1 == 8, NA, Drukket1)]

## Var values
alksistaar_values <- c(
  "drukket alkohol siste 12 mnd" = 1,
  "ikke drukket alkohol siste 12 mnd" = 2
)

dt[, kj := as.numeric(Kjonn)]
alko <- proscat_weighted(x = "kj", y = "alkosistaar", weight = vekt)

alkkb <- data.table(v1 = as.integer(alksistaar_values),
                    v2 = names(alksistaar_values))

alko[kjonnkb, on = c(kj = "v1"), gender := i.v2]
alko[alkkb, on = c(alkosistaar ="v1"), alkoyr := i.v2]
