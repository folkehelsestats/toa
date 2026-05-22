## Ren alkohol
## --------------

## -- ØL ---
# Drikker i snitt ukenlig
dt[, type1b_1 := as.numeric(type1b_1)][, flaskeroluke := fcase(
                                            type1b_1 > 99997, NA_real_,
                                            is.na(type1b_1), 0,
                                            default = type1b_1
                                          )]

## OBS! Maks verdi er 102 her
dt[, type1b_2 := as.numeric(type1b_2)][, halvliteroluke := fcase(
                                            type1b_2 > 99997, NA_real_,
                                            is.na(type1b_2), 0,
                                            default = type1b_2
                                          )]

## Drikker sjeldnere enn ukenlig dvs. totalt ila. siste fire uker
## OBS! Maks verdi her er 100. Skal den slettes?
dt[, type1c_1 := as.numeric(type1c_1)][, flaskeroltot := fcase(
                                            type1c_1 > 99997, NA_real_,
                                            is.na(type1c_1), 0,
                                            default = type1c_1
                                          )]

## OBS! Maks verdi her er 100. Skal den slettes?
dt[, type1c_2 := as.numeric(type1c_2)][, halvlitertot := fcase(
                                            type1c_2 > 99997, NA_real_,
                                            is.na(type1c_2), 0,
                                            default = type1c_2
                                          )]

## ren alkohol cl
dt[, olcl := (flaskeroluke * 1.485 + halvliteroluke * 2.25) * 4 +
       flaskeroltot * 1.485 + halvlitertot * 2.25]

## --- Vin ---
## "Gjennomsnitt antall glass vin ukenlig siste 4 uker"
dt[, type2b_1 := as.numeric(type2b_1)][, vinglassuke := fcase(
                                            type2b_1 > 99997, NA_real_,
                                            is.na(type2b_1), 0,
                                            default = type2b_1
                                          )]

## "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"
## OBS! Maks verdi er 28. Skal den slettes?
dt[, type2b_2 := as.numeric(type2b_2)][, vinflaskeruke := fcase(
                                            type2b_2 > 99997, NA_real_,
                                            is.na(type2b_2), 0,
                                            default = type2b_2
                                          )]

##"Antall glass vin totalt siste 4 uker"
dt[,type2c_1 := as.numeric(type2c_1)][, vinglasstot := fcase(
                                           type2c_1 > 99997, NA_real_,
                                           is.na(type2c_1), 0,
                                           default = type2c_1
                                         )]

##"Antall flasker vin totalt siste 4 uker"
## OBS! Maks verdi er 10. Skal den slettes?
dt[, type2c_2 := as.numeric(type2c_2)][, vinflaskertot := fcase(
                                            type2c_2 > 99997, NA_real_,
                                            is.na(type2c_2), 0,
                                            default = type2c_2
                                          )]

## delt med ren alkohol. Et glass vin er 1.5dl dvs. 1.8cl ren alkohol
dt[, vincl := (vinglassuke * 1.8 + vinflaskeruke * 9) * 4 +
       (vinglasstot * 1.8) + (vinflaskertot * 9)]

## -- Brennevin --
dt[, type3b_1 := as.numeric(type3b_1)][, brennevinglassuke := fcase(
                                            type3b_1 > 99997, NA_real_,
                                            is.na(type3b_1), 0,
                                            default = type3b_1
                                          )]

dt[, type3b_2 := as.numeric(type3b_2)][, brennevinflaskeruke := fcase(
                                            type3b_2 > 99997, NA_real_,
                                            is.na(type3b_2), 0,
                                            default = type3b_2
                                          )]

dt[, type3c_1 := as.numeric(type3c_1)][, brennevinglasstot := fcase(
                                            type3c_1 > 99997, NA_real_,
                                            is.na(type3c_1), 0,
                                            default = type3c_1
                                          )]

dt[, type3c_2 := as.numeric(type3c_2)][, brennevinflaskertot := fcase(
                                            type3c_2 > 99997, NA_real_,
                                            is.na(type3c_2), 0,
                                            default = type3c_2
                                          )]

## En flaske brennevin er 0.7l (Notat fra SSB spørreskjema 2024)
dt[, brennevincl := (brennevinglassuke * 1.6 + brennevinflaskeruke * 28)*4 +
       brennevinglasstot * 1.6 + brennevinflaskertot * 28]

## -- Rusbrus --
dt[, type4b_1 := as.numeric(type4b_1)][, rusbrusflaskeruke := fcase(
                                            type4b_1 > 99997, NA_real_,
                                            is.na(type4b_1), 0,
                                            default = type4b_1
                                          )]

dt[, type4b_2 := as.numeric(type4b_2)][, rusbrushalvliteruke := fcase(
                                            type4b_2 > 99997, NA_real_,
                                            is.na(type4b_2), 0,
                                            default = type4b_2
                                          )]

dt[, type4c_1 := as.numeric(type4c_1)][, rusbrusflaskertot := fcase(
                                            type4c_1 > 99997, NA_real_,
                                            is.na(type4c_1), 0,
                                            default = type4c_1
                                          )]

dt[, type4c_2 := as.numeric(type4c_2)][, rusbrushalvlitertot := fcase(
                                            type4c_2 > 99997, NA_real_,
                                            is.na(type4c_2), 0,
                                            default = type4c_2
                                          )]

dt[, rusbruscl := (rusbrusflaskeruke * 1.485 + rusbrushalvliteruke * 2.25) * 4 +
       rusbrusflaskertot * 1.485 + rusbrushalvlitertot * 2.25]


## Total mengde ren alkohol siste fire uker
## ---------------------------------------
dt[, totalcl := olcl + vincl + brennevincl + rusbruscl]
