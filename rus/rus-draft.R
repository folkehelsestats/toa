## get dataset ie. dt
pth <- "~/Git-hdir/toa/rus"
source(file.path(pth, "setup.R"))
source(file.path(pth, "functions.R"))

## ----
drukketVar <- grep("Druk*", names(dt), value = TRUE)
dt[, (drukketVar) := lapply(.SD, as.numeric), .SDcols = drukketVar]

# De som drikker dvs. Drukket1= , og har drukket noen ganger (Drukket1=2 & Drukket1b=1)
# Brukes til å lage nevner for de som drikker istendenfor hele befolkningen
dt[, drinker := fcase(
       Drukket1 == 1, 1,
       Drukket1 == 2 & Drukk1b == 1, 1)]

## dt[is.na(drinker), drinker := Drukket1]

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
dt[Drukket1 == 1, alkofrekvens := fcase(
                    Drukket2 == 1, 5,
                    Drukket2 == 2, 4,
                    Drukket2 == 3, 3,
                    Drukket2 == 4, 2
                  )]
dt[Drukket1 == 2, alkofrekvens := fcase(
                    Drukk1b == 1, 1,
                    Drukk1b == 2, 0
                  )]


## dt[, alkofrekvens := fcase(
##   Drukket1 == 1, 2,
##   Drukket1 == 2, 1,
##   Drukket1 == 8, NA_real_,
##   default = NA_real_
## )]
## dt[Drukk1b == 2, alkofrekvens := 0]
## dt[Drukket2 == 3, alkofrekvens := 3]
## dt[Drukket2 == 2, alkofrekvens := 4]
## dt[Drukket2 == 1, alkofrekvens := 5]
## dt[Drukket2 == 9 | Drukk1b %in% c(8, 9), alkofrekvens := NA_real_]


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
## labelled::val_labels(dt$alkofrekvens)

## ----------------
freq_labels <- data.table(
  label = names(alkofrekvens_labels),
  value = as.integer(alkofrekvens_labels)
)

## -------------------
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
## labelled::val_labels(dt$alkofeqaar)
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
  Type1a == 2 & Typ1a_uk == 1, 18, #4.5 dager x 4 uker
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
  Drukket3 >= 2, NA_real_,  # if not drukket in last 4 weeks → na
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

#-- Brennevin --
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

## -- Antall enheter siste 4 uker -> ETTER MASSE OM OG MEN ER NÅVÆRENDE LØSNING
## Å IKKE STRYKE NOE: FHI VIL ANTAKELIG GJØRE DET SAMME[ Kan muligens legge inn
## en cut-off på 70 enheter slik at alt over 70 er 70, slik det gjøres i NCD.
## Uskker på om det er per drikkesort eller totalt - rettelse: må være per
## drikkesort - ny rettelse: Elin sier det er totalt. Avventer dette, men retter
## opp enhetsberegningene så de blir lik FHIs - siste nytt: winsorizing per
## enhet, dvs endrer alle over 95% percentilen til lik 95% percentilen]

## -- ØL ---
# linje 210 i do filen
# dt[, flaskeroluke := 0]
# dt[!is.na(Type1b_1), flaskeroluke := Type1b_1]
# dt[Type1b_1 == 99998, flaskeroluke := NA_real_]

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

# Winsorize - endre alle over 95% percentile til verdien på 95% percentile
dt[, olenheterWin := DescTools::Winsorize(olenheter,
                                          quantile(olenheter,
                                                   probs = c(0, 0.95), na.rm = TRUE))]


## # Erstater NA med 0 med fcoalesce()
## dt[, olenheter2 := (fcoalesce(flaskeroluke, 0) + 1.5 * fcoalesce(halvliteroluke, 0)) * 4 +
##      fcoalesce(flaskeroltot, 0) + 1.5 * fcoalesce(halvlitertot, 0)]
var_label(dt$olenheter) <- "Alkoholenheter (øl) siste 4 uker"


dt[, olhalvlitere := (flaskeroluke / 1.5 + halvliteroluke) * 4 + flaskeroltot / 1.5 + halvlitertot]
## dt[, olhalvlitere2 := (fcoalesce(flaskeroluke, 0) / 1.5 + fcoalesce(halvliteroluke, 0)) * 4 +
##      fcoalesce(flaskeroltot, 0) / 1.5 + fcoalesce(halvlitertot, 0)]
var_label(dt$olhalvlitere) <- "Antall halvlitere øl per 4 uker"

## --- Vin ---

dt[, vinglassuke := fcase(
       as.integer(Type2b_1) %in% c(99998, 99999), NA_real_,
       is.na(Type2b_1), 0,
       default = Type2b_1
     )]

