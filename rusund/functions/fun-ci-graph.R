#' Create a Highchart with Confidence Intervals
#'
#' This function creates an interactive highchart displaying data
#' over time with 95% confidence intervals shown as a shaded area range.
#'
#' @param data A data frame containing the data to plot.
#' @param x_col Character. Name of column in the dataset for x-axis. Default: \code{"year"}.
#' @param y_col Character. Name of column in the dataset for y-axis. Default: \code{"adj_enhet"}.
#' @param lower_col Character. Name of the lower CI column. Default: \code{"lower_enhet"}.
#' @param upper_col Character. Name of the upper CI column. Default: \code{"upper_enhet"}.
#' @param title Character. Main title for the chart.
#' @param subtitle Character. Subtitle text.
#' @param y_axis_title Character. Y-axis title.
#' @param x_axis_title Character. X-axis title.
#' @param series_name Character. Name for the main data series. Default: \code{"Antall enheter"}.
#' @param line_color Character. Hex color code for the line and area. Default: \code{"#206276"}.
#' @param caption Character. Chart caption text. Default: \code{"Tall om alkohol"}.
#' @param credits_text Character. Credits text. Default: \code{"Helsedirektoratet"}.
#' @param credits_href Character. URL for credits link. Default: Helsedirektoratet URL.
#' @param height Numeric. Chart height in pixels. Default: \code{600}.
#' @param save Logical. Save file as a selfcontained HTML. Default: FALSE
#'
#' @return A \code{highchart} object that can be rendered or further customized.
#'
#' @details
#' The function creates a line chart with the following features:
#' \itemize{
#'   \item Main line series showing the central values
#'   \item Shaded area range showing 95\% confidence intervals
#'   \item Accessibility features enabled
#'   \item Export functionality
#'   \item Shared tooltip on hover
#' }
#'
#' @examples
#' \dontrun{
#' # Basic usage with default parameters
#' library(highcharter)
#' chart <- create_ci_graph(dtx)
#' chart
#'
#' # Custom title and colors
#' chart <- create_ci_graph(
#'   data = dtx,
#'   title = "Custom Alcohol Use Chart",
#'   line_color = "#FF5733"
#' )
#'
#' # Using different column names
#' chart <- create_ci_graph(
#'   data = my_data,
#'   x_col = "aar",
#'   y_col = "verdi",
#'   lower_col = "nedre_ci",
#'   upper_col = "ovre_ci"
#' )
#'
#' # Full customization
#' chart <- create_ci_graph(
#'   data = dtx,
#'   title = "Alcohol Consumption Trends",
#'   subtitle = "Age and gender adjusted rates",
#'   y_axis_title = "Units of alcohol",
#'   x_axis_title = "Year",
#'   series_name = "Units",
#'   line_color = "#1E90FF",
#'   caption = "Source: Health Survey",
#'   credits_text = "Norwegian Directorate of Health",
#'   height = 800
#' )
#' }
#'
#' @seealso \code{\link[highcharter]{highchart}}, \code{\link[highcharter]{hc_add_series}}
#'
#' @import highcharter
#' @export
create_ci_graph <- function(data,
                            x_col = "year",
                            y_col = "adj_enhet",
                            lower_col = "lower_enhet",
                            upper_col = "upper_enhet",
                            title = NULL,
                            subtitle = NULL,
                            y_axis_title = NULL,
                            x_axis_title = NULL,
                            series_name = "Antall enheter",
                            line_color = "#206276",
                            caption = "Tall om alkohol",
                            credits_text = "Helsedirektoratet",
                            credits_href = "https://www.helsedirektoratet.no/",
                            save = FALSE) {

  # Load required library
  if (!requireNamespace("highcharter", quietly = TRUE)) {
    stop("Package 'highcharter' is required but not installed.")
  }

  if (save){
    if (!requireNamespace("htmlwidges", quietly = TRUE)) {
      stop("Package 'htmlwidges' is required but not installed.")
    }
  }

  # Validate that required columns exist
  required_cols <- c(x_col, y_col, lower_col, upper_col)
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # Create base chart with title and subtitle
  hcx <- highcharter::highchart() |>
    highcharter::hc_title(
      text = title,
      margin = 20,
      align = "left",
      style = list(useHTML = TRUE)
    ) |>
    highcharter::hc_subtitle(
      text = subtitle,
      align = "left"
    )

  # Add main line series
  hc1 <- hcx |>
    highcharter::hc_add_series(
      data = data,
      name = series_name,
      type = "line",
      id = "ci",
      highcharter::hcaes(x = .data[[x_col]], y = .data[[y_col]]),
      lineWidth = 2,
      showInLegend = FALSE,
      color = highcharter::hex_to_rgba(line_color),
      marker = list(
        symbol = "circle",
        enabled = TRUE,
        radius = 4
      )
    )

  # Add axes, caption, and credits
  hc2 <- hc1 |>
    highcharter::hc_yAxis(
      title = list(text = y_axis_title),
      accessibility = list(
        enabled = TRUE,
        description = y_axis_title
      )
    ) |>
    highcharter::hc_xAxis(
      title = list(text = x_axis_title),
      accessibility = list(
        enabled = TRUE,
        description = paste0("årgangene fra ", min(data[[x_col]]), " til ", max(data[[x_col]]))
      )
    ) |>
    highcharter::hc_caption(text = caption) |>
    highcharter::hc_credits(
      enabled = TRUE,
      text = credits_text,
      href = credits_href
    )

  # Add confidence interval area
  hc3 <- hc2 |>
    highcharter::hc_add_series(
      data = data,
      name = "95% CI",
      type = "arearange",
      highcharter::hcaes(x = .data[[x_col]], low = .data[[lower_col]], high = .data[[upper_col]]),
      linkedTo = "ci",
      showInLegend = FALSE,
      color = highcharter::hex_to_rgba(line_color),
      fillOpacity = 0.6,
      lineWidth = 0,
      marker = list(enabled = FALSE)
    )

  # Add tooltip, exporting, and accessibility
  hc4 <- hc3 |>
    highcharter::hc_tooltip(shared = TRUE) |>
    highcharter::hc_exporting(enabled = TRUE) |>
    highcharter::hc_add_dependency(name = "modules/accessibility.js")

  if (save){
    filn <- "graph_med_ci.html"
    htmlwidgets::saveWidget(hc4, file = filn , selfcontained = TRUE)
    cat("File:", filn, "saved in:", getwd(), "\n")
  }

  return(hc4)
}
