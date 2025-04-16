# Description: This script reads in the data from the Rusundersøkelsen 2024 dataset.
pkgs <- c("data.table", "haven", "skimr", "codebook")
invisible(lapply(pkgs, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
    library(pkg, character.only = TRUE)
}))

Sys.setlocale("LC_ALL", "nb-NO.UTF-8")

setwd("O:\\Prosjekt\\Rusdata")
dt <- haven::read_dta(file.path("Rusundersøkelsen", "Rusus 2024", "nytt forsøk februar 25 rus24.dta"))
setDT(dt)

drukket <- grep("Druk*", names(dt), value = TRUE)
dt[, (drukket) := lapply(.SD, as.numeric), .SDcols = drukket]

# Antall dager drukket alkohol siste år (blant siste års drikkere)
dt[, alkodager := fcase(
  Drukket2 == 1, 365,
  Drukket2 == 2 & Drukk2a == 1, 234,
  Drukket2 == 2 & Drukk2a == 2, 130,
  Drukket2 == 2 & Drukk2a == 3, 52,
  Drukket2 == 3 & Drukk2b == 1, 42,
  Drukket2 == 3 & Drukk2b == 2, 30,
  Drukket2 == 3 & Drukk2b == 3, 12,
  Drukket2 == 4 & Drukk2c == 1, 7.5,
  Drukket2 == 4 & Drukk2c == 2, 2.5,
  Drukket2 == 4 & Drukk2c == 3, 1,
  Drukket2 == 9 |
    Drukk2a == 8 |
    Drukk2b == 9 |
    Drukk2c %in% c(8, 9) |
    Drukket1 %in% c(8, NA), NA_real_,
  default = 0
)]


# Alkoholfrekvens totalt og siste år
dt[, alkofrekvens := fcase(
  Drukket1 == 1, 2,
  Drukket1 == 2, 1,
  Drukket1 == 8, NA_real_,
  default = NA_real_
)]
dt[Drukk1b == 2, alkofrekvens := 0]
dt[Drukket2 == 3, alkofrekvens := 3]
dt[Drukket2 == 2, alkofrekvens := 4]
dt[Drukket2 == 1, alkofrekvens := 5]
dt[Drukket2 == 9 | Drukk1b %in% c(8, 9), alkofrekvens := NA_real_]

# dt[, alkofrekvens3 := fcase(
#   Drukk1b == 2, 0,
#   Drukket2 == 3, 3,
#   Drukket2 == 2, 4,
#   Drukket2 == 1, 5,
#   Drukket2 == 9 | Drukk1b %in% c(8, 9), NA_real_,
#   Drukket1 == 1, 2,
#   Drukket1 == 2, 1,
#   Drukket1 == 8, NA_real_,
#   default = NA_real_
# )]


# Define labels for 'alkofrekvens' (optional, for reference)
alkofrekvens_labels <- c(
    "aldri drukket" = 0,
    "ikke drukket siste år" = 1,
    "drukket sjeldnere enn månedlig siste 12 mnd" = 2,
    "drukket månedlig siste 12 mnd" = 3,
    "drukket ukentlig siste 12 mnd" = 4,
    "drukket daglig siste 12 mnd" = 5
)

codebook::val_labels(dt$alkofrekvens) <- alkofrekvens_labels
# attributes(dt$alkofrekvens)$labels <- alkofrekvens_labels
labelled::val_labels(dt$alkofrekvens)

# Alkoholfrekvens siste 12 måneder
dt[, alkofeqaar := fcase(
  alkofrekvens %in% c(0, 1), NA_real_,
  default = as.numeric(alkofrekvens)
)]

# Add labels for the variable itself
codebook::var_label(dt$alkofeqaar) <- "Alkoholfrekvens siste 12 måneder"

# Add value labels
alkofeqaar_values <- c(
  "drukket sjeldnere enn månedlig siste 12 mnd" = 2,
  "drukket månedlig siste 12 mnd" = 3,
  "drukket ukentlig siste 12 mnd" = 4,
  "drukket daglig siste 12 mnd" = 5
)

codebook::val_labels(dt$alkofeqaar) <- alkofeqaar_values
labelled::val_labels(dt$alkofeqaar)
# class(dt$alkofeqaar)


## -- Andel som drikker siste år og siste 4 uker
dt[, alkosistaar := fcase(
  Drukket1 == 8, NA_real_,
  default = Drukket1
)]

