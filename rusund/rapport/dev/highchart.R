library(highcharter)
library(dplyr)

data(diamonds, package = "ggplot2")

data <- count(diamonds, cut, color)

hc <- hchart(data, "column", hcaes(x = color, y = n, group = cut)) |>
  hc_yAxis(title = list(text = "Cases")) |>
  hc_title(text = "Diamonds Are Forever") |>
  hc_subtitle(text = "Source: Diamonds data set") |>
  hc_credits(enabled = TRUE, text = "http://jkunst.com/highcharter/") |>
  hc_tooltip(sort = TRUE, table = TRUE) |>
  hc_caption(text = "This is a caption text to show the style of this type of text")

hc

# Use plotBands to highlight background categorically
hc2 <- hchart(data, "column", hcaes(x = color, y = n, group = cut)) |>
  hc_yAxis(title = list(text = "Cases")) |>
  hc_title(text = "Diamonds Are Forever - PlotBands Method") |>
  hc_subtitle(text = "Source: Diamonds data set") |>
  hc_credits(enabled = TRUE, text = "http://jkunst.com/highcharter/") |>
  hc_tooltip(sort = TRUE, table = TRUE) |>
  hc_caption(text = "Category background using plotBands") |>
  hc_legend(
    align = "left",
    verticalAlign = "bottom",
    layout = "horizontal",
    x = 50,
    y = 0
  ) |>
  hc_plotOptions(
    column = list(
      states = list(
        hover = list(
          brightness = 0.2
        )
      ),
      point = list(
        events = list(
          mouseOver = JS("function() {
            var chart = this.series.chart;
            var categoryIndex = this.x;

            // Remove existing plotBand
            chart.xAxis[0].removePlotBand('hover-band');

            // Add plotBand for the category
            chart.xAxis[0].addPlotBand({
              id: 'hover-band',
              from: categoryIndex - 0.4,
              to: categoryIndex + 0.4,
              color: 'rgba(255, 99, 132, 0.1)',
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
  )

hc2

# Explanation
# - Uses addPlotBand() and removePlotBand() for the background effect
# - Simpler approach using Highcharts' built-in plotBand functionality
# - Pink/red background highlighting


