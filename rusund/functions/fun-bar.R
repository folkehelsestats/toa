#' Create a grouped bar plot of percentages by year
#'
#' This function generates a bar plot using ggplot2, where the x-axis is year,
#' the y-axis is percentage, and bars are grouped by a specified variable.
#'
#' @param data A data.frame containing the variables `year`, `percentage`, and the grouping variable.
#' @param group A string specifying the name of the column to use for grouping (e.g., "dk2").
#'
#' @return A ggplot object representing the bar plot.
#' @export
#'
#' @examples
#' create_bar(alkodag, "dk2")
#' create_bar(alkodag, "drukket2")
create_bar <- function(data, group) {
  group_sym <- rlang::sym(group)

  ggplot(data, aes(x = factor(year), y = percentage, fill = factor(!!group_sym))) +
    geom_bar(stat = "identity", position = "dodge") +
    labs(
      title = paste("Prosentandel etter år og gruppe:", group),
      x = "År",
      y = "Prosentandel",
      fill = group
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}