codebook::var_label(dt$alkosistaar) <- "Alkohol siste 12 måneder"
alksistaar_values <- c(
  "drukket alkohol siste 12 mnd" = 1,
  "ikke drukket alkohol siste 12 mnd" = 2
)

codebook::val_labels(dt$alkosistaar) <- alksistaar_values
labelled::val_labels(dt$alkosistaar)


dt[, alko4ukr := fcase(
  Drukket3 == 9, NA_real_,
  default = Drukket3
)]

codebook::var_label(dt$alko4ukr) <- "Alkohol siste 4 uker"

codebook::val_labels(dt$alko4ukr) <- c(
  "drukket alkohol siste 4 uker" = 1,
  "ikke drukket alkohol siste 4 uker" = 2
)

# -- alkfirukeravalle --
dt[, alkfirukeravalle := 0L]  
dt[alko4ukr == 1, alkfirukeravalle := 1L]  

codebook::var_label(dt$alkfirukeravalle) <- "Drukket alkohol siste 4 uker (dummy)"

codebook::val_labels(dt$alkfirukeravalle) <- c(
  "ikke drukket alkohol siste 4 uker" = 0,
  "drukket alkohol siste 4 uker" = 1
)

# -- totalfrekvens --
dt[, totalfrekvens := 2L]  # Default value
dt[alkofrekvens == 0, totalfrekvens := 0L]
dt[alkofrekvens == 1, totalfrekvens := 1L]
dt[alko4ukr == 1,  totalfrekvens := 3L]  # Last one takes precedence

codebook::var_label(dt$totalfrekvens) <- "Total alkoholfrekvens"

codebook::val_labels(dt$totalfrekvens) <- c(
  "aldri drukket" = 0,
  "ikke drukket siste år" = 1,
  "drukket siste år men ikke siste 4 uker" = 2,
  "drukket siste fire uker" = 3
)

#--- Siste 4 ukers konsum -----
#------------------------------

# Antall dager drukket øl, hele utvalget
dt[, oldager := fcase(
  Type1a == 1, 28,
  Type1a == 2 & Typ1a_uk == 1, 18,
  Type1a == 2 & Typ1a_uk == 2, 10,
  Type1a == 2 & Typ1a_uk == 3, 4,
  Type1a == 3 & Typ1a_mn == 1, 3.5,
  Type1a == 3 & Typ1a_mn == 2, 2.5,
  Type1a == 3 & Typ1a_mn == 3, 1,
  Type1a == 9 | Typ1a_uk == 8 | Typ1a_mn == 9, NA_real_,
  default = 0
)]

codebook::var_label(dt$oldager) <- "Antall dager drukket øl, hele utvalget"
  
dt[, oldageraktive := fcase(
  Drukket3 >= 2, NA_real_,  # if not drunk in last 4 weeks → na
  default = oldager         # else keep the øldager value
)]

codebook::var_label(dt$oldageraktive) <- "Antall dager drukket øl, kun folk som har drukket alkohol siste 4 uker"

dt[, oldagersisteår := fcase(
  Drukket1 >= 2, NA_real_,
  default = oldager
)]

codebook::var_label(dt$oldagersisteår) <- "Antall dager drukket øl, kun folk som har drukket alkohol siste år"

# - Vin ----
# Antall dager drukket vin, hele utvalget
dt[, vindager := fcase(
  Type2a == 1, 28,  
  Type2a == 2 & Typ2a_uk == 1, 18,  
  Type2a == 2 & Typ2a_uk == 2, 10,  
  Type2a == 2 & Typ2a_uk == 3, 4,  
  Type2a == 3 & Typ2a_mn == 1, 3.5,
  Type2a == 3 & Typ2a_mn == 2, 2.5,
  Type2a == 3 & Typ2a_mn == 3, 1,  
  Type2a == 9 | Typ2a_uk == 8 | Typ2a_mn == 8 | Typ2a_mn == 9, NA_real_, 
  default = 0  
)]

codebook::var_label(dt$vindager) <- "Antall dager drukket vin, hele utvalget"

dt[, vindageraktive := fcase(
  Drukket3 >= 2, NA_real_,
  default = vindager
)]

codebook::var_label(dt$vindageraktive) <- "Antal dager drukket vin, kun folk som har drukket alkohol siste 4 uker"

dt[, vinsisteaar := fcase(
  Drukket1 >= 2, NA_real_,
  default = vindager
)]

