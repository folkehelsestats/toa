## Check all files from 2012 to 2023
## ----------------------------------
## chooseCRANmirror(ind = 18)
source("c:/Users/ykama/Git-hdir/toa/rusund/setup.R")

## readClipboard()
odrive <- "O:\\Prosjekt\\Rusdata"
source(file.path(odrive, "folder-path.R"))
filpath <- file.path(Rususdata, "Rusus_2012_2023\\ORG\\alkohol_rusundersokelsen")
filer <- grep("dta$", list.files(filpath), value = TRUE)


filb4 <- length(filer)
## Read all files --------------------------
DD <- vector("list", filb4)
for (i in seq_len(filb4)){
  DD[[i]] <- haven::read_dta(file.path(filpath, filer[i]))
}

## filNames <- gsub("\\.dta$", "", filer)
## filNames <- stringi::stri_extract_first_regex(filer, "^Rus\\d{4}")
filnn <- sub("^(Rus\\d{4}).*", "\\1", filer, perl = TRUE)
names(DD) <- filnn

## Add 2024 data
DD[["Rus2024"]] <- readRDS(file.path(Rususdata, "Rusus_2024","rus2024.rds"))

filnr <- length(DD)

## Column names ------------------
ComDD <- vector("list", filnr)
for (i in seq_len(filnr)){
  ComDD[[i]] <- names(DD[[i]])
}

ComDDx <- data.table::copy(ComDD) #original columnames
invisible(lapply(DD, function(x) setnames(x, tolower(names(x)))))

names(ComDD) <- names(DD)
filNames <- names(DD)

## Convert to data.table --------
for (i in seq_len(filnr))
  setDT(DD[[i]])

## Vekting ----------
(vekt <- lapply(ComDD, function(x) grep("vekt", x, value = T)))

## dd <- DD[["Rus2012"]]
## dd[, .(sum_nyvekt_2 = sum(nyvekt_2),
##        sum_vekt_1 = sum(vekt_1numeric),
##        sum_vekt_2 = sum(vekt_2numeric))]

## dd[, .(mean_nyvekt_2 = mean(nyvekt_2),
##        mean_vekt_1 = mean(vekt_1numeric),
##        mean_vekt_2 = mean(vekt_2numeric))]

dtHis <- paste0("Rus", 2012:2015)
for (i in dtHis)
  setnames(DD[[i]], "nyvekt_2", "nyvekt2", skip_absent = T)

## Standardize weight variable for 2024 data
mean2024 <- DD$Rus2024[, mean(vekt, na.rm = T)]
DD$Rus2024[, nyvekt2 := vekt/mean2024]

## Rename unstandardized vekt
DD[["Rus2012"]][, vekt2 := vekt_2numeric]
DD[["Rus2013"]][, vekt2 := as.numeric(vekt2)]
DD[["Rus2015"]][, vekt2 := as.numeric(vekt2)]
DD[["Rus2018"]][, vekt2 := as.numeric(vekt_2org)]
DD[["Rus2021"]][, vekt2 := as.numeric(vekt21_a)]
DD[["Rus2022"]][, vekt2 := as.numeric(vektnr2)]
DD[["Rus2024"]][, vekt2 := as.numeric(vekt)]

## Sentralitet ------------
(sentral <- lapply(ComDD, function(x) grep("sentral", x, value = T)))


## Drukket -------------
## Har noen gang drukket alkohol "drukk1b" finnes ikke i 2012 og 2013
lapply(ComDD, function(x) grep("drukk1b", x, value = T))
DD[["Rus2012"]][, drukk1b := NA]
DD[["Rus2013"]][, drukk1b := NA]

## Enhet drukket -------------
lapply(ComDD, function(x) grep("type1b_", x, value = T)) # Øl ukenlig
lapply(ComDD, function(x) grep("type1c_", x, value = T)) # Øl månedlig

beerVar1 <- c("type1b_1", "type1b_2")
beerVar2 <- c("type1c_1", "type1c_2")
setnames(DD[["Rus2012"]], c("type1b_12012", "type1b_32012"), beerVar1, skip_absent = T)
setnames(DD[["Rus2012"]], c("type1c_12012", "type1c_32012"), beerVar2, skip_absent = T)
setnames(DD[["Rus2013"]], c("type1b_1", "type1b_3"), beerVar1, skip_absent = T)
setnames(DD[["Rus2013"]], c("type1c_1", "type1c_3"), beerVar2, skip_absent = T)

