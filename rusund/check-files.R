## Check all files from 2012 to 2023
## ----------------------------------
## readClipboard()
odrive <- "O:\\Prosjekt\\Rusdata"
rusdrive <- "Rusundersøkelsen\\Rusus historiske data\\ORG\\alkohol_rusundersokelsen"
filpath <- file.path(odrive, rusdrive)
filer <- grep("dta$", list.files(filpath), value = TRUE)

## chooseCRANmirror(ind = 18)
pkgs <- c("tcltk","DescTools", "gt", "here",
          "skimr", "codebook", "dataMaid", "summarytools",
          "data.table", "haven")
invisible(lapply(pkgs, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
    library(pkg, character.only = TRUE)
}))

Sys.setlocale("LC_ALL", "nb-NO.UTF-8")

alk01 <- haven::read_dta(file.path(filpath, filer[1]))
skimr::skim(alk01)
str(alk01$Kjonn)
str(alk01)

codebook::codebook(alk01)

# Example: Generate HTML codebook
dataMaid::makeCodebook(alk01, file = "alk01.html")
# Example: Generate HTML data summary
summarytools::dfSummary(alk01, file = "alk01.html", report.title = "My Codebook")

filnr <- length(filer)
## Read all files
DD <- vector("list", filnr)
for (i in seq_len(filnr)){
  DD[[i]] <- haven::read_dta(file.path(filpath, filer[i]))
}

filNames <- gsub("\\.dta$", "", filer)
names(DD) <- filNames

## Comman names
ComDD <- vector("list", filnr)
for (i in seq_len(filnr)){
  ComDD[[i]] <- names(DD[[i]])
}

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
  

# Find which vectors contain "alder" and show matches
alder_var <- lapply(ComDD, function(x) x[grepl("alder", x, ignore.case = TRUE)])
names(alder_var) <- filNames