var_label(dt$vinglassuke) <- "Gjennomsnitt antall glass vin ukenlig siste 4 uker"

## OBS! Maks verdi er 28. Skal den slettes?
dt[, vinflaskeruke := fcase(
       as.integer(Type2b_2) %in% c(99998, 99999), NA_real_,
       is.na(Type2b_2), 0,
       default = Type2b_2
     )]

var_label(dt$vinflaskeruke) <- "Gjennomsnitt antall flaske vin ukenlig siste 4 uker"


dt[, vinglasstot := fcase(
       as.integer(Type2c_1) %in% c(99998, 99999), NA_real_,
       is.na(Type2c_1), 0,
       default = Type2c_1
     )]

var_label(dt$vinglasstot) <- "Antall glass vin totalt siste 4 uker"


## OBS! Maks verdi er 10. Skal den slettes?
dt[, vinflaskertot := fcase(
       as.integer(Type2c_2) %in% c(99998, 99999), NA_real_,
       is.na(Type2c_2), 0,
       default = Type2c_2
     )]

var_label(dt$vinflaskertot) <- "Antall flasker vin totalt siste 4 uker"

dt[, vinenheter := (1.2 * vinglassuke + 6 * vinflaskeruke) * 4 + 1.2 * vinglasstot + 6 * vinflaskertot]
## dt[, vinenheter2 := fcoalesce((1.2 * vinglassuke + 6 * vinflaskeruke) * 4, 0) +
##        fcoalesce(1.2 * vinglasstot, 0) + fcoalesce(6 * vinflaskertot, 0)]

var_label(dt$vinenheter) <- "Regner 6 enheter per flaske vin siste 4 uker"

# Winsorize - endre alle over 95% percentile til verdien på 95% percentile
dt[, vinenheterWin := DescTools::Winsorize(vinenheter,
                                          quantile(vinenheter,
                                                   probs = c(0, 0.95), na.rm = TRUE))]

dt[, allevinflasker := (vinflaskeruke + vinglassuke / 5) * 4 + vinglasstot / 5 + vinflaskertot]

var_label(dt$allevinflasker) <- "Alle vin flasker siste 4 uker"

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

# Winsorize - endre alle over 95% percentile til verdien på 95% percentile
dt[, brennevinenheterWin := DescTools::Winsorize(brennevinenheter,
                                          quantile(brennevinenheter,
                                                   probs = c(0, 0.95), na.rm = TRUE))]
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
## dt[, rusbrusenheter2 := fcoalesce((rusbrussmåflaskeruke + 1.5 * rusbrushalvliteruke) * 4, 0) +
##      fcoalesce(rusbrussmåflasketot, 0) + fcoalesce(1.5 * rusbrushalvlitertot, 0)]

var_label(dt$rusbrusenheter) <- "Regner 1,5 enheter per halvliter rusbrus"

# Winsorize - endre alle over 95% percentile til verdien på 95% percentile
dt[, rusbrusenheterWin := DescTools::Winsorize(rusbrusenheter,
                                          quantile(rusbrusenheter,
                                                   probs = c(0, 0.95), na.rm = TRUE))]

dt[, rusbrushalvlitere := (rusbrussmåflaskeruke / 1.5 + rusbrushalvliteruke) * 4 +
     rusbrussmåflasketot / 1.5 + rusbrushalvlitertot]

var_label(dt$rusbrushalvlitere) <- "Havlitere rusbru eller cider"

dt[, totalenheter := olenheter + vinenheter + brennevinenheter + rusbrusenheter]
## dt[, totalenheter2 := olenheter2 + vinenheter2 + brennevinenheter2 + rusbrusenheter2]

# Winsorize - endre alle over 95% percentile til verdien på 95% percentile
dt[, totalenheterWin := DescTools::Winsorize(totalenheter,
                                          quantile(totalenheter,
                                                   probs = c(0, 0.95), na.rm = TRUE))]
## -----------------------
## --- To be continued
## -----------------------

## -------------------------------
## Beregne mengde ren alkohol (her må det avklares hvordan cl skal samordnes med
## enheter. Nåværende løsning: alle enheter telles med. Mulig annen løsning:
## basere seg på winsorized enheter)

dt[, alkoclol := olhalvlitere*2.25] #øl
dt[, alkoclvin := allevinflasker*9] #vin
dt[, alkoclbrennevin := brennevinenheter*1.6] #brennevin
dt[, alkoclrusbrus := rusbrushalvlitere*2.25] #rusbrus/cider

## Total mengde ren alkohol siste fire uker
dt[, totalcl := alkoclol + alkoclvin + alkoclbrennevin + alkoclrusbrus]

