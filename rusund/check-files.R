## Check all files from 2012 to 2023
## ----------------------------------
## readClipboard()
odrive <- "O:\\Prosjekt\\Rusdata"
rusdrive <- "Rusundersøkelsen\\Rusus historiske data\\ORG\\alkohol_rusundersokelsen"
filpath <- file.path(odrive, rusdrive)
filer <- grep("dta$", list.files(filpath), value = TRUE)

## chooseCRANmirror(ind = 18)

pkgs <- c("tcltk","data.table", "haven", "skimr", "codebook", "dataMaid", "summarytools")
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


DD <- vector("list", length(filer))

for (i in seq_len(length(filer))){
  DD[[i]] <- haven::read_dta(file.path(filpath, filer[i]))
}

names(DD) <- filer