## DD[["Rus2012"]][, (beerVar1) := .SD, .SDcols = c("type1b_12012", "type1b_32012")]
## DD[["Rus2012"]][, (beerVar2) := .SD, .SDcols = c("type1c_12012", "type1c_32012")]
## DD[["Rus2013"]][, (beerVar1) := .SD, .SDcols = c("type1b_1", "type1b_3")]
## DD[["Rus2013"]][, (beerVar2) := .SD, .SDcols = c("type1c_1", "type1c_3")]
# Rus2020 har riktig kolonnavn, men de er tomme kolloner
DD[["Rus2020"]][, (beerVar1) := .SD, .SDcols = c("type1b_11_a", "type1b_21_a")]
DD[["Rus2020"]][, (beerVar2) := .SD, .SDcols = c("type1c_11_a", "type1c_21_a")]

lapply(ComDD, function(x) grep("type2b_" , x, value = T)) # Vin ukenlig
lapply(ComDD, function(x) grep("type2c_", x, value = T)) # Vin månedlig
vinVar1 <- c("type2b_1", "type2b_2")
vinVar2 <- c("type2c_1", "type2c_2")
DD[["Rus2020"]][, (vinVar1) := .SD, .SDcols = c("type2b_11_a", "type2b_21_a")]
DD[["Rus2020"]][, (vinVar2) := .SD, .SDcols = c("type2c_11_a", "type2c_21_a")]

lapply(ComDD, function(x) grep("type3b_", x, value = T)) # Sprit ukenlig
lapply(ComDD, function(x) grep("type3c_", x, value = T)) # Sprit månedlig
brennVar1 <- c("type3b_1", "type3b_2")
brennVar2 <- c("type3c_1", "type3c_2")
DD[["Rus2020"]][, (brennVar1) := .SD, .SDcols = c("type3b_11_a", "type3b_21_a")]
DD[["Rus2020"]][, (brennVar2) := .SD, .SDcols = c("type3c_11_a", "type3c_21_a")]

lapply(ComDD, function(x) grep("type4b_", x, value = T)) # Rusbrus ukenlig
lapply(ComDD, function(x) grep("type4c_", x, value = T)) # Rusbrus månedlig
rusbrusVar1 <- c("type4b_1", "type4b_2")
rusbrusVar2 <- c("type4c_1", "type4c_2")
DD[["Rus2020"]][, (rusbrusVar1) := .SD, .SDcols = c("type4b_11_a", "type4b_21_a")]
DD[["Rus2020"]][, (rusbrusVar2) := .SD, .SDcols = c("type4c_11_a", "type4c_21_a")]
DD[["Rus2021"]][, (rusbrusVar2[1]) := .SD, .SDcols = c("type4c_11")]

## illegal rusmidler -----------------
lapply(ComDD, function(x) grep("ans2sps", x, value = T)) # Andre stoffer spesifiser
lapply(ComDD, function(x) grep("ans2_sp", x, value = T))
DD[["Rus2016"]][, ans2sps := paste(trimws(ans2_sp1), trimws(ans2_sp2), trimws(ans2_sp3), sep = ", ")]
DD[["Rus2017"]][, ans2sps := paste(trimws(ans2_sp1), trimws(ans2_sp2), trimws(ans2_sp3), sep = ", ")]

## Narkotika siste 12 måneder
DD[["Rus2016"]][, ans3_8 := ans3_sp1]
DD[["Rus2017"]][, ans3_8 := ans3_sp1]

## Narkotika spørsmål har ulike navn i 2012-2013
## ---------------------------------------
lapply(ComDD, \(x) grep("ans3_", x, value = T))

ansNew <- paste0("ans3_", 1:8)
ansOld2012 <- paste0("ans3_", letters[1:8])
data.table::setnames(DD[["Rus2012"]], ansOld2012, ansNew, skip_absent = T)


## Comman column names ------------------

nameDD <- vector("list", filnr)
for (i in seq_len(filnr)){
  nameDD[[i]] <- names(DD[[i]])
}

names(nameDD) <- names(DD)

varFelles <- Reduce(intersect, lapply(nameDD, tolower))
## dput(varFelles)

ComVars <-
c("nyvekt2", "helse", "drukket1", "drukket2", "drukk2a", "drukk2b",
"drukk2c", "drukket3", "type1", "type2", "type3", "type4", "type1a",
"typ1a_uk", "typ1a_mn", "type1b_1", "type1b_2", "type1c_1", "type1c_2",
"type2a", "typ2a_uk", "typ2a_mn", "type2b_a", "type2b_b", "type2b_1",
"type2b_2", "type2c_a", "type2c_b", "type2c_1", "type2c_2", "type3a",
"typ3a_uk", "typ3a_mn", "type3b_a", "type3b_b", "type3b_1", "type3b_2",
"type3c_a", "type3c_b", "type3c_1", "type3c_2", "type4a", "typ4a_uk",
"typ4a_mn", "type4b_a", "type4b_b", "type4b_1", "type4b_2", "type4c_a",
"type4c_b", "type4c_1", "type4c_2", "audit2", "audit3", "can1",
"can2", "can3", "can4", "can5", "can6", "can7_a", "can7_b", "can7_c",
"can7_e", "can7sps", "can8", "can8sps", "can9", "can10", "can11",
"can13", "can14", "ans1", "ans2_a", "ans2_b", "ans2_c", "ans2_d",
"ans2_e", "ans2_f", "ans2_g", "ans2_h", "ans2sps", "ans3_1",
"ans3_2", "ans3_3", "ans3_4", "ans3_5", "ans3_6", "ans3_7", "ans3_8",
"landsdel", "sentralitet", "yrkstat2", "siv", "sivstat", "antpers",
"antbarn1", "antbarn2", "vekt2", "drukk1b")

