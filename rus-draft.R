# Description: This script reads in the data from the Rusundersøkelsen 2024 dataset.
pkgs <- c("data.table", "haven", "skimr", "codebookr")
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

# # dt[, alkofrekvens3 := fcase(
# #   Drukk1b == 2, 0,
# #   Drukket2 == 3, 3,
# #   Drukket2 == 2, 4,
# #   Drukket2 == 1, 5,
# #   Drukket2 == 9 | Drukk1b %in% c(8, 9), NA_real_,
# #   Drukket1 == 1, 2,
# #   Drukket1 == 2, 1,
# #   Drukket1 == 8, NA_real_,
# #   default = NA_real_
# # )]
# 
# 
# # Define labels for 'alkofrekvens' (optional, for reference)
# alkofrekvens_labels <- c(
#     "aldri drukket" = 0, 
#     "ikke drukket siste år" = 1, 
#     "drukket sjeldnere enn månedlig siste 12 mnd" = 2, 
#     "drukket månedlig siste 12 mnd" = 3, 
#     "drukket ukentlig siste 12 mnd" = 4, 
#     "drukket daglig siste 12 mnd" = 5
# )
# 
# codebook::val_labels(dt$alkofrekvens) <- alkofrekvens_labels
# # attributes(dt$alkofrekvens)$labels <- alkofrekvens_labels
# labelled::val_labels(dt$alkofrekvens)

# Alkoholfrekvens siste 12 måneder
dt[, alkofreksisteår := fcase(
  alkofrekvens %in% c(0, 1), NA_real_,
  default = alkofrekvens
)]

# # Add labels for the variable itself
# codebook::var_label(dt$alkofreksisteår) <- "Alkoholfrekvens siste 12 måneder"
# 
# # Add value labels
# alkofreksisteår_values <- c(
#   "drukket sjeldnere enn månedlig siste 12 mnd" = 2,
#   "drukket månedlig siste 12 mnd" = 3,
#   "drukket ukentlig siste 12 mnd" = 4,
#   "drukket daglig siste 12 mnd" = 5
# )
# 
# codebook::val_labels(dt$alkofreksisteår) <- alkofreksisteår_values
# labelled::val_labels(dt$alkofreksisteår)
# class(dt$alkofreksisteår)

## -- Andel som drikker siste år og siste 4 uker
dt[, alksisteår := fcase(
  Drukket1 == 8, NA_real_,
  default = Drukket1
)]

# Add variable label (optional, for metadata)
attributes(dt$alksisteår)$label <- "Alkohol siste 12 måneder"

# Add value labels
attributes(dt$alksisteår)$labels <- c(
  "drukket alkohol siste 12 mnd" = 1,
  "ikke drukket alkohol siste 12 mnd" = 2
)

labelled::val_labels(dt$alksisteår)
codebook::codebook(dt$alksisteår)
