# ---------------------------
## Analyser for 2024 dataene
# --------------------------
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library("here")

source(file.path(here::here(), "rusund/setup.R"))
source(file.path(here::here(), "rusund/functions/fun-call.R"))
dataPath <- "O:\\Prosjekt\\Rusdata"
source(file.path(dataPath, "folder-path.R"))

DT <- readRDS(file.path(Rususdata, "Rusus_2024","rus2024.rds"))
dt <- as.data.table(DT)

pth2024 <- file.path(here::here(), "rusund", "rapport")
source(file.path(pth2024, "analysis2024/setup2024.R"))

# -------------
## Drukket year
dt[, drukket1 := as.integer(drukket1)]
dt[, alkosistaar := fifelse(drukket1 == 8, NA, drukket1)]

# Var values
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
# ------------------------
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

# Delt med ren alkohol. En enhent 15ml ren alkohol tilsvarer 1.25dl vin
# 1.5dl vin (spørreskjema) tilsvarer 1.8 cl ren alkohol er 1.8/1.5 = 1.2 dl enhet
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

# En flaske brennevin er 0.7l (Notat fra SSB spørreskjema 2024)
dt[, brennevincl := (brennevinglassuke * 1.6 + brennevinflaskeruke * 28)*4 +
       brennevinglasstot * 1.6 + brennevinflaskertot * 28]

### -- Rusbrus --
dt[, rusbrusflaskeruke := fcase(
       as.integer(type4b_1) %in% c(99998, 99999), NA_real_,
       is.na(type4b_1), 0,
       default = type4b_1
     )]

dt[, rusbrushalvliteruke := fcase(
       as.integer(type4b_2) %in% c(99998, 99999), NA_real_,
       is.na(type4b_2), 0,
       default = type4b_2
     )]

dt[, rusbrusflaskertot := fcase(
       as.integer(type4c_1) %in% c(99998, 99999), NA_real_,
       is.na(type4c_1), 0,
       default = type4c_1
     )]

dt[, rusbrushalvlitertot := fcase(
       as.integer(type4c_2) %in% c(99998, 99999), NA_real_,
       is.na(type4c_2), 0,
       default = type4c_2
     )]

# rusbrusflasker 0.33l
dt[, rusbruscl := (rusbrusflaskeruke * 1.485 + rusbrushalvliteruke * 2.25) * 4 +
       rusbrusflaskertot * 1.485 + rusbrushalvlitertot * 2.25]

### Total mengde ren alkohol siste fire uker
dt[, totalcl := olcl + vincl + brennevincl + rusbruscl]

### Øl halvliter
# 0.5l øl 2.25 cl ren alkohol
# 33cl øl 1.485 cl ren alkohol
beer <- convert_cl(dt, "olcl", cl = 1.485, unit = "enhet")

#### Figur
simple_hist(beer$both,
            x = agecat,
            y = enhet,
            group = gender,
            title = "Antall øl enheter drukket siste 4 uker (33cl)")

### Vin
# En enhet vin 12.5cl er 1.5 cl ren alkohol
wine <- convert_cl(dt, "vincl", cl = 1.5, unit = "vinglass")

#### Figur
simple_hist(wine$both,
            x = agecat,
            y = vinglass,
            group = gender,
            title = "Antall vin enheter drukket siste 4 uker (12.5cl)")

### Brennevin
# Et glass 4cl brennevin er 1.6cl ren alkohol
brenn <- convert_cl(dt, "brennevincl", cl = 1.6, unit = "glass")

#### Figur
simple_hist(brenn$both,
            x = agecat,
            y = glass,
            group = gender,
            title = "Antall brennevin enheter drukket siste 4 uker (4cl)")

### Rusbrus
# En flaske 0.33l er 1.485 cl ren alkohol
rusbrus <- convert_cl(dt, "rusbruscl", cl = 1.485, "flaske")

#### Figur
simple_hist(rusbrus$both,
            x = agecat,
            y = flaske,
            group = gender,
            title = "Antall rusbrus enheter drukket siste 4 uker (33cl)")

### Total ren alkohol
genderAlk <- dt[, round(mean(totalcl, na.rm = T), digits = 1), keyby = kjonn]
ageAlk <- dt[, round(mean(totalcl, na.rm = T), digits = 1), keyby = agecat]
ageGenderAlk <- dt[, round(mean(totalcl, na.rm = T), digits = 1), keyby = .(kjonn, agecat)]

