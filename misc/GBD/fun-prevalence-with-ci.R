#' Calculate Prevalence with Confidence Intervals
#'
#' @description
#' Calculates the prevalence (proportion) of a binary variable in a data.table,
#' with standard errors and confidence intervals. Supports weighted and unweighted
#' calculations, and can be used with grouping variables.
#'
#' @param dt A data.table object containing the data
#' @param var Character string specifying the name of the variable to calculate
#'   prevalence for
#' @param weight Character string specifying the name of the weight variable.
#'   Default is NULL (unweighted)
#' @param value The value in `var` to be considered as "success" for prevalence
#'   calculation. Default is 1
#' @param ci Confidence level for the confidence interval. Default is 0.95
#'   (95% confidence interval)
#'
#' @return A data.table with the following columns:
#' \itemize{
#'   \item n_drink: Number (or weighted sum) of successes
#'   \item n_total: Total number (or weighted sum) of observations
#'   \item percentage: Prevalence as a percentage
#'   \item SE: Standard error as a percentage
#'   \item low_CI: Lower bound of confidence interval as a percentage
#'   \item up_CI: Upper bound of confidence interval as a percentage
#' }
#'
#' @details
#' The function uses the normal approximation method to calculate confidence
#' intervals. Missing values in the specified variable are automatically excluded
#' from calculations. When weights are provided, both the numerator and denominator
#' are weighted accordingly.
#'
#' @examples
#' library(data.table)
#'
#' # Create sample data
#' dt <- data.table(
#'   alkosistaar = sample(0:1, 100, replace = TRUE),
#'   year = sample(2020:2022, 100, replace = TRUE),
#'   weight = runif(100, 0.5, 1.5)
#' )
#'
#' # Basic usage - unweighted prevalence
#' result <- calc_prevalence(dt, "alkosistaar", value = 1)
#'
#' # Weighted prevalence
#' result_weighted <- calc_prevalence(dt, "alkosistaar", weight = "weight", value = 1)
#'
#' # By group (e.g., by year)
#' result_year <- dt[, {
#'   calc_prevalence(.SD, "alkosistaar", value = 1)
#' }, by = year]
#'
#' # By group with weights
#' result_year_weighted <- dt[, {
#'   calc_prevalence(.SD, "alkosistaar", weight = "weight", value = 1)
#' }, by = year]
#'
#' # Custom confidence level (99%)
#' result_99ci <- calc_prevalence(dt, "alkosistaar", value = 1, ci = 0.99)
#'
#' @export
calc_prevalence <- function(dt, var, weight = NULL, value = 1, ci = 0.95){
  z <- qnorm(1 - (1 - ci) / 2)
  if (is.null(weight)){
    dt[!is.na(get(var)), {
      n_success <- sum(get(var) == value)
      n_total <- .N
      pct <- n_success / n_total
      se <- sqrt((pct * (1 - pct)) / n_total)
      data.table(
        n = n_success,
        total = n_total,
        percentage = pct * 100,
        SE = se * 100,
        low_CI = (pct - z * se) * 100,
        up_CI = (pct + z * se) * 100
      )
    }]
  } else {
    dt[!is.na(get(var)), {
      n_success <- sum((get(var) == value) * get(weight))
      n_total <- sum(get(weight))
      pct <- n_success / n_total
      se <- sqrt((pct * (1 - pct)) / n_total)
      data.table(
        n_weighted = n_success,
        total_weighted = n_total,
        percentage = pct * 100,
        SE = se * 100,
        low_CI = (pct - z * se) * 100,
        up_CI = (pct + z * se) * 100
      )
    }]
  }
}
