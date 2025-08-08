## Check all files from 2012 to 2023
## ----------------------------------
## chooseCRANmirror(ind = 18)
source("c:/Users/ykama/Git-hdir/toa/rusund/setup.R")

## readClipboard()
odrive <- "O:\\Prosjekt\\Rusdata"
rusdrive <- "Rusundersøkelsen\\Rusus historiske data\\ORG\\alkohol_rusundersokelsen"
filpath <- file.path(odrive, rusdrive)
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
fil2024 <- "O:\\Prosjekt\\Rusdata"
DD[["Rus2024"]] <- readRDS(file.path(fil2024, "Rusundersøkelsen", "Rusus 2024","rus2024.rds"))

filnr <- length(DD)

## Comman column names ------------------
ComDD <- vector("list", filnr)
for (i in seq_len(filnr)){
  ComDD[[i]] <- names(DD[[i]])
}

names(ComDD) <- names(DD)
filNames <- names(DD)

varFelles <- Reduce(intersect, lapply(ComDD, tolower))
## dput(varFelles)
ComVars <-
c("helse", "drukket1", "drukket2", "drukk2a", "drukk2b", "drukk2c",
"drukket3", "type1", "type2", "type3", "type4", "type1a", "typ1a_uk",
"typ1a_mn", "type2a", "typ2a_uk", "typ2a_mn", "type2b_a", "type2b_b",
"type2b_1", "type2b_2", "type2c_a", "type2c_b", "type2c_1", "type2c_2",
"type3a", "typ3a_uk", "typ3a_mn", "type3b_a", "type3b_b", "type3b_1",
"type3b_2", "type3c_a", "type3c_b", "type3c_1", "type3c_2", "type4a",
"typ4a_uk", "typ4a_mn", "type4b_a", "type4b_b", "type4b_1", "type4b_2",
"type4c_a", "type4c_b", "type4c_2", "audit2", "audit3", "can1",
"can2", "can3", "can4", "can5", "can6", "can7_a", "can7_b", "can7_c",
"can7_e", "can7sps", "can8", "can8sps", "can9", "can10", "can11",
"can13", "can14", "ans1", "ans2_a", "ans2_b", "ans2_c", "ans2_d",
"ans2_e", "ans2_f", "ans2_g", "ans2_h", "landsdel", "sentralitet",
"yrkstat2", "siv", "sivstat", "antpers", "antbarn1", "antbarn2"
)
  

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

DT <- data.table::rbindlist(dd, use.names = TRUE, ignore.attr=TRUE, fill = TRUE)
## spth <- "O:\\Prosjekt\\Rusdata/Rusundersøkelsen\\Rusus historiske data"
## fwrite(DT, file.path(spth, "data_2012_2024.csv"))
## saveRDS(DT, file.path(spth, "data_2012_2024.rds"))



## Codebook -----------

alk01 <- haven::read_dta(file.path(filpath, filer[1]))
skimr::skim(alk01)
str(alk01$Kjonn)
str(alk01)

codebook::codebook(alk01)

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
