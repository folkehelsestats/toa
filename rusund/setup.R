
# Description: This script reads in the data from the Rusundersøkelsen 2024 dataset.
# The codes here is based on Stata file "til tall om alkohol.do"
# ----------------------------------
# tcltk - to display the CRAN windows when not active. Relevant for Emacs
# DescTools - for Winsorize function
pkgs <- c("skimr", "codebook", "tcltk", "DescTools", "gt", "here", "haven", "highcharter", "data.table")
invisible(lapply(pkgs, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
    library(pkg, character.only = TRUE)
}))

Sys.setlocale("LC_ALL", "nb-NO.UTF-8")

setwd("O:\\Prosjekt\\Rusdata")
## DT <- haven::read_dta(file.path("Rusundersøkelsen", "Rusus 2024", "nytt forsøk februar 25 rus24.dta"))
## saveRDS(DT, file.path("Rusundersøkelsen", "Rusus 2024","rus2024.rds"))
DT <- readRDS(file.path("Rusundersøkelsen", "Rusus 2024","rus2024.rds"))
dt <- as.data.table(DT)

