
## Ren alkohol
## --------------

## -- ØL ---
# Drikker i snitt ukenlig
ddt[, type1b_1 := as.numeric(type1b_1)][, flaskeroluke := fcase(
                                            type1b_1 > 99997, NA_real_,
                                            is.na(type1b_1), 0,
                                            default = type1b_1
                                          )]

## OBS! Maks verdi er 102 her
ddt[, type1b_2 := as.numeric(type1b_2)][, halvliteroluke := fcase(
                                            type1b_2 > 99997, NA_real_,
                                            is.na(type1b_2), 0,
                                            default = type1b_2
                                          )]

## Drikker sjeldnere enn ukenlig dvs. totalt ila. siste fire uker
## OBS! Maks verdi her er 100. Skal den slettes?
ddt[, type1c_1 := as.numeric(type1c_1)][, flaskeroltot := fcase(
                                            type1c_1 > 99997, NA_real_,
                                            is.na(type1c_1), 0,
                                            default = type1c_1
                                          )]

## OBS! Maks verdi her er 100. Skal den slettes?
ddt[, type1c_2 := as.numeric(type1c_2)][, halvlitertot := fcase(
                                            type1c_2 > 99997, NA_real_,
                                            is.na(type1c_2), 0,
                                            default = type1c_2
                                          )]

## ren alkohol cl
ddt[, olcl := (flaskeroluke * 1.485 + halvliteroluke * 2.25) * 4 +
       flaskeroltot * 1.485 + halvlitertot * 2.25]


## --- Vin ---
## "Gjennomsnitt antall glass vin ukenlig siste 4 uker"
ddt[, type2b_1 := as.numeric(type2b_1)][, vinglassuke := fcase(
                                            type2b_1 > 99997, NA_real_,
                                            is.na(type2b_1), 0,
                                            default = type2b_1
                                          )]

## "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"
## OBS! Maks verdi er 28. Skal den slettes?
ddt[, type2b_2 := as.numeric(type2b_2)][, vinflaskeruke := fcase(
                                            type2b_2 > 99997, NA_real_,
                                            is.na(type2b_2), 0,
                                            default = type2b_2
                                          )]

##"Antall glass vin totalt siste 4 uker"
ddt[,type2c_1 := as.numeric(type2c_1)][, vinglasstot := fcase(
                                           type2c_1 > 99997, NA_real_,
                                           is.na(type2c_1), 0,
                                           default = type2c_1
                                         )]

##"Antall flasker vin totalt siste 4 uker"
## OBS! Maks verdi er 10. Skal den slettes?
ddt[, type2c_2 := as.numeric(type2c_2)][, vinflaskertot := fcase(
                                            type2c_2 > 99997, NA_real_,
                                            is.na(type2c_2), 0,
                                            default = type2c_2
                                          )]

## delt med ren alkohol. Et glass vin er 1.5dl dvs. 1.8cl ren alkohol
ddt[, vincl := (vinglassuke * 1.8 + vinflaskeruke * 9) * 4 +
       (vinglasstot * 1.8) + (vinflaskertot * 9)]

## -- Brennevin --
ddt[, type3b_1 := as.numeric(type3b_1)][, brennevinglassuke := fcase(
                                            type3b_1 > 99997, NA_real_,
                                            is.na(type3b_1), 0,
                                            default = type3b_1
                                          )]

ddt[, type3b_2 := as.numeric(type3b_2)][, brennevinflaskeruke := fcase(
                                            type3b_2 > 99997, NA_real_,
                                            is.na(type3b_2), 0,
                                            default = type3b_2
                                          )]

ddt[, type3c_1 := as.numeric(type3c_1)][, brennevinglasstot := fcase(
                                            type3c_1 > 99997, NA_real_,
                                            is.na(type3c_1), 0,
                                            default = type3c_1
                                          )]

