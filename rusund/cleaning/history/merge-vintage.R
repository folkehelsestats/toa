
source("https://raw.githubusercontent.com/folkehelsestats/rusus/refs/heads/main/folder-path.R")

library(data.table)

## All historical data from 2012 to 2024
## -----------------
DT1224 <- readRDS(file.path(Rususdata, "rusus_2012_2024.rds"))
DT1224[, sentralitet := as.numeric(sentralitet)]


## New data from 2025
## -----------------
DT25 <- readRDS(file.path(Rususdata, "Rusus_2025", "rusus2025_20251126.rds"))

setDT(DT25)
setnames(DT25, names(DT25), tolower(names(DT25)))

DT25[, year := 2025]
DT25[, vekt2 := as.numeric(sub(",", ".", vekt))]
DT25[, nyvekt2 := vekt2/mean(vekt2, na.rm = TRUE)] #standardisert vekt

DT25[, alkosistaar := ifelse(drukket1 %in% 8:9, NA, drukket1)]

DT25[, alkodager := fcase(
         drukket2 == 1, 365,
         drukket2 == 2 & drukk2a == 1, 234,
         drukket2 == 2 & drukk2a == 2, 130,
         drukket2 == 2 & drukk2a == 3, 52, # differ
         drukket2 == 3 & drukk2b == 1, 42, #
         drukket2 == 3 & drukk2b == 2, 30,
         drukket2 == 3 & drukk2b == 3, 12,
         drukket2 == 4 & drukk2c == 1, 7.5, #
         drukket2 == 4 & drukk2c == 2, 2.5, #
         drukket2 == 4 & drukk2c == 3, 1,
         drukket2 == 9 |
         drukk2a == 8 |
         drukk2b == 9 |
         drukk2c %in% c(8, 9) |
         drukket1 %in% c(8, NA), NA_real_,
         default = 0
       )]

## Merge
## -----------------
setdiff(names(DT1224), names(DT25))
DT25[, landsdel := landsdel_2025]
DT1224[, landsdel := as.numeric(landsdel)]

comVars <- intersect(names(DT1224), names(DT25))

DT1225 <- data.table::rbindlist(list(DT1224, DT25[, ..comVars]),
                                use.names = TRUE,
                                fill = TRUE,
                                ignore.attr = TRUE)

## saveRDS(DT1225, file.path(Rususdata, "rusus_2012_2025.rds"))
## rio::export(DT1225, file.path(Rususdata, "rusus_2012_2025.dta"))
## data.table::fwrite(DT1225, file.path(Rususdata, "rusus_2012_2025.csv"), row.names = FALSE)
