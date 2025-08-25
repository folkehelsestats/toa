## Alkohol enheter
## --------------

## -- ØL ---
# Drikker i snitt ukenlig
dt[, flaskeroluke := fcase(
  as.integer(Type1b_1) %in% c(99998, 99999), NA_real_,
  is.na(Type1b_1), 0,
  default = Type1b_1
)]

## OBS! Maks verdi er 102 her
dt[, halvliteroluke := fcase(
  as.integer(Type1b_2) %in% c(99998, 99999), NA_real_,
  is.na(Type1b_2), 0,
  default = Type1b_2
)]


## Drikker sjeldnere enn ukenlig dvs. totalt ila. siste fire uker
## OBS! Maks verdi her er 100. Skal den slettes?
dt[, flaskeroltot := fcase(
       as.integer(Type1c_1) %in% c(99998, 99999), NA_real_,
       is.na(Type1c_1), 0,
       default = Type1c_1
     )]


## OBS! Maks verdi her er 100. Skal den slettes?
dt[, halvlitertot := fcase(
       as.integer(Type1c_2) %in% c(99998, 99999), NA_real_,
       is.na(Type1c_2), 0,
       default = Type1c_2
     )]

# en flasker øl er en alkoholenhet
# en halvliter øl er 1,5 alkoholenhet
dt[, olenheter := (flaskeroluke + 1.5 * halvliteroluke) * 4 + flaskeroltot + 1.5 * halvlitertot]

## --- Vin ---
dt[, vinglassuke := fcase(
       as.integer(Type2b_1) %in% c(99998, 99999), NA_real_,
       is.na(Type2b_1), 0,
       default = Type2b_1
     )]

## var_label(dt$vinglassuke) <- "Gjennomsnitt antall glass vin ukenlig siste 4 uker"

## OBS! Maks verdi er 28. Skal den slettes?
dt[, vinflaskeruke := fcase(
       as.integer(Type2b_2) %in% c(99998, 99999), NA_real_,
       is.na(Type2b_2), 0,
       default = Type2b_2
     )]

## var_label(dt$vinflaskeruke) <- "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"


dt[, vinglasstot := fcase(
       as.integer(Type2c_1) %in% c(99998, 99999), NA_real_,
       is.na(Type2c_1), 0,
       default = Type2c_1
     )]

## var_label(dt$vinglasstot) <- "Antall glass vin totalt siste 4 uker"

## OBS! Maks verdi er 10. Skal den slettes?
dt[, vinflaskertot := fcase(
       as.integer(Type2c_2) %in% c(99998, 99999), NA_real_,
       is.na(Type2c_2), 0,
       default = Type2c_2
     )]

## var_label(dt$vinflaskertot) <- "Antall flasker vin totalt siste 4 uker"

dt[, vinenheter := (1.2 * vinglassuke + 6 * vinflaskeruke) * 4 + 1.2 * vinglasstot + 6 * vinflaskertot]

## -- Brennevin --
dt[, brennevinglassuke := fcase(
       as.integer(Type3b_1) %in% c(99998, 99999), NA_real_,
       is.na(Type3b_1), 0,
       default = Type3b_1
     )]


dt[, brennevinflaskeruke := fcase(
       as.integer(Type3b_2) %in% c(99998, 99999), NA_real_,
       is.na(Type3b_2), 0,
       default = Type3b_2
     )]


dt[, brennevinglasstot := fcase(
       as.integer(Type3c_1) %in% c(99998, 99999), NA_real_,
       is.na(Type3c_1), 0,
       default = Type3c_1
     )]


dt[, brennevinflaskertot := fcase(
       as.integer(Type3c_2) %in% c(99998, 99999), NA_real_,
       is.na(Type3c_2), 0,
       default = Type3c_2
     )]

dt[, brennevinenheter := (brennevinglassuke + 17.5 * brennevinflaskeruke) * 4 + brennevinglasstot + 17.5 * brennevinflaskertot]
## dt[, brennevinenheter2 := fcoalesce((brennevinglassuke + 18 * brennevinflaskeruke) * 4, 0) + fcoalesce(brennevinglasstot, 0) + fcoalesce(18 * brennevinflaskertot, 0)]

## -- Rusbrus --
dt[, rusbrussmaflaskeruke := fcase(
       as.integer(Type4b_1) %in% c(99998, 99999), NA_real_,
       is.na(Type4b_1), 0,
       default = Type4b_1
     )]

dt[, rusbrushalvliteruke := fcase(
       as.integer(Type4b_2) %in% c(99998, 99999), NA_real_,
       is.na(Type4b_2), 0,
       default = Type4b_2
     )]

dt[, rusbrussmaflasketot := fcase(
       as.integer(Type4c_1) %in% c(99998, 99999), NA_real_,
       is.na(Type4c_1), 0,
       default = Type4c_1
     )]

dt[, rusbrushalvlitertot := fcase(
       as.integer(Type4c_2) %in% c(99998, 99999), NA_real_,
       is.na(Type4c_2), 0,
       default = Type4c_2
     )]

dt[, rusbrusenheter := (rusbrussmaflaskeruke + 1.5 * rusbrushalvliteruke) * 4 +
     rusbrussmaflasketot + 1.5 * rusbrushalvlitertot]


## Beregning med alkoholenheter
## ----------------------------
dt[, alkoclol02 := olenheter*1.485] #øl 33cl 4.5%
## dt[, alkoclvin02 := vinenheter*1.8] #vin 15cl 12%
dt[, alkoclvin02 := vinenheter*1.4] #vin 12cl 12%
dt[, alkoclbrennevin02 := brennevinenheter*1.6] #brennevin 4cl 40%
dt[, alkoclrusbrus02 := rusbrusenheter*1.485] #rusbrus/cider 33cl 4.5%

## Total mengde ren alkohol siste fire uker
dt[, totalcl02 := alkoclol02 + alkoclvin02 + alkoclbrennevin02 + alkoclrusbrus02]