ddt[, type3c_2 := as.numeric(type3c_2)][, brennevinflaskertot := fcase(
                                            type3c_2 > 99997, NA_real_,
                                            is.na(type3c_2), 0,
                                            default = type3c_2
                                          )]

## En flaske brennevin er 0.7l (Notat fra SSB spørreskjema 2024)
ddt[, brenncl := (brennevinglassuke * 1.6 + brennevinflaskeruke * 28)*4 +
       brennevinglasstot * 1.6 + brennevinflaskertot * 28]

## -- Rusbrus --
ddt[, type4b_1 := as.numeric(type4b_1)][, rusbrussflaskeruke := fcase(
                                            type4b_1 > 99997, NA_real_,
                                            is.na(type4b_1), 0,
                                            default = type4b_1
                                          )]

ddt[, type4b_2 := as.numeric(type4b_2)][, rusbrushalvliteruke := fcase(
                                            type4b_2 > 99997, NA_real_,
                                            is.na(type4b_2), 0,
                                            default = type4b_2
                                          )]

ddt[, type4c_1 := as.numeric(type4c_1)][, rusbrussflaskertot := fcase(
                                            type4c_1 > 99997, NA_real_,
                                            is.na(type4c_1), 0,
                                            default = type4c_1
                                          )]

ddt[, type4c_2 := as.numeric(type4c_2)][, rusbrushalvlitertot := fcase(
                                            type4c_2 > 99997, NA_real_,
                                            is.na(type4c_2), 0,
                                            default = type4c_2
                                          )]

ddt[, rusbruscl := (rusbrussflaskeruke * 1.485 + rusbrushalvliteruke * 2.25) * 4 +
       rusbrussflaskertot * 1.485 + rusbrushalvlitertot * 2.25]


## Total mengde ren alkohol siste fire uker
## ---------------------------------------
ddt[, totalcl := olcl + vincl + brenncl + rusbruscl]


## ddt[, .(mean(totalcl, na.rm = T)), keyby = year]

## Adjust for kjønn og alder
## -------------------------

## alkomod <- lm(totalcl ~ alder + kjonn, data = ddt, weights = nyvekt2)

## alkocl <- ddt[, .(coef = coef(lm(totalcl ~ alder + kjonn, weights = nyvekt2))[1],
##                   ll = confint(lm(totalcl ~ alder + kjonn, weights = nyvekt2))[1, 1],
##                   ul = confint(lm(totalcl ~ alder + kjonn, weights = nyvekt2))[1, 2]), keyby = year]

## alkocluv <- ddt[, .(coef = coef(lm(totalcl ~ alder + kjonn))[1],
##                   ll = confint(lm(totalcl ~ alder + kjonn))[1, 1],
##                   ul = confint(lm(totalcl ~ alder + kjonn))[1, 2]), keyby = year]


library(emmeans) # for adjusted means


## list_data <- purrr::map2(enhetTbl$lower_enhet, enhetTbl$upper_enhet, ~ list(low = .x, high = .y))
## list_data <- mapply(function(low, high) list(low = low, high = high),
##                          enhetTbl$lower_enhet, enhetTbl$upper_enhet,
##                          SIMPLIFY = FALSE)

## highchart() |>
##   hc_chart(type = "line") |>
##   hc_title(text = "Alkohol bruk siste 4 uker") |>
##   hc_xAxis(categories = enhetTbl$year) |>
##   hc_yAxis(
##     title = list(text = "Alkoholeneheter"),
##     min = 0 ) |>
##   hc_add_series(name = "Antall", data = enhetTbl$adj_enhet, type = "line") |>
##   hc_add_series(
##     name = "95% CI",
##     data = list_data,
##     type = "arearange",
##     linkedTo = ":previous",
##     color = hex_to_rgba("#7cb5ec", 0.3),
##     fillOpacity = 0.3
##   ) |>
##   hc_tooltip(shared = TRUE) |>
##   hc_exporting(enabled = TRUE)
