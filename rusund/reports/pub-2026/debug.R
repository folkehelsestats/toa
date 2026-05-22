## Where are the missing values? ie. 0r not complete cases in key variables
ddt[, .(
  rows = .N,
  complete_cases = sum(complete.cases(totalcl, alder, kjonn, nyvekt2))
), by = year]