codebook::var_label(dt$vinsisteaar) <- "Antall dager drukket vin, kun folk som har drukket alkohol siste år"

#-- Brennevin
dt[, spritdager := fcase(
  Type3a == 1, 28,  
  Type3a == 2 & Typ3a_uk == 1, 18,
  Type3a == 2 & Typ3a_uk == 2, 10,
  Type3a == 2 & Typ3a_uk == 3, 4, 
  Type3a == 3 & Typ3a_mn == 1, 3.5,
  Type3a == 3 & Typ3a_mn == 2, 2.5,
  Type3a == 3 & Typ3a_mn == 3, 1, 
  Type3a == 8 | Type3a == 9 |
    Typ3a_uk == 8 |
    Typ3a_uk == 9 |
    Typ3a_mn == 8 |
    Typ3a_mn == 9, NA_real_,
  default = 0  
)]

codebook::var_label(dt$spritdager) <- "Antall dager drukket brennevin, hele utvalget"

dt[, spritdageraktive := fcase(
  Drukket3 >= 2, NA_real_,
  default = spritdager
)]

codebook::var_label(dt$spritdageraktive) <- "Antall dager drukket brennevin, kun folk som har drukket alkohol siste 4 uker"

dt[, spritdagersisteaar := fcase(
  Drukket1 >= 2, NA_real_,
  default = spritdager
)]

var_label(dt$spritdagersisteaar) <- "Antall dager drukket brennevin, kun fok som har drukket alkohol siste år"

#-- Rusbrus --
dt[, brusdager := fcase(
  Type4a == 1, 28,
  Type4a == 2 & Typ4a_uk == 1, 18,
  Type4a == 2 & Typ4a_uk == 2, 10,
  Type4a == 2 & Typ4a_uk == 3, 4,
  Type4a == 3 & Typ4a_mn == 1, 3.5,
  Type4a == 3 & Typ4a_mn == 2, 2.5,
  Type4a == 3 & Typ4a_mn == 3, 1,
  Type4a %in% c(8, 9) |
    Typ4a_uk %in% c(8, 9) |
    Typ4a_mn %in% c(8, 9), NA_real_,
  default = 0
)]

var_label(dt$brusdager) <- "Antall dager drukket rusbrus, hele utvalget"

dt[, brusdageraktive := fcase(
  Drukket3 >= 2, NA_real_,
  default = brusdager
)]

var_label(dt$brusdageraktive) <- "Antall dager drukket rusbrus, kun folk som har drukket alkohol siste 4 uker"

dt[, brusdagersisteaar := fcase(
  Drukket1 >= 2, NA_real_,
  default = brusdager
)]

var_label(dt$brusdagersisteaar) <- "Antall dager drukket rusbrus, kun folk som har drukket alkohol siste år"

# -- Frekvens drikker alkohol ---
dt[, olfrekvens := fcase(
  Type1a %in% c(8, 9), NA_real_,
  default = as.numeric(Type1a)  # Keep 1, 2, 3 as-is
)]

var_label(dt$olfrekvens) <- "Ølfrekvens siste 4 uker"
val_labels(dt$olfrekvens) <- c(
  "daglig" = 1,
  "ukentlig" = 2,
  "sjeldnere enn ukentlig" = 3
)

dt[, vinfrekvens := fcase(
  Type2a %in% c(8, 9), NA_real_,
  default = as.numeric(Type2a)  # Keep 1, 2, 3 as-is
)]

var_label(dt$vinfrekvens) <- "Vinfrekvens siste 4 uker"
val_labels(dt$vinfrekvens) <- c(
  "daglig" = 1,
  "ukentlig" = 2,
  "sjeldnere enn ukentlig" = 3
)

dt[, brennevinfrekvens := fcase(
  Type3a %in% c(8, 9), NA_real_,
  default = as.numeric(Type3a)  # Keep 1, 2, 3 as-is
)]

var_label(dt$brennevinfrekvens) <- "Brennevinfrekvens siste 4 uker"
val_labels(dt$brennevinfrekvens) <- c(
  "daglig" = 1,
  "ukentlig" = 2,
  "sjeldnere enn ukentlig" = 3
)

dt[, rusbrusfrekvens := fcase(
  Type4a %in% c(8, 9), NA_real_,
  default = as.numeric(Type4a)  # Keep 1, 2, 3 as-is
)]