ageAlk[, kjonn := 2]
tblAlk <- data.table::rbindlist(list(ageAlk, ageGenderAlk), use.names = TRUE, ignore.attr = TRUE)
tblAlk[, Alkohol := round(V1, 1)][, V1 := NULL]

# kjonnkb can be found in file setup2024.R
tblAlk[kjonnkb, on = c(kjonn = "v1"), gender := i.v2]
tblAlk[, kjonn := NULL]
data.table::setcolorder(tblAlk, c("gender", "agecat", "Alkohol"))

#### Figur
simple_hist(tblAlk,
            x = agecat,
            y = Alkohol,
            yint = 5,
            ytitle = "Centiliter ren alkohol",
            group = gender,
            title = "Total mengde alkohol konsumet siste 4 uker (cl)")

### Ren alkohol per drikkesort
drikksortcl <- dt[, .(ol = mean(olcl, na.rm = T),
                      vin = mean(vincl, na.rm = T),
                      brenn = mean(brennevincl, na.rm = T),
                      rusbrus = mean(rusbruscl, na.rm = T)),
                  keyby = kjonn]

drikksortcl[, 2:5 := lapply(.SD, round, 1), .SDcols = 2:5]
drikksortcl[kjonnkb, on = c(kjonn = "v1"), gender := i.v2][, kjonn := NULL]
drikkOld <- c("ol", "vin", "brenn", "rusbrus")
drikkNew <-  c("Øl", "Vin", "Brennevin", "Rusbrus")
data.table::setcolorder(drikksortcl, c("gender", drikkOld))
data.table::setnames(drikksortcl, drikkOld, drikkNew)

drikkTbl <- melt(drikksortcl,
                 id.vars = "gender",
                 measure.vars = c("Øl", "Vin", "Brennevin", "Rusbrus"))

drikkTbl[, pros := round(value/sum(value)*100, digits = 1), keyby = .(gender)]

make_hist(drikkTbl,
          x = gender,
          y = pros,
          group = variable,
          n = value,
          yint = 10,
          title = "Andel alkoholkonsum i centiliter ren alkohol siste 4 uker fordelt på drikkesort")

# -----------------------
## Hverdag og helg drink
alx <- paste0("al", 2:5, 2:5)
dt[, (alx) := lapply(.SD, function(x) fifelse(x %in% c(8,9), NA, x)), .SDcols = paste0("al", 2:5)]

ukeCols <- c("ukedag", "ukedagenhet", "helge", "helgeenhet")
data.table::setnames(dt, paste0("al", 2:5, 2:5), ukeCols)

for (x in ukeCols)
  set(dt, j = x, value = as.numeric(dt[[x]]))

ukeDT <- proscat("ukedag", "helge", d = dt[!is.na(ukedag)], total = F)
ukeDTx <- proscat("ukedag", "helge", z="kjonn", d = dt[!is.na(ukedag)], total = F)

ukedagVals <- c("Alle 4 ukedagene" = 1,
                "3 av 4 ukedager" = 2,
                "2 av 4 ukedager" = 3,
                "1 av 4 ukedager" = 4,
                "Ingen av ukedagene" = 5)

ukedagkb <- data.table(v1 = as.integer(ukedagVals),
                       v2 = names(ukedagVals))


helgeVals <- c("Alle 3 helgdagene" = 1,
               "2 av 3 helgdager" = 2,
               "1 av 3 helgdager" = 3,
               "Ingen av helgdagene" = 4)

helgekb <- data.table(v1 = as.integer(helgeVals),
                      v2 = names(helgeVals))

ukeDT[ukedagkb, on = c(ukedag = "v1"), ukedager := i.v2]
ukeDT[helgekb, on = c(helge = "v1"), helger := i.v2]

make_hist(ukeDT,
          x = ukedager,
          y = percentage,
          group = helger,
          xtitle = "Ukedager fra mandag til torsdag",
          n = count,
          title = "Drikker mønstre i ukedager og helgedager")

# Hvor mange drikker i hverdager
bb <- dt[!is.na(ukedag), .N, keyby = ukedag]
bb[, tot :=  N/sum(N)*100]
