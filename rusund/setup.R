
# Description: This script reads in the data from the Rusundersøkelsen 2024 dataset.
# The codes here is based on Stata file "til tall om alkohol.do"
# ----------------------------------
# tcltk - to display the CRAN windows when not active. Relevant for Emacs
# DescTools - for Winsorize function
pkgs <- c("skimr", "codebook", "tcltk", "viridisLite", "DescTools", "gt", "here", "haven", "highcharter", "data.table")
invisible(lapply(pkgs, function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
    library(pkg, character.only = TRUE)
}))

Sys.setlocale("LC_ALL", "nb-NO.UTF-8")
