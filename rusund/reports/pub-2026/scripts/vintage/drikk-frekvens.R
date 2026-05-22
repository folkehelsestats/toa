## Drikkefrekvens siste år
## -----------------------

dt[drukket1 == 1, alkofrekvens := fcase(
                    drukket2 == 1, 5,
                    drukket2 == 2, 4,
                    drukket2 == 3, 3,
                    drukket2 == 4, 2
                  )]
dt[drukket1 == 2, alkofrekvens := fcase(
                    drukk1b == 1, 1,
                    drukk1b == 2, 0
                  )]

alkofrekvens_values <- c(
    "aldri drukket" = 0,
    "ikke drukket siste år" = 1,
    "drukket sjeldnere enn månedlig siste 12 mnd" = 2,
    "drukket månedlig siste 12 mnd" = 3,
    "drukket ukentlig siste 12 mnd" = 4,
    "drukket daglig siste 12 mnd" = 5
)

dt[, kj := as.numeric(kjonn)]
alkofreq <- proscat_weighted("kj", "alkofrekvens", weight = vekt)

afKB <- data.table(v1 = as.integer(alkofrekvens_values),
                   v2 = names(alkofrekvens_values))

alkofreq[kjonnkb, on = c(kj = "v1"), gender := i.v2]
alkofreq[afKB, on = c(alkofrekvens = "v1"), alkof := i.v2]