var_label(dt$rusbrusfrekvens) <- "Rusbrusfrekvens siste 4 uker"
val_labels(dt$rusbrusfrekvens) <- c(
  "daglig" = 1,
  "ukentlig" = 2,
  "sjeldnere enn ukentlig" = 3
)

dt[, dagligdrikk := fcase(
  olfrekvens == 1 |
    vinfrekvens == 1 |
    brennevinfrekvens == 1 |
    rusbrusfrekvens == 1, 1,
  default = 0
)]

var_label(dt$dagligdrikk) <- "Total drikkefrekvens daglig"

dt[, ukedrikk := fcase(
  dagligdrikk == 0 & (
    olfrekvens == 2 |
      vinfrekvens == 2 |
      brennevinfrekvens == 2 |
      rusbrusfrekvens == 2
  ), 2,
  default = 0
)]

var_label(dt$ukedrikk) <- "Total drikkefrekvens ukenlig"

dt[, maneddrikk := fcase(
  dagligdrikk == 0 & ukedrikk == 0 & (
    olfrekvens == 3 |
      vinfrekvens == 3 |
      brennevinfrekvens == 3 |
      rusbrusfrekvens == 3
  ), 3,
  default = 0
)]

var_label(dt$maneddrikk) <- "Total drikkefrekvens månedlig"


dt[, drikkefrekvens := dagligdrikk + ukedrikk + maneddrikk]
val_labels(dt$drikkefrekvens) <- c(
  "ikke drukket siste 4 uker" = 0,
  "drukket daglig siste 4 uker" = 1,
  "drukket ukentlig siste 4 uker" = 2,
  "drukket sjeldnere enn ukentlig siste 4 uker" = 3
)
var_label(dt$drikkefrekvens) <- "Total drikkerfrekvens"

# # Fequency table
# drikkfreq <- dt[, .N, keyby = drikkefrekvens]
# drikkfreq[, values := names(val_labels(drikkefrekvens))]

##-- Antall enheter siste 4 uker (kan muligens legge inn en cut-off på 70 enheter slik at alt over 70 er 70,
## slik det gjøres i NCD. Usikker på om det er per drikkesort eller totalt - rettelse: må være per drikkesort) 

## -- ØL ---
# dt[, flaskeroluke := 0]
# dt[!is.na(Type1b_1), flaskeroluke := Type1b_1]
# dt[Type1b_1 == 99998, flaskeroluke := NA_real_]

dt[, flaskeroluke := fcase(
  !is.na(Type1b_1) & Type1b_1 != 99998, Type1b_1,
  Type1b_1 == 99998, NA_real_,
  default = 0
)]

dt[, halvliteroluke := fcase(
  !is.na(Type1b_2) & Type1b_2 != 102, Type1b_2,
  Type1b_2 == 102, NA_real_,
  default = 0
)]

dt[, flaskeroltot := fcase(
  !is.na(Type1c_1) & Type1c_1 %in% c(100, 99999), NA_real_,
  !is.na(Type1c_1), Type1c_1,
  default = 0
)]

dt[, halvlitertot := fcase(
  !is.na(Type1c_2) & Type1c_2 == 100, NA_real_,
  !is.na(Type1c_2), Type1c_2,
  default = 0
)]

dt[, olenheter := (flaskeroluke + 1.5 * halvliteroluke) * 4 + flaskeroltot + 1.5 * halvlitertot]
# Erstater NA med 0
dt[, olenheter2 := (fcoalesce(flaskeroluke, 0) + 1.5 * fcoalesce(halvliteroluke, 0)) * 4 + 
     fcoalesce(flaskeroltot, 0) + 1.5 * fcoalesce(halvlitertot, 0)]

var_label(dt$olenheter) <- "Regnet som 1,5 enheter per halvliter øl"

dt[, olhalvlitere := (flaskeroluke / 1.5 + halvliteroluke) * 4 + flaskeroltot / 1.5 + halvlitertot]
dt[, olhalvlitere2 := (fcoalesce(flaskeroluke, 0) / 1.5 + fcoalesce(halvliteroluke, 0)) * 4 + 
     fcoalesce(flaskeroltot, 0) / 1.5 + fcoalesce(halvlitertot, 0)]

var_label(dt$olhalvlitere) <- "Antall halvlitere øl per 4 uker"

## --- Vin ---
dt[, vinglassuke := fcase(
  !is.na(Type2b_1) & Type2b_1 == 99998, NA_real_,
  !is.na(Type2b_1), Type2b_1,
  default = 0
)]

