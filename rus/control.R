pth <- "~/Git-hdir/toa/rus"
source(file.path(pth, "setup.R"))

## 8 - Vil ikke svare
## 9 - Vet ikke

## Check for value 99998 and 99999
vars <- c("Type1b_1", "Type1b_2",
          "Type1c_1", "Type1c_2",
          "Type2b_1", "Type2b_2",
          "Type2c_1", "Type2c_2",
          "Type3b_1", "Type3b_2",
          "Type3c_1", "Type3c_2",
          "Type4b_1", "Type4b_2",
          "Type4c_1", "Type4c_2")

outtyp <- lapply(vars, function(v) dt[, .N, keyby = v])
