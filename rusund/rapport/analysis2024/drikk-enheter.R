## Ren alkohol
## --------------

## -- ØL ---
# Drikker i snitt ukenlig
dt[, flaskeroluke := fcase(
  as.integer(type1b_1) %in% c(99998, 99999), NA_real_,
  is.na(type1b_1), 0,
  default = type1b_1
)]

## OBS! Maks verdi er 102 her
dt[, halvliteroluke := fcase(
  as.integer(type1b_2) %in% c(99998, 99999), NA_real_,
  is.na(type1b_2), 0,
  default = type1b_2
)]

## Drikker sjeldnere enn ukenlig dvs. totalt ila. siste fire uker
## OBS! Maks verdi her er 100. Skal den slettes?
dt[, flaskeroltot := fcase(
       as.integer(type1c_1) %in% c(99998, 99999), NA_real_,
       is.na(type1c_1), 0,
       default = type1c_1
     )]

## OBS! Maks verdi her er 100. Skal den slettes?
dt[, halvlitertot := fcase(
       as.integer(type1c_2) %in% c(99998, 99999), NA_real_,
       is.na(type1c_2), 0,
       default = type1c_2
     )]

## ren alkohol cl
dt[, olcl := (flaskeroluke * 1.485 + halvliteroluke * 2.25) * 4 +
       flaskeroltot * 1.485 + halvlitertot * 2.25]

## --- Vin ---
## "Gjennomsnitt antall glass vin ukenlig siste 4 uker"
dt[, vinglassuke := fcase(
       as.integer(type2b_1) %in% c(99998, 99999), NA_real_,
       is.na(type2b_1), 0,
       default = type2b_1
     )]

## "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"
## OBS! Maks verdi er 28. Skal den slettes?
dt[, vinflaskeruke := fcase(
       as.integer(type2b_2) %in% c(99998, 99999), NA_real_,
       is.na(type2b_2), 0,
       default = type2b_2
     )]

##"Antall glass vin totalt siste 4 uker"
dt[, vinglasstot := fcase(
       as.integer(type2c_1) %in% c(99998, 99999), NA_real_,
       is.na(type2c_1), 0,
       default = type2c_1
     )]

##"Antall flasker vin totalt siste 4 uker"
## OBS! Maks verdi er 10. Skal den slettes?
dt[, vinflaskertot := fcase(
       as.integer(type2c_2) %in% c(99998, 99999), NA_real_,
       is.na(type2c_2), 0,
       default = type2c_2
     )]

## delt med ren alkohol. Et glass vin er 1.5dl dvs. 1.8cl ren alkohol
dt[, vincl := (vinglassuke * 1.8 + vinflaskeruke * 9) * 4 +
       (vinglasstot * 1.8) + (vinflaskertot * 9)]

## -- Brennevin --
dt[, brennevinglassuke := fcase(
       as.integer(type3b_1) %in% c(99998, 99999), NA_real_,
       is.na(type3b_1), 0,
       default = type3b_1
     )]

dt[, brennevinflaskeruke := fcase(
       as.integer(type3b_2) %in% c(99998, 99999), NA_real_,
       is.na(type3b_2), 0,
       default = type3b_2
     )]

dt[, brennevinglasstot := fcase(
       as.integer(type3c_1) %in% c(99998, 99999), NA_real_,
       is.na(type3c_1), 0,
       default = type3c_1
     )]

dt[, brennevinflaskertot := fcase(
       as.integer(type3c_2) %in% c(99998, 99999), NA_real_,
       is.na(type3c_2), 0,
       default = type3c_2
     )]

## En flaske brennevin er 0.7l (Notat fra SSB spørreskjema 2024)
dt[, brenncl := (brennevinglassuke * 1.6 + brennevinflaskeruke * 28)*4 +
       brennevinglasstot * 1.6 + brennevinflaskertot * 28]

## -- Rusbrus --
dt[, rusbrussflaskeruke := fcase(
       as.integer(type4b_1) %in% c(99998, 99999), NA_real_,
       is.na(type4b_1), 0,
       default = type4b_1
     )]

dt[, rusbrushalvliteruke := fcase(
       as.integer(type4b_2) %in% c(99998, 99999), NA_real_,
       is.na(type4b_2), 0,
       default = type4b_2
     )]

dt[, rusbrussflaskertot := fcase(
       as.integer(type4c_1) %in% c(99998, 99999), NA_real_,
       is.na(type4c_1), 0,
       default = type4c_1
     )]

dt[, rusbrushalvlitertot := fcase(
       as.integer(type4c_2) %in% c(99998, 99999), NA_real_,
       is.na(type4c_2), 0,
       default = type4c_2
     )]

dt[, rusbruscl := (rusbrussflaskeruke * 1.485 + rusbrushalvliteruke * 2.25) * 4 +
       rusbrussflaskertot * 1.485 + rusbrushalvlitertot * 2.25]


## Total mengde ren alkohol siste fire uker
## ---------------------------------------
dt[, totalcl := olcl + vincl + brenncl + rusbruscl]
