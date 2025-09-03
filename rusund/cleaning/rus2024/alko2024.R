## Analyser for 2024 dataene
## --------------------------
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library("here")

source(file.path(here::here(), "rusund/setup.R"))
source(file.path(here::here(), "rusund/functions/fun-call.R"))
dataPath <- "O:\\Prosjekt\\Rusdata"

## Data 2024
DT <- readRDS(file.path(dataPath, "Rusundersøkelsen", "Rusus 2024","rus2024.rds"))
dt <- as.data.table(DT)

pth2024 <- file.path(here::here(), "rusund", "rapport")
source(file.path(pth2024, "analysis2024/setup2024.R"))

## Drukket year
## -------------
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

### Figur
make_hist(d = alko,
          x = gender,
          y = percentage,
          group = alkoyr,
          n = count,
          title = "Alkohol siste 12 måneder")

### Tabell
cols <- c("kj", "alkosistaar", "sum", "weighted_count")
alko[, (cols) := NULL]

colout <- c("alkoyr", "gender", "count", "percentage")
colns <- c(" ", "Kjønn", "Antall", "Andel")
setcolorder(alko, colout)
data.table::setnames(alko, colout, colns, skip_absent = TRUE)

gt::gt(alko)

## Drikkefrekvens siste år
## ------------------------
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

### Figur
alkofreq[, alkofrekvens := as.numeric(alkofrekvens)]

make_hist(d = alkofreq,
          x = gender,
          y = percentage,
          group = alkof,
          n = count,
          title = "Drikkerfrekvens siste 12 måneder")

### Tabell
cols <- c("kj", "alkofrekvens", "sum", "weighted_count")
alkofreq[, (cols) := NULL]

colout <- c("alkof", "gender", "count", "percentage")
colns <- c(" ", "Kjønn", "Antall", "Andel")
setcolorder(alkofreq, colout)
data.table::setnames(alkofreq, colout, colns)

gt::gt(alkofreq)

# ---------------------------------
## Andel drukket 6+ enheter siste år

# Nevner inkluderer de som ikke har drukket siste år også dvs. drukket1=2(Nei)
dt[, drink6 := fcase(audit3 %in% 1:4, 1, #Daglig, ukenlig, månedlig og sjeldenere
                     audit3 == 5, 0, #aldri
                     drukket1 == 2, 0,
                     default = NA)]

drk6_24 <- proscat_weighted(x = "kj", y = "drink6", d = dt, weight = vekt, total = TRUE)

alkokb <- data.table(v1 = 0:1, v2 = c("Aldri", "Drukket 6+"))
drk6_24[kjonnkb, on = c(kj = "v1"), gender := i.v2]
drk6_24[alkokb, on = c(drink6 = "v1"), alko := i.v2]

### Figure
make_hist(d = drk6_24,
          x = gender,
          y = percentage,
          group = alko,
          n = count,
          title = "Andel drukket 6+ enheter en og samme anledning siste år")

### Tabell
cols <- c("kj", "drink6", "sum", "weighted_count")
drk6_24[, (cols) := NULL]

colout <- c("alko", "gender", "count", "percentage")
colns <- c(" ", "Kjønn", "Antall", "Andel")
setcolorder(drk6_24, colout)
data.table::setnames(drk6_24, colout, colns)

gt::gt(drk6_24)


# -------------------
## Hvor mye drikker vi
# -------------------
### -- ØL ---
# Drikker i snitt ukenlig
dt[, flaskeroluke := fcase(
  as.integer(type1b_1) %in% c(99998, 99999), NA_real_,
  is.na(type1b_1), 0,
  default = type1b_1
)]

# OBS! Maks verdi er 102 her
dt[, halvliteroluke := fcase(
  as.integer(type1b_2) %in% c(99998, 99999), NA_real_,
  is.na(type1b_2), 0,
  default = type1b_2
)]

# Drikker sjeldnere enn ukenlig dvs. totalt ila. siste fire uker
# OBS! Maks verdi her er 100. Skal den slettes?
dt[, flaskeroltot := fcase(
       as.integer(type1c_1) %in% c(99998, 99999), NA_real_,
       is.na(type1c_1), 0,
       default = type1c_1
     )]

# OBS! Maks verdi her er 100. Skal den slettes?
dt[, halvlitertot := fcase(
       as.integer(type1c_2) %in% c(99998, 99999), NA_real_,
       is.na(type1c_2), 0,
       default = type1c_2
     )]

# ren alkohol cl
dt[, olcl := (flaskeroluke * 1.485 + halvliteroluke * 2.25) * 4 +
       flaskeroltot * 1.485 + halvlitertot * 2.25]

### --- Vin ---
# "Gjennomsnitt antall glass vin ukenlig siste 4 uker"
dt[, vinglassuke := fcase(
       as.integer(type2b_1) %in% c(99998, 99999), NA_real_,
       is.na(type2b_1), 0,
       default = type2b_1
     )]

# "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"
# OBS! Maks verdi er 28. Skal den slettes?
dt[, vinflaskeruke := fcase(
       as.integer(type2b_2) %in% c(99998, 99999), NA_real_,
       is.na(type2b_2), 0,
       default = type2b_2
     )]

#"Antall glass vin totalt siste 4 uker"
dt[, vinglasstot := fcase(
       as.integer(type2c_1) %in% c(99998, 99999), NA_real_,
       is.na(type2c_1), 0,
       default = type2c_1
     )]

#"Antall flasker vin totalt siste 4 uker"
# OBS! Maks verdi er 10. Skal den slettes?
dt[, vinflaskertot := fcase(
       as.integer(type2c_2) %in% c(99998, 99999), NA_real_,
       is.na(type2c_2), 0,
       default = type2c_2
     )]

# delt med ren alkohol. Et glass vin er 1.5dl dvs. 1.8cl ren alkohol
dt[, vincl := (vinglassuke * 1.8 + vinflaskeruke * 9) * 4 +
       (vinglasstot * 1.8) + (vinflaskertot * 9)]

### -- Brennevin --
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

### -- Rusbrus --
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
dt[, totalcl := olcl + vincl + brenncl + rusbruscl]

### Øl halvliter
# 0.5l øl 2.25 cl ren alkohol

kjonncl <- dt[, round(mean(olcl, na.rm = T)/2.25, digits = 1), keyby = kjonn]
aldercl <- dt[, mean(olcl, na.rm = T)/2.25, keyby = agecat]
alderKjcl <- dt[, mean(olcl, na.rm = T)/2.25, keyby = .(kjonn, agecat)]

aldercl[, kjonn := 2]
tabcl <- data.table::rbindlist(list(aldercl, alderKjcl), use.names = TRUE, ignore.attr = T)
tabcl[, halvliter := round(V1, 1)][, V1 := NULL]

### Figur
tabcl[kjonnkb, on = c(kjonn = "v1"), gender := i.v2]
tabcl[, kjonn := NULL]
data.table::setcolorder(tabcl, c("gender", "agecat", "halvliter"))

simple_hist(tabcl,
            x = agecat,
            y = halvliter,
            group = gender,
            title = "Antall halvlitere øl drukket siste 4 uker")


