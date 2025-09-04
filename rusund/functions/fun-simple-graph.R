#' Create Simple Interactive Histogram with Highcharter
#'
#' Creates a customizable column chart using highcharter with automatic styling
#' based on the original make_hist function, simplified for basic use cases.
#'
#' @param d data.frame or data.table. The input dataset containing the variables to plot.
#' @param x Unquoted variable name. The x-axis variable (categories, e.g., agecat).
#' @param y Unquoted variable name. The y-axis variable (numerical values, e.g., halvliter).
#' @param group Unquoted variable name. The grouping variable (e.g., gender).
#' @param title Character string. Main title for the chart.
#' @param subtitle Character string, optional. Subtitle for the chart.
#'   If NULL, defaults to "Kilde: RusundersÃ¸kelse 2024". Default is NULL.
#' @param xtitle Character string, optional. X-axis title. If NULL (default), no title is shown.
#' @param ytitle Character string, optional. Y-axis title. If NULL (default), no title is shown.
#' @param yint Numeric. Interval for y-axis tick marks. Default is 1.
#' @param ylim Numeric vector of length 2, optional. Sets fixed y-axis limits as c(min, max).
#'   If NULL (default), y-axis limits are determined automatically by the data.
#' @param flip Logical. Whether to flip the chart orientation (horizontal bars). Default is FALSE.
#'
#' @return A highchart object that can be displayed or further customized.
#'
#' @examples
#' \dontrun{
#' library(highcharter)
#' library(data.table)
#'
#' # Sample data
#' dt <- data.table(
#'   agecat = rep(c("16-24", "25-34", "35-44", "45-54", "55-64", "65-79"), 3),
#'   halvliter = c(5.7, 6.9, 5.1, 5.5, 4.6, 3.8,  # Totalt
#'                 8.6, 11.4, 7.9, 9.1, 7.7, 5.7,  # Menn
#'                 2.7, 2.6, 2.0, 2.4, 1.5, 1.8),  # Kvinner
#'   gender = rep(c("Totalt", "Menn", "Kvinner"), each = 6)
#' )
#'
#' # Basic histogram
#' simple_hist(dt, agecat, halvliter, gender,
#'             title = "Alkoholkonsum etter alder og kjÃ¸nn")
#'
#' # With custom axis titles
#' simple_hist(dt, agecat, halvliter, gender,
#'             title = "Alkoholkonsum etter alder og kjÃ¸nn",
#'             xtitle = "Aldersgruppe",
#'             ytitle = "Halvliter per år")
#'
#' # With custom y-axis limits and titles
#' simple_hist(dt, agecat, halvliter, gender,
#'             title = "Alkoholkonsum etter alder og kjÃ¸nn",
#'             xtitle = "Aldersgruppe",
#'             ytitle = "Halvliter per år",
#'             ylim = c(0, 12))
#' }
#'
#' @export
simple_hist <- function(d, x, y, group,
                       title,
                       subtitle = NULL,
                       xtitle = NULL,
                       ytitle = NULL,
                       yint = 1,
                       ylim = NULL,
                       flip = FALSE) {

  # Convert arguments to character strings for consistent handling
  x <- as.character(substitute(x))
  y <- as.character(substitute(y))
  group <- as.character(substitute(group))

  # Input validation
  required_vars <- c(x, y, group)
  missing_vars <- setdiff(required_vars, names(d))
  if (length(missing_vars) > 0) {
    stop("Variables not found in data: ", paste(missing_vars, collapse = ", "))
  }

  # Validate ylim parameter
  if (!is.null(ylim)) {
    if (!is.numeric(ylim) || length(ylim) != 2) {
      stop("'ylim' must be a numeric vector of length 2, e.g., c(0, 15)")
    }
    if (ylim[1] >= ylim[2]) {
      stop("'ylim' first value must be less than second value, e.g., c(0, 15)")
    }
  }

  # Set default subtitle
  if (is.null(subtitle)) {
    subtitle <- "Kilde: Rusundersøkelse 2024"
  }

  # Set axis title text (empty string if NULL)
  x_title_text <- if (is.null(xtitle)) " " else xtitle
  y_title_text <- if (is.null(ytitle)) " " else ytitle

  # Get number of groups and set up colors
  gp <- length(unique(d[[group]]))

  # Color palette (using the same as original function)
  colors04 <- c("#025169", "#0069E8", "#7C145C", "#047FA4",
                "#C68803", "#38A389", "#6996CE", "#366558",
                "#BF78DE", "#767676")

  if (gp == 2) {
    hdir <- c("rgba(49,101,117,1)", "rgba(138,41,77,1)")
  } else if (gp <= 10) {
    hdir <- colors04[1:gp]
  } else {
    hdir <- viridis::viridis(gp, option = "D")
  }

  # Create the base chart
  chart <- highchart() %>%
    hc_chart(inverted = flip, type = "column")

  # Configure y-axis - handle ylim conditionally
  if (!is.null(ylim)) {
    chart <- chart %>%
      hc_yAxis(
        title = list(text = y_title_text),
        tickInterval = yint,
        min = ylim[1],
        max = ylim[2]
      )
  } else {
    chart <- chart %>%
      hc_yAxis(
        title = list(text = y_title_text),
        tickInterval = yint
      )
  }

  # Configure x-axis with categories
  chart <- chart %>%
    hc_xAxis(
      title = list(text = x_title_text),
      categories = unique(d[[x]]),
      tickInterval = 1,
      labels = list(step = 1)
    ) %>%
    hc_title(text = title) %>%
    hc_subtitle(text = subtitle) %>%
    hc_credits(
      enabled = TRUE,
      text = "Helsedirektoratet",
      href = "https://www.helsedirektoratet.no/"
    ) %>%
    hc_tooltip(
      useHTML = TRUE,
      shared = TRUE,
      headerFormat = '<span style="font-size: 14px; font-weight: bold;">{point.key}</span><br/>',
      pointFormat = paste0(
        '<span style="color:{series.color}">\u25CF</span> ',
        '<span style="color:black">{series.name}</span>: ',
        '<b>{point.y}</b><br/>'
      )
    ) %>%
    hc_legend(
      align = "left",
      verticalAlign = "bottom",
      layout = "horizontal",
      x = 50,
      y = 0
    ) %>%
    hc_exporting(enabled = TRUE) %>%
    hc_plotOptions(
      column = list(
        grouping = TRUE,
        states = list(
          hover = list(brightness = 0.2)
        )
      )
    )

  # Add series manually for each group
  group_levels <- unique(d[[group]])
  x_levels <- unique(d[[x]])

  for (i in seq_along(group_levels)) {
    # Filter data for this specific group
    group_data <- d[d[[group]] == group_levels[i], ]

    # Create x_index to match categories
    group_data$x_index <- match(group_data[[x]], x_levels) - 1

    chart <- chart %>%
      hc_add_series(
        data = group_data,
        type = "column",
        name = group_levels[i],
        hcaes(x = x_index, y = !!y),
        color = hdir[i],
        point = list(
          events = list(
            mouseOver = JS("function() {
              var chart = this.series.chart;
              var categoryIndex = this.x;
              chart.xAxis[0].removePlotBand('hover-band');
              chart.xAxis[0].addPlotBand({
                id: 'hover-band',
                from: categoryIndex - 0.4,
                to: categoryIndex + 0.4,
                color: 'rgba(204, 211, 255, 0.25)',
                zIndex: 0
              });
            }"),
            mouseOut = JS("function() {
              var chart = this.series.chart;
              chart.xAxis[0].removePlotBand('hover-band');
            }")
          )
        )
      )
  }

  return(chart)
}
