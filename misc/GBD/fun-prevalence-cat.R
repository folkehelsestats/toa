#' Calculate Prevalence for All Categories
#'
#' @description
#' Calculates weighted or unweighted prevalence for each category in a variable
#'
#' @param dt A data.table object
#' @param var Character string specifying the variable name
#' @param weight Character string specifying the weight variable (default: NULL)
#' @param ci Confidence level (default: 0.95)
#'
#' @return A data.table with prevalence statistics for each category
#'
#' @examples
#' # Unweighted
#' result <- calc_prevalence_category(dt, "alkodager")
#'
#' # Weighted, by groups
#' result <- dt[, calc_prevalence_category(.SD, "alkodager", "weight"),
#'              by = .(year, kjonn)]
#'
#' @export
calc_prevalence_category <- function(dt, var, weight = NULL, ci = 0.95) {
  z <- qnorm(1 - (1 - ci) / 2)

  dt[!is.na(get(var)), {
    categories <- sort(unique(get(var)))

    if (is.null(weight)) {
      # Unweighted
      n_total <- .N
      lapply(categories, function(cat) {
        n_success <- sum(get(var) == cat)
        pct <- n_success / n_total
        se <- sqrt((pct * (1 - pct)) / n_total)

        data.table(
          category = cat,
          n = n_success,
          n_total = n_total,
          percentage = pct * 100,
          SE = se * 100,
          low_CI = (pct - z * se) * 100,
          up_CI = (pct + z * se) * 100
        )
      }) |> rbindlist()
    } else {
      # Weighted
      n_total <- sum(get(weight))
      lapply(categories, function(cat) {
        n_success <- sum((get(var) == cat) * get(weight))
        pct <- n_success / n_total
        se <- sqrt((pct * (1 - pct)) / n_total)

        data.table(
          category = cat,
          n_weighted = n_success,
          n_total = n_total,
          percentage = pct * 100,
          SE = se * 100,
          low_CI = (pct - z * se) * 100,
          up_CI = (pct + z * se) * 100
        )
      }) |> rbindlist()
    }
  }]
}

