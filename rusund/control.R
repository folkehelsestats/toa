pth <- "~/Git-hdir/toa/rusund"
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

## -- Alkoholfrekvens

ttbl("Drukket1")
ttbl("Drukket2")
ttbl("Drukk1b")

dt[Drukket1 == 2 & Drukk1b == 1, .N] #ikke drukket siste år
ttbl("alkofrekvens")

## Calculate alcohol units assuming 1.5 unit for 500ml beer
## Replace missing with 0
dt[, olenheter2 :=
      (fcoalesce(Type1b_1, 0) + 1.5 * fcoalesce(Type1b_2, 0)) * 4 +
      fcoalesce(Type1c_1, 0) + 1.5 * fcoalesce(Type1c_2, 0)
]

dt[, .(olenheter, olenheter2, flaskeroluke, halvliteroluke, Type1b_1, Type1b_2, Type1c_1, Type1c_2)]

## No multiple answer for alcohol units
cols <- c("Type1b_1", "Type1b_2", "Type1c_1", "Type1c_2")
olcol <- c("flaskeroluke", "halvliteroluke", "flaskeroltot", "halvlitertot" )
dt[, olmulti4 := rowSums(!is.na(.SD)) == length(cols), .SDcols = cols]
dt[, .N, keyby = olmulti4]

dt[, olmulti2a := rowSums(!is.na(.SD)) == length(cols[1:2]), .SDcols = cols[1:2]]
dt[, .N, keyby = olmulti2a]
cols2a <- c("olmulti2a", "olenheter2", "olenheter", cols)
dt[olmulti2a == 1, ..cols2a]

## check average drinking amount weekly and monthly
OlVars <- c("Type1b_1", "Type1b_2", "Type1c_1", "Type1c_2")
dt[, lapply(.SD, function(x)
  c(
    min(x, na.rm = TRUE),
    max(x, na.rm = TRUE),
    median(x, na.rm = T),
    tail(sort(x))
  )),.SDcols = OlVars ]


VinVars <- c("Type2b_1", "Type2b_2", "Type2c_1", "Type2c_2")
dt[, lapply(.SD, function(x)
  c(
    min(x, na.rm = TRUE),
    max(x, na.rm = TRUE),
    median(x, na.rm = T),
    tail(sort(x))
  )),.SDcols = VinVars ]
