## Convert pure alcohol to units
## type - columname for pure alcohol type measure eg. olcl, vincl etc
## cl - value for pure alcohol of one unit alcohol type
## unit - Unit to be converted and depends on the cl eg. 2.25 is 0.5l beer
convert_cl <- function(dt, type, cl, unit, digits = 1){
  gender <- dt[, round(mean(get(type), na.rm = T)/cl, digits = digits), keyby = kjonn]
  age <- dt[, round(mean(get(type), na.rm = T)/cl, digits = digits), keyby = agecat]
  ageGender <- dt[, round(mean(get(type), na.rm = T)/cl, digits = digits), keyby = .(kjonn, agecat)]

  age[, kjonn := 2]
  tbl <- data.table::rbindlist(list(age, ageGender), use.names = TRUE, ignore.attr = TRUE)
  tbl[, (unit) := round(V1, digits)][, V1 := NULL]

  ## kjonnkb can be found in file setup2024.R
  tbl[kjonnkb, on = c(kjonn = "v1"), gender := i.v2]
  tbl[, kjonn := NULL]
  data.table::setcolorder(tbl, c("gender", "agecat", unit))

  list(gender = gender, age = age, both = tbl)
}



## beer and rusbrus are similar
alcohol_unit <- function(ren_alkohol_cl, what = c("all", "beer", "wine", "spirit")) {
  # Alkoholmengde per enhet
  ol_enhet <- 50 * 0.045     # 0,5 l øl med 4,5 %
  vin_enhet12 <- 12.5 * 0.12     # 12.5 cl vin med 12 %
  vin_enhet15 <- 15 * 0.12     # 15 cl vin med 12 %
  sprit_enhet <- 4 * 0.40    # 4 cl sprit med 40 %

  # Beregning av antall enheter
  ol_antall <- round(ren_alkohol_cl / ol_enhet, digits = 1)
  vin_antall12 <- round(ren_alkohol_cl / vin_enhet12, digits = 1)
  vin_antall15 <- round(ren_alkohol_cl / vin_enhet15, digits = 1)
  sprit_antall <- round(ren_alkohol_cl / sprit_enhet, digits = 1)

  # Resultattabell
  dx <- data.frame(
    drink = c("Øl (50 cl, 4,5%)", "Vin (12.5 cl, 12%)", "Vin (15 cl, 12%)","Sprit (4 cl, 40%)"),
    unit = round(c(ol_antall, vin_antall12, vin_antall15, sprit_antall), 2)
  )

  dx$line <- 1:nrow(dx)
  return(dx)
}