## Find which vectors contain selected variable and show matches
## Alder --------------
alder_var <- lapply(ComDD, function(x) x[grepl("alder", x, ignore.case = TRUE)])
names(alder_var) <- filNames
## Variable for Alder has this variation. The other types of alder are computed or recoded values
## These values are after tolower(). The real values are Alder and IOs_Alder
alderVars <- c("alder", "ios_alder")

## Kjonn ---------
kjonn_var <- lapply(ComDD, function(x) x[grepl("kjon", x, ignore.case = TRUE)])
names(kjonn_var) <- filNames
kjonnVars <- unlist(unique(tolower(kjonn_var)))

## Audit ---------
## Follow up questions for Audit3 only available for data from 2015

grep("audit3", tolower(ComDD$Rus2014), value = T)
grep("audit3", tolower(ComDD$Rus2015), value = T)

auditVars <- grep("audit3", tolower(ComDD$Rus2015), value = T)[-1]

## Merge all common and selected columns ----------
allVars <- c(ComVars, alderVars, kjonnVars, auditVars)
length(allVars)

dd <- vector("list", filnr)
for (i in seq_len(filnr)){
  d <- as.data.table(DD[[i]])
  data.table::setnames(d, tolower(names(d)))
  dn <- setdiff(names(d), allVars)
  d[, (dn) := NULL]
  dd[[i]] <- d
}

names(dd) <- filNames

lapply(dd, function(x) names(x)[grepl("alder", names(x), ignore.case = TRUE)])
lapply(dd, function(x) names(x)[grepl("kjonn", names(x), ignore.case = TRUE)])

dd$Rus2019[, alder := NULL] #har to variabler alder som er like. Det er ios_alder som skal beholders

for (i in seq_len(filnr)){
  setnames(dd[[i]], c("ios_alder", "ios_kjonn"), c("alder", "kjonn"), skip_absent = TRUE)
  yr <- as.integer(gsub("Rus", "", names(dd[i])))
  dd[[i]][, year := yr]
}

ddt <- data.table::rbindlist(dd, use.names = TRUE, ignore.attr=TRUE, fill = TRUE)
source(here::here("rusund", "cleaning", "history", "history-cleaning.R"))

DT <- data.table::copy(ddt)

## dataPath <- "O:\\Prosjekt\\Rusdata"
## source(file.path(dataPath, "folder-path.R"))
## data.table::fwrite(DT, file.path(Rususdata, "rusus_2012_2024.csv"))
## saveRDS(DT, file.path(Rususdata, "rusus_2012_2024.rds"))

## DT1224 <- readRDS(file.path(Rususdata, "rusus_2012_2024.rds"))

## --------------------
## Codebook -----------
## -------------------

alk01 <- haven::read_dta(file.path(filpath, filer[1]))
skimr::skim(alk01)
str(alk01$Kjonn)
str(alk01)

## ## This create a lots of figures separately
## codebook::codebook(alk01)

# Example: Generate HTML codebook
dataMaid::makeCodebook(alk01, file = "alk01.html")
# Example: Generate HTML data summary
summarytools::dfSummary(alk01, file = "alk01.html", report.title = "My Codebook")


## ------------------------
## Checking ---------------
DD[["Rus2017"]][, alder_var[["Rus2017"]]]


audit_var <- lapply(ComDD, function(x) x[grepl("audit", x, ignore.case = TRUE)])
names(audit_var) <- filNames
audit_var

lapply(dd, function(x) names(x)[grepl("alder", names(x), ignore.case = TRUE)])
lapply(dd, function(x) names(x)[grepl("kjonn", names(x), ignore.case = TRUE)])


identical(dd[["Rus2019"]][["ios_alder"]], dd[["Rus2019"]][["alder"]])
all.equal(dd[["Rus2019"]][["ios_alder"]], dd[["Rus2019"]][["alder"]])

ios  <- dd[["Rus2019"]][["ios_alder"]]
ald  <- dd[["Rus2019"]][["alder"]]

which(!(ios == ald | (is.na(ios) & is.na(ald))))
dd[["Rus2019"]][which(!(ios == ald | (is.na(ios) & is.na(ald)))), c("ios_alder", "alder")]


length(filer)
d <- DD[[1]]
setnames(setDT(d), tolower(names(d)))
