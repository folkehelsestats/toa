## var - variable for frequency
## dt - dataset to use
ttbl <- function(var, d = dt, sum = TRUE, codebook = NULL, digits = 1){
  var <- substitute(var)
  var <- as.character(var)

  dt <- data.table::copy(d)
  x <- dt[, .N, by = var, env = list(var = var)]
  x[, sum := sum(N, na.rm = T)][, prosent := round(100 * N/sum, digits = digits), by = var, env = list(var = var)][, sum := NULL]

  data.table::setkeyv(x, var)

  total <- "Total"
  tot <- x[, sum(N, na.rm = T)]
  if (ncol(x) == 3){
    tt <- list(total, tot, 100)
  } else {
    tt <- list(total, tot, 100, " ")
  }

  dx <- rbindlist(list(x, tt), ignore.attr = TRUE)
  dx[]
}
