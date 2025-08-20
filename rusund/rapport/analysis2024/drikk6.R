
## Nevner inkluderer de som ikke har drukket siste år også dvs. drukket1=2(Nei)
dt[, drink6 := fcase(Audit3 %in% 1:4, 1, #Daglig, ukenlig, månedlig og sjeldenere
                     Audit3 == 5, 0, #aldri
                     Drukket1 == 2, 0,
                     default = NA)]

drk6_24 <- proscat(x = "kj", y = "drink6", d = dt, total = TRUE)
kjonnkb <- data.table(v1 = 0:2, v2 = c("Menn", "Kvinner", "Totalt"))
alkokb <- data.table(v1 = 0:1, v2 = c("Aldri", "Drukket 6+"))
drk6_24[kjonnkb, on = c(kj = "v1"), gender := i.v2]
drk6_24[alkokb, on = c(drink6 = "v1"), alko := i.v2]