var_label(dt$vinglassuke) <- "Gjennomsnitt antall glass vin ukenlig siste 4 uker"

dt[, vinflaskeruke := fcase(
  !is.na(Type2b_2) & Type2b_2 %in% c(28, 99999), NA_real_,
  !is.na(Type2b_2), Type2b_2,
  default = 0
)]

var_label(dt$vinflaskeruke) <- "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"

dt[, vinglasstot := fcase(
  !is.na(Type2c_1) & Type2c_1 == 99999, NA_real_,
  !is.na(Type2c_1), Type2c_1,
  default = 0
)]

var_label(dt$vinglasstot) <- "Antall glass vin totalt siste 4 uker"

dt[, vinflaskertot := fcase(
  !is.na(Type2c_2) & Type2c_2 == 10, NA_real_,
  !is.na(Type2c_2), Type2c_2,
  default = 0
)]

var_label(dt$vinflaskertot) <- "Antall flasker vin totalt siste 4 uker"

dt[, vinenheter := (1.2 * vinglassuke + 6 * vinflaskeruke) * 4 + 1.2 * vinglasstot + 6 * vinflaskertot]
dt[, vinenheter2 := fcoalesce(
  (1.2 * vinglassuke + 6 * vinflaskeruke) * 4, 0
) + fcoalesce(1.2 * vinglasstot, 0) + fcoalesce(6 * vinflaskertot, 0)]

var_label(dt$vinenheter) <- "Regner 6 enheter per flaske vin siste 4 uker"

dt[, allevinflasker := (vinflaskeruke + vinglassuke / 5) * 4 + vinglasstot / 5 + vinflaskertot]

var_label(dt$allevinflasker) <- "Alle vin flasker siste 4 uker"

## -- Brennevin --
dt[, brennevinglassuke := fcase(
  !is.na(Type3b_1) & Type3b_1 == 99999, NA_real_,
  !is.na(Type3b_1), Type3b_1,
  default = 0
)]

dt[, brennevinflaskeruke := fcase(
  !is.na(Type3b_2) & (Type3b_2 %in% c(28, 99999)), NA_real_,
  !is.na(Type3b_2), Type3b_2,
  default = 0
)]

dt[, brennevinglasstot := fcase(
  !is.na(Type3c_1) & Type3c_1 == 99999, NA_real_,
  !is.na(Type3c_1), Type3c_1,
  default = 0
)]

dt[, brennevinflaskertot := fcase(
  !is.na(Type3c_2) & Type3c_2 %in% c(6, 8), NA_real_,
  !is.na(Type3c_2), Type3c_2,
  default = 0
)]

dt[, brennevinenheter := (brennevinglassuke + 18 * brennevinflaskeruke) * 4 + brennevinglasstot + 18 * brennevinflaskertot]


## -- Rusbrus --
dt[, rusbrussmåflaskeruke := fcase(
  !is.na(Type4b_1) & Type4b_1 == 99999, NA_real_,
  !is.na(Type4b_1), Type4b_1,
  default = 0
)]

dt[, rusbrushalvliteruke := fcase(
  !is.na(Type4b_2) & Type4b_2 %in% c(64, 99999), NA_real_,
  !is.na(Type4b_2), Type4b_2,
  default = 0
)]

dt[, rusbrussmåflasketot := fcase(
  !is.na(Type4c_1) & Type4c_1 %in% c(99998, 99999), NA_real_,
  !is.na(Type4c_1), Type4c_1,
  default = 0
)]

dt[, rusbrushalvlitertot := fcase(
  !is.na(Type4c_2) & Type4c_2 %in% c(6, 8), NA_real_,
  !is.na(Type4c_2), Type4c_2,
  default = 0
)]

dt[, rusbrusenheter := (rusbrussmåflaskeruke + 1.5 * rusbrushalvliteruke) * 4 +
     rusbrussmåflasketot + 1.5 * rusbrushalvlitertot]

var_label(dt$rusbrusenheter) <- "Regner 1,5 enheter per halvliter rusbrus"

dt[, rusbrushalvlitere := (rusbrussmåflaskeruke / 1.5 + rusbrushalvliteruke) * 4 +
     rusbrussmåflasketot / 1.5 + rusbrushalvlitertot]

var_label(dt$rusbrushalvlitere) <- "Havlitere rusbru eller cider"

dt[, totalenheter := olenheter + vinenheter + brennevinenheter + rusbrusenheter]

##-- Beregne mengde ren alkohol --