## Alternativ beregning med alkoholenheter
dt[, alkoclol02 := olenheter*1.485] #øl 33cl 4.5%
dt[, alkoclvin02 := vinenheter*1.8] #vin 15cl 12%
dt[, alkoclbrennevin02 := brennevinenheter*1.6] #brennevin 4cl 40%
dt[, alkoclrusbrus02 := rusbrusenheter*1.485] #rusbrus/cider 33cl 4.5%

dt[, alkohalvol03 := alkoclol02*22.2/50] #0.50 l øl
dt[, alkovinglass03 := alkoclvin02*8.3/15] #glass vin
dt[, alkobrennevin03 := alkoclbrennevin02*2.5/4] #en drink
dt[, alkorusbrus03 := alkoclrusbrus02*22.2/33] #en flaske rusbrus

## Total mengde ren alkohol siste fire uker
dt[, totalcl02 := alkoclol02 + alkoclvin02 + alkoclbrennevin02 + alkoclrusbrus02]


## Drikker ukedag og helg: fjerne missing AL2 - AL5
## ----------------
alx <- paste0("AL", 2:5, 2:5)
dt[, (alx) := lapply(.SD, function(x) fifelse(x %in% c(8,9), NA, x)), .SDcols = paste0("AL", 2:5)]


## gruppering av ukedag og helgedag (NB: Ingen svarte "mer enn 16 enheter" på
## ukedag i 2024. Dermed starter AL3 på 2. Dette kan endre seg til neste år)


## ------------------------
## AUDIT
##
## Berengne AUDIT (har ikke endret labels som derfor er forvirrende etter
## omregning av Audit 2, 4, 5, 6, 7 og 8. Står 0, aldri, sjeldnere enn mnd, mnd,
## ukentlig, men er egentlig: aldri, sjeldnere enn mnd, mnd, ukentlig, daglig.
## For Audit 2 : mengdeangivelser som bør regnes om. Sjekk i originalfil)

dt[, Audit1 := fcase(
  Drukk2a == 1 | Drukket2 == 1, 4,
  Drukk2a == 2, 3,
  Drukk2a == 3 | Drukk2b %in% c(1, 2), 2,
  Drukket2 == 4 | Drukk2b == 3, 1,
  default = 0
)]

## Keep Audit2 instead
dt[, aud2num := as.numeric(Audit2)]
dt[, Audit2rec := fcase(
  Audit2 == 1, 0,
  Audit2 == 2, 1,
  Audit2 == 3, 2,
  Audit2 == 4, 3,
  Audit2 == 5, 4,
  Audit2 %in% c(8, 9), NA_real_,
  default = aud2num
)]


## AUDIT3
## (sjekke skillet mellom 3 og 4 poeng. Bare daglig gir 4, eller 4-5 ggr
## i uka gir også 4? (dvs Audit3_1==1-->Audit3rec=4) - gnerelt sjekke ettersom
## kategoriene ikke overensstemmer helt med audit)
dt[, Audit3rec := fcase(
  Audit3 == 1, 4,
  Audit3_1 %in% c(1, 2), 3,
  Audit3_2 %in% c(1, 2) | Audit3_1 == 3, 2,
  Audit3 == 4 | Audit3_2 == 3, 1,
  default = 0
)]

# Define the omkoding mapping
omkoding <- c("1" = 0, "2" = 1, "3" = 2, "4" = 3, "5" = 4)

# List of variables to recode
vars <- paste0("Audit", 4:8)

# Recode in one line, creating new variables with _rec suffix
dt[, paste0(vars, "rec") := lapply(.SD, function(x) {
  out <- omkoding[as.character(x)]
  out[x %in% c(8, 9)] <- NA
  out
}), .SDcols = vars]


## Audit9 (fant Audit9 i spørreskjemaet(audit9_a_b_c)- men audit9_a er mystisk
## og stemmer ikke overense med _b og _c?
dt[, Audit9rec := fcase(
  Audit9a == 1 | Audit9b == 1, 4,
  audit9_b == 1 | audit9_c == 1, 2,
  default = 0
)]

dt[, Audit10rec := fcase(
  Audit10a == 1, 4,
  Audit10 == 1, 2,
  default = 0
)]

## Audit total
dt[, Auditscore := Audit1 + Audit2rec +
       Audit3rec + Audit4rec + Audit5rec +
       Audit6rec + Audit7rec + Audit8rec +
       Audit9rec + Audit10rec]


## ---------------------
## Risikogrupper
dt[, risikogruppe := fcase(
  Auditscore >= 0 & Auditscore <= 7, 0,
  Auditscore >= 8 & Auditscore <= 15, 1,
  Auditscore >= 16 & Auditscore <= 19, 2,
  Auditscore >= 20 & Auditscore <= 40, 3
)]

## ----------------------------
## Konstruere aldersgrupper
